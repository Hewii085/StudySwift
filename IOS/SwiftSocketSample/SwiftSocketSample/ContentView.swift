//
//  ContentView.swift
//  SwiftSocketSample
//
//  Created by 윤성빈 on 2020/08/07.
//  Copyright © 2020 윤성빈. All rights reserved.
//

import SwiftUI
import NIO

enum TCPClientError: Error {
    case invalidHost
    case invalidPort
}

class TCPClientHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    private var numBytes = 0
    
    // channel is connected, send a message
    func channelActive(ctx: ChannelHandlerContext) {
        let message = "SwiftNIO rocks!"
        var buffer = ctx.channel.allocator.buffer(capacity: message.utf8.count)
        buffer.writeString(message)
        
        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            print(received)
        }
        if numBytes == 0 {
            print("nothing left to read, close the channel")
            ctx.close(promise: nil)
        }
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}

class TCPClient {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var host: String?
    private var port: Int?
    
    private var bootstrap: ClientBootstrap {
        return ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(TCPClientHandler())
        }
        
    }
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func start() throws {
        guard let host = host else {
            throw TCPClientError.invalidHost
        }
        guard let port = port else {
            throw TCPClientError.invalidPort
        }
        do {
            let channel = try bootstrap.connect(host: host, port: port).wait()
            try channel.closeFuture.wait()
        } catch let error {
            throw error
        }
    }
    
    func stop() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down \(error.localizedDescription)")
            exit(0)
        }
        print("Client connection closed")
    }
    
    
}

struct ContentView: View {
    
    var body: some View {
        VStack{
            Text("Hello, World!")
            Button(action:{
                let clnt = TCPClient(host:"192.168.0.201",port:11001)
                    do{
                       try clnt.start()
                    }catch let error {
                        print("Error : \(error.localizedDescription)")
                        clnt.stop()
                    }
            }){ Text("Click")}
        }
    }
    
    func ButtonClickAction()
    {
        let clnt = TCPClient(host:"192.168.0.201",port:11001)
        do{
           try clnt.start()
        }catch let error {
            print("Error : \(error.localizedDescription)")
            clnt.stop()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
