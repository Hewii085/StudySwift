//
//  ContentView.swift
//  ZStackLocationTest
//
//  Created by 윤성빈 on 2020/10/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        GeometryReader{ geo in
    
            ZStack(alignment: .topLeading)
            {
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width : geo.size.width, height: geo.size.height)
                    
                
                HStack
                {
                    Text("Hi")
                    
                    Spacer()
                    HStack
                    {
                        //ForEach 배치할것
                        Button(action:{})
                        {
                            Text("1")
                        }
                        
                        Button(action:{})
                        {
                            Text("2")
                        }
                    }
                    
                    Button(action:{})
                    {
                        Text("Btn")
                    }
                }
                .frame(width:geo.size.width, height: 30, alignment: .leading)
                .background(Color.yellow)
                
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
