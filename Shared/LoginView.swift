//
//  LoginView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/2/22.
//

import SwiftUI

struct LoginView : View {
    
    let loginClass: Login
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var message: String = ""
    @State private var alertTitle: String = ""
    @State var logIn: Bool
    
    //let defaults = UserDefaults.standard

    //var function: () -> Void
    @State var username: String = ""
    @State var email: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var password: String = ""
    @State var password2: String = ""
    

    var body: some View {
        ZStack {
            Color(uiColor: backgroundColor).ignoresSafeArea()
        VStack {
            VStack(alignment: .leading, spacing: 15) {
            TextField("Username", text: $username)
                
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textContentType(.username)
                .padding([.leading, .trailing])
                
                .shadow(radius: 10.0, x: 5, y: 10)
                
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !logIn {
                TextField("Email", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .padding([.leading, .trailing])
                    .cornerRadius(25.0)
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .background(Color(.white))
                TextField("First Name", text: $firstName)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .padding([.leading, .trailing])
                    
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Last Name", text: $lastName)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .padding([.leading, .trailing])
                    
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding([.leading, .trailing])
                    
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password (Again)", text: $password2)
                    .textContentType(.newPassword)
                    .padding([.leading, .trailing])
                    
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            } else {
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding([.leading, .trailing])
                    
                    .shadow(radius: 10.0, x: 5, y: 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            }.padding([.leading, .trailing], 50)
            Button(action: {
                if logIn {
                    loginClass.loginUser(username: username, password: password) { result in
                        print("result: \(result)")
                        switch result {
                        case.success(let tuple):
                            print("login success, token: \(tuple.1)")
                            let data = Data(tuple.0.utf8)
                            let idData = Data(String(tuple.1).utf8)
                            KeychainHelper.standard.save(data, service: "token", account: "user")
                            KeychainHelper.standard.save(idData, service: "id", account: "user")
                            DispatchQueue.main.async {
                                loginClass.isAuthenticated = true
                                loginClass.id = Int(tuple.1)
                                alertTitle = "Success!"
                                message = "Logged in successfully."
                                self.showAlert = true
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                            print("is auth: \(loginClass.isAuthenticated)")
                            
                        case.failure(let error):
                            switch error {
                            case.invalidCredentials:
                                message = "Please check username and password."
                            case.custom(let errorMessage):
                                message = errorMessage
                            }
                            print("failure error: \(error.localizedDescription)")
                            alertTitle = "Error."
                            self.showAlert = true
                            
                        }
                    }
                } else {
                    loginClass.registerUser(username: username, email: email, firstName: firstName, lastName: lastName, password: password, password2: password2) { result in
                        print("result: \(result)")
                        switch result {
                        case.success(_):
                            
                            DispatchQueue.main.async {
                                alertTitle = "Success!"
                                message = "Registered successfully."
                                self.showAlert = true
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                        case.failure(let error):
                            switch error {
                            case.custom(let errorMessage):
                                message = errorMessage
                            default:
                                break
                                
                            }
                            alertTitle = "Error."
                            print("failure error: \(error.localizedDescription)")
                            self.showAlert = true
                            
                        }
                    }
                }
                
            }, label: {
                if logIn {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(textColor)
                        .padding()
                        .frame(width: 200, height: 60)
                        
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)
                } else {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(textColor)
                        .padding()
                        .frame(width: 200, height: 60)
                        
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)
                }
            }).background(.black).padding(.top, 50)//button end
            .alert(isPresented: $showAlert) {
                 Alert(title: Text(alertTitle),
                 message: Text(message),
                 dismissButton: .default(Text("Okay"))
              )
            }
        }
        }.navigationTitle("WaitTimes")
    }
    
    
    
    
    
    

}


final class Login: ObservableObject {
    @Published var isAuthenticated: Bool = false
    let data = try? KeychainHelper.standard.read(service: "token", account: "user")
    let userId = try? KeychainHelper.standard.read(service: "id", account: "user")
    
    @Published var id: Int = -1
    
    init() {
        //print("keychain data: \(String(data: userId!, encoding: .utf8))")
        if data != nil {
            isAuthenticated = true
            //id = userId!
            
            
        }
        if userId != nil {
            id = Int(String(data: userId!, encoding: .utf8)!)!
            //print("aaid: \(aaid)")
        }
        self.isAuthenticated = isAuthenticated
        self.id = id
        print(self.id)
        // store id in keychain too.
    }
    
    
    enum AuthenticationError: Error {
        case custom(errorMessage: String)
        case invalidCredentials
    }
    
    func registerUser(username: String, email: String, firstName: String, lastName: String, password: String, password2: String, completion: @escaping(Result < String, AuthenticationError > ) -> Void) {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/appuser/") else {
            print("api is down")
            return
        }
        
        if password != password2 {
            completion(.failure(.custom(errorMessage: "Passwords don't match. Fix and try again.")))
            return
        }
        
        let userData = RegisterUser(username: username, email: email, firstName: firstName, lastName: lastName, password: password)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(userData) else {
            print("failed to encode")
            return
        }
        //print("register data user: \(String(data: encoded, encoding: .utf8))")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : String] {
                
                

                print(json)
                if (json["username"] == "A user with that username already exists.") {
                    completion(.failure(.custom(errorMessage: "Username already exists. Change and try again.")))
                    return
                }
                if json["email"] == "user with this email already exists." {
                    completion(.failure(.custom(errorMessage: "Email already exists. Change and try again.")))
                    return
                } else if json["email"] == "Enter a valid email address." {
                    completion(.failure(.custom(errorMessage: "Enter a valid email address.")))
                    return
                }
                completion(.success("success"))
//
                    
                return
            } else {
                completion(.failure(.custom(errorMessage: "Something went wrong. Please try again.")))
                print("response decoding failed for user with error: \(String(describing: error))")
            }
                
        }.resume()
        
    }
    
    func loginUser(username: String, password: String, completion: @escaping(Result < (String,Int), AuthenticationError > ) -> Void) {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/api-token-auth/") else {
            print("api is down")
            return
        }
        
        let userData = SimpleUser(username: username, password: password)
        
        guard let encoded = try? JSONEncoder().encode(userData) else {
            print("failed to encode")
            return
        }
        //print("encoded: \(String(decoding: encoded, as:UTF8.self))")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")// add access token here ?/ NEEDS FIXING
        request.httpBody = encoded
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data ?? Data.init(), as: UTF8.self))")
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : String] {
                guard let token = json["token"] else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                guard let id = Int(json["user_id"] ?? "") else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                print(json)
                completion(.success((token, id)))
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


//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView(loginClass: Login())
//    }
//}
