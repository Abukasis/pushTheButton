//
//  LogIn.swift
//  MichealsApp
//
//  Created by Oliver on 6/26/19.
//  Copyright © 2019 Addie. All rights reserved.
//

import UIKit
import Parse

class LogIn: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignbackground()
        addLineToView(view: username, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: password, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
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
    
    

    @IBAction func LogInButtonPressed(_ sender: Any) {
        if(isFieldFilled(field: username) == false){
            self.displayMsg(titl: "Oops", Msg: "Username Field is blank")
        } else if(isFieldFilled(field: password) == false){
            self.displayMsg(titl: "Oops", Msg: "Password Field is blank")
            } else{
        let user = username.text
        let pass = password.text
        PFUser.logInWithUsername(inBackground: user ?? " ", password: pass ?? " ") { (user, error) in
            if user != nil{
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
            else{
                self.displayMsg(titl: "Oops", Msg: "Invalid Username or Password")
            }
        }
    }
    }
    func displayMsg(titl:String,Msg:String){
        let alert = UIAlertController(title: titl, message: Msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert,animated: true,completion: nil )
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.username {
            textField.resignFirstResponder()
            self.password.becomeFirstResponder()
        } else if textField == self.password {
            if(isFieldFilled(field: username) == false){
                self.displayMsg(titl: "Oops", Msg: "Username Field is blank")
            } else if(isFieldFilled(field: password) == false){
                self.displayMsg(titl: "Oops", Msg: "Password Field is blank")
            } else{
            let Email = self.username.text
            let Pin = self.password.text
            PFUser.logInWithUsername(inBackground : Email! , password: Pin! , block : { (user,error) -> Void in
                if((user) != nil){
                    self.performSegue(withIdentifier: "toMain", sender: self)
                }else{
                    DispatchQueue.main.async {
                        self.displayMsg(titl: "Oops!", Msg: "Invalid Username/Password")
                    }
                }
            })
        }
        }
        return true
    }
}
func isFieldFilled(field:UITextField ) -> Bool{
    if(field.text?.count ?? 0 <= 0){
        return false
    } else{ return true
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
