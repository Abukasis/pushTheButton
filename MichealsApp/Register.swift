//
//  Register.swift
//  MichealsApp
//
//  Created by Oliver on 6/26/19.
//  Copyright © 2019 Addie. All rights reserved.
//

import UIKit
import Parse
import FacebookLogin
import FacebookCore

class Register: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLineToView(view: Username, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: Password, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: Email, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        hideKeyboardWhenTappedAround()
        
        assignbackground()
        // Do any additional setup after loading the view.
    }
    func assignbackground(){
        let background = #imageLiteral(resourceName: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func CreateAccountButtonPressed(_ sender: Any) {
        if( isFieldFilled(field: Email) || isFieldFilled(field: Username) || isFieldFilled(field: Password)){
        let NewUser: PFUser = PFUser()
        NewUser.email = Email.text
        NewUser.username = Username.text
        NewUser.password = Password.text
        NewUser.signUpInBackground { (results, error) in
            if error == nil{
                let object = PFObject(className: "usercount")
                object.setValue(NewUser.username!, forKey: "username")
                object.setValue(0, forKey: "count")
                object.setValue(0, forKey: "currentButton")
                object.setValue(true, forKey:"firstTime")
                object.add(0, forKey: "boughtButtons")
                object.saveInBackground(block: { (respon, error) in
                    if(error == nil){
                        PFUser.logInWithUsername(inBackground: NewUser.username ?? " ", password: NewUser.password ?? " ", block: { ( user, error) in
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "signuptomain", sender: self)
                            }
                            })
                    }
                })
            }else{
                self.displayMsg(titl: "Oops", Msg: "failed to create account")
            }
        }
    }
        else{
            displayMsg(titl: "Oops", Msg: "All fields must be filled out")
        }
    }
    func displayMsg(titl:String,Msg:String){
        let alert = UIAlertController(title: titl, message: Msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert,animated: true,completion: nil )
    }
    func isFieldFilled(field:UITextField ) -> Bool{
        if(field.text?.count ?? 0 <= 0){
            return false
        } else{ return true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.Email {
            textField.resignFirstResponder()
            self.Username.becomeFirstResponder()
        } else if textField == self.Username {
            textField.resignFirstResponder()
            self.Password.becomeFirstResponder()
        } else if textField == self.Password{
            if(!isFieldFilled(field: Email) || !isFieldFilled(field: Username) || !isFieldFilled(field: Password)){
                let NewUser: PFUser = PFUser()
                NewUser.email = Email.text
                NewUser.username = Username.text
                NewUser.password = Password.text
                NewUser.signUpInBackground { (results, error) in
                    if error == nil{
                        let object = PFObject(className: "usercount")
                        object.setValue(NewUser.username!, forKey: "username")
                        object.setValue(0, forKey: "count")
                        object.setValue(0, forKey: "currentButton")
                        object.setValue(true, forKey:"firstTime")
                        object.add(0, forKey: "boughtButtons")
                        object.saveInBackground(block: { (respon, error) in
                            if(error == nil){
                                PFUser.logInWithUsername(inBackground: NewUser.username ?? " ", password: NewUser.password ?? " ", block: { ( user, error) in
                                    DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "signuptomain", sender: self)                                    }
                                })
                            }else {
                                self.displayMsg(titl: "Oops", Msg: "failed")
                            }
                        })
                    }
                    else{
                        self.displayMsg(titl: "Oops", Msg: "Failed to create account")
                    }
                }
            }
            else{
                self.displayMsg(titl: "Oops", Msg: "All fields must be filled out")
            }
            }
        return true
    }
    

    
}
