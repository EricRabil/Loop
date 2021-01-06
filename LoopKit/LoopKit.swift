//
//  LoopKit.swift
//  LoopKit
//
//  Created by Eric Rabil on 7/28/20.
//

import Foundation
import AVKit

private func AVLoopingMetadataItem() -> AVMetadataItem {
    let item = AVMutableMetadataItem.init()
    let identifier = AVMetadataIdentifier.init(rawValue: "udta/LOOP")
    
    item.identifier = identifier
    item.dataType = "com.apple.metadata.datatype.raw-data"
    item.keySpace = AVMetadataKeySpace.quickTimeUserData
    item.key = NSNumber.init(value: 1280266064)
    item.value = NSMutableData.init(length: 4)!
    
    var extraAttributes: [AVMetadataExtraAttributeKey : Any] = [AVMetadataExtraAttributeKey : Any]()
    
    extraAttributes[AVMetadataExtraAttributeKey(rawValue: "dataType")] = 0
    extraAttributes[AVMetadataExtraAttributeKey(rawValue: "dataTypeNamespace")] = "com.apple.quicktime.udta"
    
    item.extraAttributes = extraAttributes
    
    return item
}

public struct LoopingVideoResult {
    public var asset: AVURLAsset;
    public var tempPath: URL?;
}

public class LKLoopUtilities {
    public static func loopingVideo(for asset: AVURLAsset, completion: @escaping (LoopingVideoResult) -> Void) -> Void {
        let existingLoop = asset.metadata.first {
            guard let identifier = $0.identifier else { return false }
            
            switch (identifier.rawValue) {
            case "udta/LOOP":
                return true
            default:
                return false
            }
        } != nil
        
        if existingLoop { return completion(LoopingVideoResult(asset: asset, tempPath: nil)) }
        
        print("creating export session")
        
        guard let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return completion(LoopingVideoResult(asset: asset, tempPath: nil)) }
        
        print("assigning export url")
        
        var exportURL = NSURL(string: NSTemporaryDirectory())!.appendingPathComponent("\(UUID().uuidString).mov")!
        var components = URLComponents(url: exportURL, resolvingAgainstBaseURL: true)!
        components.scheme = "file"
        exportURL = components.url!
        
        print("using url \(exportURL)")
        
        exportSession.metadata = [AVLoopingMetadataItem()]
        
        exportSession.outputURL = exportURL
        exportSession.outputFileType = .mov
        
        print("export now")
        
        exportSession.exportAsynchronously {
            print("hit completion! passing along the lords word")
            completion(LoopingVideoResult(asset: AVURLAsset(url: exportURL), tempPath: exportURL))
        }
    }
}
