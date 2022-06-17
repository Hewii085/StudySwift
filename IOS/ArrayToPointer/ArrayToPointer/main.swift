//
//  main.swift
//  ArrayToPointer
//
//  Created by 윤성빈 on 2020/10/21.
//

import Foundation

func convert<T>(count: Int, data: UnsafePointer<T>?) -> [T]
{
    let buffer = UnsafeBufferPointer(start: data, count: count);
    return Array(buffer)
}

var arry = [UInt8]()
arry.append(1)
arry.append(2)
arry.append(3)
arry.append(4)
arry.append(5)
arry.append(6)
arry.append(7)
arry.append(8)
arry.append(9)
arry.append(10)

let ptr = UnsafeMutablePointer(mutating: arry)

let data = NSData(bytes: ptr, length: arry.count)

var rslt = [UInt8]()

data.getBytes(&rslt, range: NSRange(location:0, length: data.length))

print(rslt)


