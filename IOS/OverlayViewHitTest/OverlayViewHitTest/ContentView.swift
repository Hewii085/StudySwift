//
//  ContentView.swift
//  OverlayViewHitTest
//
//  Created by 윤성빈 on 2020/10/13.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common)
    
    
    var body: some View {
        
        ZStack
        {
            Button(action: { print("Hello")})
            {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            }.padding(.bottom, 100)
            .allowsHitTesting(true)
            
            VStack
            {
                Button(action: { print("Hello2")})
                {
                    /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                }.allowsHitTesting(true)
            }.frame(maxWidth : .infinity, maxHeight: .infinity)
            .allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
            
            Button(action: { print("Hello")})
            {
                
            }.padding(.top, 100)
        
        }.background(Color(red:0,green:0,blue:0,opacity: 0))
        .onTapGesture{
            print("Tap")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
