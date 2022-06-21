//
//  Tester.swift
//  NIOTest
//
//  Created by 윤성빈 on 2022/06/21.
//

import Foundation
import NIO
import CloudKit

func asyncPrint(on ev: EventLoop, delayInSecond: UInt32, string:String) ->EventLoopFuture<String> {
    
    let promise = ev.makePromise(of: String.self)
    
    let _ = ev.submit {
        sleepAndPrint(delayInSecond: delayInSecond, string : string)
        promise.succeed("Success")
        return
    }
    
    return promise.futureResult
}

func sleepAndPrint(delayInSecond : UInt32, string: String) {
    sleep(delayInSecond)
    print(string)
}


func EventFuturetest()
{
    print("System Cores: \(System.coreCount)\n")

    let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let ev = evGroup.next()
    let future = asyncPrint(on: ev, delayInSecond: 10, string: "Hello ")

    print("Waiting...")

    future.whenSuccess{ message in
        print(message)
    }

    future.whenFailure{ message in
        print(message)
    }

    print("world!")

    try? evGroup.syncShutdownGracefully()

    
}
