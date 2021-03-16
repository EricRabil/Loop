//
//  ShareViewController.swift
//  LoopShareExtension
//
//  Created by Eric Rabil on 1/11/21.
//

import UIKit
import LoopKit
import Social
import AVFoundation

class ShareViewContext: NSExtensionContext {
    
}

extension FileManager {
    static func temporaryFileURL() -> URL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                            isDirectory: true)

        let temporaryFilename = ProcessInfo().globallyUniqueString

        return temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
    }
}

class ShareViewController: SLComposeServiceViewController {
    let previewView = UIImageView()
    
    var videoURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = self.navigationController?.navigationBar.items {
            for item in items {
                if let rightItem = item.rightBarButtonItem {
                    rightItem.title = "Convert"
                }
            }
        }
    }
    
    override func loadPreviewView() -> UIView! {
        loadInputItems()
        return previewView
    }
    
    func loadInputItems() {
        guard let inputItems = self.extensionContext?.inputItems else {
           return
       }
       for inputItem in inputItems {
           guard let item = inputItem as? NSExtensionItem else {
               continue
           }
           guard let attachments = item.attachments else {
               continue
           }
           for attachment in attachments {
               guard let provider = attachment as? NSItemProvider else {
                   continue
               }
               loadInputURL(provider)
               loadInputVideo(provider)
           }
       }
    }
    
    func loadInputURL(_ provider: NSItemProvider) {
        if provider.hasItemConformingToTypeIdentifier("public.url") {
            provider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: {
                (item, error) in
                guard let itemURL = item as? URL else {
                    return
                }
                if !itemURL.absoluteString.hasPrefix("http") {
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    if self.textView.text.isEmpty {
                        self.textView.text = itemURL.absoluteString
                    } else {
                        self.textView.text = self.textView.text + " " + itemURL.absoluteString
                    }
                    self.textView.selectedRange = NSRange.init(location: 0, length: 0)
                    self.textView.setContentOffset(CGPoint.zero, animated: false)
                    self.validateContent()
                })
            })
        }
    }
    
    func loadInputVideo(_ provider: NSItemProvider) {
        if provider.hasItemConformingToTypeIdentifier("public.movie") {
            provider.loadItem(forTypeIdentifier: "public.movie", options: nil, completionHandler: {
                (item, error) in
                switch item {
                case let imageURL as URL:
                    self.loadVideoURL(imageURL)
                case let imageData as Data:
                    let tmp = FileManager.temporaryFileURL()
                    
                    FileManager.default.createFile(atPath: tmp.absoluteString, contents: imageData, attributes: nil)
                    
                    self.loadVideoURL(tmp)
                default:
                    break
                }
            })
        }
    }
    
    func loadVideoURL(_ url: URL) {
        let generator = AVAssetImageGenerator(asset: .init(url: url))
        
        if let image = try? generator.copyCGImage(at: .zero, actualTime: nil) {
            previewView.image = .init(cgImage: image)
        }
        
        videoURLs.append(url)
    }
    
    @objc func run() {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
        NSLog("Hello")
        
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
            attachments.forEach { attachment in
                if attachment.hasItemConformingToTypeIdentifier("public.movie") {
                    attachment.loadItem(forTypeIdentifier: "public.movie", options: nil) { (item, err) in
                        guard let url = item as? URL else {
                            return
                        }
                        
                        LKLoopUtilities.loopingVideo(for: .init(url: url)) { result in
                            let newURL = result.tempPath ?? url
                            
                            let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                            
                            do {
                                try FileManager.default.copyItem(at: newURL, to: downloadsDirectory.appendingPathComponent(newURL.lastPathComponent))
                                
                                if newURL == result.tempPath {
                                    try FileManager.default.removeItem(at: newURL)
                                }
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        } else {
            NSLog("No Attachments")
        }
    }

}
