//
//  JoystickView.swift
//  JoyStick
//
//  Created by 윤성빈 on 2020/09/28.
//

import SwiftUI
import Combine

struct JoystickView: View
{
    @State var innerCircleDiameter : CGFloat = 50;
    @State var outterCircleDiameter : CGFloat = 100;
    @State var positionX : CGFloat = 0.0
    @State var positionY : CGFloat = 0.0
    
    func GetHypotenuse(x : CGFloat, y: CGFloat) -> CGFloat
    {
        return sqrt(pow(x,2) + pow(y,2))
    }
    
    var body: some View {
        
        let gest = DragGesture()
            .onEnded { value in
                let outterCircleRadius = outterCircleDiameter / 2
                let innerCircleRadius = innerCircleDiameter / 2
                self.positionX = outterCircleRadius - innerCircleRadius;
                self.positionY = outterCircleRadius - innerCircleRadius;
                
            }
            .onChanged{value in
                
                let innerCircleRadius = innerCircleDiameter / 2
                let outterCircleRadius = outterCircleDiameter / 2
                
                let stdPosX = value.location.x - outterCircleRadius
                let stdPosY = outterCircleRadius - value.location.y
                let hypotenuse = GetHypotenuse(x: stdPosX, y: stdPosY)
                
                let rangeCircleRadius = outterCircleRadius - innerCircleRadius
                let rsltPosX = (stdPosX / hypotenuse) * rangeCircleRadius
                let rsltPosY = (stdPosY / hypotenuse) * rangeCircleRadius
                
                self.positionX =  outterCircleRadius + rsltPosX - innerCircleRadius
                self.positionY = outterCircleRadius - rsltPosY - innerCircleRadius
            }
    
        return GeometryReader { geo in
            
            ZStack
            {
                Ellipse()
                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
                    .frame(width: self.outterCircleDiameter,
                           height: self.outterCircleDiameter,
                           alignment: .center)
                
                Ellipse() // 이 Ellpise를 어떻게 움직이는가
                    .fill(Color(red:0, green:0 , blue:0, opacity: 0.2))
                    .position(x: positionX <= 0 ? (outterCircleDiameter / 2 ) - (innerCircleDiameter / 2) : positionX,
                              y: positionY <= 0 ? (outterCircleDiameter / 2 ) - (innerCircleDiameter / 2) : positionY)
                    .frame(width: innerCircleDiameter, height: innerCircleDiameter, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                    .position(x: positionX,
//                              y: positionY)
                //frame과 position 순서에 따라 control location이 다른데 뭔가 다른 메커니즘이 존재 하는듯 하다.
                //TabGesture?
            }.gesture(gest)
            
        }
        
    }
}

struct JoystickView_Previews: PreviewProvider {
    static var previews: some View {
        JoystickView()
    }
}
