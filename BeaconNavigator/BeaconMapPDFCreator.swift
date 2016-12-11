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
    
    var pageSize = CGSize.zero
    let name : String
    var pageFont : UIFont {
        get {
            return UIFont.systemFont(ofSize: 10.0)
        }
    }

    var baseViewControllerForPreview : UIViewController?
    
    var pdfPath : String {
        get {
            let pdfName = "\(name).pdf"
            let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let pdfPath = documentsDirectory.appendingPathComponent(pdfName)
            return ""
        }
    }
    
    required init(name : String) {
        self.name = name
    }
    
    func generatePDF(mapView: BeaconMapView, loggedPositionsString : String, currentPositionsString : String, userPositionsString : String) {
        let calculatedHeight = mapView.frame.height + heightForView(text: loggedPositionsString) + heightForView(text: currentPositionsString) + heightForView(text: userPositionsString) + 200
        pageSize = CGSize(width: mapView.frame.width, height: calculatedHeight)
        setupPDFDocument()
        beginPage()
        addView(view: mapView, atPoint: CGPoint.zero)
        let loggedPositionTextFrame = addText(text: loggedPositionsString, atPoint: CGPoint(x: 0, y: mapView.frame.height + 20), withColor: .black)
        let currentPositionTextFrame = addText(text: currentPositionsString, atPoint: CGPoint(x: 0, y: loggedPositionTextFrame.height + loggedPositionTextFrame.origin.y), withColor: positionPointColor)
        addText(text: userPositionsString, atPoint: CGPoint(x: 0, y: currentPositionTextFrame.height + currentPositionTextFrame.origin.y),withColor: userDefpositionPointColor)
        
        finishPDF()
    }
    
    func setupPDFDocument() {
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRect.zero, nil)
    }
    
    func beginPage() {
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height), nil)
    }
    
    func addText(text : String, atPoint point : CGPoint, withColor color: UIColor) -> CGRect {
        let stringSize = CGSize(width: pageSize.width, height: heightForView(text: text))
        let renderingRect = CGRect(x: point.x, y: point.y, width: pageSize.width, height: stringSize.height)
        let textFontAttributes = [
            NSFontAttributeName: pageFont,
            NSForegroundColorAttributeName: color
        ]

        (text as NSString).draw(in: renderingRect, withAttributes: textFontAttributes)
        return renderingRect
    }
    
    func addImage(image : UIImage, atPoint point : CGPoint) -> CGRect {
        let renderingFrame = CGRect(x: point.x,y: point.y, width: image.size.width, height: image.size.height)
        image.draw(in: renderingFrame)
        return renderingFrame
    }
    
    func addView(view : UIView, atPoint point : CGPoint) -> CGRect {
        let context = UIGraphicsGetCurrentContext()
        view.layer.render(in: context!)
        return view.frame
    }
    
    func heightForView(text: String) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: pageSize.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
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
        let pdfURL = NSURL(fileURLWithPath: pdfPath)
        documentInteractionVC.url = pdfURL as URL
        documentInteractionVC.delegate = self
        documentInteractionVC.presentPreview(animated: true)
        
    }
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return baseViewControllerForPreview!
    }

}
