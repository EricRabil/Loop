//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Eric Rabil on 7/28/20.
//

import Intents
import AVKit
import LoopKit

class IntentHandler: INExtension, LoopIntentHandling {
    func handle(intent: LoopIntent, completion: @escaping (LoopIntentResponse) -> Void) {
        guard let video = intent.video else { fatalError("Video not provided") }
        
        print("creating asset from url")
        
        var tempPath = URL(string: NSTemporaryDirectory())!.appendingPathComponent("\(UUID().uuidString)-\(video.filename)")
        var components = URLComponents(url: tempPath, resolvingAgainstBaseURL: true)!
        components.scheme = "file"
        tempPath = components.url!
        
        do {
            try video.data.write(to: tempPath)
        } catch {
            print("fuck 💔 \(error)")
        }
        
        let asset = AVURLAsset.init(url: tempPath)
        
        LKLoopUtilities.loopingVideo(for: asset) { result in
            let file = INFile(fileURL: result.tempPath ?? tempPath, filename: video.filename, typeIdentifier: "public.movie")
            
            let response = LoopIntentResponse.init(code: .success, userActivity: .none)
            response.result = file
            
            print("passing skinny completion to skinny queen! file: \(file)")
            
            completion(response)
        }
    }
    
    func resolveVideo(for intent: LoopIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        guard let video = intent.video else { fatalError("Video not provided") }
        completion(INFileResolutionResult.success(with: video))
    }
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is LoopIntent else { fatalError("Unknown intent passed") }
        
        return self
    }
    
}
