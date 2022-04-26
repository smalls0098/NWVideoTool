//
//  Bundle+NWV.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/22.
//

import UIKit

private class BundleFinder {}

extension Bundle: NWVCompatible {}

internal extension NWVideoTool where Base: Bundle {
    
    static func NWVideoToolBundle(subPath: String?=nil) -> Bundle? {
        return normalModule(bundleName: "NWVideoTool", subPath: subPath) ?? spmModule(bundleName: "NWVideoTool_NWVideoTool", subPath: subPath)
    }
    
    static func normalModule(bundleName: String, subPath: String?=nil) -> Bundle? {
        var candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: NWV.self).resourceURL,
            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        #if SWIFT_PACKAGE
        // For SWIFT_PACKAGE.
        candidates.append(Bundle.module.bundleURL)
        #endif
        for candidate in candidates {
            var bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let subPath = subPath {
                bundlePath?.appendPathComponent(subPath)
            }
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return nil
    }
    
    static func spmModule(bundleName: String, subPath: String?=nil) -> Bundle? {
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,
            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        for candidate in candidates {
            var bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let subPath = subPath {
                bundlePath?.appendPathComponent(subPath)
            }
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return nil
    }
    
}
