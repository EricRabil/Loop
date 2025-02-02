//
//  MessagesViewController.swift
//  MessageExtension
//
//  Created by Eric Rabil on 7/29/20.
//

import UIKit
import SwiftUI
import MobileCoreServices
import Messages
import AVKit
import LoopKit

class MessagesViewController: MSMessagesAppViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let controller = UIImagePickerController()
        controller.sourceType = .savedPhotosAlbum
        controller.mediaTypes = [kUTTypeVideo, kUTTypeMovie] as [String]
        controller.delegate = self
        controller.allowsEditing = true
        controller.modalPresentationStyle = .overFullScreen
        
        present(controller, animated: true) {
            print("PickerController presented")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let url = info[.mediaURL] as? URL {
            let asset = AVURLAsset.init(url: url)
            
            LKLoopUtilities.loopingVideo(for: asset) { result in
                self.activeConversation?.insertAttachment(result.asset.url, withAlternateFilename: result.asset.url.lastPathComponent) { _ in
                    DispatchQueue.main.sync {
                        self.dismiss()
                    }
                    print("Attachment inserted")
                }
            }
        }
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
