//  Market.swift
//  MichealsApp
//  Created by Oliver on 6/26/19.
//  Copyright © 2019 Addie. All rights reserved.

import UIKit
import Parse
import Stripe

class Market:UITableViewController ,PKPaymentAuthorizationViewControllerDelegate {
    var buttonAboutToBuy:Int = 0
    
    @IBOutlet var tableview: UITableView!
        let imageArray = [ #imageLiteral(resourceName: "SilverButton") ,#imageLiteral(resourceName: "GoldMedalButton") , #imageLiteral(resourceName: "RadioActiveButton") , #imageLiteral(resourceName: "UnicornButton") , #imageLiteral(resourceName: "BrokenThumbsUpButton") , #imageLiteral(resourceName: "ScratchedThumbsUpButton") , #imageLiteral(resourceName: "PrestineGreenThumbsUpButton") , #imageLiteral(resourceName: "StickyNoteButton") , #imageLiteral(resourceName: "ButtonMadeOfWood") , #imageLiteral(resourceName: "GoldButton"), #imageLiteral(resourceName: "PoopEmogiButton")]
    var boughtButtonsArr = [0,1,2,3]
    let lockImage = #imageLiteral(resourceName: "lock")
    
    func getBoughtButtons(){
        
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if result == nil{
                print("Not bought ye")
            }
            else {
            let myList =   result?.object(forKey: "boughtButtons")
                print(myList.debugDescription)
                self.boughtButtonsArr += myList as! Array
            }
        }
        
    }
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonStruct", for: indexPath) as! ButtonStruct
        
        if(boughtButtonsArr.contains(indexPath.row)){
        cell.button.setImage(imageArray[indexPath.row], for: UIControl.State.normal)
        }else{
            cell.button.setImage(lockImage, for: UIControl.State.normal)
        }
        cell.tapAction = {(cell) in
            
            self.buttonAboutToBuy = indexPath.row
            
            if(self.boughtButtonsArr.contains(indexPath.row)){
                DispatchQueue.main.async {
                self.setUserCurrentButton(index: indexPath.row)
                }
                }else{
                self.payButton(productLabel: "New Button", priceAmount: 2.00)
                }
            
        }
        return cell
    }
    override func viewDidLoad() {
        getBoughtButtons()
        super.viewDidLoad()
        
        self.tableview.rowHeight = 200
        tableview.reloadData()
        // Do any additional setup after loading the view.
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "marketback" {
            let viewController = segue.destination as! ViewController
            
        }
    }

    
    func saveButton(index:Int){
            let query = PFQuery(className: "usercount")
            query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
            query.getFirstObjectInBackground { (result, error) in
                if error == nil{
                    let object = result!
                   object.add(index, forKey: "boughtButtons")
                    object.saveInBackground(block: { (Bool, error) in
                        if(error == nil){
                            print("saved bought button")
                        }
                    })
                }
                else {
                    print("could not save bought button")
                }
            }
        }
    
    func checkIfButtonWasBought(indexx:Int){
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.whereKey("boughtButtons", equalTo: indexx)
        
        query.getFirstObjectInBackground { (result, error) in
            if result == nil{
             print("Not bought yet")
                self.payButton(productLabel: "New Button", priceAmount: 2.00)
            }
            else {
               print("Already Bought")
                
            }
        }
    }
    
    func setUserCurrentButton(index:Int) {
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                object.setValue(index, forKey: "currentButton")
                object.saveInBackground(block: { (result, error) in
                    if error == nil {
                        self.performSegue(withIdentifier: "marketback", sender: self)
                        print("save success")
                    }else {
                        print("failed")
                    }
                })
            }
            else {
                print("could not set user current button")
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
    
    func payButton(productLabel: String , priceAmount:NSDecimalNumber){
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.stickerpaynow"
        request.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: productLabel , amount: priceAmount)
        ]
        
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self 
        self.present(applePayController!, animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        STPAPIClient.shared().createToken(with: payment) { (token, error) in
            print("created token")
            PFCloud.callFunction(inBackground: "ChargeCard", withParameters: ["token" : token?.tokenId ?? " " , ], block: { (response, error) in
                if response != nil{
                    let respons = response as! Bool
                    if respons == true{
                        completion(PKPaymentAuthorizationStatus.success)
                    }else{
                        self.displayMsg(titl: "Oops", Msg: "There was an error proccessing this transaction")
                        completion(PKPaymentAuthorizationStatus.failure)
                    }
                }
            })
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        self.saveButton(index: self.buttonAboutToBuy)
        self.setUserCurrentButton(index: self.buttonAboutToBuy)
    }
}


