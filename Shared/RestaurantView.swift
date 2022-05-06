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
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
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
                        Text("Report your own wait time here:") // add a constraint that must be int
                        TextField("WaitTime", value: $inputTime, formatter: numberFormatter)
                        Form {
                            DatePicker("Arrival Time", selection: $arrivalTime, displayedComponents: [.date, .hourAndMinute])
                        }
                        Form {
                            DatePicker("Seated Time", selection: $seatedTime, displayedComponents: [.date, .hourAndMinute])
                        }
                        Button {
                            updateRestaurant()
                        } label: {
                            Text("Send in wait time!")
                        }

                    }
                }
            }.navigationTitle("\(restaurant.name)")
                .onAppear {
                    print("waittime from restaurantview \(restaurant.id): \(waitTime)")
                }
        }
        
        
    }
}

final class Update: ObservableObject {
    
    enum InputError: Error {
        case custom(errorMessage: String)
        
    }
    
    func updateRestaurant(inputTime: Float, arrivalTime: Date?, seatedTime: Date?, restaurant: Restaurant, completion: @escaping(Result < String, InputError > ) -> Void) {
        
        
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/api-token-auth/") else {
            print("api is down")
            return
        }
        
        let restaurantData = InputWaitTime(id: nil, restaurant: restaurant, waitLength: inputTime?, reportingUser: User, accuracy: nil, pointValue: nil, postTime: nil, arrivalTime: <#T##String?#>, seatedTime: <#T##String?#>)
        
        guard let encoded = try? JSONEncoder().encode(userData) else {
            print("failed to encode")
            return
        }
        //print("encoded: \(String(decoding: encoded, as:UTF8.self))")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")// add access token here ?/ NEEDS FIXING
        request.httpBody = encoded
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : String] {
                guard let token = json["token"] else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                completion(.success(token))
//                if let response = try? JSONDecoder().decode(User.self, from: data) {
//                    print(response)
//                    DispatchQueue.main.async {
//                        // here save token - if valid. if not return authentication error.
//                        potentResponse = response
//
//                    }
//                }
                    
                return
            } else {
                completion(.failure(.invalidCredentials))
                print("response decoding failed for user")
            }
                
        }.resume()
    }
    
}


struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344), waitTime: 0.0, loggedIn: false, loginClass: Login())
    }
}
