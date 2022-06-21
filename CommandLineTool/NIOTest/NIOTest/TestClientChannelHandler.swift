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
    public typealias InboundIn = MessageResponse
    public typealias OutboundIn = RequestWrapper
    public typealias OutboundOut = String
    
    func channelInactive(context: ChannelHandlerContext) {
        print("Channel Inactivate")
    }
    
    func channelActive(context: ChannelHandlerContext) {
        print("Channel Activate")
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
       print("read Packet")
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let reqWrapper = self.unwrapOutboundIn(data)
        context.write(wrapOutboundOut(reqWrapper.request), promise: promise)
    }
}
