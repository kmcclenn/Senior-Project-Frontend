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
        ZStack {
            Color(uiColor: backgroundColor).ignoresSafeArea()
        
            VStack {
                
                List() {
                    ForEach(points.indices) {i in
                    HStack {
                        Spacer()
                        if i == 0 {
                            Image("gold-medal")
                                .resizable()
                                .frame(width: 24.0, height: 36.0)
                                .foregroundColor(textColor)
                                .padding()
                        } else if i == 1 {
                            Image("silver-medal")
                                .resizable()
                                .frame(width: 24.0, height: 36.0)
                                .foregroundColor(textColor)
                                .padding()
                        } else if i == 2 {
                            Image("bronze-medal")
                                .resizable()
                                .frame(width: 24.0, height: 36.0)
                                .foregroundColor(textColor)
                                .padding()
                        } else if i <= 49 {
                            Image(systemName: "\(i+1).square.fill")
                                .resizable()
                                .frame(width: 28.0, height: 28.0)
                                .foregroundColor(textColor)
                                .padding()
                        } else {
                            Text("\(i+1).").bold().foregroundColor(textColor).padding()
                        }
                        
                        
                        Spacer()
                        Text("\(self.usernames[points[i].id] ?? String(points[i].id))")
                            .foregroundColor(textColor)
                            .bold()
                            .font(.headline)
                        Spacer()
                        Text("\(points[i].points) pts.")
                            .foregroundColor(textColor)
                            .bold()
                            .font(.headline)
                        Spacer()
                        
                        
                    }.listRowBackground(Color.init(uiColor: backgroundColor))
                    .listRowSeparatorTint(.white)
                    .onAppear {
                        
                        Load().load(endpoint: "appuser/\(points[i].id)", decodeType: User.self, string: "user", tokenRequired: true) { newUser in
                            self.usernames[(newUser as! User).id] = (newUser as! User).username
                        }
                            //print("load instance closure running")
                    }
                    
                }.refreshable {
                    Load().load(endpoint: "user_points", decodeType: [Points].self, string: "points", tokenRequired: true) { points in
                        self.points = points as! [Points]
                        
                    }
                }
                }.listStyle(PlainListStyle())
            }.navigationTitle("Leaderboard")
            .onAppear {
                print("points: \(points)")
            }
        }
    }
}

//struct LeaderboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardView()
//    }
//}
