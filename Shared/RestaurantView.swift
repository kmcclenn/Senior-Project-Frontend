//
//  RestaurantView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 3/25/22.
//

import SwiftUI

struct RestaurantView: View {
    @Environment(\.dismiss) var dismiss
    @State var restaurant: Restaurant
    @State var waitTime: Float
    @State var loggedIn: Bool
    @StateObject var loginClass: Login
    @State var currentUser: User?
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    @StateObject var updateInstance = Update()
    
    @State var message: String = ""
    @State private var showAlert = false
    
    @State var showArrival: Bool = false
    @State var showSeated: Bool = false
    
    @State var inputTime: Int = 0
    @State var arrivalTime: Date = Date()
    @State var seatedTime: Date = Date() // then use DateFormatter to convert to string - same as arrivalTime
    
    @FocusState var inputFieldInFocus: Bool
    
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                Text("\(restaurant.address)")
                    .onChange(of: inputTime) { newValue in
                        print("input time: \(inputTime) and binding: \($inputTime)")
                    }
                Spacer()
                if (waitTime == -1.0) {
                    Text("No user inputs yet. Be the first!")
                    if loggedIn {
                        Text("See below to input!")
                    } else {
                        NavigationLink("Login to input!", destination: LoginView(loginClass: loginClass, logIn: true))
                    }// have link to that.
                } else {
                    Text("Waittime: \(Int(round(waitTime))) minutes.")
                }
                
                Spacer()
                if loggedIn {
                    VStack {
                        Text("Report your own wait time here:") // add a constraint that must be int - if not alert
                        
                        Form {
                            Toggle("Show Arrival Time", isOn: $showArrival)
                            Toggle("Show Seated Time", isOn: $showSeated)
                            HStack {
                                TextField("WaitTime", value: $inputTime, formatter: numberFormatter)
                                    .focused($inputFieldInFocus)
                                Text("minutes")
                                    .font(.headline)
                                    .bold()
                            }
                            
                            if showArrival {
                                DatePicker("Arrival Time", selection: $arrivalTime, displayedComponents: [.date, .hourAndMinute])
                            }
                            if showSeated {
                                DatePicker("Seated Time", selection: $seatedTime, displayedComponents: [.date, .hourAndMinute])
                            }
                            
                                
                        }
                        //Text("input time: \(inputTime)")
                        Button {
                            print("inputTime: \(inputTime)")
                            var arrival: Date? = nil
                            if showArrival {
                                arrival = arrivalTime
                            }
                            
                            var seated: Date? = nil
                            if showSeated {
                                seated = seatedTime
                            }
                            updateInstance.updateRestaurant(inputTime: inputTime, arrivalTime: arrival, seatedTime: seated, restaurant: restaurant, currentUser: currentUser!) {result in
                                switch result {
                                case.success(_):
                                    inputFieldInFocus = false
                                    DispatchQueue.main.async {
                                        self.inputTime = 0
                                        self.arrivalTime = Date()
                                        self.seatedTime = Date()
                                        reload()
                                    }
                                    
                                    
                                    print("input success")
                                case.failure(let error):
                                    print("failure error: \(error.localizedDescription)")
                                    //$inputTime.wrappedValue = 0
                                    //$arrivalTime.wrappedValue = Date()
                                    //$seatedTime.wrappedValue = Date()
                                    switch error {
                                    case.notSignedIn:
                                        message = "Sign in first."
                                    case.custom(let errorMessage):
                                        message = errorMessage
                                    }
                                    showAlert = true
                                }
                            }
                        } label: {
                            Text("Send in wait time!")
                        }
                        Spacer()
                    }
                }
            }.navigationTitle("\(restaurant.name)")
                .onAppear {
                    print("waittime from restaurantview \(restaurant.id): \(waitTime)")
                }
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
            message: Text(message),
            dismissButton: .default(Text("Okay"))
         )
       }
        
        
    }
    
    func reload() {
        Load().loadWaitTime(restaurantID: restaurant.id) { waitLength in
            waitTime = waitLength
        }
        
        
    }
}

final class Update: ObservableObject {
    
    enum InputError: Error {
        case custom(errorMessage: String)
        case notSignedIn
    }
    
    func updateRestaurant(inputTime: Int?, arrivalTime: Date?, seatedTime: Date?, restaurant: Restaurant, currentUser: User, completion: @escaping(Result < String, InputError > ) -> Void) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var arrivalTimeString: String? = nil
        var seatedTimeString: String? = nil
        if arrivalTime != nil {
            arrivalTimeString = formatter.string(from: arrivalTime!)
        }
        
        
        if seatedTime != nil {
            seatedTimeString = formatter.string(from: seatedTime!)
        }

        if (inputTime == nil && arrivalTime == nil && seatedTime == nil) {
            completion(.failure(.custom(errorMessage: "You must input either a wait time or a seated time and arrival time. Try again.")))
            return
        }
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/inputtedwaittimes/") else {
            print("api is down")
            return
        }
      
        let restaurantData = InputWaitTime(restaurant: restaurant.id, waitLength: inputTime, reportingUser: currentUser.id, arrivalTime: arrivalTimeString, seatedTime: seatedTimeString)
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
                if (try? decoder.decode(InputWaitTime.self, from: data)) != nil {
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
    
    func updateUser(newUser: User, completion: @escaping(Result < User, InputError > ) -> Void) {
        
       
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/appuser/\(newUser.id)/") else {
            print("api is down")
            return
        }
      
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(newUser) else {
            print("failed to encode")
            return
        }
        
        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
        var token = String(data: data ?? Data.init(), encoding: .utf8)
        token = token!
        if token == nil {
            completion(.failure(.notSignedIn))
        }
        print("Token \(token!)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/JSON", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = encoded
        print(request.allHTTPHeaderFields!)
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                print("data: \(String(decoding: data, as: UTF8.self))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let result = try? decoder.decode(User.self, from: data){
                    completion(.success(result))
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

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344), waitTime: 0.0, loggedIn: false, loginClass: Login(), currentUser: User(id: 0, username: "", firstName: "", lastName: "", email: ""))
    }
}
