//
//  ContentView.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/16.
//

import SwiftUI
import AVFoundation



struct ContentView: View
{
    var ctrl : CameraViewController = CameraViewController()

    var body: some View {
        
        ZStack{
            ctrl.edgesIgnoringSafeArea(.top)
            
            Button(action : {  }){ Text("Encoding")}
                .frame(width : 50 , height: 50)
            
        }
    }
    
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
