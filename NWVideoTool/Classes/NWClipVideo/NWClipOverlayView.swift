//
//  NWClipOverlayView.swift
//  NWVideoTool
//
//  Created by Ming on 2022/4/24.
//

import UIKit

public class NWClipOverlayView: UIView {
    
    static let cornerLineWidth: CGFloat = 3
    private var cornerBoldLines: [UIView] = []
    private var velLines: [UIView] = []
    private var horLines: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        func line(_ isCorner: Bool) -> UIView {
            let line = UIView()
            line.backgroundColor = .white
            if !isCorner {
                line.layer.shadowOffset = .zero
                line.layer.shadowRadius = 1.5
                line.layer.shadowOpacity = 0.8
            }
            self.addSubview(line)
            return line
        }

        (0..<4).forEach { (index) in
            let velView = line(false)
            self.velLines.append(velView)
            let horView = line(false)
            self.horLines.append(horView)
        }
        
        (0..<8).forEach { (_) in
            let lineView = line(true)
            self.cornerBoldLines.append(lineView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
        let borderLineLength: CGFloat = 20
        let borderLineWidth: CGFloat = NWClipOverlayView.cornerLineWidth
        
        let normalLineWidth: CGFloat = 1
        var x: CGFloat = 0
        var y: CGFloat = -1
        // 横线
        for (index, line) in self.horLines.enumerated() {
            if index == 0 || index == 3 {
                x = borderLineLength-borderLineWidth
            } else  {
                x = 0
            }
            line.frame = CGRect(x: x, y: y, width: self.bounds.width - x * 2, height: normalLineWidth)
            y += (self.bounds.height + 1) / 3
        }

        x = -1
        y = 0
        // 竖线
        for (index, line) in self.velLines.enumerated() {
            if index == 0 || index == 3 {
                y = borderLineLength-borderLineWidth
            } else  {
                y = 0
            }
            line.frame = CGRect(x: x, y: y, width: normalLineWidth, height: self.bounds.height - y * 2)
            x += (self.bounds.width + 1) / 3
        }
        
        for (i, line) in self.cornerBoldLines.enumerated() {
            switch i {
            case 0:
                // 左上 hor
                line.frame = CGRect(x: -borderLineWidth, y: -borderLineWidth, width: borderLineLength, height: borderLineWidth)
            case 1:
                // 左上 vel
                line.frame = CGRect(x: -borderLineWidth, y: -borderLineWidth, width: borderLineWidth, height: borderLineLength)
            case 2:
                // 右上 hor
                line.frame = CGRect(x: self.bounds.width-borderLineLength+borderLineWidth, y: -borderLineWidth, width: borderLineLength, height: borderLineWidth)
            case 3:
                // 右上 vel
                line.frame = CGRect(x: self.bounds.width, y: -borderLineWidth, width: borderLineWidth, height: borderLineLength)
            case 4:
                // 左下 hor
                line.frame = CGRect(x: -borderLineWidth, y: self.bounds.height, width: borderLineLength, height: borderLineWidth)
            case 5:
                // 左下 vel
                line.frame = CGRect(x: -borderLineWidth, y: self.bounds.height-borderLineLength+borderLineWidth, width: borderLineWidth, height: borderLineLength)
            case 6:
                // 右下 hor
                line.frame = CGRect(x: self.bounds.width-borderLineLength+borderLineWidth, y: self.bounds.height, width: borderLineLength, height: borderLineWidth)
            case 7:
                line.frame = CGRect(x: self.bounds.width, y: self.bounds.height-borderLineLength+borderLineWidth, width: borderLineWidth, height: borderLineLength)

            default:
                break
            }
        }
        
    }
    
}
