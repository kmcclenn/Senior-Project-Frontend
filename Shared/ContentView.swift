//
//  ContentView.swift
//  Shared
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import SwiftUI

struct ContentView: View {
    @State var restaurants = [Restaurant]()
    var body: some View {
        
        ForEach(restaurants, id: \.self) {item in
            HStack {
                Image(systemName: "banknote").foregroundColor(.green)
                Text(item.name)
                Spacer()
                
                
            
            }
        }.onAppear(perform: loadRestaurant)
    }
    
    func loadRestaurant() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/restaurant/") else {
            print("api is down")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic amhjc2NvbXB1dGVyMTpkZXhJU2RleDMxNA==", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) {
data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode([Restaurant].self, from: data) {
                    DispatchQueue.main.async {
                        self.restaurants = response
                    }
                    return
                }
            }
        }.resume()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
