//
//  NWRemoveWaterView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/21.
//

import UIKit

public class NWRemoveWaterView: UIView {
    
    private var blockViews: [NWRemoveWaterBlockView] = []
    private var currentBlock: NWRemoveWaterBlockView?
    
    private var minClipSize = CGSize(width: 20, height: 20)
    private var touchViewIndex = -1
    private var isNewView = false
    private var panEdge = NWRemoveWaterView.DragPanEdge.none
    private var touchStart: CGPoint = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds=true
        isUserInteractionEnabled=true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(recognizer:)))
        addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(recognizer:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func locations() -> [CGRect] {
        var ret: [CGRect] = []
        blockViews.forEach { block in
            ret.append(block.frame)
        }
        return ret
    }
    
}

extension NWRemoveWaterView: NWRemoveWaterBlockViewDelegate {
    
    func onShowView(blockView: NWRemoveWaterBlockView) {
        blockViews.forEach { view in
            view.hidePointAndClose()
            if view == blockView {
                blockView.showPointAndClose()
            }
        }
    }
    
    func onRemoveView(blockView: NWRemoveWaterBlockView) {
        blockViews.removeAll(where: {$0 == blockView})
    }
    
}

extension NWRemoveWaterView {
    
    enum DragPanEdge {
        case none
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    @objc private func onTap(recognizer: UITapGestureRecognizer) {
        let touch = recognizer.location(in: self)
        var blockView: NWRemoveWaterBlockView?
        for (_, block) in self.blockViews.reversed().enumerated() {
            let frame = block.frame.insetBy(dx: -10, dy: -10)
            if frame.contains(touch) {
                blockView = block
            }
        }
        guard let blockView = blockView else {
            self.blockViews.forEach { view in
                view.hidePointAndClose()
            }
            return
        }
        let panEdge = self.calculatePanEdge(at: touch, blockView: blockView)
        if panEdge != .topRight {
            self.blockViews.forEach { view in
                view.hidePointAndClose()
            }
            return
        }
        self.onShowView(blockView: blockView)
        self.onRemoveView(blockView: blockView)
        blockView.removeFromSuperview()
    }
    
    @objc private func onPan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            blockViews.forEach { view in
                view.hidePointAndClose()
            }
            self.touchStart = recognizer.location(in: self)
            (self.touchViewIndex, self.isNewView) = self.touchBlockView(at: self.touchStart, blocksView: self.blockViews)
            if self.touchViewIndex > -1 {
                self.panEdge = self.calculatePanEdge(at: self.touchStart,
                                                     blockView: self.blockViews[self.touchViewIndex])
            }
        } else if recognizer.state == .cancelled || recognizer.state == .ended {
            self.blockViews[touchViewIndex].showClose()
            self.touchStart = .zero
            self.touchViewIndex = -1
            self.panEdge = .none
            self.isNewView = false
        } else if recognizer.state == .changed  {
            // 新加
            if self.touchViewIndex == -1 {
                return
            }
            guard self.panEdge != .none else {
                // 移动
                let touch = recognizer.location(in: self)
                self.translateUsingTouchLocation(touch,
                                                 touchStart: self.touchStart,
                                                 touchViewIndex: self.touchViewIndex)
                self.touchStart = touch
                return
            }
            // 判断是否是新创建的
            if isNewView {
                let tran = recognizer.translation(in: self)
                let x = abs(tran.x)
                let y = abs(tran.y)
                if max(x, y) < 10 {
                    self.touchStart = recognizer.location(in: self)
                    return
                }
                if (tran.x<0 && tran.y<0) {
                    self.panEdge = .topLeft
                }
                if (tran.x<0 && tran.y>0) {
                    self.panEdge = .bottomLeft
                }
                if (tran.x>0 && tran.y<0) {
                    self.panEdge = .topRight
                }
                if (tran.x>0 && tran.y>0) {
                    self.panEdge = .bottomRight
                }
            }
            
            // 放大-缩小
            self.updateClipFrame(at: recognizer.location(in: self),
                                 touchStart: self.touchStart,
                                 touchViewIndex: self.touchViewIndex)
        }
    }
    
    private func updateClipFrame(at point: CGPoint, touchStart: CGPoint, touchViewIndex: Int) {
        var newPoint = point
        newPoint.x = min(self.frame.maxX, newPoint.x)
        newPoint.y = min(self.frame.maxY, newPoint.y)
        
        var frame = blockViews[touchViewIndex].frame
        let diffX = ceil(newPoint.x - self.touchStart.x)
        let diffY = ceil(newPoint.y - self.touchStart.y)
        switch self.panEdge {
        case .none:
            break
        case .topLeft:
            frame.origin.x = frame.minX + diffX
            frame.size.width = frame.width - diffX
            frame.origin.y = frame.minY + diffY
            frame.size.height = frame.height - diffY
            break
        case .topRight:
            frame.size.width = frame.width + diffX
            frame.origin.y = frame.minY + diffY
            frame.size.height = frame.height - diffY
            break
        case .bottomLeft:
            frame.origin.x = frame.minX + diffX
            frame.size.width = frame.width - diffX
            frame.size.height = frame.height + diffY
            break
        case .bottomRight:
            frame.size.width = frame.width + diffX
            frame.size.height = frame.height + diffY
            break
        }
        
        let minSize: CGSize = self.minClipSize
        let maxSize: CGSize = self.frame.size
        let maxClipFrame: CGRect =  self.frame
        frame.size.width = min(maxSize.width, max(minSize.width, frame.size.width))
        frame.size.height = min(maxSize.height, max(minSize.height, frame.size.height))
        frame.origin.x = min(maxClipFrame.maxX-minSize.width, max(frame.origin.x, maxClipFrame.minX))
        frame.origin.y = min(maxClipFrame.maxY-minSize.height, max(frame.origin.y, maxClipFrame.minY))
        if (self.panEdge == .topLeft || self.panEdge == .bottomLeft) &&
            frame.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = frame.maxX - minSize.width
        }
        if (self.panEdge == .topLeft || self.panEdge == .topRight) &&
            frame.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = frame.maxY - minSize.height
        }
        
        if frame.origin.x+frame.width > self.frame.maxX {
            frame.size.width = self.frame.maxX - frame.origin.x
        }
        if frame.origin.y+frame.height > self.frame.maxY {
            frame.size.height = self.frame.maxY - frame.origin.y
        }

        blockViews[touchViewIndex].frame = frame
        self.touchStart = newPoint
    }
    
    private func translateUsingTouchLocation(_ touchPoint: CGPoint, touchStart: CGPoint, touchViewIndex: Int) {
        let frame = self.blockViews[touchViewIndex].frame
        var newPoint = CGPoint.init(x: frame.origin.x + touchPoint.x - touchStart.x,
                                    y: frame.origin.y + touchPoint.y - touchStart.y)
        // 确保不会导致视图移出屏幕
        let minX = self.frame.minX
        let minY = self.frame.minY
        newPoint.x = min(self.frame.width - frame.width - minX, max(minX, newPoint.x))
        newPoint.y = min(self.frame.height - frame.height - minY, max(minY, newPoint.y))
        // 确保不会导致视图移出屏幕
        self.blockViews[touchViewIndex].frame = .init(origin: newPoint, size: self.blockViews[touchViewIndex].frame.size)
    }
    
    
    private func touchBlockView(at: CGPoint, blocksView: [NWRemoveWaterBlockView]) -> (Int, Bool) {
        if blocksView.isEmpty {
            return (makeBlockView(at: at), true)
        }
        for (index, blockView) in blocksView.reversed().enumerated() {
            let frame = blockView.frame.insetBy(dx: -10, dy: -10)
            if frame.contains(at) {
                blockView.showPointAndClose()
                return (blocksView.firstIndex(of: blockView) ?? blocksView.count-index-1, false)
            }
        }
        return (makeBlockView(at: at), true)
    }
    
    private func makeBlockView(at: CGPoint) -> Int {
        let view = NWRemoveWaterBlockView.init(frame: CGRect.init(x: 0,
                                                                  y: 0,
                                                                  width: self.minClipSize.width,
                                                                  height: self.minClipSize.height))
        view.center = .init(x: at.x, y: at.y)
        view.hideClose()
        view.delegate = self
        self.blockViews.append(view)
        addSubview(view)
        self.currentBlock = view
        return self.blockViews.count-1
    }
    
    private func calculatePanEdge(at point: CGPoint, blockView: NWRemoveWaterBlockView) -> DragPanEdge {
        let frame = blockView.frame.insetBy(dx: -14, dy: -14)
        
        let cornerSize = CGSize(width: 28, height: 28)
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
        
        return .none
    }
    
    
}
