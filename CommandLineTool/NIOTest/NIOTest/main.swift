//
//  main.swift
//  NIOTest
//
//  Created by 윤성빈 on 2022/06/17.
//

import Foundation
import NIO

class TestClientChannelHandler : ChannelInboundHandler, ChannelOutboundHandler
{
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = [UInt8]
}
