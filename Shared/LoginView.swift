//
//  LoginView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/2/22.
//

import SwiftUI

struct LoginView : View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State public var isAuthenticated = false // not sure if needed
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
            Button("Dismiss") {
                dismiss()
            }
            Button(action: {
                loginUser(username: username, password: password) { result in
                                      
                    switch result {
                    case.success(let token):
                        print("login success, token: \(token)")
                        //UserDefaults.standard.setValue(token, forKey: "tokenName") - saving here is bad.
                        let data = Data(token.utf8)
                        KeychainHelper.standard.save(data, service: "token", account: "user")
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                        }
                    case.failure(let error):
                        //self.loginAlert = true
                        print("error: \(error.localizedDescription)")
                }
      
            
            
                }
            }, label: { Text("Save") })
            
        }
    }
    
    enum AuthenticationError: Error {
        case custom(errorMessage: String)
        case invalidCredentials
        
    }
    
    func loginUser(username: String, password: String, completion: @escaping(Result < String, AuthenticationError > ) -> Void) {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/api-token-auth/") else {
            print("api is down")
            return
        }
        
        let userData = SimpleUser(username: self.username, password: self.password)
        
        guard let encoded = try? JSONEncoder().encode(userData) else {
            print("failed to encode")
            return
        }
        //print("encoded: \(String(decoding: encoded, as:UTF8.self))")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic a21jY2xlbm46ZGV4SVNkZXgzMTQ=", forHTTPHeaderField: "Authorization")// add access token here ?/ NEEDS FIXING
        request.httpBody = encoded
        //print("request created")
        URLSession.shared.dataTask(with: request) {data, response, error in
            print("data: \(String(decoding: data!, as: UTF8.self))")
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : String] {
                guard let token = json["token"] else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                completion(.success(token))
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
        LoginView()
    }
}
