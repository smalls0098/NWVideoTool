//
//  UIImage+NWV.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/22.
//

import UIKit

extension UIImage: NWVCompatible {
    /// 转换为正方形
    func convertToSquare() -> UIImage? {
        let length = min(size.width, size.height)
        let cgImage = cgImage
        let centerX = size.width / 2
        let centerY = size.height / 2
        let rect = CGRect(x: centerX - (length / 2),
                          y: centerY - (length / 2),
                          width: length,
                          height: length)
        let newCgImage = cgImage?.cropping(to: rect)
        guard newCgImage != nil else {
            return nil
        }
        return UIImage(cgImage: newCgImage!)
    }
    
    /// 缩放到大小
    func scaleToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
}

internal extension NWVideoTool where Base: UIImage {
    
    static func getBundleImage(_ named: String, _ path: String?=nil) -> UIImage? {
        let bundle = Bundle.nwv.NWVideoToolBundle(subPath: path)
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
    
}
