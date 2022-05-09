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
    
    @State var inputTime: Int = 0
    @State var arrivalTime = Date()
    @State var seatedTime = Date() // then use DateFormatter to convert to string - same as arrivalTime
    
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                Text("\(restaurant.address)")
                Spacer()
                if (waitTime == -1.0) {
                    Text("No user inputs yet. Be the first!")
                    if loggedIn {
                        Text("See below to input!")
                    } else {
                        NavigationLink("Login to input!", destination: LoginView(loginClass: loginClass))
                    }// have link to that.
                } else {
                    Text("Waittime: \(Int(round(waitTime))) minutes.")
                }
                
                Spacer()
                if loggedIn {
                    VStack {
                        Text("Report your own wait time here:") // add a constraint that must be int - if not alert
                        
                        Form {
                            TextField("WaitTime", value: $inputTime, formatter: numberFormatter)
                            DatePicker("Arrival Time", selection: $arrivalTime, displayedComponents: [.date, .hourAndMinute])
                            DatePicker("Seated Time", selection: $seatedTime, displayedComponents: [.date, .hourAndMinute])
                        }
                        
                        Button {
                            updateInstance.updateRestaurant(inputTime: inputTime, arrivalTime: arrivalTime, seatedTime: seatedTime, restaurant: restaurant, currentUser: currentUser!) {result in
                                switch result {
                                case.success(_):
                                    reload()
                                    self.inputTime = 0
                                    self.arrivalTime = Date()
                                    self.seatedTime = Date()
                                    print("input success")
                                case.failure(let error):
                                    print("failure error: \(error.localizedDescription)")
                                    inputTime = 0
                                    arrivalTime = Date()
                                    seatedTime = Date()
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
    
    func updateRestaurant(inputTime: Int, arrivalTime: Date?, seatedTime: Date?, restaurant: Restaurant, currentUser: User, completion: @escaping(Result < String, InputError > ) -> Void) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        var arrivalTimeString: String? = nil
        var seatedTimeString: String? = nil
        if arrivalTime != nil {
            arrivalTimeString = formatter.string(from: arrivalTime!)
        }
        if seatedTime != nil {
            seatedTimeString = formatter.string(from: seatedTime!)
        }
        
        
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/inputtedwaittimes/") else {
            print("api is down")
            return
        }
        
        
        
        
       //let restaurantData = 3
        let restaurantData = InputWaitTime(restaurant: restaurant.id, waitLength: inputTime, reportingUser: currentUser.id, arrivalTime: arrivalTimeString, seatedTime: seatedTimeString)
        print(restaurantData)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(restaurantData) else {
            print("failed to encode")
            return
        }
        print("encoded: \(String(describing: String(data: encoded, encoding: .utf8)))")
        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
        var token = String(data: data ?? Data.init(), encoding: .utf8)
        token = token!
        
        print("token: \(token!)")
        
        if token == nil {
            completion(.failure(.notSignedIn))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")// add access token here ?/ NEEDS FIXING
        request.httpBody = encoded
        //print("request created")
        
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
    
}



struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344), waitTime: 0.0, loggedIn: false, loginClass: Login(), currentUser: User(id: 0, username: "", firstName: "", lastName: "", email: ""))
    }
}
