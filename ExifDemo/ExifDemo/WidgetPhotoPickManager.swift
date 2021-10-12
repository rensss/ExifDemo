//
//  WidgetPhotoPickManager.swift
//  BestWidget
//
//  Created by iMac on 2020/11/11.
//

import Foundation
import PhotosUI
typealias importImgDataBlock = (UIImage, _ url:URL?) -> ()
typealias importImgsDataBlock = ([UIImage]) -> ()


class WidgetPhotoPickManager: NSObject, PHPickerViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    static let sharedManager = WidgetPhotoPickManager()
    
    private override init() {
        
    }
    
    var importSingleImgBlock: importImgDataBlock?
    var importImgsBlock: importImgsDataBlock?
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    func imagePicker(limit: Int, _ editing: Bool = true)  {
        if limit == 1 {
            let picker = UIImagePickerController.init()
            picker.allowsEditing = editing
            picker.delegate = self
            if let viewController = UIWindow.xnkeyWindow()?.rootViewController {
                viewController.present(picker, animated: true, completion: nil)
            } else {
                debugPrint("UIViewController.topMost == nil")
            }
        } else {
            var config = PHPickerConfiguration.init()
            config.filter = PHPickerFilter.images
            config.selectionLimit = limit
            let picker = PHPickerViewController.init(configuration: config)
            picker.delegate = self
            if let viewController = UIWindow.xnkeyWindow()?.rootViewController {
                viewController.present(picker, animated: true, completion: nil)
            } else {
                debugPrint("UIViewController.topMost == nil")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.delegate = nil
            picker.dismiss(animated: true, completion: nil)
            
//            self.importSingleImgBlock?(self.zipNsdataWithImg(img: image, maxSize: 2000))
            
            self.importSingleImgBlock?(image, info[.imageURL] as? URL)
            self.importSingleImgBlock = nil
            
//            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [info[.referenceURL]], options: nil)
//            let asset = fetchResult.firstObject
//            print(asset?.location?.coordinate.latitude)
//            print(asset?.creationDate)

        } else {
            debugPrint("choose photo failure")
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
        
        if results.count == 0 {
            self.importSingleImgBlock = nil
        }
        
        if importImgsBlock != nil {
            
            var i = 0
            var imagesArray: [UIImage] = []
            if results.count > 0 {
                let semaphore = DispatchSemaphore.init(value: 0)
                results.forEach { (obj) in
                    if obj.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        obj.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                            if object is UIImage {
                                let image = object as! UIImage
                                imagesArray.append(self.zipNsdataWithImg(img: image, maxSize: 2000))
                            } else {
                                debugPrint("---- object isn't UIImage :: loadObject failure")
                            }
                            i += 1
                            debugPrint("---- i = \(i)")
                            if i == results.count {
                                semaphore.signal()
                            }
                        }
                    } else {
                        i += 1
                        debugPrint("---- itemProvider can't LoadObject ---- i = \(i)")
                        if i == results.count {
                            semaphore.signal()
                        }
                    }
                }
                
                semaphore.wait()
            }
            
            self.importImgsBlock?(Array(imagesArray.reversed()))
            self.importImgsBlock = nil
            
        } else {
            if ((results.first?.itemProvider.canLoadObject(ofClass: UIImage.self)) != nil) {
                results.first?.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if object is UIImage {
                        let image: UIImage = object as! UIImage
                        
                        self.importSingleImgBlock?(self.zipNsdataWithImg(img: image, maxSize: 2000), nil)
                        self.importSingleImgBlock = nil
                        
                    } else {
                        debugPrint("choose photo failure")
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
        if importImgsBlock != nil {
            self.importImgsBlock?([])
            self.importImgsBlock = nil
        } else {
            self.importSingleImgBlock = nil
        }
    }
    
    // MARK: 压缩图片
    func zipNsdataWithImg(img:UIImage, maxSize:Double) -> UIImage {
        let max:Double = maxSize
        // 进行图像尺寸的压缩
        let imageSize:CGSize = img.size
        var width:Double = Double(imageSize.width)
        var height:Double = Double(imageSize.height)
        // 1.宽高大于1280(宽高比不按照2来算，按照1来算)
        let scale = width/height
        if (width > max || height > max) && scale <= 1 {
            
            if width > height {
                let scale1 = height/width
                width = max
                height = width*scale1
            } else {
                let scale2 = width/height
                height = max
                width = height * scale2
            }
        } else if (width > max && height > max && scale > 1) {
            if width > height {
                let scale1 = width / height
                height = max
                width = height * scale1
            } else {
                let scale2 = height / width
                width = max
                height = width * scale2
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: Int(width), height: Int(height)), false, img.scale)
        img.draw(in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIWindow {
    
    /// 获取keywindow
    class func xnkeyWindow() -> UIWindow? {
        let keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow
    }

}
