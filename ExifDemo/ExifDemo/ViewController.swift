//
//  ViewController.swift
//  ExifDemo
//
//  Created by Rzk on 2021/9/28.
//

import UIKit
import ImageIO
import Photos
import TZImagePickerController

class ViewController: UIViewController {
    
    var imageUrl: URL?
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(selectBtn)
        selectBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        selectBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 60)
        selectBtn.autoSetDimensions(to: CGSize(width: 100, height: 50))
        
        view.addSubview(analyzeBtn)
        analyzeBtn.autoAlignAxis(.vertical, toSameAxisOf: selectBtn, withOffset: 0)
        analyzeBtn.autoPinEdge(.top, to: .bottom, of: selectBtn, withOffset: 40)
        analyzeBtn.autoSetDimensions(to: CGSize(width: 100, height: 50))
        
        view.addSubview(fetchBtn)
        fetchBtn.autoAlignAxis(.vertical, toSameAxisOf: selectBtn, withOffset: 0)
        fetchBtn.autoPinEdge(.top, to: .bottom, of: analyzeBtn, withOffset: 40)
        fetchBtn.autoSetDimensions(to: CGSize(width: 100, height: 50))
        
        view.addSubview(textView)
        textView.autoPinEdge(.top, to: .top, of: selectBtn)
        textView.autoPinEdge(.bottom, to: .bottom, of: fetchBtn)
        textView.autoPinEdge(.left, to: .right, of: selectBtn, withOffset: 15)
        textView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        
        view.addSubview(imageView)
        imageView.autoPinEdge(.top, to: .bottom, of: textView, withOffset: 30)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 50)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
    }
    
    // MARK:- func
    func analyzeImage(image: UIImage) {
        if let url = imageUrl as CFURL? {
            if let source = CGImageSourceCreateWithURL(url, nil) {
                if let imageInfo = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as Dictionary? {
                    print("imageInfo \n \(imageInfo)")
                    self.textView.text = imageInfo.description
                }
            }
        }
        if let data = image.jpegData(compressionQuality: 1.0) {
            self.textView.text = analyzeImage(imageData: data)
        }
    }
    
    func analyzeImage(imageData: Data) -> String? {
        var descriptionStr: String?
        let startTime = CFAbsoluteTimeGetCurrent()
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
            if let imageInfo = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as Dictionary? {
                let endTime = CFAbsoluteTimeGetCurrent()
                print("---- analyzeImage 代码执行时长：\(endTime - startTime) 毫秒")
                print("imageInfo \n \(imageInfo)")
                descriptionStr = imageInfo.description
//                NSDictionary *exifDic = (__bridge NSDictionary *)CFDictionaryGetValue(imageInfo, kCGImagePropertyExifDictionary);
                let exifDic = imageInfo[NSString(string: "{Exif}")]
                print("{Exif} \n \(exifDic as Any)")
            }
        }
        return descriptionStr
    }
    
    func findOriginalImage(_ asset: PHAsset) {
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .opportunistic
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOption) { image, dictionary in
            self.imageView.image = image
            print("dictionary \n \(dictionary as Any)")
        }
    }
    
    func findOriginalImageData(_ asset: PHAsset) {
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .opportunistic
        
        let startTime = CFAbsoluteTimeGetCurrent()
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOption) { imageData, uti, orientation, dictionary in
            let endTime = CFAbsoluteTimeGetCurrent()
            print("---- requestImageData 代码执行时长：\(endTime - startTime) 毫秒")
            
            if let imageData = imageData {
                self.imageView.image = UIImage(data: imageData)
                self.imageData = imageData
            }
            print("uti \n \(uti as Any)")
            
            // CGImagePropertyOrientation
            print("orientation \n \(orientation.rawValue)")

//            print(dictionary as Any)
        }
    }
    
    func getAllAssetWithAscending(_ ascending: Bool) -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: ascending)
        allPhotosOptions.sortDescriptors = [sort]
        let allAsset = PHAsset.fetchAssets(with: allPhotosOptions)
        return allAsset
    }
    
    // MARK:- event
    @objc func selectClick() {
//        WidgetPhotoPickManager.sharedManager.importSingleImgBlock = { [unowned self] image, url in
//            self.imageView.image = image
//            self.imageUrl = url
//            self.imageData = nil
//        }
//        WidgetPhotoPickManager.sharedManager.imagePicker(limit: 1, false)
        
        if let imagePickerVc = TZImagePickerController(maxImagesCount: 1, delegate: self) {
            imagePickerVc.didFinishPickingPhotosHandle = { [weak self] photos, assets, isOriginal in
                if let asset = assets?.first as? PHAsset {
                    self?.findOriginalImageData(asset)
                }
            }
            self.present(imagePickerVc, animated: true, completion: nil)
        }
    }
    
    @objc func analyzeClick() {
        if let data = imageData {
            self.textView.text = self.analyzeImage(imageData: data)
            return
        }
        
        if let image = self.imageView.image {
            analyzeImage(image: image)
        } else {
            if let bundlePath = Bundle.main.path(forResource: "IMG_7607", ofType: "HEIC"), let image = UIImage(contentsOfFile: bundlePath) {
                imageView.image = image
                analyzeImage(image: image)
            }
        }
    }
    
    @objc func fetchClick() {
        let all = getAllAssetWithAscending(false)
        if let asset = all.firstObject {
//            findOriginalImage(asset)
            findOriginalImageData(asset)
        }
    }
    
    // MARK:- lazy
    lazy var selectBtn: UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor.withRandom()
        b.setTitle("select", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(selectClick), for: .touchUpInside)
        return b
    }()
    
    lazy var analyzeBtn: UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor.withRandom()
        b.setTitle("analyze", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(analyzeClick), for: .touchUpInside)
        return b
    }()
    
    lazy var fetchBtn: UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor.withRandom()
        b.setTitle("fetch last", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(fetchClick), for: .touchUpInside)
        return b
    }()
    
    lazy var imageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    lazy var textView: UITextView = {
        let t = UITextView()
        t.isEditable = false
        return t
    }()
    
}

extension ViewController: TZImagePickerControllerDelegate {
    
}
