//
//  NWStickerView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

public protocol NWStickerViewDelegate: AnyObject {
    func refreshStickerView(view: UIView)
}

public class NWStickerView: UIView {
    
    public weak var delegate: NWStickerViewDelegate? = nil
    
    /// 贴图集合
    public var stackerViews: [NWStickerItemView] = []
    /// 当前贴图
    public var currentStickerView: NWStickerItemView? {
        didSet {
            guard let currentStickerView = currentStickerView else {return}
            self.bringSubviewToFront(currentStickerView)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds=true
        isUserInteractionEnabled=true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(recognizer:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func addStickerImage(image: UIImage) {
        self.clearAllSelected()
        let imageStickerView = NWImageStickerView.init(stickerId: self.stackerViews.count+1,
                                                       image: image)
        imageStickerView.delegate = self
        self.currentStickerView = imageStickerView
        self.addSubview(imageStickerView)
        self.stackerViews.append(imageStickerView)
    }
    
    /// 清除所有
    public func clearAllSelected() {
        self.currentStickerView?.selected = false
        self.stackerViews.forEach { it in
            it.selected = false
        }
    }
    
}

extension NWStickerView: NWStickerItemViewDelegate {
    
    public func toFirstStickerView(view: NWStickerItemView) {
        if self.currentStickerView == nil {
            self.currentStickerView = view
        } else {
            if self.currentStickerView! == view {
                return
            }
            self.currentStickerView?.selected = false
            self.currentStickerView = view
        }
    }
    
    public func removeStickerView(view: NWStickerItemView) {
        stackerViews.removeAll(where: {$0 == view})
    }
    
    public func endEditStickerView(view: NWStickerItemView) {
        self.delegate?.refreshStickerView(view: view)
    }
    
}


extension NWStickerView {
    
    @objc private func onTap(recognizer: UITapGestureRecognizer) {
        self.clearAllSelected()
        self.currentStickerView = nil
    }

}
