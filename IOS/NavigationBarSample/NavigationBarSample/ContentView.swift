//
//  ContentView.swift
//  NavigationBarSample
//
//  Created by 윤성빈 on 2020/10/12.
//

import SwiftUI

struct TestView : View
{
    //현재 View의 Activation 신호를 줘야한다
    var body: some View{
        VStack
        {
            Text("Test Page")
        }.navigationBarBackButtonHidden(true)
        // Back Button 가리기
        .navigationBarItems(leading: Button(action:{}){ Text("??") })
        
    }
}

struct ContentView: View
{
    var body: some View
    {
        NavigationView {
            NavigationLink(destination: TestView()) {
                Text("Hello, world!")
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .principal)
                { // <3>
                    VStack
                    {
                        Text("Title").font(.headline)
                        Text("Subtitle").font(.subheadline)
                    }
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
