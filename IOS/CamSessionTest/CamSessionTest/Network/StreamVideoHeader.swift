//
//  StreamVideoHeader.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/22.
//

import Foundation

struct BitmapHeader
{
    var biSize : Int32 = 0
    var biWidth : Int32 = 0
    var biHeight : Int32 = 0
    var biPlanes : Int16 = 0
    var biBitCount : Int16 = 0
    var biCompression : Int32 = 0
    var biSizeImage : Int32 = 0
    var biXpelsPerMeter : Int32 = 0
    var biYpelsPerMeter : Int32 = 0
    var biClrUsed : Int32 = 0
    var biClrImportant : Int32 = 0
    
    init()
    {
        
    }
    
    init(data:[UInt8])
    {
        self.Encoding(data: data)
    }
    
    mutating func Encoding(data: [UInt8])
    {
        self.biSize = BitConverter.BytesConvertData(bytes: data, startIdx:0)
        self.biWidth = BitConverter.BytesConvertData(bytes: data, startIdx:4)
        self.biHeight = BitConverter.BytesConvertData(bytes: data, startIdx:8)
        
        self.biPlanes = BitConverter.BytesConvertData(bytes: data, startIdx:12)
        self.biBitCount = BitConverter.BytesConvertData(bytes: data, startIdx:14)
        
        self.biCompression = BitConverter.BytesConvertData(bytes: data, startIdx:16)
        self.biSizeImage = BitConverter.BytesConvertData(bytes: data, startIdx:20)
        
        self.biXpelsPerMeter = BitConverter.BytesConvertData(bytes: data, startIdx:24)
        self.biYpelsPerMeter = BitConverter.BytesConvertData(bytes: data, startIdx:28)
        self.biClrUsed = BitConverter.BytesConvertData(bytes: data, startIdx:32)
        self.biClrImportant = BitConverter.BytesConvertData(bytes: data, startIdx:36)
    }
    
    func GetBytes() -> [UInt8]
    {
        var rawData = [UInt8]()
        
        rawData.append(contentsOf : withUnsafeBytes(of: biSize.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biWidth.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biHeight.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biPlanes.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biBitCount.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biCompression.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biSizeImage.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biXpelsPerMeter.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biYpelsPerMeter.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biClrUsed.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: biClrImportant.littleEndian,
                                                        Array.init))
        
        return rawData
    }
}

struct StreamVideoHeader
{
    var bih : BitmapHeader? //40
    var Ts : Int64 = 0 // 8
    var Tcl : Int64 = 0 // 8
    
    var streamType : Int32 = 0 // 4
    var dwFlag : Int32 = 0 // 4
    
    mutating func Encoding(data: [UInt8])
    {
        self.bih = BitmapHeader(data:data)
        self.Ts = BitConverter.BytesConvertData(bytes: data, startIdx:40)
        self.Tcl = BitConverter.BytesConvertData(bytes: data, startIdx:48)
        self.streamType = BitConverter.BytesConvertData(bytes: data, startIdx:56)
        self.dwFlag = BitConverter.BytesConvertData(bytes: data, startIdx:60)
    }
    
    func GetBytes() -> [UInt8]
    {
        var rawData = [UInt8]()
        
        rawData.append(contentsOf : bih!.GetBytes())
        rawData.append(contentsOf : withUnsafeBytes(of: Ts.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: Tcl.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: streamType.littleEndian,
                                                        Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: dwFlag.littleEndian,
                                                        Array.init))
    
        return rawData
    }
   
}
