//
//  NWVideoScrollProgressView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

open class NWVideoScrollProgressView: UIView {
        
    /// 视频进度内容宽度（必须要设置）
    public var videoContentWidth: CGFloat = .zero {
        didSet {
            //容器最大滑动宽度
            var maxContentWidth: CGFloat
            if videoContentWidth >= UIScreen.main.bounds.width / 2 {
                maxContentWidth = videoContentWidth + UIScreen.main.bounds.width
            }else{
                maxContentWidth = videoContentWidth
            }
            scrollView.contentSize = .init(width: maxContentWidth, height: 0)
        }
    }
    /// 滚动视图
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(origin: CGPoint.zero,
                                              size: CGSize(width: 0, height: self.frame.width)))
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    lazy var thumbnailView: NWVideoProgressImageView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = NWVideoProgressImageView.init(frame: CGRect.zero,
                                                 collectionViewLayout: layout)
        view.layer.cornerRadius = 4
        view.isScrollEnabled = false
        return view
    }()
    
    /// 是否初始化
    private var isInit = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayouts()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLayouts() {
        self.addSubview(self.scrollView)
        self.addConstraints([
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .trailing,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerY,
                               multiplier: 1,
                               constant: 0),
        ])
        self.scrollView.addSubview(self.contentView)
        self.scrollView.addConstraints([
            NSLayoutConstraint(item: self.contentView,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: self.scrollView,
                               attribute: .leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: self.scrollView,
                               attribute: .trailing,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self.scrollView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: self.scrollView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.scrollView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0),
        ])
        self.contentView.addSubview(self.thumbnailView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}


extension NWVideoScrollProgressView: UIScrollViewDelegate {
    
}
