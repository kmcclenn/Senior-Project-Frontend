//
//  CreateRestaurantView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/11/22.
//

import SwiftUI

struct CreateRestaurantView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var website: String = ""
    @State var yelpPage: String = ""
    @State var phoneNumber: String = "" // only way to include blank space is to type 0
    @State var userWhoCreated: Int
    @State var imgUrl: String = ""
    
    @State var message: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    
    //Address stuff
    @State var street: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var zip: String = ""
    @StateObject var postInstance = Post()
    
//    @State var showImagePicker = false
//    @State var selectedImage: Image? = Image("")
    
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        nf.zeroSymbol = ""
        
        return nf
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: backgroundColor).ignoresSafeArea()
                VStack {
                    Text("Restaurant will have to be approved by an Admin before you see it on the page. Will take up to 2-3 business days.").foregroundColor(textColor)
                
                    List{
                       
                            
                            
                            TextField("Restaurant name", text: $name)
                                .disableAutocorrection(true)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(Color.black)
                            TextField("Website", text: $website)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Yelp Page", text: $yelpPage)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("URL of Logo", text: $imgUrl)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            //Text("Entered: " + (phoneNumber != nil ? "\(phoneNumber!)" : ""))
                            TextField("Phone Number", text: $phoneNumber)
                                .onChange(of: phoneNumber) { newValue in
                                    print(newValue)
                                }.disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            //TextField("Restaurant name", text: $userWhoCreated)
                            TextField("Street name", text: $street)
                                .disableAutocorrection(true)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("City", text: $city)
                                .disableAutocorrection(true)
                                .padding([.leading, .trailing])
                                .listRowBackground(Color.init(uiColor: backgroundColor))
                                .listRowSeparator(.hidden)
                                .shadow(radius: 10.0, x: 5, y: 10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Zip Code", text: $zip)
                            .disableAutocorrection(true)
                            .padding([.leading, .trailing])
                            .listRowBackground(Color.init(uiColor: backgroundColor))
                            .listRowSeparator(.hidden)
                            .shadow(radius: 10.0, x: 5, y: 10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack {
                            Spacer()
                            Text("Choose State")
                                .foregroundColor(textColor)
                                .font(.headline)
                            Spacer()
                        }.background(Color.init(uiColor: backgroundColor))
                            .listRowBackground(Color.init(uiColor: backgroundColor))
                            .listRowSeparator(.hidden)
                        Picker(selection: $state) {
                                
                                ForEach(stateChoices, id:\.self) {
                                    Text($0).foregroundColor(textColor).listRowBackground(Color.init(uiColor: backgroundColor))
                                }
                                
                            } label: {
                                Text("Choose State").foregroundColor(textColor)
                            }.pickerStyle(WheelPickerStyle())
                            .listRowBackground(Color.init(uiColor: backgroundColor))
                            .listRowSeparatorTint(.white)
                            .frame(height: 200)
                            .padding([.top], 0)
//                        HStack {
//                            Spacer()
//                            Button {
//                                self.showImagePicker.toggle()
//                            } label: {
//                                Text("Choose Image").foregroundColor(textColor)
//                            }
//                            if (self.selectedImage != nil && self.selectedImage != Image("")) {
//                                self.selectedImage!.resizable().scaledToFit()
//                            }
//                            Spacer()
//                        }.background(Color.init(uiColor: backgroundColor))
//                        .sheet(isPresented: $showImagePicker, content: { ImagePicker(image: self.$selectedImage) } )

                            
                        
                            
                                
                    }.onAppear { // ADD THESE
                        UITableView.appearance().backgroundColor = .clear
                      }
                      .onDisappear {
                        UITableView.appearance().backgroundColor = .systemGroupedBackground
                      }
                    .listStyle(GroupedListStyle())
                        
                }.navigationBarTitle("Add Restaurant")
                
                    
                    
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                //let intZip: Int = (zip == nil ? 0 : zip)
                                postInstance.postAddress(street: street, city: city, state: state, zip: zip) { result in
                                    switch result {
                                    case.success(let json):
                                        let address = json
                                        //let intPhoneNumber: Int = (phoneNumber == nil ? 0 : phoneNumber)
                                        postInstance.postRestaurant(name: name, address: address, website: website, yelpPage: yelpPage, userWhoCreated: userWhoCreated, phoneNumber: phoneNumber, imgUrl: imgUrl) { result in
                                            switch result {
                                            case.success(_):
                                                DispatchQueue.main.async {
                                                    message = "Restaurant created successfully. Please wait 2-3 business days for it to be approved."
                                                    alertTitle = "Success!"
                                                    self.showAlert = true
                                                    
                                                }
                                                
                                               
                                                
                                                print("input success")
                                            case.failure(let error):
                                                print("failure error: \(error.localizedDescription)")
                                                switch error {
                                                case.notSignedIn:
                                                    message = "Sign in first."
                                                case.custom(let errorMessage):
                                                    message = errorMessage
                                                }
                                                self.alertTitle = "Error."
                                                self.showAlert = true
                                            }
                                        }
                                    case.failure(let error):
                                        print("failure error: \(error.localizedDescription)")
                                        switch error {
                                        case.notSignedIn:
                                            message = "Sign in first."
                                        case.custom(let errorMessage):
                                            message = errorMessage
                                        }
                                        self.alertTitle = "Error."
                                        self.showAlert = true
                                    }
                                }
                            } label: {
                                Text("Save")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }).alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitle),
                        message: Text(message),
                        dismissButton: .default(Text("Okay"), action: {
                            if alertTitle == "Success!" {
                                dismiss()
                            }
                        })
                     )
                   }.frame(maxWidth: .infinity, maxHeight: .infinity) // 1
                    .accentColor(textColor)
                    .background(Color.init(uiColor: backgroundColor))
            }
            
        }
    }
}



class Post: ObservableObject {
    enum PostError: Error {
        case custom(errorMessage: String)
        case notSignedIn
    }
    
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
    
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a == b
    }
    
    func postAddress(street: String, city: String, state: String, zip: String, completion: @escaping(Result < Address, PostError > ) -> Void) {
        
        
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/address/") else {
            print("api is down")
            return
        }
        if street == "" || city == "" || state == "" || zip == "" {
            completion(.failure(.custom(errorMessage:"Fields are required.")))
            print("street: \(street), city: \(city), state: \(state), zip: \(zip)")
            return
        }
        
        var intZip: Int?
        intZip = Int(zip)
        if intZip == nil {
            completion(.failure(.custom(errorMessage: "Please enter a valid zip code. Try again.")))
            return
        } else if numberOfDigits(in: intZip!) != 5 {
            completion(.failure(.custom(errorMessage: "Invalid Zip Code")))
            return
        }
        let raw = "\(street), \(city), \(state) \(String(intZip!)), USA"
        
        let addressData = Address(raw: raw, street: street, city: city, state: state, zip: intZip!)
        print(addressData)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(addressData) else {
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
                print("data: \(String(decoding: data, as: UTF8.self))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
               
                if let json = try? decoder.decode(Address.self, from: data) {
                    //print(json)
                    completion(.success(json))
                } else {
                    completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                    print("response decoding failed for user for address")
                }
            } else {
                completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                print("response decoding failed for user for address")
            }
                
        }.resume()
    }
    
    func postRestaurant(name: String, address: Address, website: String, yelpPage: String, userWhoCreated: Int, phoneNumber: String, imgUrl: String, completion: @escaping(Result < String, PostError > ) -> Void) {
        
        
//        let uiImage: UIImage? = image.asUIImage()
//        if uiImage == nil {
//            completion(.failure(.custom(errorMessage: "Please enter a valid image.")))
//            return
//        }
//        let imgData: Data = uiImage?.jpegData(compressionQuality: 0.1) ?? Data()
//        let imgString: String = imgData.base64EncodedString()
        
        guard let url = URL(string: "https://shrouded-savannah-80431.herokuapp.com/api/restaurant/") else {
            print("api is down")
            return
        }
        if name == "" {
            completion(.failure(.custom(errorMessage: "Name is required.")))
            return
        }
        //print(phoneNumber)
        var formattedWebsite: String
        if website.starts(with: "www.") {
            formattedWebsite = "https://\(website)"
        } else if !website.starts(with: "https://www.") && website != "" {
            formattedWebsite = "https://www.\(website)"
        } else {
            formattedWebsite = website
        }
        
        
        var formattedYelp: String
        if !yelpPage.starts(with: "https://www.") && yelpPage != "" {
            formattedYelp = "https://www.\(yelpPage)"
        } else {
            formattedYelp = yelpPage
        }
        
        var intPhoneNumber: Int?
        if phoneNumber == "" {
            intPhoneNumber = nil
        } else {
            intPhoneNumber = Int(phoneNumber)
            if intPhoneNumber == nil {
                completion(.failure(.custom(errorMessage: "Please enter a valid phone number. Try again.")))
                return
            } else if intPhoneNumber! < 0 {
                completion(.failure(.custom(errorMessage: "Invalid Phone Number. Please enter a valid 10 digit phone number.")))
                return
            } else if numberOfDigits(in: intPhoneNumber!) != 10 {
                completion(.failure(.custom(errorMessage: "Invalid Phone Number. Please enter a valid 10 digit phone number.")))
                return
            }
        }
        let newPhoneNumber: String? = intPhoneNumber == nil ? nil : String(intPhoneNumber!)
        
        let restaurantData = Restaurant(id: nil, name: name, address: address.raw, website: formattedWebsite, yelpPage: formattedYelp, phoneNumber: newPhoneNumber, userWhoCreated: userWhoCreated, logoUrl: imgUrl) // yelppage, phonenumber are optional
        //print(restaurantData)
        print("raw: \(restaurantData)")
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
            print("data for rest before if: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let data = data {
                print("data for rest: \(String(decoding: data, as: UTF8.self))")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : [String]] {
                    print(json)
                    if (json["name"] ?? [""]).first == "restaurant with this name already exists." {
                        completion(.failure(.custom(errorMessage: "Restaurant already exists.")))
                        return
                    }
                    if (json["website"] ?? [""]).first == "Enter a valid URL." {
                        completion(.failure(.custom(errorMessage: "Enter a valid website URL.")))
                        return
                    }
                    if (json["yelpPage"] ?? [""]).first == "Enter a valid URL." {
                        completion(.failure(.custom(errorMessage: "Enter a valid website URL.")))
                        return
                    }
                    if (json["phoneNumber"] ?? [""]).first == "Enter a valid value." {
                        completion(.failure(.custom(errorMessage: "Enter a valid value.")))
                        return
                    }
                    
                } else if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    print(json)
                    completion(.success("Success"))
                } else {
                    completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                    print("response decoding failed for user for rest")
                }
            } else {
                print("error \(String(describing: error))")
                completion(.failure(.custom(errorMessage: "Something went wrong. Try again.")))
                print("response decoding failed for user for rest")
            }
                
        }.resume()
    }
}
//struct CreateRestaurantView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateRestaurantView()
//    }
//}
