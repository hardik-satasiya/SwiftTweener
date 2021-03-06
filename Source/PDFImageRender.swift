//
//  PDFImageView.m
//  Tweener
//
//  Created by Alejandro Ramirez Varela on 2/15/16.
//  Copyright © 2016 Alejandro Ramirez Varela. All rights reserved.
//

import Foundation
import UIKit

public class PDFImageRender
{
    var data: Data?
    var document: CGPDFDocument?

    var pageCount: Int
    {
        if self.document == nil{return 0}
        else {return (self.document?.numberOfPages)!}
    }
    
    func setPDFData(data:Data?)
    {
        if (data != nil)
        {
            self.data = data
            //TODO:validate file
            let provider: CGDataProvider = CGDataProvider(data: self.data! as CFData )!
            self.document = CGPDFDocument(provider)
            if self.document == nil {print("document nil")}
        }else
        {
            print("Error invalid file")
        }
    }
    
    func loadFromBundle(filename: String)
    {
        let path:String = Bundle.main.path(forResource: filename, ofType: ".pdf")!
        loadFile(path: path)
    }
    
    func loadFile(path:String)
    {
        setPDFData(data: FileManager.default.contents(atPath: path))
    }
    
    //Get current page size
    func getPageSize(page:Int) ->CGSize
    {
        if self.data == nil {return CGSize.zero}
        return self.document!.page(at: page)!.getBoxRect(.cropBox).size
    }
    
    func renderPage(page: Int, scale:Double) -> UIImage?
    {
        if self.document == nil {return nil}
        
        //Add retina scale support
        let retinaScale: CGFloat = CGFloat(scale) * UIScreen.main.scale

        //Get page
        let pdfPage: CGPDFPage = self.document!.page(at: page)!
        
        //Get the rectangle of the cropped inside
        var mediaRect: CGRect = pdfPage.getBoxRect(.cropBox)
        mediaRect.size.width *= retinaScale
        mediaRect.size.height *= retinaScale
        
        //Get graphic context
        UIGraphicsBeginImageContext(mediaRect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        //Clear
        context.clear(mediaRect)
        
        //Flip y coordinates
        context.scaleBy(x: retinaScale, y: -retinaScale)
        context.translateBy(x: 0.0, y: -(mediaRect.size.height / retinaScale))
        
        //Draw it and generate UIImage
        context.drawPDFPage(pdfPage)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Return new image with retina scale
        return UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
}
