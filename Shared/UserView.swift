//
//  UserView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/6/22.
//

import SwiftUI

struct UserView: View {
    @State var currentUser: User
    @State var credibility: Float
    @State var showEdit = false
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Your profile.")
                if (currentUser.firstName ?? nil != nil || currentUser.firstName ?? "" != "") && (currentUser.lastName ?? nil != nil || currentUser.lastName ?? "" != "") {
                    Text("Hello, \(currentUser.firstName ?? "") \(currentUser.lastName ?? "")!").onAppear {
                        print("firstlast \(currentUser.firstName!)")
                    }
                } else {
                    Text("Hello, \(currentUser.username)!")
                }
                HStack {
                    Spacer()
                    Text("Credibility rating:")
                    Text("\(round(credibility * 100))%")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                Spacer()
            }
        }.navigationTitle(currentUser.username)
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



struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(currentUser: User(id: 1, username: "", firstName: "", lastName: "", email: ""), credibility: 1.0)
    }
}
