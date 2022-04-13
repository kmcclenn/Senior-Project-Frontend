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
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                Text("\(restaurant.address)")
                Spacer()
                Button("Dismiss") {
                    dismiss()
                }
                Spacer()
            }.navigationTitle("\(restaurant.name)")
        }
        
        
    }
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView(restaurant: Restaurant(id: 1, name: "test", address: "12234", website: "hhhh", yelpPage: "ssss", phoneNumber: 22344))
    }
}
