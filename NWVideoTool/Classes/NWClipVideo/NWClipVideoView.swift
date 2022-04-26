//
//  NWClipVideoView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

public class NWClipVideoView: UIView {
    
    /// 裁剪叠加视图
    private lazy var overlayView: NWClipOverlayView = {
        return NWClipOverlayView()
    }()
    
    /// 是否初始化
    private var isInit = false
    /// 开始拖动的点
    public private(set) var touchStart: CGPoint = .zero
    /// 平移边缘
    private var panEdge: NWClipVideoView.ClipPanEdge = .none
    /// 最小剪辑大小
    private var minClipSize = CGSize(width: 70, height: 70)
    /// 选择的比例
    public var selectedScale: CGFloat = .zero {
        didSet {
            updateScaleFrame()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.overlayView)
        self.initData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initData() {
        self.isUserInteractionEnabled = true
        let gest = UIPanGestureRecognizer(target: self, action: #selector(onPanOverlayView(gest:)))
        self.addGestureRecognizer(gest)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.isInit {
            let frame = CGRect(x: self.frame.width/4,
                               y: self.frame.height/4,
                               width: self.frame.width/2,
                               height: self.frame.height/2)
            self.overlayView.frame = frame
            self.isInit = true
        }
    }
    
    private func updateScaleFrame() {
        var frame = self.overlayView.frame
        if self.selectedScale == 0 {
            frame.origin = .init(x: self.frame.width/4,
                                 y: self.frame.height/4)
            frame.size = .init(width: self.frame.width/2,
                               height: self.frame.height/2)
        } else {
            let size = reScale(videoSize: self.frame.size,
                               scale: selectedScale)
            let fitSize = aspectFit(videoSize: size,
                                    boundingSize: .init(width: self.frame.width/2,
                                                        height: self.frame.height/2),
                                             scale: 1)
            frame.origin = .init(x: (self.frame.width-fitSize.width)/2, y: (self.frame.height-fitSize.height)/2)
            frame.size = .init(width: fitSize.width, height: fitSize.height)
        }
        self.overlayView.frame = frame
    }
    
    public func location() -> CGRect {
        return self.overlayView.frame
    }
    
}


extension NWClipVideoView {
    
    enum ClipPanEdge {
        case none
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    @objc private func onPanOverlayView(gest: UIPanGestureRecognizer) {
        if gest.state == .began {
            self.touchStart = gest.location(in: self)
            self.panEdge = calculatePanEdge(at: self.touchStart)
        } else if gest.state == .cancelled || gest.state == .ended {
            self.panEdge = .none
        } else if gest.state == .changed  {
            guard self.panEdge != .none else {
                // 移动
                let touch = gest.location(in: self)
                self.translateUsingTouchLocation(touch)
                self.touchStart = touch
                return
            }
            // 放大-缩小
            self.updateClipFrame(at: gest.location(in: self))
        }
    }
    
    private func updateClipFrame(at point: CGPoint) {
        var newPoint = point
        newPoint.x = min(self.frame.maxX, newPoint.x)
        newPoint.y = min(self.frame.maxY, newPoint.y)
        
        var frame = self.overlayView.frame
        let diffX = ceil(newPoint.x - self.touchStart.x)
        let diffY = ceil(newPoint.y - self.touchStart.y)
        let selectedScale = self.selectedScale
        switch self.panEdge {
        case .none:
            break
        case .top:
            frame.origin.y = frame.minY + diffY
            frame.size.height = frame.height - diffY
            if selectedScale != 0 {
                frame.size.width = frame.width - diffY * selectedScale
            }
            break
        case .bottom:
            frame.size.height = frame.height + diffY
            if selectedScale != 0 {
                frame.size.width = frame.width + diffY * selectedScale
            }
            break
        case .left:
            frame.size.width = frame.width - diffX
            frame.origin.x = frame.origin.x + diffX
            if selectedScale != 0 {
                frame.size.height = frame.height - diffX / selectedScale
            }
            break
        case .right:
            frame.size.width = frame.width + diffX
            if selectedScale != 0 {
                frame.size.height = frame.height + diffX / selectedScale
            }
            break
        case .topLeft:
            if selectedScale != 0 {
                frame.origin.x = frame.minX + diffX
                frame.size.width = frame.width - diffX
                frame.origin.y = frame.minY + diffX / selectedScale
                frame.size.height = frame.height - diffX / selectedScale
            } else {
                frame.origin.x = frame.minX + diffX
                frame.size.width = frame.width - diffX
                frame.origin.y = frame.minY + diffY
                frame.size.height = frame.height - diffY
            }
            break
        case .topRight:
            if selectedScale != 0 {
                frame.size.width = frame.width + diffX
                frame.origin.y = frame.minY - diffX / selectedScale
                frame.size.height = frame.height + diffX / selectedScale
            } else {
                frame.size.width = frame.width + diffX
                frame.origin.y = frame.minY + diffY
                frame.size.height = frame.height - diffY
            }
            break
        case .bottomLeft:
            if selectedScale != 0 {
                frame.origin.x = frame.minX + diffX
                frame.size.width = frame.width - diffX
                frame.size.height = frame.height - diffX / selectedScale
            } else {
                frame.origin.x = frame.minX + diffX
                frame.size.width = frame.width - diffX
                frame.size.height = frame.height + diffY
            }
            break
        case .bottomRight:
            if selectedScale != 0 {
                frame.size.width = frame.width + diffX
                frame.size.height = frame.height + diffX / selectedScale
            } else {
                frame.size.width = frame.width + diffX
                frame.size.height = frame.height + diffY
            }
            break
        }
        
        let minSize: CGSize
        let maxSize: CGSize
        let maxClipFrame: CGRect
        if selectedScale != 0 {
            if selectedScale >= 1 {
                minSize = CGSize(width: self.minClipSize.height * selectedScale, height: self.minClipSize.height)
            } else {
                minSize = CGSize(width: self.minClipSize.width, height: self.minClipSize.width / selectedScale)
            }
            if selectedScale > self.frame.width / self.frame.height {
                maxSize = CGSize(width: self.frame.width, height: self.frame.width / selectedScale)
            } else {
                maxSize = CGSize(width: self.frame.height * selectedScale, height: self.frame.height)
            }
            maxClipFrame = CGRect(origin: CGPoint(x: self.frame.minX + (self.frame.width-maxSize.width)/2,
                                                  y: self.frame.minY + (self.frame.height-maxSize.height)/2),
                                  size: maxSize)
        } else {
            minSize = self.minClipSize
            maxSize = self.frame.size
            maxClipFrame = self.frame
        }
        frame.size.width = min(maxSize.width, max(minSize.width, frame.size.width))
        frame.size.height = min(maxSize.height, max(minSize.height, frame.size.height))
        frame.origin.x = min(maxClipFrame.maxX-minSize.width, max(frame.origin.x, maxClipFrame.minX))
        frame.origin.y = min(maxClipFrame.maxY-minSize.height, max(frame.origin.y, maxClipFrame.minY))
        
        if (self.panEdge == .topLeft || self.panEdge == .bottomLeft || self.panEdge == .left) &&
            frame.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = frame.maxX - minSize.width
        }
        if (self.panEdge == .topLeft || self.panEdge == .topRight || self.panEdge == .top) &&
            frame.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = frame.maxY - minSize.height
        }
        
        if frame.origin.x+frame.width > self.frame.maxX {
            frame.size.width = self.frame.maxX - frame.origin.x
        }
        if frame.origin.y+frame.height > self.frame.maxY {
            frame.size.height = self.frame.maxY - frame.origin.y
        }

        self.overlayView.frame = frame
        self.touchStart = newPoint
    }
    
    private func calculatePanEdge(at point: CGPoint) -> NWClipVideoView.ClipPanEdge {
        let frame = self.overlayView.frame.insetBy(dx: -20, dy: -20)
        
        let cornerSize = CGSize(width: 40, height: 40)
        let topLeftRect = CGRect(origin: frame.origin, size: cornerSize)
        if topLeftRect.contains(point) {
            return .topLeft
        }
        
        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX-cornerSize.width, y: frame.minY), size: cornerSize)
        if topRightRect.contains(point) {
            return .topRight
        }
        
        let bottomLeftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY-cornerSize.height), size: cornerSize)
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }
        
        let bottomRightRect = CGRect(origin: CGPoint(x: frame.maxX-cornerSize.width, y: frame.maxY-cornerSize.height), size: cornerSize)
        if bottomRightRect.contains(point) {
            return .bottomRight
        }
        
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: cornerSize.height))
        if topRect.contains(point) {
            return .top
        }
        
        let bottomRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY-cornerSize.height), size: CGSize(width: frame.width, height: cornerSize.height))
        if bottomRect.contains(point) {
            return .bottom
        }
        
        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: cornerSize.width, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }
        
        let rightRect = CGRect(origin: CGPoint(x: frame.maxX-cornerSize.width, y: frame.minY), size: CGSize(width: cornerSize.width, height: frame.height))
        if rightRect.contains(point) {
            return .right
        }
        
        return .none
    }
    
    private func translateUsingTouchLocation(_ touchPoint: CGPoint) {
        let frame = self.overlayView.frame
        var newPoint = CGPoint.init(x: frame.origin.x + touchPoint.x - touchStart.x,
                                    y: frame.origin.y + touchPoint.y - touchStart.y)
        // 确保不会导致视图移出屏幕
        let minX = self.frame.minX
        let minY = self.frame.minY
        newPoint.x = min(self.frame.width - frame.width - minX, max(minX, newPoint.x))
        newPoint.y = min(self.frame.height - frame.height - minY, max(minY, newPoint.y))
        // 确保不会导致视图移出屏幕
        self.overlayView.frame = .init(origin: newPoint, size: self.overlayView.frame.size)
    }
    
    
}

extension NWClipVideoView {
    
    func aspectFit(videoSize: CGSize, boundingSize: CGSize, scale: CGFloat = 1.0) -> CGSize {
        var size = CGSize.init(width: boundingSize.width, height: boundingSize.height)
        let mW = boundingSize.width / videoSize.width
        let mH = (boundingSize.height / videoSize.height) * scale
        if( mH < mW ) {
            size.width = boundingSize.height / videoSize.height * videoSize.width
        }
        else if( mW < mH ) {
            size.height = boundingSize.width / videoSize.width * videoSize.height
        }
        size.width = size.width * scale
        size.height = size.height * scale
        return size
    }
    
    func aspectFill(videoSize: CGSize, boundingSize: CGSize, scale: CGFloat = 1.0) -> CGSize {
        var size = CGSize.init(width: boundingSize.width, height: boundingSize.height)
        let mW = boundingSize.width / videoSize.width
        let mH = boundingSize.height / videoSize.height
        if( mH > mW ) {
            size.width = (boundingSize.height / videoSize.height * videoSize.width) * scale
        } else if ( mW > mH ) {
            size.height = (boundingSize.width / videoSize.width * videoSize.height) * scale
        }
        return size
    }
    
    func reScale(videoSize: CGSize, scale: CGFloat=1.0) -> CGSize {
        var size = CGSize.init(width: videoSize.width,
                               height: videoSize.height)
        if scale > 2 {
            return size
        }
        if scale <= 1 {
            if videoSize.height >= videoSize.width {
                size.width = videoSize.height
                size.height = size.height / scale
            }else if videoSize.height < videoSize.width {
                size.height = videoSize.width
                size.width = videoSize.width / scale
            }
        } else {
            if videoSize.height >= videoSize.width {
                size.height = videoSize.height
                size.width = size.height * scale
            }else if videoSize.height < videoSize.width {
                size.width = videoSize.width
                size.height = videoSize.width * scale
            }
        }
        return size
    }
    
}
