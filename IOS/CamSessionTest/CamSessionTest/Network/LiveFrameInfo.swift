//
//  LiveFrameInfo.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/22.
//

import Foundation

enum FrameType : Int32
{
    case IFrame = 0,
         PFrame,
         BFrame
}

enum StreamType : Int32
{
    case VIDEO = 0,
         AUDIO,
         TEXT,
         EVENT,
         BIN,
         META
}

struct LiveFrameInfo
{
    public var info : OPINSStreamInfo
    public var rawData : [UInt8]
    
    init(info : OPINSStreamInfo, rawData : [UInt8])
    {
        self.info = info
        self.rawData = rawData
    }
}

