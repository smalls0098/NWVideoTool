//
//  NWVideoProgressImageView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit
import AVFoundation

public class NWVideoProgressImageView: UICollectionView {
    
    /// 视频不同时间
    private var items: [CMTime] = [] {
        didSet {
            reloadData()
        }
    }
    
    /// 视频资源，会从该资源读取图片
    private var asset: AVAsset? {
        willSet {
            guard newValue != nil else {
                return
            }
            generator = AVAssetImageGenerator(asset: newValue!)
            generator!.requestedTimeToleranceAfter = .zero
            generator!.requestedTimeToleranceBefore = .zero
            //防止获取的图片旋转
            generator!.appliesPreferredTrackTransform = true
        }
    }
    
    private var generator: AVAssetImageGenerator?
    private let queuePool = NWDispatchQueuePool(name: "NWVideoProgressImageView.LoadImages",
                                                queueCount: 6,
                                                qos: .userInteractive)
    
    public override init(frame: CGRect,
                         collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(NWVideoProgressImageCell.self,
                 forCellWithReuseIdentifier: String(describing: NWVideoProgressImageCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 加载数据
    /// - Parameters:
    ///   - asset: 视频资源
    ///   - times: 不同时期的视频时间
    public func loadData(asset: AVAsset, times: [CMTime]) {
        self.asset = asset
        self.items = times
    }
    
    /// 加载图片
    /// - Parameters:
    ///   - time: 时间
    ///   - closure: 闭包
    private func loadImage(at time: CMTime, _ closure: @escaping (_ image: UIImage?) -> Void) {
        guard generator != nil else {
            closure(nil)
            return
        }
        var image: UIImage?
        queuePool.queue.async {
            autoreleasepool {
                do {
                    let cgImage = try self.generator!.copyCGImage(at: time, actualTime: nil)
                    let convertImage = UIImage(cgImage: cgImage).convertToSquare()
                    guard convertImage != nil else {
                        return
                    }
                    image = convertImage!.scaleToSize(.init(width: self.bounds.height,
                                                            height: self.bounds.height))
                } catch {
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.sync {
                closure(image)
            }
        }
    }
    
}

extension NWVideoProgressImageView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width:  self.bounds.height,
                     height: self.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = items[indexPath.row]
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: NWVideoProgressImageCell.self), for: indexPath) as! NWVideoProgressImageCell
        loadImage(at: data) { (image) in
            cell.imageLayer.contents = image?.cgImage
        }
        return cell
    }
    
}


public class NWVideoProgressImageCell: UICollectionViewCell {
    
    lazy var imageLayer: CALayer = {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.layer.addSublayer(imageLayer)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.imageLayer.frame = contentView.frame
    }
    
}

