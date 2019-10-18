//  ViewController.swift
//  MichealsApp
//  Created by Oliver on 6/25/19.
//  Copyright © 2019 Addie. All rights reserved.

import UIKit
import PassKit
import Parse
import Stripe
import AVFoundation
import AVKit


class ViewController: UIViewController {
    @IBOutlet weak var PersonScoreLabel: UILabel!
    @IBOutlet weak var GlobalScoreLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    var firstT:Bool = false
    var presentedFirstT = false
    var globalIndex = 1
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var shouldPlay: Bool = false
    
    var player: AVAudioPlayer?
    func playAnimationAndSound(){
        
        self.playSound()
        self.shouldPlay = false
    }
    
    func playVideo(){
        print("trying to play video")
           avPlayer.play()
        print(avPlayer.reasonForWaitingToPlay.debugDescription)
        print("past play block")
      
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero,completionHandler: nil)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "cheering", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

     let imageArray = [ #imageLiteral(resourceName: "SilverButton") ,#imageLiteral(resourceName: "GoldMedalButton") , #imageLiteral(resourceName: "RadioActiveButton") , #imageLiteral(resourceName: "UnicornButton") , #imageLiteral(resourceName: "BrokenThumbsUpButton") , #imageLiteral(resourceName: "ScratchedThumbsUpButton") , #imageLiteral(resourceName: "PrestineGreenThumbsUpButton") , #imageLiteral(resourceName: "StickyNoteButton") , #imageLiteral(resourceName: "ButtonMadeOfWood") , #imageLiteral(resourceName: "GoldButton"), #imageLiteral(resourceName: "PoopEmogiButton")]
    
    
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        if(firstT == true){
            IncrementAll()
            tutorialSequence(index: globalIndex)
            saveButton(index: globalIndex)
              globalIndex += 1
            playAnimationAndSound()
            if globalIndex == 4 {
                self.firstT = false
                tutorialDone()
            }
          
            
            
        }
        else{
        
        if(sender.tag == 1){
        payButton(productLabel: "Button Press", priceAmount: 2.00 )
        }else{
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "toMarket", sender: self)
        }
        }
        }
    }
    
    
    @IBAction func marketButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            
        self.performSegue(withIdentifier: "toMarket", sender: self)
        }
    }
    //88888888899823456789876543456895
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserCurrentButton()
        getUserScore()
        getGlobalScore()
        if(presentedFirstT == false){
            firstTime()
            
        }
        
        
        let theUrl = Bundle.main.url(forResource: "Video", withExtension: "mp4")
        
        
        avPlayer = AVPlayer(url: theUrl!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear;
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: avPlayer.currentItem)
        avPlayer.play()
        if(self.shouldPlay == true){
            self.playAnimationAndSound()
            
            
          avPlayer.play()
            
        }
        
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func purchaseItem(){

    }
    
    func getUserScore(){
        var score = 0
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                score = object.object(forKey: "count")! as! Int
                self.PersonScoreLabel.text = String(score)
            }
            else {
                print("could not find user score")
            }
        }
    }
    func getUserCurrentButton() {
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                let index = object.object(forKey: "currentButton")! as! Int
                self.buyButton.setImage(self.imageArray[index], for: UIControl.State.normal)
            }
            else {
                print("could not find user score")
            }
        }
    }
    func firstTime() {
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                let first = object.object(forKey: "firstTime")! as! Bool
                if(first == true){
                    self.firstT = true
                    self.presentedFirstT = true
                    self.tutorialSequence(index: 0)
                    
                }
            }
            else {
                print("could not find userobj")
            }
        }
    }
    
    func tutorialSequence(index:Int){
        if(index == 0){
       displayMsg(titl: "Welcome to Press The Button!", Msg: "We've included 3 free button presses for you, go ahead and press the button!")
        }else if(index == 1){
            displayMsg(titl: "You did it!", Msg: "You've increased your personal & the world-wide score! You also unlocked a new button! Great Job! Press the button again to unlock a new button! ")
        }else if(index == 2){
            displayMsg(titl: "Great job!", Msg: "Press the button one more time!")
        }else if(index == 3){
            displayMsg(titl: "Sweet! You've unlocked 3 buttons!", Msg: "To change between your unlocked buttons & buy new ones, go to the market page from the top right of the screen!")
            
        }
    }
    
    func IncrementAll(){
        incrementUserScore()
        incrementGlobalScore()
        viewDidLoad()
    }
    
    
    func getGlobalScore() {
        var score = 0
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: "Global")
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                score = object.object(forKey: "count")! as! Int
                self.GlobalScoreLabel.text = String(score)
            }else{
                print("Couldnt find global score")
            }
        }
    }
    func incrementUserScore(){
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                object.incrementKey("count")
                object.saveInBackground(block: { (result, error) in
                    if error == nil{
                        print("save user score success")
                        self.viewDidLoad()
                    }
                })
            }
        }
    }
    func incrementGlobalScore(){
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: "Global")
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                object.incrementKey("count")
                object.saveInBackground(block: { (result, error) in
                    if error == nil{
                        print("save global scoresuccess")
                        self.viewDidLoad()
                    }
                })
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
                        self.setUserCurrentButton(index:index)
                    }
                })
            }
            else {
                print("could not save bought button")
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
                        print("save success")
                        self.getUserCurrentButton()
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
    
    func tutorialDone() {
        let query = PFQuery(className: "usercount")
        query.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let object = result!
                object.setValue(false, forKey: "firstTime")
                object.saveInBackground(block: { (result, error) in
                    if error == nil {
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
    
    
    }
extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        STPAPIClient.shared().createToken(with: payment) { (token, error) in
            print("created token")
            PFCloud.callFunction(inBackground: "ChargeCard", withParameters: ["token" : token?.tokenId ?? " " , ], block: { (response, error) in
                if response != nil{
                let respons = response as! Bool
                if respons == true{
                    self.incrementUserScore()
                    self.incrementGlobalScore()
                    self.shouldPlay = true
                    completion(PKPaymentAuthorizationStatus.success)
                }else{
                    completion(PKPaymentAuthorizationStatus.failure)
                }
                }
            })
        }
    }
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
      
        controller.dismiss(animated: true, completion: nil)
    }
}
