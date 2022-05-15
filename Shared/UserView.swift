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
            VStack {
                Text("Your profile.")
                if (currentUser.firstName ?? nil != nil && currentUser.firstName ?? "" != "") && (currentUser.lastName ?? nil != nil && currentUser.lastName ?? "" != "") {
                    Text("Hello, \(currentUser.firstName ?? "") \(currentUser.lastName ?? "")!")
                } else {
                    Text("Hello, \(currentUser.username)!")
                }
                HStack {
                    Spacer()
                    Text("Credibility rating:")
                    Text("\(Int(round(credibility * 100)))%")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                Spacer()
            }.onAppear {
                Load().load(endpoint: "get_credibility/\(currentUser.id)", decodeType: Credibility.self, string: "credibility", tokenRequired: true) { credibility in
                    self.credibility = (credibility as! Credibility).credibility
                }
            }
        .navigationTitle(currentUser.username)
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



//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView(currentUser: User(id: 1, username: "", firstName: "", lastName: "", email: ""), credibility: 1.0)
//    }
//}
