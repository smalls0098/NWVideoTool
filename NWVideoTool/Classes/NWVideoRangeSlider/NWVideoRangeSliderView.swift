//
//  NWVideoRangeSliderView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit
import AVFoundation

@objc
public protocol NWVideoRangeSliderViewDelegate: AnyObject {
    func didChangeValue(videoRangeSlider: NWVideoRangeSliderView,
                        drag: NWVideoRangeSliderView.DragHandleChoice,
                        startTime: Float64,
                        endTime: Float64)
    
    @objc optional func sliderGesturesBegan()
    @objc optional func sliderGesturesEnded()
}

public class NWVideoRangeSliderView: UIView {
    
    public weak var delegate: NWVideoRangeSliderViewDelegate? = nil
    /// 顶部边框高度
    private let topBorderHeight: CGFloat = 5
    /// 底部边框高度
    private let bottomBorderHeight: CGFloat = 5
    /// 左边百分比
    public var startPercentage: CGFloat = 0
    /// 右边百分比
    public var endPercentage: CGFloat = 100
    /// 最小空间
    public var minSpace: Float = 1
    /// 最大空间
    public var maxSpace: Float = 0
    /// 是否更新缩略图
    private var isUpdatingThumbnails = false
    /// 是否接收手势
    private var isReceivingGesture = false
    
    /// 视频总时间
    private var duration: Float64 = 0.0
    /// 视频资源
    private var asset: AVURLAsset?
    /// 缩略图集合
    private var thumbnailViews = [UIImageView]()
    
    /// 缩略图容器
    public var thumbnailsView: UIView = {
        let view = UIView()
        view.clipsToBounds=true
        return view
    }()
    
    /// 左边指示器
    public lazy var startIndicator: UIImageView = {
        let view = UIImageView()
        view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        view.image = UIImage.nwv.getBundleImage("range_slider_start_indicator")
        view.isUserInteractionEnabled = true
        let startDrag = UIPanGestureRecognizer(target:self,
                                               action: #selector(startDragged(recognizer:)))
        view.addGestureRecognizer(startDrag)
        return view
    }()
    
    /// 右边指示器
    public lazy var endIndicator: UIImageView = {
        let view = UIImageView()
        view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        view.image = UIImage.nwv.getBundleImage("range_slider_end_indicator")
        view.isUserInteractionEnabled = true
        let endDrag = UIPanGestureRecognizer(target:self,
                                               action: #selector(endDragged(recognizer:)))
        view.addGestureRecognizer(endDrag)
        return view
    }()
    
    /// 进度指示器
    public lazy var progressIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.thumbnailsView)
        self.addSubview(self.startIndicator)
        self.addSubview(self.endIndicator)
        self.addSubview(self.progressIndicator)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.startIndicator.frame = CGRect(x: 0,
                                           y: -topBorderHeight,
                                           width: 20,
                                           height: self.frame.height + bottomBorderHeight + topBorderHeight)
        self.endIndicator.frame = CGRect(x: 0,
                                         y: -topBorderHeight,
                                         width: 20,
                                         height: self.frame.height + bottomBorderHeight + topBorderHeight)
        
        self.thumbnailsView.frame = CGRect(x: self.startIndicator.frame.width,
                                          y: 0,
                                          width: self.frame.width - self.startIndicator.frame.width - self.endIndicator.frame.width,
                                          height: self.frame.height)
        
        self.progressIndicator.frame = CGRect(x: 0,
                                              y: 0,
                                              width: 1,
                                              height: self.frame.height)
        
        let startPosition = positionFromValue(value: self.startPercentage)
        let endPosition = positionFromValue(value: self.endPercentage)
        
        self.progressIndicator.center = CGPoint(x: startPosition+self.startIndicator.frame.width,
                                                y: self.progressIndicator.center.y)
        
        self.startIndicator.center = CGPoint(x: startPosition, y: self.startIndicator.center.y)
        self.endIndicator.center = CGPoint(x: self.startIndicator.frame.width+endPosition, y: self.endIndicator.center.y)
    }
    
    public func load(asset: AVURLAsset) {
        self.duration = asset.duration.seconds
        self.asset = asset
        self.superview?.layoutSubviews()
        self.updateThumbnails()
    }
    
    private func updateThumbnails() {
        if asset == nil { return }
        if !isUpdatingThumbnails {
            self.isUpdatingThumbnails = true
            let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
            backgroundQueue.async {
                _ = self.updateThumbnails(view: self.thumbnailsView,
                                     asset: self.asset!,
                                     duration: self.duration)
                self.isUpdatingThumbnails = false
            }
        }
    }
    
}

extension NWVideoRangeSliderView {
    
    private func thumbnailFromVideo(asset: AVURLAsset, time: CMTime) -> UIImage {
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            
        }
        return UIImage()
    }
    
    private func updateThumbnails(view: UIView,
                          asset: AVURLAsset,
                          duration: Float64) -> [UIImageView] {
        var thumbnails = [UIImage]()
        var offset: Float64 = 0
        
        for view in self.thumbnailViews {
            DispatchQueue.main.sync {
                view.removeFromSuperview()
            }
        }
        
        let imagesCount = self.thumbnailCount(inView: view)
        
        for i in 0..<imagesCount {
            let thumbnail = thumbnailFromVideo(asset: asset,
                                               time: CMTimeMake(value: Int64(offset), timescale: 1))
            offset = Float64(i) * (duration / Float64(imagesCount))
            thumbnails.append(thumbnail)
        }
        self.addImagesToView(images: thumbnails, view: view)
        return self.thumbnailViews
    }
    
    private func thumbnailCount(inView: UIView) -> Int {
        var num : Double = 0
        DispatchQueue.main.sync {
            num = Double(inView.frame.size.width) / Double(inView.frame.size.height)
        }
        return Int(ceil(num))
    }
    
    private func addImagesToView(images: [UIImage], view: UIView) {
        self.thumbnailViews.removeAll()
        // 开始的位置
        var xPos: CGFloat = 0
        for image in images {
            DispatchQueue.main.async {
                let imageView = UIImageView(image: image)
                imageView.alpha = 0
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: xPos,
                                         y: 0.0,
                                         width: view.frame.size.height,
                                         height: view.frame.size.height)
                self.thumbnailViews.append(imageView)
                
                view.addSubview(imageView)
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    imageView.alpha = 1.0
                })
                view.sendSubviewToBack(imageView)
                xPos = xPos + view.frame.size.height
            }
        }
    }
    
}


extension NWVideoRangeSliderView {
    
    @objc
    public enum DragHandleChoice: Int {
        case start
        case end
    }
    
    @objc private func startDragged(recognizer: UIPanGestureRecognizer) {
        self.processHandleDrag(
            recognizer: recognizer,
            drag: .start,
            currentPositionPercentage: self.startPercentage,
            currentIndicator: self.startIndicator
        )
    }
    
    @objc private func endDragged(recognizer: UIPanGestureRecognizer) {
        self.processHandleDrag(
            recognizer: recognizer,
            drag: .end,
            currentPositionPercentage: self.endPercentage,
            currentIndicator: self.endIndicator
        )
    }
    
    private func processHandleDrag(
        recognizer: UIPanGestureRecognizer,
        drag: DragHandleChoice,
        currentPositionPercentage: CGFloat,
        currentIndicator: UIView
        ) {
        
        self.updateGestureStatus(recognizer: recognizer)
        
        let translation = recognizer.translation(in: self)
        
        var position: CGFloat = positionFromValue(value: currentPositionPercentage) // self.startPercentage or self.endPercentage
        
        position = position + translation.x
        
        if position < 0 { position = 0 }
        
        if position > self.thumbnailsView.frame.width {
            position = self.thumbnailsView.frame.width
        }

        let positionLimits = getPositionLimits(with: drag)
        position = checkEdgeCasesForPosition(with: position, and: positionLimits.min, and: drag)

        if Float(self.duration) > self.maxSpace && self.maxSpace > 0 {
            if drag == .start {
                if position < positionLimits.max {
                    position = positionLimits.max
                }
            } else {
                if position > positionLimits.max {
                    position = positionLimits.max
                }
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        currentIndicator.center = CGPoint(x: position , y: currentIndicator.center.y)
        
        let percentage = currentIndicator.center.x * 100 / self.thumbnailsView.frame.width
        
        let startSeconds = secondsFromValue(value: self.startPercentage)
        let endSeconds = secondsFromValue(value: self.endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self,
                                      drag: drag,
                                      startTime: startSeconds,
                                      endTime: endSeconds)
        
            
        if drag == .start {
            self.startPercentage = percentage
        } else {
            self.endPercentage = percentage
        }
        layoutSubviews()
    }
    
    private func positionFromValue(value: CGFloat) -> CGFloat{
        return value * self.thumbnailsView.frame.width / 100
    }
    
    private func updateGestureStatus(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            self.isReceivingGesture = true
            self.delegate?.sliderGesturesBegan?()
        } else if recognizer.state == .ended {
            self.isReceivingGesture = false
            self.delegate?.sliderGesturesEnded?()
        }
    }
    
    private func getPositionLimits(with drag: DragHandleChoice) -> (min: CGFloat, max: CGFloat) {
        if drag == .start {
            return (
                positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: self.minSpace)),
                positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: self.maxSpace))
            )
        } else {
            return (
                positionFromValue(value: self.startPercentage + valueFromSeconds(seconds: self.minSpace)),
                positionFromValue(value: self.startPercentage + valueFromSeconds(seconds: self.maxSpace))
            )
        }
    }
    
    private func checkEdgeCasesForPosition(with position: CGFloat,
                                           and positionLimit: CGFloat,
                                           and drag: DragHandleChoice) -> CGFloat {
        if drag == .start {
            if Float(self.duration) < self.minSpace {
                return 0
            } else {
                if position > positionLimit {
                    return positionLimit
                }
            }
        } else {
            if Float(self.duration) < self.minSpace {
                return self.thumbnailsView.frame.width
            } else {
                if position < positionLimit {
                    return positionLimit
                }
            }
        }
        
        return position
    }
    
    
    private func secondsFromValue(value: CGFloat) -> Float64{
        return duration * Float64((value / 100))
    }

    private func valueFromSeconds(seconds: Float) -> CGFloat{
        return CGFloat(seconds * 100) / CGFloat(duration)
    }
    
}
