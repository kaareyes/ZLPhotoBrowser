//
//  ZLPhotoModel.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos


public class ZLCameraAssetMode : NSObject {
    var image : UIImage?
    var videoURL : URL?
}

public extension ZLPhotoModel {
    
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
}

public class ZLPhotoModel: NSObject {
    
    public var ident: String
    public var isAsset : Bool
    public let asset: PHAsset?
    public var cameraAsset : ZLCameraAssetMode?
    public var type: ZLPhotoModel.MediaType = .unknown
    
    public var duration: String = ""
    
    public var isSelected: Bool = false
    
    private var pri_dataSize: ZLPhotoConfiguration.KBUnit?
    
    public var dataSize: ZLPhotoConfiguration.KBUnit? {
        guard let asset = self.asset else {return 0.0}
        if let pri_dataSize = pri_dataSize {
            return pri_dataSize
        }
        
        let size = ZLPhotoManager.fetchAssetSize(for: asset)
        pri_dataSize = size
        
        return size
    }
    
    private var pri_editImage: UIImage?
    
    public var editImage: UIImage? {
        set {
            pri_editImage = newValue
        }
        get {
            if let _ = editImageModel {
                return pri_editImage
            } else {
                return nil
            }
        }
    }
    
    public var second: ZLPhotoConfiguration.Second {
        guard type == .video, let asset = self.asset else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    public var whRatio: CGFloat {
        guard let asset = self.asset else {return 0.0}
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    public var previewSize: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        if whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, ZLMaxImageWidth) * scale
            let w = h * whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, ZLMaxImageWidth) * scale
            let h = w / whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    // Content of the last edit.
    public var editImageModel: ZLEditImageModel?
    
    
    public init(image : UIImage?, url : URL?) {
        ident =  UUID().uuidString
        isAsset = false
        self.asset = nil
        super.init()
    }
    
    public init(asset: PHAsset?) {
        ident =  UUID().uuidString
        self.asset = asset
        self.isAsset = asset != nil
        super.init()
        if let asset = self.asset {
            ident = asset.localIdentifier
            type = transformAssetType(for: asset)
            if type == .video {
                duration = transformDuration(for: asset)
            }
        }
    }
    
    public func transformAssetType(for asset: PHAsset) -> ZLPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if asset.zl.isGif {
                return .gif
            }
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}

public extension ZLPhotoModel {
    
    static func ==(lhs: ZLPhotoModel, rhs: ZLPhotoModel) -> Bool {
        return lhs.ident == rhs.ident
    }
    
}
