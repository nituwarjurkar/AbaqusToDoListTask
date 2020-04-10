//
//  Extensions.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 10/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//

import UIKit

public class Extensions: NSObject {

}
//Mark: UIViewcontroller
public extension UIViewController
{
    func showHUD(message:String)
    {
        DispatchQueue.main.async {
            ALLoadingView.manager.resetToDefaults()
            ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
            ALLoadingView.manager.messageText = message
        }
        
    }
    func hideHUD()
    {
        DispatchQueue.main.async {
            ALLoadingView.manager.hideLoadingView(withDelay: 0.0)
        }
    }
}
