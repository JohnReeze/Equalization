//
//  ViewController.swift
//  Equalization_of_images
//
//  Created by Admin on 18.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var string : NSNumber = 0
    var images = [UIImage(named: "1"), UIImage(named: "2"), UIImage(named: "3"), UIImage(named: "4"), UIImage(named: "5")]
    var rgba : RGBAImage? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rgba = RGBAImage(image: images[0]!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let q = DispatchQueue.global(qos : .utility)
        q.async {
            //get instanse of RGBAImage in order to use it's brightness arrays
            self.rgba = RGBAImage(image: self.images[indexPath.row]!)
            self.rgba?.process(functor: { (pixel) -> Pixel in
                var pixel = pixel
                pixel.R = UInt8((self.rgba?.rBr[Int(pixel.R)])! * 255)
                pixel.G = UInt8((self.rgba?.gBr[Int(pixel.G)])! * 255)
                pixel.B = UInt8((self.rgba?.bBr[Int(pixel.B)])! * 255)
                return pixel
            })
            self.images[indexPath.row] = self.rgba?.toUIImage()
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.i.image = images[indexPath.row]
        return cell
    }
    
}


