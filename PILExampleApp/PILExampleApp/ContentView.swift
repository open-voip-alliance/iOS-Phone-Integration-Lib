//
//  ContentView.swift
//  PILExampleApp
//
//  Created by Chris Kontos on 28/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var number: String = "+31630821207"
    
    var body: some View {
        VStack {
            Text("VoIP PIL").font(.largeTitle)
            Divider()
            HStack {
                Button(action: register) {
                    Text("Register").font(.title)
                }
                Spacer()
                Button(action: unregister) {
                    Text("Unregister").font(.title)
                }
            }.padding()
            HStack() {
                Button(action: call(number: number)) {
                    Text("Call").font(.title)
                }
                Spacer()
                TextField("+31630821207", text: $number).font(.title).multilineTextAlignment(.trailing)
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



