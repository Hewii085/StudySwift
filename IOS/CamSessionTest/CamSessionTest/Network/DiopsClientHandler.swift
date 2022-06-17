//
//  DiopsClientHandler.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/22.
//
import Foundation
import NIO

protocol DiopsPacketReceiver
{
    func ReceivedPacket(data : ByteBuffer)
}

class DiopsClientHandler : ChannelInboundHandler
{
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    var receiver: DiopsPacketReceiver

    
    private func printByte(_ byte: UInt8) {
        fputc(Int32(byte), stdout)
    }
    
    init(receiver : DiopsPacketReceiver)
    {
        self.receiver = receiver
    }

    func channelInactive(context: ChannelHandlerContext) {
        print("Channel Inactivate")
    }
    
    func channelActive(context: ChannelHandlerContext) {
        print("Channel Activate")
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
        let buffer = self.unwrapInboundIn(data)
        receiver.ReceivedPacket(data: buffer)
    }
    
    
    
//    func SendData(data: String)
//    {
//        var buffer = self.ctx?.channel.allocator.buffer(capacity: data.utf8.count)
//        buffer?.writeString(data)
//        self.ctx?.writeAndFlush(wrapOutboundOut(buffer!), promise: nil)
//    }
}
