//
//  NWVideoTool.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/22.
//

import Foundation

internal class NWV: NSObject {
    
}

internal struct NWVideoTool<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

internal protocol NWVCompatible {}

internal extension NWVCompatible {
    
    static var nwv: NWVideoTool<Self>.Type {
        set {}
        get { NWVideoTool<Self>.self }
    }
    
    var nwv: NWVideoTool<Self> {
        set {}
        get { NWVideoTool(self) }
    }
    
}
