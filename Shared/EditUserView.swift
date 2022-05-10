//
//  EditUserView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/9/22.
//

import SwiftUI

struct EditUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Binding var user: User
    @State var defaultUser: User
    @StateObject var updateInstance = Update()
    
    @State var message: String = ""
    @State private var showAlert = false
    
    init(user: Binding<User>) {
        self._user = user
        self._defaultUser = State(initialValue: user.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            List {
                
                TextField("Username", text: $user.username)
                TextField("First Name", text: $user.firstName ?? "")
                TextField("Last Name", text: $user.lastName ?? "")
                TextField("Email Address", text: $user.email ?? "")
                
            }.listStyle(GroupedListStyle())
            .navigationTitle(Text("Edit User"))
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        updateInstance.updateUser(newUser: user) {result in
                            switch result {
                            case.success(_):
                                
                                dismiss()
                                print("input success")
                            case.failure(let error):
                                print("failure error: \(error.localizedDescription)")
                                
                                switch error {
                                case.notSignedIn:
                                    message = "Sign in first."
                                case.custom(let errorMessage):
                                    message = errorMessage
                                }
                                showAlert = true
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        self.user = self.defaultUser
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }).alert(isPresented: $showAlert) {
                Alert(title: Text("Error"),
                message: Text(message),
                dismissButton: .default(Text("Okay"))
             )
           }
            
    }
    }
    
}



func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
//struct EditUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditUserView()
//    }
//}
