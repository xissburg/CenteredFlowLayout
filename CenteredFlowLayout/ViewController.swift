//
//  ViewController.swift
//  CenteredFlowLayout
//
//  Created by Nilson Souto on 6/15/16.
//  Copyright © 2016 xissburg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, CenteredFlowLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var colors: [[UIColor]] = []
    var sizes: [[CGSize]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        for _ in 0..<5 {
            let r = 3 + arc4random_uniform(27)
            var colorArray: [UIColor] = []
            var sizeArray: [CGSize] = []
            let height = 40 + CGFloat(arc4random_uniform(50))
            
            for _ in 0..<r {
                colorArray.append(createRandomColor())
                
                let width = 22 + CGFloat(arc4random_uniform(178))
                sizeArray.append(CGSize(width: width, height: height))
            }
            
            colors.append(colorArray)
            sizes.append(sizeArray)
        }
    }
    
    func createRandomColor() -> UIColor {
        return UIColor(hue: random01(), saturation: random01(), brightness: random01(), alpha: 1)
    }
    
    func random01() -> CGFloat {
        return CGFloat(arc4random())/(CGFloat(Int64(1)<<32)-1)
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = colors[indexPath.section][indexPath.item]
        return cell
    }
    
    // MARK: - CenteredFlowLayoutDelegate
    
    func centeredFlowLayout(layout: CenteredFlowLayout, sizeAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizes[indexPath.section][indexPath.row]
    }
}

