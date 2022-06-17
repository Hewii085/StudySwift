//
//  PacketParser.swift
//  SwiftCmdTest
//
//  Created by 윤성빈 on 2020/08/15.
//  Copyright © 2020 윤성빈. All rights reserved.
//

import Foundation

class BitConverter
{
    static func BytesConvertData<T>(bytes:[UInt8],startIdx : Int = 0) -> T
    {
        let destIdx = (MemoryLayout<T>.size - 1) + startIdx
        let rslt = bytes[startIdx...destIdx].withUnsafeBytes { $0.load(as: T.self) }
        return rslt
    }
}

protocol SerializablePakcet
{
    func GetBytes() -> [UInt8]
    mutating func Encoding(data : [UInt8])
}

struct DiopsPacketHeader : SerializablePakcet
{
    public var opinsID : [UInt8] = [UInt8](repeating: 0, count: 8)
    public var cmd : Int64 = 0
    public var size : Int64 = 0
    public var isSecurity : Int64 = 0
    public var res : UInt32 = 0
    public var key : UInt32 = 0
    public var jsonSize : Int64 = 0
    
    init()
    {
        
    }
    
    init(data : [UInt8])
    {
        self.Encoding(data: data)
    }
    
    func GetBytes() -> [UInt8]
    {
        var rawData = [UInt8]()
        rawData.append(contentsOf : opinsID)
        rawData.append(contentsOf : withUnsafeBytes(of: cmd.littleEndian, Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: size.littleEndian, Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: isSecurity.littleEndian, Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: res.littleEndian, Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: key.littleEndian, Array.init))
        rawData.append(contentsOf : withUnsafeBytes(of: jsonSize.littleEndian, Array.init))
        
        return rawData
    }
        
    mutating func Encoding(data: [UInt8])
    {
        self.opinsID = Array(data[0...7])
        self.cmd = BitConverter.BytesConvertData(bytes: data,startIdx: 8)
        self.size = BitConverter.BytesConvertData(bytes: data, startIdx:16)
        self.isSecurity = BitConverter.BytesConvertData(bytes: data, startIdx:24)
        self.res = BitConverter.BytesConvertData(bytes: data, startIdx:28)
        self.key = BitConverter.BytesConvertData(bytes: data, startIdx:32)
        self.jsonSize = BitConverter.BytesConvertData(bytes: data, startIdx:40)
    }
}

struct DiopsLoginInfo
{
    var loginType : Int32 = 0
    var loginID : String = ""
    var loginPw : String = ""
    
    func GetBytes()->[UInt8]
    {
        var rawData = [UInt8]()
        var loginIdBytes = [UInt8](repeating: 0,count:257)
        let loginIDRaw = Array(loginID.utf8)
        loginIdBytes.replaceSubrange(0...loginIDRaw.count, with: loginIDRaw)
        
        var loginPwBytes = [UInt8](repeating: 0, count:257)
        let loginPwdRaw = Array(loginPw.utf8)
        loginPwBytes.replaceSubrange(0...loginPwdRaw.count, with: loginPwdRaw)
        
        rawData.append(contentsOf: withUnsafeBytes(of: loginType.littleEndian, Array.init))
        rawData.append(contentsOf: loginIdBytes)
        rawData.append(contentsOf: loginPwBytes)
        
        return rawData
    }
}

struct PacketHeader : SerializablePakcet
{
    public var len : Int32 = 0
    public var cmd : Int32 = 0
    
    init(len : Int32 = 0, cmd :Int32 = 0)
    {
        self.len = len
        self.cmd = cmd
    }
    
    func GetBytes() -> [UInt8]
    {
        var rawData = [UInt8]()
        let rawContent = withUnsafeBytes(of: cmd.littleEndian, Array.init)
        let rawLen = withUnsafeBytes(of: len.littleEndian, Array.init)
        
        rawData.append(contentsOf : rawLen)
        rawData.append(contentsOf : rawContent)
        
        return rawData
    }
    
    mutating func Encoding(data: [UInt8])
    {
        self.len = BitConverter.BytesConvertData(bytes: data)
        self.cmd = BitConverter.BytesConvertData(bytes: data, startIdx:4)
        //String Convert
//        self.content = String(bytes : data[3...data.count], encoding : .utf8)!
    }
}

class PacketParser
{
    public var rawData : [UInt8] = [UInt8]()
    public var curHeader : DiopsPacketHeader
    
    public var Body : [UInt8]{
        get{
            let startIdx = MemoryLayout<DiopsPacketHeader>.size
            let lastIdx = rawData.count - 1
            return Array(rawData[startIdx...lastIdx])
        }
    }
    public var IsReadComplete : Bool {
        get{
            return MemoryLayout<DiopsPacketHeader>.size + Int(curHeader.size) == rawData.count
        }
    }
    
    init()
    {
        curHeader = DiopsPacketHeader()
    }
    
    func ParseHeader(data : [UInt8], startIdx : Int) -> Int
    {
        let headerLen = MemoryLayout<DiopsPacketHeader>.size
        let readLen = min(data.count - startIdx , headerLen)
        let lastIdx = readLen - 1 + startIdx
        rawData.append(contentsOf: data[startIdx...lastIdx])
        
        if rawData.count >= headerLen
        {
            self.curHeader.Encoding(data: rawData)
        }
        
        return readLen
    }
    
    func ReceivedBody(data : [UInt8], startIdx: Int) -> Int
    {
        let headerLen = MemoryLayout<DiopsPacketHeader>.size
        
        if rawData.count < headerLen || self.curHeader.size == 0
        {
            return 0
        }
        
        let destIdx = curHeader.size - Int64(rawData.count - headerLen)
        //새로 데이터 들어올때가 문제임
        let readLen = min(data.count - startIdx, Int(destIdx))
        let lastIdx = readLen - 1 + startIdx
        rawData.append(contentsOf: data[startIdx...lastIdx])
//        print("Body Append : \(startIdx) %% \(lastIdx)")
        return readLen
    }
    
    func Clear()
    {
        self.rawData = [UInt8]()
    }
}
