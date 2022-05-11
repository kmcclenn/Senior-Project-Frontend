//
//  CreateRestaurantView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/11/22.
//

import SwiftUI

struct CreateRestaurantView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var website: String = ""
    @State var yelpPage: String = ""
    @State var phoneNumber: Int? = nil
    @State var userWhoCreated: Int
    
    @State var message: String = ""
    @State private var showAlert = false
    
    //Address stuff
    @State var street: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var zip: Int? = nil
    
    @StateObject var postInstance = Post()
    
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    var body: some View {
        NavigationView{
                    List{
                        Section{
                            Text("Restaurant will have to be approved by an Admin before you see it on the page. Will take up to 2-3 business days.")
                            TextField("Restaurant name", text: $name)
                            TextField("Website", text: $website)
                            TextField("Yelp Page", text: $yelpPage)
                            TextField("Phone Number", value: $phoneNumber, formatter: numberFormatter)
                            //TextField("Restaurant name", text: $userWhoCreated)
                            TextField("Street name", text: $street)
                            TextField("City", text: $city)
                            Picker("State", selection: $state) {
                                ForEach(stateChoices, id:\.self) {
                                    Text($0)
                                }
                            }
                            TextField("Zip Code", value: $zip, formatter: numberFormatter)
                            
                        }
                    }.listStyle(GroupedListStyle())
                    .navigationBarTitle("Add Restaurant")
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                postInstance.postAddress(street: street, city: city, state: state, zip: zip ?? nil) { result in
                                    switch result {
                                    case.success(let json):
                                        let address = json
                                        postInstance.postRestaurant(name: name, address: address, website: website, yelpPage: yelpPage, userWhoCreated: userWhoCreated, phoneNumber: phoneNumber ?? nil) { result in
                                            switch result {
                                            case.success(_):
                                                dismiss()
                                                print("input success")
                                            case.failure(let error):
                                                print("failure error: \(error.localizedDescription)")
                                                switch error {
                                                case.notSignedIn:
                                                    message = "Sign in first."
                                                case.custom(let errorMessage):
                                                    message = errorMessage
                                                }
                                                self.showAlert = true
                                            }
                                        }
                                    case.failure(let error):
                                        print("failure error: \(error.localizedDescription)")
                                        switch error {
                                        case.notSignedIn:
                                            message = "Sign in first."
                                        case.custom(let errorMessage):
                                            message = errorMessage
                                        }
                                        self.showAlert = true
                                    }
                                }
                            } label: {
                                Text("Save")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }).alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"),
                        message: Text(message),
                        dismissButton: .default(Text("Okay"))
                     )
                   }
        }
    }
}



class Post: ObservableObject {
    enum PostError: Error {
        case custom(errorMessage: String)
        case notSignedIn
    }
    
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
    
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a == b
    }
    
    func postAddress(street: String, city: String, state: String, zip: Int?, completion: @escaping(Result < ReadAddress, PostError > ) -> Void) {
        
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/address/") else {
            print("api is down")
            return
        }
        if street == "" || city == "" || state == "" || zip == nil {
            completion(.failure(.custom(errorMessage:"Fields are required.")))
            return
        }
        if numberOfDigits(in: zip!) != 5 {
            completion(.failure(.custom(errorMessage: "Invalid Zip Code")))
            return
        }
        let raw = "\(street), \(city), \(state) \(String(zip!)), USA"
        
        let addressData = Address(raw: raw, city: city, state: state, zip: zip)
        //print(restaurantData)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(addressData) else {
            print("failed to encode")
            return
        }
        
        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
        var token = String(data: data ?? Data.init(), encoding: .utf8)
        token = token!
        
        if token == nil {
            completion(.failure(.notSignedIn))
            return
        }
        print("token: \(token!)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let data = data {
                print("data: \(String(decoding: data, as: UTF8.self))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let json = try? decoder.decode(ReadAddress.self, from: data) {
                    completion(.success(json))
                } else {
                    completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                    print("response decoding failed for user")
                }
            } else {
                completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                print("response decoding failed for user")
            }
                
        }.resume()
    }
    
    func postRestaurant(name: String, address: ReadAddress, website: String, yelpPage: String, userWhoCreated: Int, phoneNumber: Int?, completion: @escaping(Result < String, PostError > ) -> Void) {
        
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/restaurant/") else {
            print("api is down")
            return
        }
        if name == "" {
            completion(.failure(.custom(errorMessage: "Name is required.")))
            return
        }
        if phoneNumber != nil {
            if numberOfDigits(in: phoneNumber!) != 10 {
                completion(.failure(.custom(errorMessage: "Invalid Zip Code")))
                return
            }
        }
      
        let restaurantData = Restaurant(id: nil, name: name, address: address.raw, website: website, yelpPage: yelpPage, phoneNumber: phoneNumber) // yelppage, phonenumber are optional
        //print(restaurantData)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(restaurantData) else {
            print("failed to encode")
            return
        }
        
        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
        var token = String(data: data ?? Data.init(), encoding: .utf8)
        token = token!
        
       
        if token == nil {
            completion(.failure(.notSignedIn))
            return
        }
        print("token: \(token!)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let data = data {
                print("data: \(String(decoding: data, as: UTF8.self))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    print(json)
                    if self.isEqual(type: String.self, a: json["name"] ?? "", b: "restaurant with this name already exists.") {
                        completion(.failure(.custom(errorMessage: "Restaurant already exists.")))
                        return
                    }
                    if self.isEqual(type: String.self, a: json["website"] ?? "", b: "Enter a valid URL.") {
                        completion(.failure(.custom(errorMessage: "Enter a valid website URL.")))
                        return
                    }
                    if self.isEqual(type: String.self, a: json["yelpPage"] ?? "", b: "Enter a valid URL.") {
                        completion(.failure(.custom(errorMessage: "Enter a valid website URL.")))
                        return
                    }
                    if self.isEqual(type: String.self, a: json["phoneNumber"] ?? "", b: "Enter a valid value.") {
                        completion(.failure(.custom(errorMessage: "Enter a valid value.")))
                        return
                    }
                    completion(.success("Success"))
                } else {
                    completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                    print("response decoding failed for user")
                }
            } else {
                completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                print("response decoding failed for user")
            }
                
        }.resume()
    }
}
//struct CreateRestaurantView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateRestaurantView()
//    }
//}
