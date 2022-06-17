//
//  TestClient.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/22.
//
import Foundation
import NIO

protocol IIntegrationPacketReceiver
{
    func Connected(sender : TestClient)
    func Disconnected(sender : TestClient)
    func NeedTryConnect(sender : TestClient)
    func NeedTryLogin(sender: TestClient)
    
    func SucceedLogin(sender : TestClient)
    func ReceivedFrame(frame : LiveFrameInfo)
}

struct DiopsNetworkMessage
{
    var rawData : [UInt8]
    
    init(rawData : [UInt8])
    {
        self.rawData = rawData
    }
    
}

class TestClient : DiopsPacketReceiver
{
    enum ReadStep
    {//Nested
        case Header, Body
    }
    
    private let grp : EventLoopGroup
    private var host : String?
    private var port : Int?
    private let bootStrap : ClientBootstrap
    
    private var clntChannel : Channel?
    private var parser : PacketParser = PacketParser()
    private var readStep : ReadStep = .Header
    private var sendBuffer : ByteBuffer?
    private var reservedPacket : [DiopsNetworkMessage] = [DiopsNetworkMessage]()
    var isConnected : Bool = false
    var receiver : IIntegrationPacketReceiver?
    
    
    init()
    {
        self.grp = MultiThreadedEventLoopGroup(numberOfThreads: 1)//이 쓰레드의미를 잘 알아야한다.
//
//        var option = ChannelOptions.Storage()
//        option.append(key:ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),SO_REUSEADDR), value : 1 )
//        option.append(key: ChannelOptions.tcpOption(.tcp_nodelay), value: 1)
//
        self.bootStrap = ClientBootstrap(group: grp)
//            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_SNDBUF), value : 16384)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),SO_REUSEADDR),value:1)
            .channelOption(ChannelOptions.tcpOption(.tcp_nodelay), value: 1)
        
    }
    
    convenience init(receiver : IIntegrationPacketReceiver ,host:String?, port:Int?)
    {
        self.init()
        self.receiver = receiver
        self.host = host
        self.port = port
    }
    
    func connect(receiver : IIntegrationPacketReceiver , host:String?, port:Int?) -> Bool
    {
        self.receiver = receiver
        
        guard let remoteAddr = host else{
            return false
        }
        
        guard let remotePort = port else{
            return false
        }
        
        var _ = bootStrap.connect(host:remoteAddr, port:remotePort).always(OnConnected)
        
        return true
    }
    
    func connect_sync(receiver : IIntegrationPacketReceiver , host:String?, port:Int?) -> Bool
    {
        self.receiver = receiver
        
        guard let remoteAddr = host else{
            return false
        }
        
        guard let remotePort = port else{
            return false
        }
        
        do{
            var _ = try bootStrap.connect(host:remoteAddr, port:remotePort).always(OnConnected).wait()
            
            
        }
        catch let msg
        {
            print("\(msg)")
        }
        
        return true
    }
    
    private func connect(host:String?, port:Int?) -> Bool
    {
        guard let remoteAddr = host else{
            return false
        }
        
        guard let remotePort = port else{
            return false
        }
        
        var _ = bootStrap.connect(host:remoteAddr, port:remotePort).always(OnConnected)
        
        return true
    }
    
    func ReceivedPkacet(data: String)
    {
        print("Received Packet")
    }
    
    func OnConnected(rslt : Result<Channel,Error>)
    {
        do{
            switch rslt {
                case .success:
                    self.clntChannel = try rslt.get()
                    var _ = self.clntChannel?
                                .pipeline
                                .addHandler(DiopsClientHandler(receiver : self)).always(OnSent)
                    //let _ = clntChannel?.getOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_SNDBUF))
                    
                    if let itf = receiver
                    {
                        itf.Connected(sender: self)
                    }
                    
                    self.isConnected = true
                case .failure:
                    if let itf = receiver{
                        itf.Disconnected(sender: self)
                    }
            }
        }catch let error{
            print("Result Error : \(error.localizedDescription)")
        }
    }
    
    
    func TryLogin(loginId : String, loginPass : String)
    {
        var loginModel = DiopsLoginInfo()
        loginModel.loginID = loginId
        loginModel.loginPw = loginPass
        loginModel.loginType = 1
        
        let packet = self.MakePacket(cmd: .OPINS_CMD_REQ_LOGIN,data: loginModel.GetBytes())
        self.Send(rawData: packet)
    }
    
    func Send(rawData : [UInt8])
    {
        var buffer = self.clntChannel?.allocator.buffer(capacity: rawData.count)
        buffer?.writeBytes(rawData)
        var _ = self.clntChannel?.writeAndFlush(buffer)
    }
    
    func SendData(cmd : OPINSProtocolCommand)
    {
        var header : DiopsPacketHeader = DiopsPacketHeader()
        header.opinsID = [79,80,80,82,0,0,0,0]
        header.cmd = cmd.rawValue
        header.size = 0
        header.isSecurity = 0
        header.res = 1
        header.key = 0
        header.jsonSize = 0
            
        var rawData = [UInt8]()
        rawData.append(contentsOf: header.GetBytes())
        Send(rawData: rawData)
    }
    
    func MakePacket(cmd: OPINSProtocolCommand,data:[UInt8]) -> [UInt8]
    {
        var header : DiopsPacketHeader = DiopsPacketHeader()
        header.opinsID = [79,80,80,82,0,0,0,0]
        header.cmd = cmd.rawValue
        header.size = Int64(data.count)
        header.isSecurity = 0
        header.res = 1
        header.key = 0
        header.jsonSize = 0
        
//        let headerSize = MemoryLayout<DiopsPacketHeader>.size
        var rawData = [UInt8]()
        rawData.append(contentsOf: header.GetBytes())
        rawData.append(contentsOf: data)

        return rawData
    }
    
    func MakePacket(cmd: OPINSProtocolCommand, json : [UInt8],data:[UInt8]) -> [UInt8]
    {
        var header : DiopsPacketHeader = DiopsPacketHeader()
        header.opinsID = [79,80,80,82,0,0,0,0]
        header.cmd = cmd.rawValue
        header.size = Int64(data.count + json.count)
        header.isSecurity = 0
        header.res = 1
        header.key = 0
        header.jsonSize = Int64(json.count)
        
//        let headerSize = MemoryLayout<DiopsPacketHeader>.size
        var rawData = [UInt8]()
        rawData.append(contentsOf: header.GetBytes())
        rawData.append(contentsOf: json)
        rawData.append(contentsOf: data)

        return rawData
    }
    
    func OnSent(rslt: Result<Void,Error>)
    {
        
    }
    
    func ReceivedPacket(data: ByteBuffer)
    {//PacketParser Receive 가 어떻게 올지 모름 버퍼를 운영하되 패킷 잘라넣기 해야된다
        ReceivedDiopsPacket(data: data)
    }

    func ReceivedDiopsPacket(data: ByteBuffer)
    {
        var readLen = 0
        let readBytes = data.getBytes(at : 0, length: data.readableBytes)
        
        while readLen < readBytes!.count
        {
            switch readStep {
            case .Header:
                let rslt = parser.ParseHeader(data: readBytes!, startIdx: readLen)
                
                if rslt >= MemoryLayout<DiopsPacketHeader>.size
                {
                    if parser.curHeader.size > 0
                    {
                        readStep = .Body
                    }
                    else
                    {
                        self.ProcPacket(header: parser.curHeader)
                        self.parser.Clear()
                    }
                }
                readLen += rslt
            case .Body:
                let rslt = parser.ReceivedBody(data: readBytes!, startIdx: readLen)
                
                if parser.IsReadComplete
                {
                    readStep = .Header
                    self.ProcPacket(header: parser.curHeader)
                    self.parser.Clear()
                }
                
                readLen += rslt
            }
        }
    }
    
    func ProcPacket(header : DiopsPacketHeader)
    {
        let cmd = OPINSProtocolCommand(rawValue: header.cmd)
        
        switch cmd
        {
        case .OPINS_CMD_RES_LOGIN:
            let rslt = OPINSResult(rawValue : header.res)
            self.ReceivedLoginResult(rslt : rslt!)
        case .OPINS_CMD_RES_STREAM:
            let rawData = self.parser.Body
            let decoder = JSONDecoder()
            let str = String(bytes:rawData[0...Int(header.jsonSize-1)], encoding: .utf8) // slice 특성상 배열의 index를 정해줘야 하기 때문에 -1 해야됨
            
            if let strmInfo = try? decoder.decode(OPINSStreamInfo.self,from : str!.data(using: .utf8)!)
            {
                var strmData = [UInt8]()
                strmData.append(contentsOf : rawData[Int(header.jsonSize)...Int(header.size-1)])
                self.ReceivedStream(info: strmInfo, data: strmData)
            }
            
        default:
            print("Unknown Command : \(cmd.debugDescription)")
        }
    }
    
    func ReceivedLoginResult(rslt : OPINSResult)
    {
        switch rslt {
        case .USERLOGINOK:
            print("Integration Server Login Succeed")
            self.receiver?.SucceedLogin(sender: self)
            
            self.SendReservedPacket()
        default:
            print("Login Fail")
        }
    }
    
    private func SendReservedPacket()
    {
        for item in reservedPacket
        {
            Send(rawData: item.rawData)
            reservedPacket.removeFirst()
        }
    }
    
    func ReceivedStream(info : OPINSStreamInfo ,data : [UInt8])
    {
        if let receiver = self.receiver
        {
            receiver.ReceivedFrame(frame: LiveFrameInfo(info : info, rawData: data))
        }
    }
    
    func SendFrame(info : OPINSStreamInfo,data : [UInt8])
    {
        if self.isConnected == false
        {
            return
        }
        
        let encoder = JSONEncoder()
        
        do
        {
            let rslt = try encoder.encode(info)
            let rawJson = [UInt8](rslt)
            let packet = self.MakePacket(cmd: .OPINS_CMD_RES_STREAM, json: rawJson, data : data)
//            print("sendFrame : \(rawJson.count) \(data.count)")
            self.Send(rawData: packet)
            
        }catch let err
        {
            print("Request Live Stream Failed : \(err.localizedDescription)")
            return ;
        }
    }
    
    func close()
    {
        var _ = self.clntChannel?.close()
    }
}

