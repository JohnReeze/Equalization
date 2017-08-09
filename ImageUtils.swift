//
//  ImageUtils.swift
//  Equalization_of_images
//
//  Created by Admin on 09.08.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public struct Pixel {
    
    public var value: UInt32
    
    //red
    public var R: UInt8 {
        get { return UInt8(value & 0xFF); }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    
    //green
    public var G: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    
    //blue
    public var B: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    
    //alpha
    public var A: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
}

public struct RGBAImage {
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    public var width: Int
    public var height: Int
    var rBr = [Double]()
    var gBr = [Double]()
    var bBr = [Double]()
    
    public init?(image: UIImage) {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let hw = width*height
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo = bitmapInfo | CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        imageContext.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
        for _ in 0...255 {
            rBr.append(0.0)
            gBr.append(0.0)
            bBr.append(0.0)
        }
        
        pixels.forEach { (pixel) in
            rBr[Int(pixel.R)] += 1;
            gBr[Int(pixel.G)] += 1;
            bBr[Int(pixel.B)] += 1;
        }
        
        for i in 0...255 {
            rBr[i] = rBr[i] / Double(hw)
            gBr[i] = gBr[i] / Double(hw)
            bBr[i] = bBr[i] / Double(hw)
        }
        
        for i in 1...255 {
            rBr[i] = (rBr[i-1] + rBr[i]);
            gBr[i] = gBr[i-1] + gBr[i];
            bBr[i] = bBr[i-1] + bBr[i];
        }
        
    }
    
    public mutating func countBrightness() {
        for _ in 0...255 {
            rBr.append(0.0)
            gBr.append(0.0)
            bBr.append(0.0)
        }
        
        pixels.forEach { (pixel) in
            rBr[Int(pixel.R)] += 1;
            gBr[Int(pixel.G)] += 1;
            bBr[Int(pixel.B)] += 1;
        }
        let hw = width*height
        for i in 0...255 {
            rBr[i] = rBr[i] / Double(hw)
            gBr[i] = rBr[i] / Double(hw)
            bBr[i] = rBr[i] / Double(hw)
        }
        
        for i in 1...255 {
            rBr[i] = rBr[i-1] + rBr[i];
            gBr[i] = gBr[i-1] + gBr[i];
            bBr[i] = bBr[i-1] + bBr[i];
        }
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        let bytesPerRow = width * 4
        
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil) else {
            return nil
        }
        
        guard let cgImage = imageContext.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    public func process( functor : ((Pixel) -> Pixel) ) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let outPixel = functor(pixels[index])
                pixels[index] = outPixel
            }
        }
    }
    
}

