//  FirstPage.swift
//  MichealsApp
//  Created by Oliver on 6/26/19.
//  Copyright © 2019 Addie. All rights reserved.

import UIKit
import Parse
import FBSDKLoginKit
import FacebookCore


class FirstPage: UIViewController, LoginButtonDelegate {
    var Email:String = " "
    override func viewDidLoad() {
        super.viewDidLoad()
        autologin()
        print("start")
        print(Email)
        print("done")
      assignbackground()
        let button =   FBLoginButton(frame: CGRect.init() , permissions: [Permission.email])
        view.addSubview(button)
        button.center = view.center
        button.delegate = self
        // Do any additional setup after loading the view.
    }

    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        return true
    }
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        fetchProfile()
        
    }
    
    
    func autologin(){
        if(PFUser.current() == nil){
            print("no user logged")
        }else {
            print("user logged, attemping autologin")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "autologin", sender: self)
            }
        }
    }
    
    
    func fetchProfile(){
    
        let r = GraphRequest(graphPath: "me", parameters: ["fields":" email , name "], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod.get)
        r.start(completionHandler: { (test, result, error) in
            if(error == nil)
            {
                let ResponseOfCall = result as! NSDictionary
                let userEmail = ResponseOfCall["email"] as! String
                let userPass = ResponseOfCall["id"] as! String
                let NewUser: PFUser = PFUser()
                NewUser.email = userEmail
                NewUser.username = userEmail
                NewUser.password = userPass
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
                                        self.performSegue(withIdentifier: "autologin", sender: self)
                                    }
                                })
                            }
                        })
                    }else{
                        self.displayMsg(titl: "Oops", Msg: "failed to create account")
                    }
                }
                
                
            }
        })
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     
    */
    func displayMsg(titl:String,Msg:String){
        let alert = UIAlertController(title: titl, message: Msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert,animated: true,completion: nil )
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
}
