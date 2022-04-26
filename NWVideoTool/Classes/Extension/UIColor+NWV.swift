//
//  UIColor.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/22.
//

import UIKit

extension UIColor: NWVCompatible {}

internal extension NWVideoTool where Base: UIColor {
    
    /// hex 色值
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let tempStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexint = intFromHexString(tempStr)
        let color = UIColor(red: ((CGFloat)   ((hexint & 0xFF0000) >> 16 )) / 255,
                            green: ((CGFloat) ((hexint & 0x00FF00) >> 8) )  / 255,
                            blue: ((CGFloat)  (hexint  & 0x0000FF)       )  / 255,
                            alpha: alpha)
        return color
    }
    
    /// 从Hex装换int
    private static func intFromHexString(_ hexString: String) -> UInt32 {
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var result : UInt32 = 0
        scanner.scanHexInt32(&result)
        return result
    }
    
}
