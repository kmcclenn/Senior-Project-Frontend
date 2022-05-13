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
                        
                        Load().load(endpoint: "appuser/\(point.id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
                            self.usernames[(newUser as! User).id] = (newUser as! User).username
                        }
                            //print("load instance closure running")
                    }
                    
                }.refreshable {
                    Load().load(endpoint: "user_points", decodeType: [Points].self, string: "points", tokenRequired: true) { points in
                        self.points = points as! [Points]
                        
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
