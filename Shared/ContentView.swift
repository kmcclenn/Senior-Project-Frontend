//
//  ContentView.swift
//  Shared
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import SwiftUI


struct ContentView: View {
    @State var restaurants = [Restaurant]()
    @State var waitTimes: [Int: Float] = [:]
    @StateObject var loadInstance = Load()
    @State private var restaurantSheet = false
    @State private var loginSheet = false
    @StateObject var loginClass = Login()
    @State var loggedIn: Bool = false
    @State var username: String = ""
    @State var token: String?
    
    @State var currentUser: User?
    //@State var user: User?
    //@State var defaults = UserDefaults.standard
//    let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var body: some View {
        
        VStack {
//            Button("Login") { loginSheet.toggle()
//            }.sheet(isPresented: $loginSheet) {
//                LoginView()
//            }
            
            
            
            // maybe error here?
            
            
            
//
            NavigationView {
                VStack {
                    if loggedIn && currentUser != nil {
                        
                        Text("logged in: \(currentUser!.username)")
                            .onAppear(perform: {
                                let data = try? KeychainHelper.standard.read(service: "token", account: "user")
                                token = String(data: data ?? Data.init(), encoding: .utf8)
                            })
                        // then use token for any necessary api calls.
                    }
                    List(restaurants) { restaurant in
                        NavigationLink(destination: RestaurantView(restaurant: restaurant, waitTime: self.waitTimes[restaurant.id] ?? -1, loggedIn: loggedIn, loginClass: loginClass, currentUser: currentUser ?? nil)) {
                            Text("\(restaurant.name)")
                        }
//
                    }.refreshable {
                        loadInstance.loadRestaurant { (restaurants) in
                            self.restaurants = restaurants
                        }
                    }.onAppear(perform: {
                        print("is authenticated: \(loginClass.isAuthenticated)")
                        
                        //print("is logged in \(loggedIn)")
                         loadInstance.loadRestaurant { (restaurants) in
                             self.restaurants = restaurants
                             for restaurant in self.restaurants {
                                 loadInstance.loadWaitTime(restaurantID: restaurant.id) { waitLength in
                                     self.waitTimes[restaurant.id] = waitLength
                                 }
                             }
                         }
                        if loginClass.isAuthenticated {
                            self.loggedIn = true
                            
                        }
                        loadInstance.loadUser(user_id: loginClass.id) { newUser in
                            self.currentUser = newUser
                            
                            print("load instance closure running")
                        }
                        //self.loggedIn = loginClass.isAuthenticated
                        print("is logged in \(loggedIn)")
                        print("current user: \(String(describing: currentUser))")
                        
                    }).listStyle(PlainListStyle())
                    

                    if !loggedIn {
                    NavigationLink("Login", destination: LoginView(loginClass: loginClass))
                        .onChange(of: loginClass.isAuthenticated) { newValue in
                            self.loggedIn = newValue
                        }.onChange(of: loginClass.id) { newValue in
                            loadInstance.loadUser(user_id: newValue) { newUser in
                                self.currentUser = newUser
                            }
                            
                        }
                        //.onChange(of: loginClass.username) { newValue in
//                            username = newValue
//                        }
                        
                    } else {
                        Button(action: { signoutUser() }, label: { Text("Logout") })
                    }
                }
               .navigationTitle("Restaurants")
               
                
                
            }
        }
    }
    
    func signoutUser() {
        
        KeychainHelper.standard.delete(service: "token", account: "user")
        KeychainHelper.standard.delete(service: "id", account: "user")
        DispatchQueue.main.async {
            loginClass.isAuthenticated = false
            loggedIn = false
            token = nil
        }
    }
}
    
    


class Load: ObservableObject {
    @Published var restaurants = [Restaurant]()
    @Published var waitTime: [Int: Float] = [:]
    @Published var user: User?
    
    func loadUser(user_id: Int, completion:@escaping (User) -> ()) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/appuser/\(user_id)") else {
            print("api is down")
            return
        }

        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
        let token = String(data: data ?? Data.init(), encoding: .utf8)
        
        if token == nil {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token \(String(describing: token))", forHTTPHeaderField: "Authorization")
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in

            if let data = data {
                //print("waittime data \(String(describing: response))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let response = try? decoder.decode(User.self, from: data) {
                    print("user response: \(response)")
                    DispatchQueue.main.async {
                        completion(response)
                        print("completion run")
                    }

                } else {
                    print("error: \(String(describing: error))")
                    return

                }

                return
            } else {
                    print("response decoding failed")
            }

        }.resume()
    }
    
    func loadWaitTime(restaurantID:Int, completion:@escaping (Float) -> ()) {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/average_time/\(restaurantID)") else {
            print("api is down")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let data = data {
                //print("waittime data \(String(describing: response))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let response = try? decoder.decode(WaitTime.self, from: data) {
                    print("waittime response: \(response)")
                    DispatchQueue.main.async {
                        completion(response.averageWaittimeWithinPast30Minutes)
                        print("completion run")
                    }
                    
                } else {
                    print("error: \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion(-1.0)
                    }
                    
                }
                    
                return
            } else {
                    print("response decoding failed")
            }
                
        }.resume()
    }
   
    
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
        //request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
//
                if let response = try? JSONDecoder().decode([Restaurant].self, from: data) {
                    //print(response)
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






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
         }
    }
}
