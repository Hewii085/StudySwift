//
//  MainService.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/21.
//

import Foundation

class MainService : IIntegrationPacketReceiver, ObservableObject
{
    func Connected(sender: TestClient) {
        
    }
    
    func Disconnected(sender: TestClient) {
        
    }
    
    func NeedTryConnect(sender: TestClient) {
        
    }
    
    func NeedTryLogin(sender: TestClient) {
        
    }
    
    func SucceedLogin(sender: TestClient) {
        
    }
    
    func ReceivedFrame(frame: LiveFrameInfo) {
        print("Received Frame")
    }
    
    var clnt : TestClient
    
    init()
    {
        self.clnt = TestClient()
        let _ = self.clnt.connect(receiver: self, host: "fokin.iptime.org", port: 10010)
    }
    
    var beForeDate : Date = Date()
    var cnt : Int = 0
    
    
    public func SendFrame(data : [UInt8], isIFrame : Bool)
    {
        DispatchQueue.global().async {
            let curDate = Date()
            
            let rslt = Int(curDate.timeIntervalSince(self.beForeDate))
            
            if rslt >= 1
            {
                self.beForeDate = Date()
                print("\(self.cnt)")
                self.cnt = 0
            }
            
            var info : OPINSStreamInfo = OPINSStreamInfo()
            info.StreamType = 0
            self.cnt += 1
            self.clnt.SendFrame(info: info, data: data)
        }
    }
}
