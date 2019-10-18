//  ButtonStruct.swift
//  MichealsApp
//  Created by Oliver on 6/27/19.
//  Copyright © 2019 Addie. All rights reserved.

import Foundation
import UIKit
import AVKit


class ButtonStruct:UITableViewCell{
    
    @IBOutlet weak var button: UIButton!
    
    var tapAction:((UITableViewCell)-> Void)?
    
    @IBAction func ButtonPressed(_ sender: Any) {
        tapAction?(self)
        
    }
    
    
}


