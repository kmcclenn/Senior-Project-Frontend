//
//  ContentView.swift
//  Shared
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import SwiftUI

struct ContentView: View {
    @State var restaurants = [Restaurant]()
    @StateObject var loadInstance = Load()
    @State private var restaurantSheet = false
    @State private var loginSheet = false
//    let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var body: some View {
        VStack {
            Button("Login") { loginSheet.toggle()
            }.sheet(isPresented: $loginSheet) {
                LoginView()
            }
            Button("Logout") {
            
            }
            NavigationView {

               List(restaurants) { restaurant in

                   Button("\(restaurant.name)") { restaurantSheet.toggle()
                   }.sheet(isPresented: $restaurantSheet) {
                       RestaurantView(restaurant: restaurant)
                   }

                }.onAppear(perform: {
                    //print("before running function")
                    loadInstance.loadRestaurant { (restaurants) in
                        self.restaurants = restaurants
                    }
                    print(self.restaurants)
                    //self.restaurants = loadInstance.restaurants
        //            print("restaurants: \(restaurants)")
        //            print("after running function")
        //            print(body)

                }).navigationTitle("Restaurants")
                    .listStyle(PlainListStyle())
            }
        }
    }
}
    
    


class Load: ObservableObject {
    @Published var restaurants = [Restaurant]()
    
    
    
    func loadRestaurant(completion:@escaping ([Restaurant]) -> ()) {
        //print("loaded started")
        //print(self.restaurants)
        guard let url = URL(string: "http://127.0.0.1:8000/api/restaurant/") else {
            print("api is down")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")
        //print("request created")
        URLSession.shared.dataTask(with: request) {
data, response, error in
            if let data = data {
//
                if let response = try? JSONDecoder().decode([Restaurant].self, from: data) {
                    print(response)
                    DispatchQueue.main.async {
                        completion(response)
                
                    }
                }
                    
                    return
            } else {
                    print("response decoding failed")
            }
                
        }.resume()
    }
}




struct LoginView : View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State public var isAuthenticated = false
    let defaults = UserDefaults.standard

    //var function: () -> Void
    @State var username: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Dismiss") {
                dismiss()
            }
            Button(action: {
                postUser(username: username, password: password) { result in
                                      
                    switch result {
                    case.success(let token):
                        print("login success, token: \(token)")
                        defaults.setValue(token, forKey: "tokenName")
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                        }
                    case.failure(let error):
                        //self.loginAlert = true
                        print(error.localizedDescription)
                }
      
            
            
                }
            }, label: { Text("Save") })
            
        }
    }
    
    enum AuthenticationError: Error {
        case invalidCredentials
        case custom(errorMessage: String)
    }
    
    func postUser(username: String, password: String, completion: @escaping(Result < String, AuthenticationError > ) -> Void) {
        //print("loaded started")
        //print(self.restaurants)
        //let potentResponse = ""
        guard let url = URL(string: "http://127.0.0.1:8000/api/api-token-auth/") else {
            print("api is down")
            return
        }
        
        let userData = SimpleUser(username: self.username, password: self.password)
        
        guard let encoded = try? JSONEncoder().encode(userData) else {
            print("failed to encode")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("Token ", forHTTPHeaderField: "Authorization")// add access token here ?/ NEEDS FIXING
        request.httpBody = encoded
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
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
                print("response decoding failed")
            }
                
        }.resume()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
         }
    }
}
