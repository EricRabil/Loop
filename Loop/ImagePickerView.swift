import SwiftUI
import AssetsLibrary
import AVKit

public struct ImagePickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.movie"]
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
//                let filePath = url.absoluteString
                let asset = AVURLAsset.init(url: url)
                
                let existingLoop = asset.metadata.first {
                    guard let identifier = $0.identifier else { return false }
                    
                    switch (identifier.rawValue) {
                    case "udta/LOOP":
                        print([($0.value as! NSMutableData).count])
                        return true
                    default:
                        return false
                    }
                } != nil
                
                if !existingLoop {
                    let item = AVMutableMetadataItem.init()
                    let identifier = AVMetadataIdentifier.init(rawValue: "udta/LOOP")
                    
                    item.identifier = identifier
                    item.dataType = "com.apple.metadata.datatype.raw-data"
                    item.keySpace = AVMetadataKeySpace.quickTimeUserData
                    item.key = NSNumber.init(value: 1280266064)
                    item.value = NSMutableData.init(length: 4)
                    
                    var extraAttributes: [AVMetadataExtraAttributeKey : Any] = [AVMetadataExtraAttributeKey : Any]()
                    
                    extraAttributes[AVMetadataExtraAttributeKey(rawValue: "dataType")] = 0
                    extraAttributes[AVMetadataExtraAttributeKey(rawValue: "dataTypeNamespace")] = "com.apple.quicktime.udta"
                    
                    item.extraAttributes = extraAttributes
                    
                    guard let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
                    
                    let exportPath = NSTemporaryDirectory().appendingFormat("\(UUID().uuidString).mov")
                    let exportURL = NSURL.fileURL(withPath: exportPath)
                    
                    exportSession.metadata = [item]
                    
                    print(exportSession.metadata!)
                    
                    exportSession.outputURL = exportURL
                    exportSession.outputFileType = .mov
                
                    exportSession.exportAsynchronously {
                        let library = ALAssetsLibrary()
                        library.writeVideoAtPath(toSavedPhotosAlbum: exportURL) { (url, err) in
                            guard let url = url else { return }
                            
                            print("Daddy ❤️");
                        }
                    }
                }
            }
            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}
