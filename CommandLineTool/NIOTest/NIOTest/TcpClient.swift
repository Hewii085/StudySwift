//
//  TcpClient.swift
//  NIOTest
//
//  Created by 윤성빈 on 2022/06/17.
//

import Foundation
import NIO
import NIOConcurrencyHelpers

struct RequestWrapper{
    let request : String
    let promise: EventLoopPromise<MessageResponse>
}

public enum ClientError{
    case notReady
    case timeOut
}

public struct TcpClientError : Swift.Error, Equatable {
    public let errorType : ClientError
    
    init(_ clntError : ClientError){
        self.errorType = clntError
    }
}

internal struct MessageResponse : Codable{
    let cmd : Int
}

public enum ResultType<Value, Error> {
    case success(Value)
    case failure(Error)
}

internal extension ResultType where Value == Int, Error == TcpClientError{
    
    init(_ response: MessageResponse) {
        if response.cmd == 0 {
            self = .success(response.cmd)
        }else{
            self = .failure(TcpClientError(ClientError.notReady))
        }
    }
}


class TcpClient: @unchecked Sendable{
    public typealias Result = ResultType<Int, TcpClientError>
    private let lock = Lock()
    public let group : MultiThreadedEventLoopGroup
    private var channel: Channel?
    
    init(group : MultiThreadedEventLoopGroup){
        self.group = group
    }
    
    public func connect(host: String, port:Int) -> EventLoopFuture<TcpClient> {
        let bootStrap = ClientBootstrap(group:self.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer{handler in return handler.pipeline.addHandler(TestClientChannelHandler()) }
        
        return bootStrap.connect(host: host, port: port).flatMap{ channel in
            self.channel = channel
            return channel.eventLoop.makeSucceededFuture(self)
        }
    }
    
    public func Send(message:String) -> EventLoopFuture<Result> {

        guard let channel = self.channel else {
            return self.group.next().makeFailedFuture(TcpClientError(ClientError.notReady))
        }

        let promise: EventLoopPromise<MessageResponse> = channel.eventLoop.makePromise()
        let request = RequestWrapper(request: message, promise: promise)
        let future = channel.writeAndFlush(request)
        future.cascadeFailure(to: promise)

        return future.flatMap{
            promise.futureResult.map{ Result($0)}
        }
    }
 }
