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
    
    init(user: Binding<User>) {
        
        self._user = user
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
                        
                    } label: {

                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            })
            
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
