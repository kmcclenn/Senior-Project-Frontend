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
        
    }
    
    var body: some View {
        
            VStack {
                if showContent {
                    // contents of normal view
                    origContents
                    
                } else {
                    // loading screen for first 0.5 seconds
                    ZStack {
                        Color(uiColor: backgroundColor).ignoresSafeArea()
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    }
                }
            }.onAppear {
                print("vstack appeared")
                showContent = true
            }
        .onChange(of: self.childViewShown) { newArray in // when a restaurant is clicked, then wait 0.5 seconds and then show original view
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
                showContent = false
                appearFunction()
          }
        }.onChange(of: self.toLeaderboard) { show in
              if show {
                  showContent = true
              } else {
                showContent = false
                appearFunction()
            }
        }.onChange(of: self.toAbout) { show in
            if show {
                showContent = true
            } else {
                showContent = false
              appearFunction()
            }
        }
        

    }
    
    var origContents: some View {
        NavigationView {
            ZStack {
                Color(uiColor: backgroundColor).ignoresSafeArea()
            
                VStack {
                    //title
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
                    
                    // list of restaurants that navigate to restaurant view
                    List(restaurants) { restaurant in
                        
                        NavigationLink(destination: RestaurantView(restaurant: restaurant, waitTime: self.waitTimes[restaurant.id!] ?? -1, loggedIn: loggedIn, loginClass: loginClass, currentUser: currentUser ?? nil, waitList: self.waitLists[restaurant.id!] ?? ""), isActive: binding(for: restaurant.id!)) {
                            Label(title: {
                                HStack {
                                    Spacer()
                                    
                                    // shows the average wait time at each restaurant
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

                    }.refreshable {
                        appearFunction()
                    }.onAppear(perform: {
                        appearFunction()
                    }).listStyle(PlainListStyle())
                    
                    // shows login and register buttons
                    if !loggedIn {
                        HStack {
                            Spacer()
                            NavigationLink(destination: LoginView(loginClass: loginClass, logIn: true), label: { Text("Login").foregroundColor(textColor).font(.headline).bold() } )
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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        // shows user icon button
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
                    
                        // shows three bar menu
                       ToolbarItemGroup(placement: .navigationBarLeading) {
                           if loggedIn && currentUser != nil {

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
                                   // loads the user points when menu appears
                                   loadInstance.load(endpoint: "user_points/0", decodeType: [Points].self, string: "points", tokenRequired: true) { points in
                                       print("points: \(points)")
                                       self.leaderPoints = points as! [Points]
 
                               } // starts off with all time user points
                           }
                       }
                       }
                   
               }.sheet(isPresented: $showAdd, content: {
                   CreateRestaurantView(userWhoCreated: currentUser!.id)
               })
               .accentColor(textColor)
            
            }
        }
    
    }
    
    // function that runs when view appears or is reloaded
    func appearFunction() {
        print("is authenticated: \(loginClass.isAuthenticated)")
        
        // loads restaurants
         loadInstance.load(endpoint: "restaurant/", decodeType: [Restaurant].self, string: "restaurant", tokenRequired: false) { (restaurants) in
             self.restaurants = restaurants as! [Restaurant]
             print("restaurants: \(self.restaurants.count)")
             
             // for each restaurant, loads wait time
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
             
             // after 0.5 seconds for waittimes to load, sorts restaurant list by waittime
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
                 showContent = true
             }
         }
        if loginClass.isAuthenticated {
            self.loggedIn = true
        }
        // loads user info
        loadInstance.load(endpoint: "appuser/\(loginClass.id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
            self.currentUser = newUser as? User
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
    
    // signs out user by removing their data from the keychain
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
    
// generic load class (get requests)
class Load: ObservableObject {
    @Published var restaurants = [Restaurant]()
    @Published var waitTime: [Int: Float] = [:]
    @Published var user: User?
    
    // generic load function
    func load<T: Decodable>(endpoint: String, decodeType: T.Type, string: String, tokenRequired: Bool, completion:@escaping (Any) -> ()) {
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/\(endpoint)") else {
            print("api is down")
            return
        }
        
        // if token required, sees if user is authenticated
        var token: String?
        if tokenRequired {
            let data = try? KeychainHelper.standard.read(service: "token", account: "user")
            token = String(data: data ?? Data.init(), encoding: .utf8)
            
            if token == nil {
                fatalError("Token is nil. Not signed in.")
            }
        }
        
        // sets request params
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if tokenRequired {
            request.addValue("Token \(token!)", forHTTPHeaderField: "Authorization")
        }
        
        // creates url session to send request
        URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let data = data {
                print("\(string) data \(String(data: data, encoding: .utf8))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let response = try? decoder.decode(T.self, from: data) {
                    
                    DispatchQueue.main.async {
                        completion(response)
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
