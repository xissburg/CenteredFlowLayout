//
//  CenteredFlowLayout.swift
//  CenteredFlowLayout
//
//  Created by Nilson Souto on 6/15/16.
//  Copyright © 2016 xissburg. All rights reserved.
//

import UIKit

@objc public protocol CenteredFlowLayoutDelegate: UICollectionViewDelegate {
    func centeredFlowLayout(layout: CenteredFlowLayout, sizeAtIndexPath indexPath: NSIndexPath) -> CGSize
}

public class CenteredFlowLayout: UICollectionViewLayout {
    
    @IBOutlet weak var delegate: AnyObject?//CenteredFlowLayoutDelegate?
    var frames: Array<Array<CGRect>> = []
    var contentSize: CGSize = CGSizeZero
    @IBInspectable var cellSpacing: CGFloat = 5
    @IBInspectable var lineSpacing: CGFloat = 7
    @IBInspectable var sectionSpacing: CGFloat = 20
    
    class func centeredRects(rects: Array<CGRect>, width: CGFloat, cellSpacing: CGFloat) -> Array<CGRect> {
        var rectsWidth: CGFloat = 0
        
        for r in rects {
            rectsWidth += r.size.width
        }
        
        rectsWidth += CGFloat(rects.count - 1) * cellSpacing
        let left = width/2 - rectsWidth/2
        let offset = left - rects.first!.origin.x
        var centeredRects = Array<CGRect>()
        
        for r in rects {
            let rect = CGRectMake(r.origin.x + offset, r.origin.y, r.size.width, r.size.height)
            centeredRects.append(rect)
        }
        
        return centeredRects
    }
    
    public struct Measurements {
        public var collectionViewSize: CGSize = CGSizeZero
        public var collectionViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
        public var numberOfItemsInSections: [Int] = []
        public var itemsSizes: [[CGSize]] = []
        public var lineSpacing: CGFloat = 5
        public var cellSpacing: CGFloat = 7
        public var sectionSpacing: CGFloat = 20
        
        public init() {}
    }
    
    class public func calculateFramesAndContentSizeWithMeasurements(measurements: Measurements) -> ([[CGRect]], CGSize) {
        var frames: [[CGRect]] = []
        var contentSize = CGSizeZero
        
        let sections = measurements.numberOfItemsInSections.count
        
        for section in 0 ..< sections {
            let count = measurements.numberOfItemsInSections[section]
            var sectionFrames = Array<CGRect>()
            var lineFrames = Array<CGRect>()
            var lineHeight: CGFloat = 0
            var x: CGFloat = 0
            var y: CGFloat = contentSize.height
            let insets = measurements.collectionViewContentInset
            let width = measurements.collectionViewSize.width - insets.left - insets.right
            
            for i in 0 ..< count {
                var size = measurements.itemsSizes[section][i]
                size.width = min(measurements.collectionViewSize.width, size.width)
                
                if size.height > lineHeight {
                    lineHeight = size.height
                }
                
                var frame = CGRectMake(x, y, size.width, size.height)
                
                if frame.origin.x + frame.size.width > width {
                    x = 0
                    y += lineHeight + measurements.lineSpacing
                    contentSize.height += lineHeight + measurements.lineSpacing
                    
                    if lineFrames.count > 0 {
                        sectionFrames += centeredRects(lineFrames, width: width, cellSpacing: measurements.cellSpacing)
                        
                        lineFrames.removeAll(keepCapacity: true)
                        
                        frame.origin.x = x
                        frame.origin.y = y
                        lineFrames.append(frame)
                        x += frame.size.width + measurements.cellSpacing
                        
                        if i == count - 1 {
                            sectionFrames += centeredRects(lineFrames, width: width, cellSpacing: measurements.cellSpacing)
                            
                            if section <= sections - 1 {
                                contentSize.height += lineHeight
                            }
                        }
                    }
                    else {
                        frame.origin.x = width/2 - frame.size.width/2
                        sectionFrames.append(frame)
                    }
                    
                    lineHeight = 0
                }
                else if i == count - 1 {
                    lineFrames.append(frame)
                    sectionFrames += centeredRects(lineFrames, width: width, cellSpacing: measurements.cellSpacing)
                    contentSize.height += lineHeight + measurements.lineSpacing
                }
                else {
                    lineFrames.append(frame)
                    x += size.width + measurements.cellSpacing
                }
            }
            
            assert(sectionFrames.count == count)
            frames.append(sectionFrames)
            
            let sectionWidth =  measurements.collectionViewSize.width - insets.left - insets.right
            contentSize.width = max(contentSize.width, sectionWidth)
            
            if section < sections - 1 {
                contentSize.height += measurements.sectionSpacing
            }
        }
        
        return (frames, contentSize)
    }
    
    override public func prepareLayout() {
        super.prepareLayout()
        
        if let collectionView = collectionView, dataSource = collectionView.dataSource, delegate = delegate {
            var measurements = Measurements()
            measurements.collectionViewSize = collectionView.bounds.size
            measurements.collectionViewContentInset = collectionView.contentInset
            measurements.lineSpacing = lineSpacing
            measurements.cellSpacing = cellSpacing
            measurements.sectionSpacing = sectionSpacing
            
            var numberOfItemsInSections: [Int] = []
            var numberOfSections = 1
            
            if let f = dataSource.numberOfSectionsInCollectionView {
                numberOfSections = f(collectionView)
            }
            
            for i in 0..<numberOfSections {
                numberOfItemsInSections.append(dataSource.collectionView(collectionView, numberOfItemsInSection: i))
            }
            
            measurements.numberOfItemsInSections = numberOfItemsInSections
            
            var itemsSizes: [[CGSize]] = []
            
            for i in 0..<numberOfSections {
                var sizes: [CGSize] = []
                
                for j in 0..<numberOfItemsInSections[i] {
                    let indexPath = NSIndexPath(forItem: j, inSection: i)
                    let size = delegate.centeredFlowLayout(self, sizeAtIndexPath: indexPath)
                    sizes.append(size)
                }
                
                itemsSizes.append(sizes)
            }
            
            measurements.itemsSizes = itemsSizes
            
            (frames, contentSize) = CenteredFlowLayout.calculateFramesAndContentSizeWithMeasurements(measurements)
        }
    }
    
    override public func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = frames[indexPath.section][indexPath.item]
        return attributes
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = Array<UICollectionViewLayoutAttributes>()
        
        for (section, sectionFrames) in frames.enumerate() {
            for (index, frame) in sectionFrames.enumerate() {
                if CGRectIntersectsRect(rect, frame) {
                    let indexPath = NSIndexPath(forItem: index, inSection: section)
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    attributes.frame = frame
                    attributesArray.append(attributes)
                }
            }
        }
        
        return attributesArray
    }
}
