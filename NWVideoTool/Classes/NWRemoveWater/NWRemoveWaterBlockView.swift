//
//  NWRemoveWaterBlockView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/22.
//

import UIKit

protocol NWRemoveWaterBlockViewDelegate: AnyObject {
    func onShowView(blockView: NWRemoveWaterBlockView)
    func onRemoveView(blockView: NWRemoveWaterBlockView)
}

public class NWRemoveWaterBlockView: UIView {
    
    weak var delegate: NWRemoveWaterBlockViewDelegate? = nil
    
    var linesView: [UIView] = []
    
    var closeView: UIImageView!
    var topLeftPointView: UIView!
    var topRightPointView: UIView!
    var bottomLeftPointView: UIView!
    var bottomRightPointView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.nwv.hex("#FD857D").withAlphaComponent(0.5)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        func line() -> UIView {
            let line = UIView()
            line.backgroundColor = .white
            self.addSubview(line)
            return line
        }
        (0..<4).forEach { (index) in
            let view = line()
            self.linesView.append(view)
        }
        func point() -> UIView {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 9
            self.addSubview(view)
            return view
        }
        topLeftPointView = point()
        topRightPointView = point()
        bottomLeftPointView = point()
        bottomRightPointView = point()
        closeView = UIImageView()
        closeView.image = UIImage.nwv.getBundleImage("rw_close")
        closeView.isUserInteractionEnabled=true
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRemoveView)))
        addSubview(closeView)
        
        isUserInteractionEnabled=true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()

        // 线高度
        let normalLineWidth: CGFloat = 2
        let pointWidth: CGFloat = 18
        for (index, line) in self.linesView.enumerated() {
            // top
            if index == 0 {
                line.frame = CGRect(x: 0,
                                    y: 0,
                                    width: self.bounds.width,
                                    height: normalLineWidth)
            }
            // left
            if index == 1 {
                line.frame = CGRect(x: 0,
                                    y: normalLineWidth,
                                    width: normalLineWidth,
                                    height: self.bounds.height)
            }
            // right
            if index == 2 {
                line.frame = CGRect(x: self.bounds.width,
                                    y: 0,
                                    width: normalLineWidth,
                                    height: self.bounds.height)
            }
            // bottom
            if index == 3 {
                line.frame = CGRect(x: normalLineWidth,
                                    y: self.bounds.height,
                                    width: self.bounds.width,
                                    height: normalLineWidth)
            }
        }
        
        topLeftPointView.frame = CGRect(x: 0-pointWidth/2,
                                        y: 0-pointWidth/2,
                                        width: pointWidth,
                                        height: pointWidth)
        
        topRightPointView.frame = CGRect(x: self.bounds.width-pointWidth/2,
                                           y: 0-pointWidth/2,
                                           width: pointWidth,
                                           height: pointWidth)
        
        bottomLeftPointView.frame = CGRect(x: 0-pointWidth/2,
                                         y: self.bounds.height-pointWidth/2,
                                         width: pointWidth,
                                         height: pointWidth)
        
        bottomRightPointView.frame = CGRect(x: self.bounds.width-pointWidth/2,
                                            y: self.bounds.height-pointWidth/2,
                                            width: pointWidth,
                                            height: pointWidth)
    
        
        closeView.frame = CGRect(x: self.bounds.width-24/2,
                                 y: 0-24/2,
                                 width: 24,
                                 height: 24)
    
    }
    
}

extension NWRemoveWaterBlockView {
    @objc private func onTap() {
        delegate?.onShowView(blockView: self)
    }
    
    @objc private func onRemoveView() {
        delegate?.onRemoveView(blockView: self)
        self.removeFromSuperview()
    }
}

extension NWRemoveWaterBlockView {
    
    public func hidePoint() {
        topLeftPointView.isHidden=true
        topRightPointView.isHidden=true
        bottomLeftPointView.isHidden=true
        bottomRightPointView.isHidden=true
    }
    
    public func showPoint() {
        topLeftPointView.isHidden=false
        topRightPointView.isHidden=false
        bottomLeftPointView.isHidden=false
        bottomRightPointView.isHidden=false
    }
    
    public func showClose() {
        closeView.isHidden=false
    }
    
    public func hideClose() {
        closeView.isHidden=true
    }
    
    public func hidePointAndClose() {
        hidePoint()
        hideClose()
    }
    
    public func showPointAndClose() {
        showPoint()
        showClose()
    }
    
}
