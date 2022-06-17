//
//  ContentView.swift
//  JoyStick
//
//  Created by 윤성빈 on 2020/09/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        JoystickView().frame(width : 100, height: 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
