//
//  main.swift
//  ExtensionTest
//
//  Created by 윤성빈 on 2020/10/18.
//

import Foundation
/*
 Extension을 활용해서 다중상속 구현을 깔끔하게 나눌 수 있음
 
 */

protocol BoostEngine
{
    func Boost()
}

class MotorCycle
{
    var model : String = "Yamaha"
    func SetMachine()
    {
        print("SetMachine : \(model)")
    }
}

extension MotorCycle : BoostEngine
{
    func Boost() {
        self.model = "Yamaha 2.0"
        print("Called Boost : \(self.model)")
    }
    
}

var st = MotorCycle()
st.SetMachine()
st.Boost()
