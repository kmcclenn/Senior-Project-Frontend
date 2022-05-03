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
    //@State var defaults = UserDefaults.standard
//    let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var body: some View {
        
        VStack {
//            Button("Login") { loginSheet.toggle()
//            }.sheet(isPresented: $loginSheet) {
//                LoginView()
//            }
            
            
            
            // maybe error here?
            let data = try? KeychainHelper.standard.read(service: "token", account: "user")
            if data != nil {
                let token = String(data: data!, encoding: .utf8)
                Text("logged in")
            }
//
            NavigationView {
                VStack {
                    List(restaurants) { restaurant in

                        Button("\(restaurant.name)") { restaurantSheet.toggle()
                        }.sheet(isPresented: $restaurantSheet) {
                            RestaurantView(restaurant: restaurant)
                        }

                    }.onAppear(perform: {
                         loadInstance.loadRestaurant { (restaurants) in
                             self.restaurants = restaurants
                         }
                    }).listStyle(PlainListStyle())
                    NavigationLink("Login", destination: LoginView())
                }
               .navigationTitle("Restaurants")
                
                
            }
        }
    }
    
    func signoutUser() {
        
        
        print(UserDefaults.standard.dictionaryRepresentation())
        UserDefaults.standard.removeObject(forKey: "tokenName")
        DispatchQueue.main.async {
            //self.isAuthenticated = false
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






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
         }
    }
}
