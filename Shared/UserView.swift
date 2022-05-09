//
//  UserView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/6/22.
//

import SwiftUI

struct UserView: View {
    @State var currentUser: User
    var body: some View {
        Text("User!!!!!!!!")
    }
}



struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(currentUser: User(id: 1, username: "", firstName: "", lastName: "", email: ""))
    }
}
