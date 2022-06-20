//
//  TestClientChannelHandler.swift
//  NIOTest
//
//  Created by 윤성빈 on 2022/06/17.
//

import Foundation
import NIO

class TestClientChannelHandler : ChannelInboundHandler, ChannelOutboundHandler
{
    typealias InboundIn = MessageResponse
    typealias OutboundIn = [UInt8]
    
    
    func channelInactive(context: ChannelHandlerContext) {
        print("Channel Inactivate")
    }
    
    func channelActive(context: ChannelHandlerContext) {
        print("Channel Activate")
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
       
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        //write Logic 작성.
    }
}
