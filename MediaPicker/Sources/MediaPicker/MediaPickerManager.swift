//
//  MediaPicker.swift
//
//
//  Created by Skywinds on 10/9/20.
//

import CoreServices
import AVFoundation
import Photos
import UIKit

public struct MediaInfo {
    let image: UIImage?
    let url: URL?
    let filename: String
}

public class MediaPickerManager: NSObject {
    
    // MARK: Public properties
    
    public var pickedBlock: ((MediaInfo) -> Void)?
    
    public enum MediaSupport {
        case camera
        case photoLibrary
        case file
    }
    
    // MARK: Public methods
    
    public func showMediaPickerActionSheet(from viewController: UIViewController, mediaTypes: [MediaSupport], sender: UIControl?) {
        let chooseOption = NSLocalizedString("CHOOSE_OPTION", bundle: .module, comment: "Choose option")
        let choosePhoto = NSLocalizedString("CHOOSE_PHOTO", bundle: .module, comment: "Choose photo")
        let takePhoto = NSLocalizedString("TAKE_PHOTO", bundle: .module, comment: "Take Photo")
        let takeFile = NSLocalizedString("FILE", bundle: .module, comment: "Choose File")
        let cancel = NSLocalizedString("CANCEL", bundle: .module, comment: "Cancel")
        
        let actionSheet = UIAlertController(title: nil, message: chooseOption, preferredStyle: .actionSheet)
        
        mediaTypes.forEach { (support) in
            switch support {
            case .photoLibrary:

                let photoLibrary = UIAlertAction(title: choosePhoto, style: .default) { [unowned viewController]action in
                    self.authorizedPhotoLibrary(for: .photoLibrary, from: viewController)
                }
                
                actionSheet.addAction(photoLibrary)
                
            case .camera:

                let camera = UIAlertAction(title: takePhoto, style: .default) { [unowned viewController] action in
                    
                    self.authorizedPhotoLibrary(for: .camera, from: viewController)
                }
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    actionSheet.addAction(camera)
                }
                
            case .file:
                let file = UIAlertAction(title: takeFile, style: .default) { [unowned viewController] action in
                    self.openDocumentPicker(from: viewController)
                }
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    actionSheet.addAction(file)
                }
            }
        }
        
        if sender != nil {
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.sourceRect = sender!.frame
            actionSheet.popoverPresentationController?.sourceView = sender!.superview
        }
        
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)

        actionSheet.addAction(cancelAction)

        viewController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    lazy private var pickerController = UIImagePickerController()
    
    // MARK: Private methods
    
    private func authorizedPhotoLibrary(for optionType: MediaSupport, from viewController: UIViewController) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
            
        case .authorized:
            
            switch optionType {
            case .camera:
                openCamera(from: viewController)
            case .photoLibrary:
                openPhotoLibrary(from: viewController)
            case .file: break
            }
            
        case .denied:
            print("permission denied")
            
            self.alertMessage(for: optionType, from: viewController)
            
        case .notDetermined:
            print("Permission Not Determined")
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if status == PHAuthorizationStatus.authorized {
                    // photo library access given
                    print("access given")
                    
                    switch optionType {
                    case .camera:
                        self.openCamera(from: viewController)
                    case .photoLibrary:
                        self.openPhotoLibrary(from: viewController)
                    case .file: break
                    }
                    
                } else {
                    self.alertMessage(for: optionType, from: viewController)
                }
                
            })
            
        case .restricted:
            self.alertMessage(for: optionType, from: viewController)
            
        default:
            break
        }
    }
    
    private func alertMessage(for optionType: MediaSupport, from vc: UIViewController) {
        switch optionType {
        case .camera:
            let message = NSLocalizedString("TAKE_PHOTO_MESSAGE", bundle: .module, comment: "Library access message")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.present(alert, animated: true, completion: nil)
        
        case .photoLibrary:
            let message = NSLocalizedString("CHOOSE_PHOTO_MESSAGE", bundle: .module, comment: "Library access message")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.present(alert, animated: true, completion: nil)
            
        case .file: break
        }
    }
    
    private func openCamera(from viewController: UIViewController) {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.pickerController.delegate = self
                self.pickerController.sourceType = .camera
                self.pickerController.allowsEditing = false
                viewController.present(self.pickerController, animated: true, completion: nil)
            }
        }
    }
    
    private func openPhotoLibrary(from viewController: UIViewController) {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.pickerController.delegate = self
                self.pickerController.sourceType = .photoLibrary
                
                viewController.present(self.pickerController, animated: true, completion: nil)
            }
        }
    }

    private func openDocumentPicker(from viewController: UIViewController) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.image", "public.data"], in: .import)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension MediaPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc public func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        var fileName = "filename.png"
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            fileName = url.lastPathComponent
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickedBlock?(MediaInfo(image: image, url: nil, filename: fileName))
        }
    }
    
}

extension MediaPickerManager: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        defer {
            controller.dismiss(animated: true, completion: nil)
        }

        if let url = urls.first {
            self.pickedBlock?(MediaInfo(image: nil, url: url, filename: url.lastPathComponent))
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
