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
    @State var loggedIn: Bool = false
    @State var token: String?
    @StateObject var loginClass = Login()
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
                    if loggedIn {
                        
                        Text("logged in")
                            .onAppear(perform: {
                                let data = try? KeychainHelper.standard.read(service: "token", account: "user")
                                token = String(data: data ?? Data.init(), encoding: .utf8)
                            })
                        // then use token for any necessary api calls.
                    }
                    List(restaurants) { restaurant in
                        NavigationLink(destination: RestaurantView(restaurant: restaurant, waitTime: self.waitTimes[restaurant.id] ?? -1, loggedIn: loggedIn, loginClass: loginClass)) {
                            Text("\(restaurant.name)")
                        }
//                        Button("\(restaurant.name)") {
//                            loadInstance.loadWaitTime(restaurantID: restaurant.id) { waitLength in
//                                self.waitTimes[restaurant.id] = waitLength
//                                if waitTimes[restaurant.id] != nil {
//                                    restaurantSheet.toggle()
//                                    print("toggled - sheet showing. waittimeself: \(self.waitTimes)")
//
//                                } else {
//                                    print("data not saved yet")
//                                }
//
//
//                            }
//
//                        }.sheet(isPresented: $restaurantSheet) {
//
//                            RestaurantView(restaurant: restaurant, waitTime: self.waitTimes[restaurant.id] ?? -1)
//                        }

                    }.refreshable {
                        loadInstance.loadRestaurant { (restaurants) in
                            self.restaurants = restaurants
                        }
                    }.onAppear(perform: {
                        print(loginClass.isAuthenticated)
                         loadInstance.loadRestaurant { (restaurants) in
                             self.restaurants = restaurants
                             for restaurant in self.restaurants {
                                 loadInstance.loadWaitTime(restaurantID: restaurant.id) { waitLength in
                                     self.waitTimes[restaurant.id] = waitLength
                                 }
                             }
                         }
                        
                        
                        
                    }).listStyle(PlainListStyle())
                    if !loggedIn {
                    NavigationLink("Login", destination: LoginView(loginClass: loginClass))
                        .onChange(of: loginClass.isAuthenticated) { newValue in
                            loggedIn = newValue
                        }
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
