//
//  OPINSStreamInfo.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/22.
//

import Foundation

struct OPINSStreamInfo : Codable
{
    public var DeviceID : String = ""
    public var EdgeDeviceID : String = ""
    public var Channel : Int = 0
    public var FrameType : Int = 0
    public var StreamType : Int = 0
    public var StreamNo : Int = 0
}
