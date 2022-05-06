//
//  RestaurantView.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 3/25/22.
//

import SwiftUI

struct RestaurantView: View {
    @Environment(\.dismiss) var dismiss
    @State var restaurant: Restaurant
    @State var waitTime: Float
    @State var loggedIn: Bool
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                Text("\(restaurant.address)")
                Spacer()
                if (waitTime == -1.0) {
                    Text("No user inputs yet. Be the first!")
                    if loggedIn {
                        Text("See below to input!")
                    } else {
                        
                    }// have link to that.
                } else {
                    Text("Waittime: \(Int(round(waitTime))) minutes.")
                }
                
                Spacer()
                Button("Dismiss") {
                    dismiss()
                }
                Spacer()
                if loggedIn {
                    HStack {
                        Text("Report your own wait time here:")
                    }
                }
            }.navigationTitle("\(restaurant.name)")
                .onAppear {
                    print("waittime from restaurantview \(restaurant.id): \(waitTime)")
                }
        }
        
        
    }
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344), waitTime: 0.0, loggedIn: false)
    }
}
