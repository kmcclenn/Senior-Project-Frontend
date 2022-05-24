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
    @State var waitList: String
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        nf.zeroSymbol = ""
        return nf
    }()
    
    @StateObject var updateInstance = Update()
    
    @State var message: String = ""
    @State var alertTitle: String = ""
    @State private var showAlert = false
    
    @State private var waitArray: [Any] = [[]]
    @State private var reportCount: Int = 0
    
    @State var showArrival: Bool = false
    @State var showSeated: Bool = false
    
    @State var inputTime: String = ""
    @State var arrivalTime: Date = Date()
    @State var seatedTime: Date = Date() // then use DateFormatter to convert to string - same as arrivalTime
    
    @FocusState var inputFieldInFocus: Bool
    
    
    
    var body: some View {
        
        ZStack {
            Color(uiColor: backgroundColor).ignoresSafeArea()
            VStack(spacing: 0) {
//
                if restaurant.logoUrl != nil {
                    AsyncImage(url: URL(string: restaurant.logoUrl!)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit().scaleEffect(0.7).padding(0)
                        case .failure:
                           EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                        
                    }.padding(0)
                    
                
                }
                HStack {
                    
                    Spacer()
                    Link(destination: URL(string: "https://www.google.com/maps/search/?api=1&query=\(restaurant.address.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "%2C"))")!, label: {
                        Label {
                            Text("Directions").foregroundColor(textColor)
                        } icon: {
                            Image(systemName: "arrow.uturn.right.circle.fill")
                                .resizable()
                                .frame(width: 28.0, height: 28.0)
                                .foregroundColor(textColor)
                                .padding(.top, 15)
                        }.labelStyle(VerticalLabelStyle())

                    })
                    if restaurant.phoneNumber != nil && restaurant.phoneNumber != "" {
                        Spacer()
                        Link(destination: URL(string: "tel:\(restaurant.phoneNumber!)")!, label: {
                            Label {
                                Text("Call").foregroundColor(textColor)
                            } icon: {
                                Image(systemName: "phone.circle.fill")
                                    .resizable()
                                    .frame(width: 28.0, height: 28.0)
                                    .foregroundColor(textColor)
                                    .padding(.top, 15)
                            }.labelStyle(VerticalLabelStyle())

                        })
                    
                    }
                    if restaurant.website != nil && restaurant.website != "" {
                        Spacer()
                         Link(destination: URL(string: "\(String(describing: restaurant.website!))")!, label: {
                             Label {
                                 Text("Website").foregroundColor(textColor)
                             } icon: {
                                 Image(systemName: "globe")
                                     .resizable()
                                     .frame(width: 28.0, height: 28.0)
                                     .foregroundColor(textColor)
                                     .padding(.top, 15)
                             }.labelStyle(VerticalLabelStyle())

                         })
                     
                     }
                    if restaurant.yelpPage != nil && restaurant.yelpPage != "" {
                        Spacer()
                        Link(destination: URL(string: "\(restaurant.yelpPage!)")!, label: {
                            
                            Label {
                                Text("Yelp Page").foregroundColor(textColor)
                            } icon: {
                                Image(systemName: "star.circle.fill")
                                    .resizable()
                                    .frame(width: 28.0, height: 28.0)
                                    .foregroundColor(textColor)
                                    .padding(.top, 15)
                            }.labelStyle(VerticalLabelStyle())

                        })
                    
                    }
                    Spacer()
                }
                Spacer()
                if (waitTime == -1.0) {
                    Text("No user inputs yet. Be the first!").foregroundColor(textColor)
                    if loggedIn {
                        Text("See below to input!").foregroundColor(textColor)
                    } else {
                        NavigationLink(destination: LoginView(loginClass: loginClass, logIn: true), label: { Text("Log in to input.").foregroundColor(textColor).bold().underline() } )
                    }// have link to that.
                } else {
                    HStack {
                        Spacer()
                        Text("\(Int(round(waitTime)))").font(.largeTitle).bold().foregroundColor(textColor)
                        if reportCount == 1 {
                            Text("minute long wait time (\(reportCount) report)").foregroundColor(textColor)
                        } else {
                            Text("minute long wait time (\(reportCount) reports)").foregroundColor(textColor)
                        }
                       
                        Spacer()
                    }.onAppear {
                        waitArray = waitList.components(separatedBy: "], [")
                        reportCount = waitArray.count
                    }
                }
                
                Spacer()
                if loggedIn {
                    
                    Text("Report your own wait time here. Either put in a wait time directly or put your arrival time and then the time you were seated.").foregroundColor(textColor).padding()// add a constraint that must be int - if not alert
                        
                        Form {
                            Toggle("Show Arrival Time", isOn: $showArrival)
                            Toggle("Show Seated Time", isOn: $showSeated)
                            HStack {
                                TextField("WaitTime", text: $inputTime)
                                    .focused($inputFieldInFocus)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: inputTime) { newValue in
                                        print(newValue)
                                    }
                                Text("minutes")
                                    .font(.headline)
                                    .bold()
                                    
                            }
                            
                            if showArrival {
                                
                                DatePicker("Arrival Time", selection: $arrivalTime, displayedComponents: [.date, .hourAndMinute]).onAppear {
                                    inputFieldInFocus = false
                                }
                            }
                            if showSeated {
                                
                                DatePicker("Seated Time", selection: $seatedTime, displayedComponents: [.date, .hourAndMinute]).onAppear {
                                    inputFieldInFocus = false
                                }
                            }
                            
                                
                        }.background(Color.init(uiColor: backgroundColor))
                        .onAppear { // ADD THESE
                          UITableView.appearance().backgroundColor = .clear
                        }
                        .onDisappear {
                          UITableView.appearance().backgroundColor = .systemGroupedBackground
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
                                        self.inputTime = ""
                                        self.showArrival = false
                                        self.arrivalTime = Date()
                                        self.showSeated = false
                                        self.seatedTime = Date()
                                        message = "Input logged."
                                        alertTitle = "Success!"
                                        
                                        reload()
                                        showAlert = true
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
                                    alertTitle = "Error."
                                    showAlert = true
                                }
                            }
                        } label: {
                            Text("Send in wait time!")
                                .font(.headline)
                                .foregroundColor(textColor)
                                .padding()
                                .frame(width: 200, height: 60)
                                .shadow(radius: 10.0, x: 20, y: 10)
                        }.background(.black).cornerRadius(20.0).padding(.top, 50)
                        Spacer()
                    
                }
            }.onAppear {
                if loginClass.isAuthenticated {
                    loggedIn = true
                    Load().load(endpoint: "appuser/\(loginClass.id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
                        self.currentUser = newUser as? User
                        
                        //print("load instance closure running")
                    }
                }
                    print("waittime from restaurantview \(String(describing: restaurant.id)): \(waitTime)")
            }
        .navigationTitle("\(restaurant.name)")
        .navigationBarTitleDisplayMode(.large)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle),
            message: Text(message),
            dismissButton: .default(Text("Okay"))
         )
        }.onTapGesture {
            print("tapped")
            self.inputFieldInFocus = false
        }
        }
        
    }
    
    
    
    func reload() {
        
        Load().load(endpoint: "average_time/\(restaurant.id!)", decodeType: WaitTime.self, string: "waittime", tokenRequired: false) { waitLength in
            if waitLength as? String == "error" {
               waitTime = -1.0
            } else {
                waitTime = (waitLength as! WaitTime).averageWaittimeWithinPast30Minutes
                waitList = (waitLength as! WaitTime).waitList
                waitArray = waitList.components(separatedBy: "], [")
                reportCount = waitArray.count
            }
        }
        
        
        
    }
}


final class Update: ObservableObject {
    
    enum InputError: Error {
        case custom(errorMessage: String)
        case notSignedIn
    }
    
    func updateRestaurant(inputTime: String, arrivalTime: Date?, seatedTime: Date?, restaurant: Restaurant, currentUser: User, completion: @escaping(Result < String, InputError > ) -> Void) {
        
        if arrivalTime != nil && seatedTime != nil {
            let secondsBetween = seatedTime!.timeIntervalSince(arrivalTime!)
            if secondsBetween / 60 > 120 {
                completion(.failure(.custom(errorMessage: "Wait time too large. Enter a valid number.")))
                return
            } else if secondsBetween < 0 {
                completion(.failure(.custom(errorMessage: "Seated time must be after arrival time.")))
                return
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var arrivalTimeString: String? = nil
        var seatedTimeString: String? = nil
        if arrivalTime != nil {
            arrivalTimeString = formatter.string(from: arrivalTime!)
        }
        
        print("inputtime: \(inputTime)")
        
        if seatedTime != nil {
            seatedTimeString = formatter.string(from: seatedTime!)
        }
        
        var intInputTime: Int?
        if inputTime == "" {
            intInputTime = nil
        } else {
            intInputTime = Int(inputTime)
            if intInputTime == nil {
                completion(.failure(.custom(errorMessage: "Please enter a valid number. Try again.")))
                return
            } else if intInputTime! < 0 {
                completion(.failure(.custom(errorMessage: "Please enter a valid number. Try again.")))
                return
            } else if intInputTime! > 120 {
                completion(.failure(.custom(errorMessage: "Wait time too large. Enter a valid number.")))
                return
            }
        }
        
        if (intInputTime == nil && arrivalTime == nil && seatedTime == nil) {
            completion(.failure(.custom(errorMessage: "You must input either a wait time or a seated time and arrival time. Try again.")))
            return
        }
        
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/inputtedwaittimes/") else {
            print("api is down")
            return
        }
      
        let restaurantData = InputWaitTime(restaurant: restaurant.id!, waitLength: intInputTime, reportingUser: currentUser.id, arrivalTime: arrivalTimeString, seatedTime: seatedTimeString)
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
            //print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let data = data {
                print("data: (\(String(decoding: data, as: UTF8.self)))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    try decoder.decode(InputWaitTime.self, from: data)
                    completion(.success("Success"))
                } catch {
//                } else {
                    print("decodererror: \(error)")
                    if String(decoding: data, as: UTF8.self) == "[\"wait to input new time\"]" {
                        completion(.failure(.custom(errorMessage: "You can only input a wait time at one restaurant once every 30 minutes.")))
                        return
                    }
                    completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                    print("response decoding failed for user")
                }
            } else {
                print("input error: \(error)")
                completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                print("response decoding failed for user")
            }
                
        }.resume()
    }
    
    func updateUser(newUser: User, completion: @escaping(Result < User, InputError > ) -> Void) {
        
       
        
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/appuser/\(newUser.id)/") else {
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

//struct RestaurantView_Previews: PreviewProvider {
//    static var previews: some View {
//        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344), waitTime: 0.0, loggedIn: false, loginClass: Login(), currentUser: User(id: 0, username: "", firstName: "", lastName: "", email: ""))
//    }
//}
