//
//  LeaderboardView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/10/22.
//

import SwiftUI

struct LeaderboardView: View {
    @State var points: [Points]
    @State var usernames: [Int:String] = [:]
    
    var body: some View {
        NavigationView {
            
            VStack {
                List(points) { point in
                    HStack {
                        Text("Total points: \(point.points)")
                        Text("User: \(self.usernames[point.id] ?? String(point.id))")
                    }.onAppear {
                        Load().loadUser(user_id: point.id) { user in
                            self.usernames[user.id] = user.username
                        }
                    }
                }.refreshable {
                    Load().loadPoints { (points) in
                        self.points = points
                    }
                }.listStyle(PlainListStyle())
            }.navigationTitle("Leaderboard")
            
            Spacer()
        }.onAppear {
                print("points: \(points)")
            }
    }
}

//struct LeaderboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardView()
//    }
//}
