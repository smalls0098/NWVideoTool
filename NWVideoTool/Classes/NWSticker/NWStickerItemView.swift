//
//  NWStickerItemView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

public protocol NWStickerItemViewDelegate: AnyObject {
    func toFirstStickerView(view: NWStickerItemView)
    func removeStickerView(view: NWStickerItemView)
    func endEditStickerView(view: NWStickerItemView)
}

open class NWStickerItemView: UIView {
    
    /// 代理
    open weak var delegate: NWStickerItemViewDelegate? = nil
    
    /// 是否选中
    open var selected: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
