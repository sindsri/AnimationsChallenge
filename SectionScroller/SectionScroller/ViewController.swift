//
//  ViewController.swift
//  SectionScroller
//
//  Created by Rebouh Aymen on 27/02/2019.
//  Copyright © 2019 Rebouh Aymen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrubberView: UIView!
    @IBOutlet weak var scrubberViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestures: do {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
            scrubberView.addGestureRecognizer(panGesture)
        }
    }
    
    @objc private func handleGesture(gesture: UIPanGestureRecognizer) {
        
        let translationY = gesture.translation(in: gesture.view!).y

        let contentInset = collectionView.contentInset
        let contentSize = collectionView.contentSize
        let scrubberOffsetRange = collectionView.scrollIndicatorInsets.top ... (collectionView.frame.height - scrubberView.frame.height - collectionView.scrollIndicatorInsets.bottom)
        let contentOffsetRange = contentInset.top ..< (contentSize.height-collectionView.frame.height)

        switch gesture.state {
            
        case .changed:
            // Update scrubber
            let constant = self.scrubberViewTopConstraint.constant + translationY
            self.scrubberViewTopConstraint.constant = (constant ... constant).clamped(to: scrubberOffsetRange).lowerBound
            gesture.setTranslation(.zero, in: gesture.view!)

            // Update collectionView
            let scrubberProgress = (constant - scrubberOffsetRange.lowerBound)
                / (scrubberOffsetRange.upperBound - scrubberOffsetRange.lowerBound)

            let scrubberClampedProgress = (scrubberProgress ... scrubberProgress).clamped(to: 0 ... 1).lowerBound
            let targetOffsetY = contentOffsetRange.lowerBound
                + (scrubberClampedProgress * (contentOffsetRange.upperBound - contentOffsetRange.lowerBound))
            collectionView.contentOffset.y = targetOffsetY

            print("clampedProgress: \(scrubberClampedProgress), offsetY: \(targetOffsetY),  contentSize = \(contentSize.height)")
            
        default: break
        }
    }
}

extension ViewController:  UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderCell
        header.titleLabel.text = "Section \(indexPath.section)"
        
        return header
    }
}

