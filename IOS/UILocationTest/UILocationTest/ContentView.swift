//
//  ContentView.swift
//  UILocationTest
//
//  Created by 윤성빈 on 2020/09/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader{ geometry in
            Text("Header").position(x: geometry.size.width, y: geometry.size.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
