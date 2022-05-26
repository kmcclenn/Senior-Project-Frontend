//
//  UserView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/6/22.
//

import SwiftUI

struct UserView: View {
    @State var currentUser: User
    @State var credibility: Float = 1.0
    @State var showEdit = false
    var body: some View {
        ZStack {
            Color(uiColor: backgroundColor).ignoresSafeArea()
        
            // displays user info
            VStack {
                
                if (currentUser.firstName ?? nil != nil && currentUser.firstName ?? "" != "") && (currentUser.lastName ?? nil != nil && currentUser.lastName ?? "" != "") {
                    Text("Hello, \(currentUser.firstName ?? "") \(currentUser.lastName ?? "")!")
                        .font(.system(size: 40.0).italic().bold())
                        .foregroundColor(textColor)
                } else {
                    Text("Hello, \(currentUser.username)!")
                        .font(.system(size: 40.0).italic().bold())
                        .foregroundColor(textColor)
                        
                }
                
                
                HStack {
                    Spacer()
                    Text("Profile Details")
                        .padding()
                        
                        
                        .foregroundColor(textColor)
                        .font(.title)
                        .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 5)
                                )
                    Spacer()
                }
                HStack {
                    Text("Username:")
                        .foregroundColor(textColor)
                        .padding([.leading, .trailing, .top])
                        .font(.system(size: 18.0))
                
                    Text("\(currentUser.username)")
                        .padding([.leading, .trailing])
                        .foregroundColor(.black)
                        .font(.system(size: 18.0))
                        .background(.white)
                        .cornerRadius(15)
                        .padding([.top])
                    Spacer()
                }
               
                if (currentUser.email ?? nil != nil && currentUser.email ?? "" != "") {
                    
                    HStack {
                        Text("Email:")
                            .foregroundColor(textColor)
                            .padding([.leading, .trailing, .top])
                            .font(.system(size: 18.0))
                    
                        Text("\(currentUser.email!)")
                            .padding([.leading, .trailing])
                            .foregroundColor(.black)
                            .font(.system(size: 18.0))
                            .background(.white)
                            .cornerRadius(15)
                            .padding([.top])
                        Spacer()
                    }
                }
                if (currentUser.firstName ?? nil != nil && currentUser.firstName ?? "" != "") && (currentUser.lastName ?? nil != nil && currentUser.lastName ?? "" != "") {
                    HStack {
                        Text("Full Name:")
                            .foregroundColor(textColor)
                            .padding([.leading, .trailing, .top])
                            .font(.system(size: 18.0))
                    
                        Text("\(currentUser.firstName ?? "") \(currentUser.lastName ?? "")")
                            .padding([.leading, .trailing])
                            .foregroundColor(.black)
                            .font(.system(size: 18.0))
                            .background(.white)
                            .cornerRadius(15)
                            .padding([.top])
                        Spacer()
                    }
                }
                HStack {
                
                    Text("Credibility rating:")
                        .foregroundColor(textColor)
                        .padding([.leading, .trailing, .top])
                        .font(.system(size: 18.0))
                    
                    
                    Text("\(Int(round(credibility * 100)))%")
                        .padding([.leading, .trailing])
                        .foregroundColor(.black)
                        .font(.system(size: 18.0))
                        .background(.white)
                        .cornerRadius(15)
                        .padding([.top])
                
                    Spacer()
                }
                
                Spacer()
            }.onAppear {
                Load().load(endpoint: "get_credibility/\(currentUser.id)", decodeType: Credibility.self, string: "credibility", tokenRequired: true) { credibility in
                    self.credibility = (credibility as! Credibility).credibility
                }
            }
        .navigationTitle(currentUser.username)
        .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button {
                    showEdit.toggle()
                } label: {
                    Text("Edit Profile")
                        .sheet(isPresented: $showEdit, content: {
                                            EditUserView(user: $currentUser)
                                        })
                }


            }
        }
    }
}



//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView(currentUser: User(id: 1, username: "", firstName: "", lastName: "", email: ""), credibility: 1.0)
//    }
//}
