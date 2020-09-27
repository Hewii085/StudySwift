//
//  main.swift
//  AboutVariable
//
//  Created by 윤성빈 on 2020/09/18.
//  Copyright © 2020 윤성빈. All rights reserved.
//
import Foundation
/*
 Declare
 Type
  - Dictionary
  - Array
  - Tuple
  - Optional
 
 */

/*
 변수의 선언
 
 (var or let) (name) : (type)
 (var or let) (name) = Initial value
 
 Swift에서 변수의 선언은 var, let(constant)로 선언 할 수 있다.
 let (constant ) : 처음 초기화이후 해당 변수는 변경 할 수 없다
 var (variable)  : 초기화 이후에 해당 변수에 다른값으로 변경 할 수 있다
 
 상황에 따라 다르지만 let keyword로 선언한 변수는 꽤나 안전하게 변수를 사용 할 수있도록 도와준다.
 협업시에 선언부분에 let을 사용 할 경우 이 변수는 앞으로 변하지 않고 지속적으로 사용한다는 의미를 부여 할 수 있다.
 그리고 해당 변수의 값이 변경되지 않도록 막을 수 있다.
*/

func SampleOne()
{
    var numOne = 0
    numOne = 5 // 변경 가능
    
    let numTwo = 0
//    numTwo = 10  // error :  Cannot assign to value: 'numTwo' is a 'let' constant
//                 // 변경 불가능
}


/**
 Type
  - 기본적으로 Integer , Floating Num, String , Bool 을 지원하며 C#, Java등과 같은 언어와 비슷하다
 
 */

func SampleTwo()
{
    var arry : [Int] = [Int]()
    arry.append(1)
    arry.append(2)
    
    var arryTwo = (1,2,3,4,5)
    arry.append(6)
    arry.append(7)
}

var num : Int? = nil
var name : String? = nil
var isContinue : Bool? = nil

