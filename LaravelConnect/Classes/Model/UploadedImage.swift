//
//  UploadedImage.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 13/03/2018.
//

import UIKit




public class UploadedImageCoreDataTransformer: ValueTransformer {
    
 
    open override class func transformedValueClass() -> Swift.AnyClass {
        return NSData.self
    }
    
    open override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    
    open override func transformedValue(_ value: Any?) -> Any? {
        
        if let image:UploadedImage = value as? UploadedImage {
           return image.convert()
        }
        return Data()
    }
    
    open override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        return UploadedImage(with: value as! Data)
    }
}



extension NSValueTransformerName {
    
    static let UploadedImageCoreDataTransformerName = NSValueTransformerName(rawValue: "UploadedImageCoreDataTransformer")
}



public class UploadedImage: NSObject, NSCoding  {
    
    public var image:UIImage?
    public let imageUrl:URL?
    
    init(string:String?){
        if  let s = string, let img = URL(string:s) {
            self.imageUrl = img
        }else {
            self.imageUrl = nil
        }
    }
    
    init(url url:URL?){
       self.imageUrl = url
    }
    
    init(image image:UIImage?){
        self.imageUrl = nil
        self.image = image
    }

    public override convenience init(){
        self.init(string:nil)
    }
    
    convenience init(with data:Data){
        let datastring = String(data: data, encoding: .utf8)
        self.init(string:datastring)
    }
    
    public func convert() -> Data {
        
        if let fullUrl:String = self.imageUrl?.absoluteString,
            let data = fullUrl.data(using: .utf8) {
            return data
        }
        return Data()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.imageUrl, forKey: "image")
    }
    
    public required init?(coder decoder: NSCoder) {
       self.imageUrl = decoder.decodeObject(forKey: "image") as? URL
    }
    
    override open var description : String {
        
        if let img = self.imageUrl as? URL {
            return "\(img)"
        }
        return "no image"
    }
    
    override open var debugDescription : String {
        if let img = self.imageUrl as? URL {
            return "\(img)"
        }
        return "no image"
    }
    
    static func ==(lhs: UploadedImage, rhs: UploadedImage) -> Bool
    {
        return lhs.imageUrl == rhs.imageUrl && lhs.image == rhs.image
    }

    static func !=(lhs: UploadedImage, rhs: UploadedImage) -> Bool
    {
        return !(lhs == rhs)
    }
}
