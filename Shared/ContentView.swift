//
//  ContentView.swift
//  Shared
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import SwiftUI

let backgroundColor = UIColor(red: 0.16, green: 0.42, blue: 0.71, alpha: 1.0)
let textColor: Color = Color.white

struct ContentView: View {
    @State var restaurants = [Restaurant]()
    @State var waitTimes: [Int: Float] = [:]
    @State var waitLists: [Int: String] = [:]
    @StateObject var loadInstance = Load()
    @State private var restaurantSheet = false
    @State private var loginSheet = false
    @StateObject var loginClass = Login()
    @State var loggedIn: Bool = false
    @State var username: String = ""
    @State var token: String?
    @State var credibility: Float = 1.0
    @State var leaderPoints: [Points]? = [Points]()
    @State var toLeaderboard = false
    @State var toAbout = false
    
    @State var showAdd = false
    
    @State var currentUser: User?
    
    @State private var hasTimeElapsed = false
    
    @State var showContent = false
    
    @State var childViewShown: [Int: Bool] = [:]
    
    init() {
        Theme.navigationBarColors(background: backgroundColor, titleColor: UIColor(textColor))
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //@State var user: User?
    //@State var defaults = UserDefaults.standard
//    let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var body: some View {
        
            VStack {
                if showContent {
                    origContents
                    
                    
                } else {
                    ZStack {
                        Color(uiColor: backgroundColor).ignoresSafeArea()
                    
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    }
                }
            }.onAppear {
                print("vstack appeared")
                //appearFunction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  showContent = true
                }
            }
        .onChange(of: self.childViewShown) { newArray in
            print(newArray.values)
            var show = false
            for value in newArray.values {
                if value == true {
                    show = true
                    break
                }
            }
            if show {
                showContent = true
            } else {
//                DispatchQueue.main.async {
//                    appearFunction()
//                }
                  showContent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showContent = true
                }
          }
      }.onChange(of: self.toLeaderboard) { show in
          if show {
              showContent = true
          } else {
              DispatchQueue.main.async {
                  appearFunction()
              }
                showContent = false
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  showContent = true
              }
        }
    }.onChange(of: self.toAbout) { show in
        if show {
            showContent = true
        } else {
            DispatchQueue.main.async {
                appearFunction()
            }
              showContent = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showContent = true
            }
      }
  }
        

    }
    
    var origContents: some View {
        NavigationView {
            ZStack {
                Color(uiColor: backgroundColor).ignoresSafeArea()
            
            VStack {
                    VStack {
                    
                        Text("Kue").font(.largeTitle).bold().foregroundColor(textColor)
                        Text("Wait Less.").font(.headline).bold().foregroundColor(textColor).padding([.bottom])
                    }
                Divider()
                HStack {
                    Spacer()
                    Text("View restaurants in JH (top has shortest wait time).")
                        .foregroundColor(textColor)
                        .font(.headline)
                    Spacer()
                }
                    // then use token for any necessary api calls.
                
                List(restaurants) { restaurant in
                    
                    NavigationLink(destination: RestaurantView(restaurant: restaurant, waitTime: self.waitTimes[restaurant.id!] ?? -1, loggedIn: loggedIn, loginClass: loginClass, currentUser: currentUser ?? nil, waitList: self.waitLists[restaurant.id!] ?? ""), isActive: binding(for: restaurant.id!)) {
                        Label(title: {
                            HStack {
                                Spacer()
                            
                            VStack {
                               
                               
                                    
                                    Text("\(restaurant.name)").bold().foregroundColor(textColor)
                                
                                
                                if self.waitTimes[restaurant.id!] ?? -1 == -1 {
                                    Text(" (no wait time inputs)")
                                    .foregroundColor(textColor)
                                } else {
                                    Text(" (\(String(describing: Int(round(self.waitTimes[restaurant.id!]!)))) minute long wait time)")
                                        .foregroundColor(textColor)
                                }
                                
                            
                            }
                                Spacer()
                            }
                            
                        } , icon: {
                             
                            Image(systemName: "arrowtriangle.forward.fill")
                            
                            
                            
                        } )
                    }.listRowBackground(Color.init(uiColor: backgroundColor))
                    .listRowSeparatorTint(.white)
                    
//
                }.refreshable {
//                        loadInstance.load(endpoint: "restaurant/", decodeType: [Restaurant].self, string: "restaurant", tokenRequired: false) { (restaurants) in
//                            self.restaurants = restaurants as! [Restaurant]
//                        }
                    appearFunction()
                }.onAppear(perform: {
                    appearFunction()
                    //print("content apepared")
                }).listStyle(PlainListStyle())
//                    if loggedIn {
//                        NavigationLink("View Leaderboards", destination:LeaderboardView(points: self.leaderPoints))
//                            .onAppear {
//                                loadInstance.load(endpoint: "user_points", decodeType: [Points].self, string: "points", tokenRequired: true) { points in
//                                    self.leaderPoints = points as! [Points]
//
//                                }
//                            }
//                    }
                if !loggedIn {
                    HStack {
                        Spacer()
                        NavigationLink(destination: LoginView(loginClass: loginClass, logIn: true), label: {               Text("Login").foregroundColor(textColor).font(.headline).bold() } )
                            .onChange(of: loginClass.isAuthenticated) { newValue in
                                self.loggedIn = newValue
                            }.onChange(of: loginClass.id) { newValue in
                                loadInstance.load(endpoint: "appuser/\(loginClass.id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
                                    self.currentUser = newUser as? User
                                }
                            
                            }.buttonStyle(PlainButtonStyle())
                        Spacer()
                        NavigationLink(destination: LoginView(loginClass: loginClass, logIn: false), label: { Text("Register").foregroundColor(textColor).font(.headline).bold() } )
                            .buttonStyle(PlainButtonStyle())
                            
                        Spacer()
                        }
                    }
            }
            //.navigationTitle("Kue")
            .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               
                       
                       
                       
                   ToolbarItemGroup(placement: .navigationBarTrailing) {
                       if loggedIn && currentUser != nil {
                           NavigationLink {
                               UserView(currentUser: currentUser!, credibility: credibility)
                           } label: {
                               Image(systemName: "person.fill")
                                   .resizable()
                                   .frame(width: 32.0, height: 32.0)
                                   .foregroundColor(textColor)
                            
                           }.onAppear(perform: {
                               let data = try? KeychainHelper.standard.read(service: "token", account: "user")
                               token = String(data: data ?? Data.init(), encoding: .utf8)
                           })
                               
                       }
                       
                   }
                   ToolbarItemGroup(placement: .navigationBarLeading) {
                       if loggedIn && currentUser != nil {
                           
                           // add dropdown menu here.
                           Menu {
                               Button(action: {showAdd.toggle()}, label: {
                                   Label(title: { Text("Add Restaurant") },
                                         icon: { Image(systemName: "plus.circle") }
                                   )
                                                
                               })
                               Button {
                                   self.toLeaderboard = true
                               } label: {
                                   Label {
                                       Text("View Leaderboards")
                                   } icon: {
                                       Image(systemName: "123.rectangle.fill")
                                       
                                   }

                               }
                               Button(action: { signoutUser() },
                                      label: { Label(title: { Text("Logout") } , icon: { Image(systemName: "rectangle.portrait.and.arrow.right") } ) }
                               )
                               Button {
                                   self.toAbout = true
                               } label: {
                                   Label {
                                       Text("About")
                                   } icon: {
                                       Image(systemName: "info.circle.fill")
                                   }
                               }
                              
                               
                           } label: {
                               Image(systemName: "line.3.horizontal")
                                   .resizable()
                                   .frame(width: 32.0, height: 27.0)

                           }.background(NavigationLink(destination: LeaderboardView(points: self.leaderPoints!), isActive: $toLeaderboard) {
                               EmptyView()
                           }).background(NavigationLink(destination: AboutView(), isActive: $toAbout) {
                               EmptyView()
                           })
                           .onAppear {
                               
                               loadInstance.load(endpoint: "user_points/0", decodeType: [Points].self, string: "points", tokenRequired: true) { points in
                                   print("points: \(points)")
                                   self.leaderPoints = points as! [Points]
//                                       if self.leaderPoints == nil {
//                                           print("points: \(points)")
//                                           self.leaderPoints = [points as! Points]
//                                       }
                           } // starts off with all time
                       }
                   }
                   }
               
           }.sheet(isPresented: $showAdd, content: {
               CreateRestaurantView(userWhoCreated: currentUser!.id)
           })
//               .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
           .accentColor(textColor)
//                .background(Color.init(uiColor: backgroundColor))
            
            }
        }
    
    }
    
    private func binding(for key: Int) -> Binding<Bool> {
            return Binding(get: {
                return self.childViewShown[key] ?? false
            }, set: {
                //print($0)
                self.childViewShown[key] = $0
                print(self.childViewShown)
            })
        }
    
    func appearFunction() {

        
        print("is authenticated: \(loginClass.isAuthenticated)")
        
        //print("is logged in \(loggedIn)")
         loadInstance.load(endpoint: "restaurant/", decodeType: [Restaurant].self, string: "restaurant", tokenRequired: false) { (restaurants) in
             self.restaurants = restaurants as! [Restaurant]
             print("restaurants: \(self.restaurants.count)")
             
             for restaurant in self.restaurants {
                 self.childViewShown[restaurant.id!] = false
                 loadInstance.load(endpoint: "average_time/\(restaurant.id!)", decodeType: WaitTime.self, string: "waittime", tokenRequired: false) { waitLength in
                     //print("load WT run")
                     print(waitLength)
                     if waitLength as? String == "error" {
                         self.waitTimes[restaurant.id!] = -1.0
                         self.waitLists[restaurant.id!] = ""
                         //print("WT error running")
                     } else {
                         self.waitTimes[restaurant.id!] = (waitLength as! WaitTime).averageWaittimeWithinPast30Minutes
                         self.waitLists[restaurant.id!] = (waitLength as! WaitTime).waitList
                     }
                     print(self.waitTimes)
                     
                 }
             }
             //print("waittimes: \(self.waitTimes)")
            
            
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 
                 
                 
                 self.restaurants.sort {
                     let waitTime1 = self.waitTimes[$0.id!] ?? -1
                     let waitTime2 = self.waitTimes[$1.id!] ?? -1
                     //print("wt1: \(waitTime1)")
                     if (waitTime1 >= 0 && waitTime2 < 0) {
                         return true
                     } else if (waitTime1 < 0 && waitTime2 >= 0) {
                         return false
                     } else if (waitTime1 >= 0 && waitTime2 >= 0) {
                         return waitTime1 < waitTime2
                     } else if (waitTime1 < 0 && waitTime2 < 0) {
                         return false
                     } else {
                         return false
                     }
                                    
                     
                 }
             }
         }
        if loginClass.isAuthenticated {
            self.loggedIn = true
            
            
        }
        loadInstance.load(endpoint: "appuser/\(loginClass.id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
            self.currentUser = newUser as? User
            
            //print("load instance closure running")
        }
        //self.loggedIn = loginClass.isAuthenticated
        //print("is logged in \(loggedIn)")
        //print("current user: \(String(describing: currentUser))")
        
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
    
    private func delayText() async {
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        hasTimeElapsed = true
    }
    
}
    
    


class Load: ObservableObject {
    @Published var restaurants = [Restaurant]()
    @Published var waitTime: [Int: Float] = [:]
    @Published var user: User?
    
    func load<T: Decodable>(endpoint: String, decodeType: T.Type, string: String, tokenRequired: Bool, completion:@escaping (Any) -> ()) {
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/\(endpoint)") else {
            print("api is down")
            return
        }
        var token: String?
        if tokenRequired {
            let data = try? KeychainHelper.standard.read(service: "token", account: "user")
            token = String(data: data ?? Data.init(), encoding: .utf8)
            
            if token == nil {
                fatalError("Token is nil. Not signed in.")
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if tokenRequired {
            request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
        }
        
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let data = data {
                print("\(string) data \(String(data: data, encoding: .utf8))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let response = try? decoder.decode(T.self, from: data) {
                    
                    DispatchQueue.main.async {
                        
                        
                        completion(response)
                        //print("completion run")
                    }

                } else {
                    
                    print("error in \(string): \(String(describing: error))")
                    completion("error")
                    return

                }

                return
            } else {
                    print("response decoding failed for \(string)")
            }

        }.resume()
        
    }
    
//
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
         }
    }
}


// extra functions //
//func loadCredibility(user_id: Int, completion:@escaping (Float) -> ()) {
//        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/get_credibility/\(user_id)") else {
//            print("api is down")
//            return
//        }
//
//        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
//        let token = String(data: data ?? Data.init(), encoding: .utf8)
//
//        if token == nil {
//            fatalError("Token is nil. Not signed in.")
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
//        //print("request created")
//        URLSession.shared.dataTask(with: request) {data, response, error in
//
//            if let data = data {
//                //print("waittime data \(String(describing: response))")
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                if let response = try? decoder.decode(Credibility.self, from: data) {
//
//                    DispatchQueue.main.async {
//                        completion(response.credibility)
//                        //print("completion run")
//                    }
//
//                } else {
//
//                    print("error in credibility: \(String(describing: error))")
//                    return
//
//                }
//
//                return
//            } else {
//                    print("response decoding failed for credibility")
//            }
//
//        }.resume()
//    }
//
//    func loadPoints(completion:@escaping ([Points]) -> ()) {
//        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/user_points") else {
//            print("api is down")
//            return
//        }
//
//        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
//        let token = String(data: data ?? Data.init(), encoding: .utf8)
//
//        if token == nil {
//            fatalError("Token is nil. Not signed in.")
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
//        //print("request created")
//        URLSession.shared.dataTask(with: request) {data, response, error in
//
//            if let data = data {
//                print("point data \(String(describing: String(data: data, encoding: .utf8)))")
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                if let response = try? decoder.decode([Points].self, from: data) {
//
//                    DispatchQueue.main.async {
//                        completion(response)
//                        //print("completion run")
//                    }
//
//                } else {
//
//                    print("error in points: \(String(describing: error))")
//                    return
//
//                }
//
//                return
//            } else {
//                    print("response decoding failed for points")
//            }
//
//        }.resume()
//    }
//
//    func loadUser(user_id: Int, completion:@escaping (User) -> ()) {
//        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/appuser/\(user_id)") else {
//            print("api is down")
//            return
//        }
//
//        let data = try? KeychainHelper.standard.read(service: "token", account: "user")
//        let token = String(data: data ?? Data.init(), encoding: .utf8)
//
//        if token == nil {
//            fatalError("Token is nil. Not signed in.")
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
//        //print("request created")
//        URLSession.shared.dataTask(with: request) {data, response, error in
//
//            if let data = data {
//                //print("waittime data \(String(describing: response))")
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                if let response = try? decoder.decode(User.self, from: data) {
//                    print("user response: \(response)")
//                    DispatchQueue.main.async {
//                        completion(response)
//                        print("completion run")
//                    }
//
//                } else {
//                    print("error in loaduser: \(String(describing: error))")
//                    return
//
//                }
//
//                return
//            } else {
//                    print("response decoding failed for loaduser")
//            }
//
//        }.resume()
//    }
//
//    func loadWaitTime(restaurantID:Int, completion:@escaping (Float) -> ()) {
//
//        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/average_time/\(restaurantID)") else {
//            print("api is down")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        //request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")
//        //print("request created")
//        URLSession.shared.dataTask(with: request) {data, response, error in
//
//            if let data = data {
//                //print("waittime data \(String(describing: response))")
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                if let response = try? decoder.decode(WaitTime.self, from: data) {
//                    //print("waittime response: \(response)")
//                    DispatchQueue.main.async {
//                        completion(response.averageWaittimeWithinPast30Minutes)
//                        print("completion run")
//                    }
//
//                } else {
//                    print("error in load WT: \(String(describing: error))")
////                    DispatchQueue.main.async {
////                        completion(-1.0)
////                    }
//
//                }
//
//                return
//            } else {
//                    print("response decoding failed for WT")
//            }
//
//        }.resume()
//    }
//
//
//    func loadRestaurant(completion:@escaping ([Restaurant]) -> ()) {
//        //print("loaded started")
//        //print(self.restaurants)
//        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/restaurant/") else {
//            print("api is down")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        //request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")
//        //print("request created")
//        URLSession.shared.dataTask(with: request) {data, response, error in
//            if let data = data {
////
//                if let response = try? JSONDecoder().decode([Restaurant].self, from: data) {
//                    //print(response)
//                    DispatchQueue.main.async {
//                        completion(response)
//
//                    }
//                }
//
//                    return
//            } else {
//                    print("response decoding failed for Restaurant")
//            }
//
//        }.resume()
//    }
