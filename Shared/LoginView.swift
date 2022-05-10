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
    
    //let defaults = UserDefaults.standard

    //var function: () -> Void
    @State var username: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textContentType(.username)
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            Button(action: {
                loginClass.loginUser(username: username, password: password) { result in
                    print("result: \(result)")
                    switch result {
                    case.success(let tuple):
                        print("login success, token: \(tuple.1)")
                        //UserDefaults.standard.setValue(token, forKey: "tokenName") - saving here is bad.
                        let data = Data(tuple.0.utf8)
                        let idData = Data(String(tuple.1).utf8)
//                        guard let idData = try? JSONEncoder().encode(Data(id: tuple.1)) else {
//                            print("fail")
//                        }
                        //let idData = Data("{")
                        //print(String(data: idData, encoding: .utf8))
                        KeychainHelper.standard.save(data, service: "token", account: "user")
                        KeychainHelper.standard.save(idData, service: "id", account: "user")
                        DispatchQueue.main.async {
                            loginClass.isAuthenticated = true
                            loginClass.id = Int(tuple.1)
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        print("is auth: \(loginClass.isAuthenticated)")
                        
                    case.failure(let error):
                        //self.loginAlert = true
                        print("failure error: \(error.localizedDescription)")
                        self.showAlert = true
                    }
      
            
            
                }
                
            }, label: { Text("Login") })
            .alert(isPresented: $showAlert) {
                 Alert(title: Text("Login Error"),
                 message: Text("Please check username and password."),
                 dismissButton: .default(Text("Okay"))
              )
            }
        }
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


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginClass: Login())
    }
}
