//
//  ContentView.swift
//  Shared
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import SwiftUI
import Auth0

struct ContentView: View {
    @State var restaurants = [Restaurant]()
    @StateObject var loadInstance = Load()
    @State private var restaurantSheet = false
//    let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var body: some View {
        Button("Login") {
            Auth0
                .webAuth()
                .start { result in
                    switch result {
                    case .success(let credentials):
                        print("Obtained credentials: \(credentials)")
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                }
        }
        
        //Text("hello")
        
//            ForEach(restaurants, id: \.self) { restaurant in
//
//                VStack {
//
//                    Text("\(restaurant.name)")
//
//
//                }
            // what is the difference between List and For Each????
//    NavigationView {
//
//       List(restaurants) { restaurant in
//
//           Button("\(restaurant.name)") { restaurantSheet.toggle()
//           }.sheet(isPresented: $restaurantSheet) {
//               RestaurantView(restaurant: restaurant)
//           }
//
//        }.onAppear(perform: {
//            //print("before running function")
//            loadInstance.loadRestaurant { (restaurants) in
//                self.restaurants = restaurants
//            }
//            print(self.restaurants)
//            //self.restaurants = loadInstance.restaurants
////            print("restaurants: \(restaurants)")
////            print("after running function")
////            print(body)
//
//        }).navigationTitle("Restaurants")
//            .listStyle(PlainListStyle())
//    }
    
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
                        
                        //print(self.restaurants)
//                        queue.async {
//                            Thread.sleep(forTimeInterval: Double.random(in: 0...2))
//                            completed()
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
