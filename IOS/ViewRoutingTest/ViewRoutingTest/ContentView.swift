//
//  ContentView.swift
//  ViewRoutingTest
//
//  Created by 윤성빈 on 2020/10/02.
//

import SwiftUI

enum ViewState
{
    case Normal, Warning, Alert
}

struct ContentView: View {
    @State var viewStat : ViewState = .Normal
    
    var body: some View {
        
        
        VStack{
            
            if viewStat == .Normal
            {
                Text("Normal")
            }
            else if viewStat == .Warning
            {
                Text("Warining")
            }
            else
            {
                Text("Alert")
            }
            
            HStack{
                Button(action:{ self.viewStat = .Normal})
                {
                    Text("N")
                }
                
                Button(action:{ self.viewStat = .Warning})
                {
                    Text("W")
                }.padding(30)
                
                Button(action:{ self.viewStat = .Alert})
                {
                    Text("A")
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
