//
//  AboutView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 5/22/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(uiColor: backgroundColor).ignoresSafeArea()
        
        VStack {
            Group {
                HStack {
                    Spacer()
                    Text("Hello!").font(.title).bold().foregroundColor(textColor)
                    Spacer()
                }
                
                Text("My name is Kai McClennen, and I am a current senior at the Jackson Hole Community School in Jackson, WY. This app is my senior project, with the goal of combating the problem of overcrowding in my hometown of Jackson.").foregroundColor(textColor).font(.subheadline).multilineTextAlignment(.center).padding()
                
                Text("In an area that relies heavily on tourism, Jackson restaurants get exceedingly crowded for both visitors and locals. So, my idea is to show live wait times based on user inputs so that customers choose the restaurants that are less busy. Therefore, people will ideally spread out.").foregroundColor(textColor).font(.subheadline).multilineTextAlignment(.center).padding()
                
                Text("To use the app, all you have to do is log in and then input the wait time you are told when you visit a restaurant. The more inputs you send in, the higher you climb on the leaderboard, but be careful. If your inputs are inaccurate they will count less in the future. You can also add a restaurant if you so choose. Good luck!").foregroundColor(textColor).font(.subheadline).multilineTextAlignment(.center).padding()
                
            }
            Group {
                Text("You can contact me at ").foregroundColor(textColor).font(.subheadline).multilineTextAlignment(.center)
                HStack {
                    Spacer()
                    
                    Link(destination: URL(string: "mailto:kai.mcclennen@gmail.com")!) { Text("kai.mcclennen@gmail.com").underline().tint(textColor)
                    }
                    Text(" or ").foregroundColor(textColor).font(.subheadline)
                    Link(destination: URL(string: "tel:3076999693")!) { Text("3076999693").foregroundColor(textColor).underline()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        }
    }
}




struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
