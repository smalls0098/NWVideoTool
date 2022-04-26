//
//  NWImageStickerView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

public class NWImageStickerView: NWStickerItemView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = nil
        imageView.image = imageSticker
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleToFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    
    private lazy var btnDelete: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.nwv.getBundleImage("sticker_close")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRemove)))
        return btn
    }()
    
    private lazy var btnAdjust: UIImageView = {
        let btn = UIImageView()
        btn.image = UIImage.nwv.getBundleImage("sticker_adjust")
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onAdjust(recognizer:))))
        return btn
    }()
    
    /// 贴图ID
    public private(set) var stickerId: Int = 0
    /// 贴图图片
    public private(set) var imageSticker: UIImage = UIImage()
    
    /// 是否初始化
    private var isInit = false
    /// 图片宽高比例
    private var scale: CGFloat = .zero
    /// 默认大小
    private lazy var defaultSize: CGSize = {
        let defaultWidth: CGFloat = 100
        var size = CGSize.zero
        size.width = defaultWidth
        size.height = defaultWidth/scale
        return size
    }()
    /// 最小贴图大小
    private lazy var minStickerSize: CGSize = {
        let min: CGFloat = 30
        var size = CGSize.zero
        size.width = min
        size.height = min/scale
        return size
    }()
    /// 三角角度
    private lazy var deltaAngle: CGFloat = {
        return atan2(self.frame.origin.y+self.frame.height-self.center.y,
                     self.frame.origin.x+self.frame.width-self.center.x)
    }()
    /// 是否选中
    public override var selected: Bool {
        didSet {
            self.btnDelete.isHidden = !selected
            self.btnAdjust.isHidden = !selected
            self.imageView.layer.borderWidth = selected ? 1 : 0
            if self.selected {
                NSLog("stickerId : %d is On", self.stickerId)
            }
            if !self.selected {
                self.delegate?.endEditStickerView(view: self)
            }
        }
    }
    /// 调整-开始触摸位置
    private var adjustTouchStart: CGPoint = .zero
    /// 移动-开始触摸位置
    private var moveTouchStart: CGPoint = .zero
    
    public init(stickerId: Int, image: UIImage) {
        super.init(frame: .zero)
        self.stickerId = stickerId
        self.imageSticker = image
        self.scale = image.size.width / image.size.height
        self.setupLayouts()
        self.selected = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NWImageStickerView {
    
    private func setupLayouts() {
        self.addSubview(self.imageView)
        self.addSubview(self.btnDelete)
        self.addSubview(self.btnAdjust)
        
        self.backgroundColor = nil
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapView(recognizer:))))
        self.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(onRotation(recognizer:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onMove(recognizer:))))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.isInit {
            self.frame = .init(origin: .zero, size: self.defaultSize)
            if let superview = self.superview {
                self.center = CGPoint.init(x: superview.frame.width / 2, y: superview.frame.height / 2)
            }
            self.isInit = true
        }
        
        let imageWidth: CGFloat = 26
        self.btnDelete.frame = CGRect(x: 0-imageWidth/3,
                                      y: 0-imageWidth/3,
                                      width: imageWidth,
                                      height: imageWidth)
        
        self.btnAdjust.frame = CGRect(x: self.bounds.width-(imageWidth-imageWidth/3),
                                      y: self.bounds.height-(imageWidth-imageWidth/3),
                                      width: imageWidth,
                                      height: imageWidth)
    }
    
}


extension NWImageStickerView {
    
    @objc private func onRemove() {
        self.removeFromSuperview()
        self.delegate?.removeStickerView(view: self)
    }
    
    @objc private func onAdjust(recognizer: UIPanGestureRecognizer) {
        // 不是选中的不能进行调整
        if !self.selected {
            return
        }
        if recognizer.state == .began {
            self.adjustTouchStart = recognizer.location(in: self)
        } else if recognizer.state == .cancelled || recognizer.state == .ended {
            self.adjustTouchStart = .zero
        } else if recognizer.state == .changed {
            if self.bounds.width < minStickerSize.width || self.bounds.height < minStickerSize.height {
                // 防止图片被缩小太多
                self.bounds = CGRect(x: self.bounds.origin.x,
                                     y: self.bounds.origin.y,
                                     width: minStickerSize.width+1,
                                     height: minStickerSize.height+1)
                self.adjustTouchStart = recognizer.location(in: self)
                return
            } else {
                // 调整大小
                let point = recognizer.location(in: self)
                var wChange: CGFloat = 0, hChange: CGFloat = 0
                 wChange = point.x - self.adjustTouchStart.x
                 let wRatioChange = wChange/self.bounds.width
                 hChange = wRatioChange*self.bounds.height
                if abs(wChange) > 50 || abs(hChange) > 50 {
                    self.adjustTouchStart = recognizer.location(ofTouch: 0, in: self)
                    return
                }
                var finalWidth = self.bounds.width + wChange
                var finalHeight = self.bounds.height + hChange
                let height = defaultSize.width / scale
                if finalWidth > defaultSize.width*(1+2) {
                    finalWidth = defaultSize.width*(1+2)
                }
                if finalWidth < defaultSize.width*(1-2) {
                    finalWidth = defaultSize.width*(1-2)
                }
                if finalHeight > height*(1+2) {
                    finalHeight = height*(1+2)
                }
                if finalHeight < height*(1-2) {
                    finalHeight = height*(1-2)
                }
                self.bounds = CGRect.init(x: self.bounds.origin.x,
                                          y: self.bounds.origin.y,
                                          width: finalWidth,
                                          height: finalHeight)
                self.adjustTouchStart = recognizer.location(ofTouch: 0, in: self)
            }
            /* 回转 */
            let ang = atan2(recognizer.location(in: self.superview).y-self.center.y,
                            recognizer.location(in: self.superview).x-self.center.x)
            let angleDiff = deltaAngle - ang
            self.transform = CGAffineTransform.init(rotationAngle: -angleDiff)
        }
    }
    
    
    @objc private func onRotation(recognizer: UIRotationGestureRecognizer) {
        self.transform = self.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
        self.selected = true
        self.delegate?.toFirstStickerView(view: self)
    }
    
    @objc private func onTapView(recognizer: UITapGestureRecognizer) {
        self.selected = true
        self.delegate?.toFirstStickerView(view: self)
    }
    
    
    @objc private func onMove(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.selected = true
            self.delegate?.toFirstStickerView(view: self)
            self.moveTouchStart = recognizer.location(in: self.superview)
        } else if recognizer.state == .cancelled || recognizer.state == .ended {
            self.moveTouchStart = .zero
        } else if recognizer.state == .changed {
            // 不是选中的不能进行调整
            if !self.selected {
                return
            }
            let touchLocation = recognizer.location(in: self)
            if btnAdjust.frame.contains(touchLocation) {
                return
            }
            let touchPoint = recognizer.location(in: self.superview)
            var newCenter = CGPoint.init(x: self.center.x + touchPoint.x - moveTouchStart.x,
                                         y: self.center.y + touchPoint.y - moveTouchStart.y)
            let midPointX = self.bounds.midX
            let midPointY = self.bounds.midY
            // 确保不会导致视图移出屏幕
            if let superView = self.superview {
                if newCenter.x > superView.bounds.width - midPointX {
                    newCenter.x = superView.bounds.width - midPointX
                }
            }
            if newCenter.x < midPointX {
                newCenter.x = midPointX
            }
            if let superView = self.superview {
                if newCenter.y > superView.bounds.height - midPointY {
                    newCenter.y = superView.bounds.height - midPointY
                }
            }
            if newCenter.y < midPointY {
                newCenter.y = midPointY
            }
            // 确保不会导致视图移出屏幕
            self.center = newCenter
            self.moveTouchStart = touchPoint
        }
    }
    
}
