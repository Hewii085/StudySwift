//
//  CameraController.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/16.
//

import UIKit
import AVFoundation
import VideoToolbox

//delegator
//265 Test 필요.
fileprivate var NALUHeader: [UInt8] = [0, 0, 0, 1]
let H265 = true


func compressionOutputCalback265(outputCallbackRefCon: UnsafeMutableRawPointer?,
                                 sourceFrameRefCon: UnsafeMutableRawPointer?,
                                 status: OSStatus,
                                 infoFlags: VTEncodeInfoFlags,
                                 sampleBuffer: CMSampleBuffer?) -> Swift.Void
{
    guard status == noErr else {
        print("error: \(status)")
        return
    }
    
    
    if infoFlags == .frameDropped {
        print("frame dropped")
        return
    }
    
    guard let sampleBuffer = sampleBuffer else {
        print("sampleBuffer is nil")
        return
    }
    
    if CMSampleBufferDataIsReady(sampleBuffer) != true {
        print("sampleBuffer data is not ready")
        return
    }

    let vc: CameraController = Unmanaged.fromOpaque(outputCallbackRefCon!).takeUnretainedValue()
    
    if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true)
    {
        
        let rawDic: UnsafeRawPointer = CFArrayGetValueAtIndex(attachments, 0)
        let dic: CFDictionary = Unmanaged.fromOpaque(rawDic).takeUnretainedValue()
        
        let keyFrame = !CFDictionaryContainsKey(dic, Unmanaged.passUnretained(kCMSampleAttachmentKey_NotSync).toOpaque())
        
        var vpsData: [UInt8]? = nil
        var spsData: [UInt8]? = nil
        var ppsData: [UInt8]? = nil
        
        if keyFrame
        {
            
            let format = CMSampleBufferGetFormatDescription(sampleBuffer)
            var spsSize: Int = 0
            var spsCount: Int = 0
            var nalHeaderLength: Int32 = 0
            var sps: UnsafePointer<UInt8>?
            var status: OSStatus
            
            
            var vpsSize: Int = 0
            var vpsCount: Int = 0
            var vps: UnsafePointer<UInt8>?
            var ppsSize: Int = 0
            var ppsCount: Int = 0
            var pps: UnsafePointer<UInt8>?

            status = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(format!, parameterSetIndex: 0, parameterSetPointerOut: &vps, parameterSetSizeOut: &vpsSize, parameterSetCountOut: &vpsCount, nalUnitHeaderLengthOut: &nalHeaderLength)
            
            if status == noErr
            {
                
                status = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(format!, parameterSetIndex: 1, parameterSetPointerOut: &sps, parameterSetSizeOut: &spsSize, parameterSetCountOut: &spsCount, nalUnitHeaderLengthOut: &nalHeaderLength)
                
                if status == noErr {
                    
                    status = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(format!, parameterSetIndex: 2, parameterSetPointerOut: &pps, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &ppsCount, nalUnitHeaderLengthOut: &nalHeaderLength)
                    
                    if status == noErr {

                        vpsData = convert(count : vpsSize, data: vps)
                        spsData = convert(count : spsSize, data: sps)
                        ppsData = convert(count : ppsSize, data: pps)
                    }
                }
            }
        }
        
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }
        
        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        if CMBlockBufferGetDataPointer(dataBuffer, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &dataPointer) == noErr
        {
            var bufferOffset: Int = 0
            let AVCCHeaderLength = 4
            
            if keyFrame
            {
                var NALUnitLength: UInt32 = 0
                memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
                
                let info = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                
                bufferOffset += Int(AVCCHeaderLength)
                bufferOffset += Int(NALUnitLength)
                
                memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
            
                let data = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                
                vc.SendKeyFrame(vps:vpsData, sps: spsData, pps: ppsData, info: info, data: data)
                
            }
            else
            {
                while bufferOffset < (totalLength - AVCCHeaderLength)
                {
                    var NALUnitLength: UInt32 = 0
                    memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                    NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
                    
                    let data = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                    
                    if keyFrame{
                        print("data : \(NALUnitLength) , \(data.count)")
                    }
                    
                    vc.encode(vps: vpsData, sps: spsData, pps: ppsData, data : data, isKeyFrame: keyFrame)
                    
                    bufferOffset += Int(AVCCHeaderLength)
                    bufferOffset += Int(NALUnitLength)
                }
                
            }
        }
    }
}

//compressionOutputCallback 264
func compressionOutputCallback(outputCallbackRefCon: UnsafeMutableRawPointer?,
                               sourceFrameRefCon: UnsafeMutableRawPointer?,
                               status: OSStatus,
                               infoFlags: VTEncodeInfoFlags,
                               sampleBuffer: CMSampleBuffer?) -> Swift.Void
{
    //압축 완료시 이쪽으로 Data들어옴
    guard status == noErr else {
        print("error: \(status)")
        return
    }
    
    if infoFlags == .frameDropped {
        print("frame dropped")
        return
    }
    
    guard let sampleBuffer = sampleBuffer else {
        print("sampleBuffer is nil")
        return
    }
    
    if CMSampleBufferDataIsReady(sampleBuffer) != true {
        print("sampleBuffer data is not ready")
        return
    }

    
    let vc: CameraController = Unmanaged.fromOpaque(outputCallbackRefCon!).takeUnretainedValue()
    
    if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true) {
        
        let rawDic: UnsafeRawPointer = CFArrayGetValueAtIndex(attachments, 0)
        let dic: CFDictionary = Unmanaged.fromOpaque(rawDic).takeUnretainedValue()
        
        let keyFrame = !CFDictionaryContainsKey(dic, Unmanaged.passUnretained(kCMSampleAttachmentKey_NotSync).toOpaque())
        var spsData : [UInt8]? = nil
        var ppsData : [UInt8]? = nil
        
        if keyFrame
        {
            let format = CMSampleBufferGetFormatDescription(sampleBuffer)
            var spsSize: Int = 0
            var spsCount: Int = 0
            var nalHeaderLength: Int32 = 0
            var sps: UnsafePointer<UInt8>?
            var status: OSStatus
            
            if CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format!,
                                                                  parameterSetIndex: 0,
                                                                  parameterSetPointerOut: &sps,
                                                                  parameterSetSizeOut: &spsSize,
                                                                  parameterSetCountOut: &spsCount,
                                                                  nalUnitHeaderLengthOut: &nalHeaderLength) == noErr
            {
                var ppsSize: Int = 0
                var ppsCount: Int = 0
                var pps: UnsafePointer<UInt8>?
                
                if CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format!,
                                                                      parameterSetIndex: 1,
                                                                      parameterSetPointerOut: &pps,
                                                                      parameterSetSizeOut: &ppsSize,
                                                                      parameterSetCountOut: &ppsCount,
                                                                      nalUnitHeaderLengthOut: &nalHeaderLength) == noErr {
                    spsData = convert(count : spsSize, data : sps)
                    ppsData = convert(count : ppsSize, data : pps)
                }
            }
        }
        
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }
        
        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        if CMBlockBufferGetDataPointer(dataBuffer, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &dataPointer) == noErr
        {
            var bufferOffset: Int = 0
            let AVCCHeaderLength = 4
            
            if keyFrame
            {
                var NALUnitLength: UInt32 = 0
                memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
                
                var info = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                bufferOffset += Int(AVCCHeaderLength)
                bufferOffset += Int(NALUnitLength)
                
                memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
                var data = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                
                vc.SendKeyFrame(sps: spsData, pps: ppsData, info: info, data: data)
                
            }
            else
            {
                while bufferOffset < (totalLength - AVCCHeaderLength)
                {
                    var NALUnitLength: UInt32 = 0
                    memcpy(&NALUnitLength, dataPointer?.advanced(by: bufferOffset), AVCCHeaderLength)
                    NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
                    var data = convert(count: Int(NALUnitLength), data: dataPointer?.advanced(by: bufferOffset + AVCCHeaderLength))
                    
                    if keyFrame{
                        print("data : \(NALUnitLength) , \(data.count)")
                    }
                    
                    vc.encode(sps: spsData, pps: ppsData, data : data, isKeyFrame: keyFrame)
                    
                    bufferOffset += Int(AVCCHeaderLength)
                    bufferOffset += Int(NALUnitLength)
                }
                
            }
        }
    }
}

func convert<T>(count: Int, data: UnsafePointer<T>?) -> [T]
{
    let buffer = UnsafeBufferPointer(start: data, count: count);
    return Array(buffer)
}

//func convertWithType(count: Int, data: UnsafePointer<Int8>?) -> [UInt8]
//{
//    let buffer = UnsafeBufferPointer(start: data, count: count);
//    let arry : Array<UInt8> = Array(buffer)
//    return arry
//}

extension CameraController : AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    //member : cur frame info width , height, pixelformat,
    //         codecType
    
    public func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        guard let pixelbuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        self.curWidth = Int32(CVPixelBufferGetBytesPerRow(imageBuffer) / 4)
        self.curHeight = Int32(CVPixelBufferGetHeight(imageBuffer))
        self.videoHeader.bih!.biWidth = self.curWidth
        self.videoHeader.bih!.biHeight = self.curHeight
        
        let _ = CVPixelBufferGetBaseAddress(imageBuffer)
        
        if compressionSession == nil
        {
            if H265{
                let _ = VTCompressionSessionCreate(allocator: kCFAllocatorDefault,
                                                   width: self.curWidth,
                                                   height: self.curHeight,
                                                   codecType: kCMVideoCodecType_HEVC,
                                                   encoderSpecification: nil, imageBufferAttributes: nil, compressedDataAllocator: nil,
                                                   outputCallback: compressionOutputCalback265,
                                                   refcon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                                   compressionSessionOut: &compressionSession)
                
                
            }
            else
            {
                let _ = VTCompressionSessionCreate(allocator: kCFAllocatorDefault,
                                                   width: self.curWidth,
                                                   height: self.curHeight,
                                                   codecType: kCMVideoCodecType_H264,
                                                   encoderSpecification: nil, imageBufferAttributes: nil, compressedDataAllocator: nil,
                                                   outputCallback: compressionOutputCallback,
                                                   refcon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                                   compressionSessionOut: &compressionSession)
            }
            
            guard let c = compressionSession else {
                return
            }
            
            if H265
            {
                VTSessionSetProperty(c, key: kVTCompressionPropertyKey_ProfileLevel,
                                     value: kVTProfileLevel_HEVC_Main10_AutoLevel)
            }
            else
            {
                VTSessionSetProperty(c, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_Baseline_AutoLevel)
            }
             
            VTSessionSetProperty(c, key: kVTCompressionPropertyKey_RealTime, value: true as CFTypeRef)
            VTSessionSetProperty(c, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: 30 as CFTypeRef)
            VTSessionSetProperty(c, key: kVTCompressionPropertyKey_AverageBitRate, value: self.curWidth * self.curHeight * 2 * 32 as CFTypeRef)
            VTSessionSetProperty(c, key: kVTCompressionPropertyKey_DataRateLimits, value: [self.curWidth * self.curHeight * 2 * 4, 1] as CFArray)

            VTCompressionSessionPrepareToEncodeFrames(c)
            
        }

        if let c = compressionSession
        {
            let presentationTimestamp = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            let duration = CMSampleBufferGetOutputDuration(sampleBuffer)
            
            VTCompressionSessionEncodeFrame(c, imageBuffer: pixelbuffer, presentationTimeStamp: presentationTimestamp, duration: duration, frameProperties: nil, sourceFrameRefcon: nil, infoFlagsOut: nil)
        }
    }
}

class CameraController: NSObject
{
    var curHeight : Int32 = 0
    var curWidth : Int32 = 0
    var svc : MainService = MainService()
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var captureSessionQueue = DispatchQueue(label: "MetalCameraSessionQueue", attributes: [])
    var compressionSession: VTCompressionSession?
    var outputData : AVCaptureVideoDataOutput?
    var isStartRecord : Bool = false
    
    var spsData : NSData?
    var ppsData : NSData?
    
    var codecType: Int32 = 0x35363248 //264 0x35363248
    var videoHeader : StreamVideoHeader = StreamVideoHeader()
    var fileHandler: FileHandle?
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    func configureCaptureDevices() throws
    {
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        self.frontCamera = camera
    }
    
    func configureDeviceInputs() throws
    {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        if let frontCamera = self.frontCamera
        {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession.canAddInput(self.frontCameraInput!)
            {
                captureSession.addInput(self.frontCameraInput!)
            }
            else
            {
                throw CameraControllerError.inputsAreInvalid
            }
        }
        else
        {
            throw CameraControllerError.noCamerasAvailable
        }
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void){
        
        print("Call Prepare")
        
        videoHeader.bih = BitmapHeader()
        videoHeader.bih!.biCompression = self.codecType
//
//        let path = NSTemporaryDirectory() + ("/temp.h264")
//        try? FileManager.default.removeItem(atPath: path)
//
//        if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
//            fileHandler = FileHandle(forWritingAtPath: path)
//        }
//
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = AVCaptureSession.Preset.vga640x480
            //set cam resolution
        }
        
        captureSessionQueue.async
        {
            do
            {
                createCaptureSession()
                self.captureSession?.beginConfiguration()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                self.initializeOutputData()
                self.captureSession?.commitConfiguration()
                self.captureSession?.startRunning()
            }
            catch
            {
                DispatchQueue.main.async
                {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async
            {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    fileprivate func initializeOutputData()
    {
        if let capSession = self.captureSession
        {
            let outputData = AVCaptureVideoDataOutput()

            outputData.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            outputData.alwaysDiscardsLateVideoFrames = true
            outputData.setSampleBufferDelegate(self, queue: captureSessionQueue)
            
            guard  capSession.canAddOutput(outputData) else {
                return
            }
            
            
            self.outputData = outputData
            capSession.addOutput(self.outputData!)
            print("Initialize Output Data")
        }
    }
    
    /*
     1. NAL,
     2. SPS
     3. NAL
     4. PPS
     5. NAL
     6. Frame
     */
    
    func testhandle(sps: [UInt8], pps: [UInt8], vps: NSData? = nil) {
        guard let fh = fileHandler else {
            return
        }

        fh.write(Data(NALUHeader))
        fh.write(Data(sps))
        fh.write(Data(NALUHeader))
        fh.write(Data(pps))
    }
    
    func testencode(data: [Int8], isKeyFrame: Bool) {
        guard let fh = fileHandler else {
            return
        }
        
        let uintArray = data.map { UInt8(bitPattern: $0) }
        fh.write(Data(NALUHeader))
        fh.write(Data(uintArray))
    }
    
    public func SendKeyFrame(sps : [UInt8]?, pps: [UInt8]?, info : [Int8],data: [Int8])
    {
        var frameData = [UInt8]()

        var len = sps!.count + pps!.count + NALUHeader.count + data.count + NALUHeader.count + info.count
        
        self.videoHeader.bih!.biSizeImage = Int32(len)
        
        frameData.append(contentsOf: self.videoHeader.GetBytes())
        
        if let spsData = sps{
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : spsData)
        }

        if let ppsData = pps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : ppsData)
        }
        
        frameData.append(contentsOf: NALUHeader)
        let uintArrayInfo = info.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArrayInfo)
        
        frameData.append(contentsOf: NALUHeader)
        let uintArray = data.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArray)

//        self.fileHandler?.write(Data(frameData))
        svc.SendFrame(data: frameData, isIFrame: true)
    }
    
    public func SendKeyFrame(vps: [UInt8]?,sps : [UInt8]?, pps: [UInt8]?, info : [Int8],data: [Int8])
    {
        var frameData = [UInt8]()

        var len = vps!.count + sps!.count + pps!.count + NALUHeader.count + data.count + NALUHeader.count + info.count
        
        self.videoHeader.bih!.biSizeImage = Int32(len)
        
        frameData.append(contentsOf: self.videoHeader.GetBytes())
        
        if let vpsData = vps{
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : vpsData)
        }
        
        if let spsData = sps{
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : spsData)
            
        }

        if let ppsData = pps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : ppsData)
        }
        
        frameData.append(contentsOf: NALUHeader)
        let uintArrayInfo = info.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArrayInfo)
        
        frameData.append(contentsOf: NALUHeader)
        let uintArray = data.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArray)

//        self.fileHandler?.write(Data(frameData))
        svc.SendFrame(data: frameData, isIFrame: true)
    }
    
    public func encode(vps : [UInt8]?, sps : [UInt8]?, pps: [UInt8]?,data: [Int8], isKeyFrame : Bool)
    {
        var frameData = [UInt8]()

        if isKeyFrame {
            print("KeyFrame : \(sps!.count) , \(pps!.count), \(NALUHeader.count), \(data.count)")
            let len = vps!.count + sps!.count + pps!.count + NALUHeader.count + data.count + NALUHeader.count
            self.videoHeader.bih!.biSizeImage = Int32(len)
        }
        else
        {
            let len = NALUHeader.count + data.count
            self.videoHeader.bih!.biSizeImage = Int32(len)
        }

        frameData.append(contentsOf: self.videoHeader.GetBytes())
        
        if let vpsData = vps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : vpsData)
        }
        
        if let spsData = sps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : spsData)
        }

        if let ppsData = pps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : ppsData)
        }
        
        frameData.append(contentsOf: NALUHeader)
        let uintArray = data.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArray)

        svc.SendFrame(data: frameData, isIFrame: isKeyFrame)
    }
    
    public func encode(sps : [UInt8]?, pps: [UInt8]?,data: [Int8], isKeyFrame : Bool)
    {
        var frameData = [UInt8]()

        if isKeyFrame {
            print("KeyFrame : \(sps!.count) , \(pps!.count), \(NALUHeader.count), \(data.count)")
            let len = sps!.count + pps!.count + NALUHeader.count + data.count + NALUHeader.count
            self.videoHeader.bih!.biSizeImage = Int32(len)
        }
        else
        {
            let len = NALUHeader.count + data.count
            self.videoHeader.bih!.biSizeImage = Int32(len)
        }

        frameData.append(contentsOf: self.videoHeader.GetBytes())
        
        if let spsData = sps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : spsData)
        }

        if let ppsData = pps {
            frameData.append(contentsOf: NALUHeader)
            frameData.append(contentsOf : ppsData)
        }
        
        frameData.append(contentsOf: NALUHeader)
        let uintArray = data.map { UInt8(bitPattern: $0) }
        frameData.append(contentsOf : uintArray)

        svc.SendFrame(data: frameData, isIFrame: isKeyFrame)
    }
    
    public func StartRecord()
    {
        self.isStartRecord = true
    }
    
    public func SetFunc(svc : MainService)
    {
        self.svc = svc
    }
}
