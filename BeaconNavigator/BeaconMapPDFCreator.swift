//
//  BeaconMapPDFCreater.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 25.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import UIKit

class BeaconMapPDFCreator : NSObject, UIDocumentInteractionControllerDelegate {
    
    var pageSize = CGSizeZero
    let name : String
    var pageFont : UIFont {
        get {
            return UIFont.systemFontOfSize(10.0)
        }
    }

    var baseViewControllerForPreview : UIViewController?
    
    var pdfPath : String {
        get {
            let pdfName = "\(name).pdf"
            let paths = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let pdfPath = documentsDirectory.stringByAppendingPathComponent(pdfName)
            return pdfPath
        }
    }
    
    required init(name : String) {
        self.name = name
    }
    
    func generatePDF(mapView: BeaconMapView, loggedPositionsString : String, currentPositionsString : String, userPositionsString : String) {
        let calculatedHeight = mapView.frame.height + heightForView(loggedPositionsString) + heightForView(currentPositionsString) + heightForView(userPositionsString) + 200
        pageSize = CGSizeMake(mapView.frame.width, calculatedHeight)
        setupPDFDocument()
        beginPage()
        addView(mapView, atPoint: CGPointZero)
        let loggedPositionTextFrame = addText(loggedPositionsString, atPoint: CGPointMake(0, mapView.frame.height), color: .blackColor())
        let currentPositionTextFrame = addText(currentPositionsString, atPoint: CGPointMake(0, loggedPositionTextFrame.height + loggedPositionTextFrame.origin.y), color: positionPointColor)
        addText(userPositionsString, atPoint: CGPointMake(0, currentPositionTextFrame.height + currentPositionTextFrame.origin.y),color: userDefpositionPointColor)
        
        finishPDF()
    }
    
    func setupPDFDocument() {
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil)
    }
    
    func beginPage() {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil)
    }
    
    func addText(text : String, atPoint point : CGPoint, color: UIColor) -> CGRect {
        let stringSize = CGSizeMake(pageSize.width, heightForView(text))
        let renderingRect = CGRectMake(point.x, point.y, pageSize.width, stringSize.height)
        let textFontAttributes = [
            NSFontAttributeName: pageFont,
            NSForegroundColorAttributeName: color
        ]

        (text as NSString).drawInRect(renderingRect, withAttributes: textFontAttributes)
        return renderingRect
    }
    
    func addImage(image : UIImage, atPoint point : CGPoint) -> CGRect {
        let renderingFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height)
        image.drawInRect(renderingFrame)
        return renderingFrame
    }
    
    func addView(view : UIView, atPoint point : CGPoint) -> CGRect {
        let context = UIGraphicsGetCurrentContext()
        view.layer.renderInContext(context)
        return view.frame
    }
    
    func heightForView(text:String) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, pageSize.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = pageFont
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func finishPDF() {
        UIGraphicsEndPDFContext()
    }
    
    func openPDF(baseViewController : UIViewController) {
        baseViewControllerForPreview = baseViewController
        let documentInteractionVC = UIDocumentInteractionController()
        if let pdfURL = NSURL(fileURLWithPath: pdfPath) {
    
            documentInteractionVC.URL = pdfURL
            documentInteractionVC.delegate = self
            documentInteractionVC.presentPreviewAnimated(true)
        }
        
    }
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return baseViewControllerForPreview!
    }

}