//
//  OTPViewController.swift
//  Kenakata
//
//  Created by Md Sifat on 6/10/20.
//  Copyright © 2020 Md Sifat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import AlamofireImage
import Realm
import RealmSwift

class OTPViewController: UIViewController {
    
    enum RegistrationError: Error {
        case registrationFailed
    }
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var otp1TxtField: UITextField!
    @IBOutlet weak var otp2TxtField: UITextField!
    @IBOutlet weak var otp3TxtField: UITextField!
    @IBOutlet weak var otp4TxtField: UITextField!
    @IBOutlet weak var otp5TxtField: UITextField!
    @IBOutlet weak var otp6TxtField: UITextField!
    var mobileNumber = ""
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var uniqUserName = ""
    var postcode = ""
    var phone = ""
    var billing : [String:Any] = [:]
    var shipping : [String:Any] = [:]
    var regData : [String:Any] = [:]
    var otpCode: String?
    var userEmail: String?
    var userPass = ""
    var checkOtp: String?
    var apiUsername = "afiqsouq2021"
    var apiPass = "12afiqsouq3434$"
    
    let otpSendUrl = "http://66.45.237.70/api.php?"
    let loginURL = "https://afiqsouq.com/api/user/generate_auth_cookie?"
    let regURL = "https://afiqsouq.com//wp-json/wc/v3/customers?consumer_key=ck_62eed78870531071b419c0dca0b1dd9acf277227&consumer_secret=cs_a5b646ab7513867890dd63f2c504af98f00cee53"
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let sms = "Welcome to AfiqSouq.com. Your OTP is : \(self.otpCode!)"
        //
        //        let params = ["username": apiUsername, "password": apiPass, "number": mobileNumber, "message": sms ]
        //        Alamofire.request(otpSendUrl, method: .get, parameters: params as Parameters).validate(statusCode: 200..<299).responseJSON(completionHandler: {response in
        //            switch response.result {
        //            case .success:
        //                if let value = response.result.value{
        //                    let data = JSON(value)
        //                    print("Data\(data)")
        //
        //                }
        //
        //            case .failure( let error):
        //                print(error)
        //                print(".....")
        //            }
        //
        //        })
        print("OTP : \(self.otpCode!)")
    }
    
    func newRequest(json: [String:Any]) throws{
        var success = false
        let url = URL(string: regURL)!
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options:[])
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            Alamofire.request(request).validate(statusCode: 200..<299).responseJSON(completionHandler: {
                (response) in
                switch response.result {
                case .success(let data):
                    success = true
                    print(data)
                case .failure(let error):
                    success = false
                    print(error)

                }
            })
        } catch {
            success = false
            print("Failed to serialise and send JSON")
        }
        
        if !success{
            throw RegistrationError.registrationFailed
        }
        
    }
    
    @IBAction func onClickVarifyBtn(_ sender: Any) {
        print("OTP : \(self.otpCode!)")
        print("OTP : \(self.otp1TxtField.text!)\(self.otp2TxtField.text!)\(self.otp3TxtField.text!)\(self.otp4TxtField.text!)\(self.otp5TxtField.text!)\(self.otp6TxtField.text!)")
        if "Welcome to AfiqSouq.com. Your OTP is : \(self.otpCode!)" == "Welcome to AfiqSouq.com. Your OTP is : \(self.otp1TxtField.text!)\(self.otp2TxtField.text!)\(self.otp3TxtField.text!)\(self.otp4TxtField.text!)\(self.otp5TxtField.text!)\(self.otp6TxtField.text!)"{
            SVProgressHUD.show(withStatus: "Loading...")
            
            //            let dict: Dictionary<String, Any> = ["password": self.userPass!, "email": self.email, "first_name": self.firstName, "last_name": self.lastName, "username": self.uniqUserName, "billing": self.billing, "shipping": self.shipping, ]
            //            print(dict)
            let customKeys = ["email", "first_name", "password", "last_name", "username", "billing", "shipping", ]
            let customValues = [self.email, self.firstName, self.userPass, self.lastName, self.uniqUserName, self.billing, self.shipping, ] as [Any]
            let neDictionary = Dictionary(uniqueKeysWithValues: zip(customKeys,customValues))
            self.regData = neDictionary as [String: Any]
            
            //            let dic: Dictionary<String, Any> = ["email": self.email, "first_name": self.firstName, "password": self.userPass, "last_name": self.lastName, "username": self.uniqUserName, "billing": self.billing, "shipping": self.shipping, ]
            
            print(self.regData)
            do {
                try newRequest(json: self.regData)
                            let params = ["email": userEmail!, "password": userPass]
                              Alamofire.request(loginURL, method: .post, parameters: params as Parameters).validate(statusCode: 200..<299).responseJSON(completionHandler: { response in
                                  switch response.result {
                                  case .success:
                                      if let value = response.result.value{
                                          let data = JSON(value)
                                          print("Data\(data)")
                                          let token = data["cookie"]
                                          let user = data["user"]["email"]
                                          UserDefaults.standard.setLoggedIn(tokenText: token)
                                          if [self.userEmail!] == [user]{
                                              self.changeRootView()
                                          }
                                      }
                  
                                  case let .failure(error):
                                      print(error)
                                      print("Wrong")
                                  }
                  
                              })

                
            } catch RegistrationError.registrationFailed {
    
                let alertController = UIAlertController(title: "Unable To Register!", message: "There was an error when attempting to Register", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUp")
                    self.present(signUpVC, animated: false)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

            } catch {
                Alert.showBasic(title: "Unable To Login", message: "There was an error when attempting to login", vc: self)
                
            }
            
//            let jsonObject = try? JSONSerialization.data(withJSONObject: self.regData, options: JSONSerialization.WritingOptions.prettyPrinted)
//            print(NSString(data: jsonObject!, encoding: String.Encoding.utf8.rawValue)!)
//
//
//            // let userDatas = try? JSONSerialization.data(withJSONObject: self.regData )
//            //            Alamofire.upload(multipartFormData: { (multiFoormData) in
//            //                multiFoormData.append(jsonObject!, withName: "data")
//            //
//            //            }, to: regURL, method: .post, headers: nil) { encodingResult in
//            //                switch encodingResult {
//            //                case .success(let upload, _, _):
//            //                    upload.response { answer in
//            //
//            //                        print("statusCode: \(answer.response?.statusCode)")
//            //
//            //                    }
//            //                    upload.uploadProgress { progress in
//            //                        //call progress callback here if you need it
//            //                    }
//            //                case .failure(let encodingError):
//            //                    print("multipart upload encodingError: \(encodingError)")
//            //                }
//            //            }
            //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                    let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUp")
            //                    self.present(signUpVC, animated: false)
            //            let userData = try? JSONSerialization.data(withJSONObject: dict)
            //            Alamofire.upload(multipartFormData: { (multiFoormData) in
            //                multiFoormData.append(userData!, withName: "data")
            //
            //            }, to: regURL, method: .post, headers: nil) { encodingResult in
            //                switch encodingResult {
            //                case .success(let upload, _, _):
            //                    upload.response { answer in
            //
            //
            //                        print(answer)
            //                        print("statusCode: \(answer.response?.statusCode)")
            //
            //                    }
            //                    upload.uploadProgress { progress in
            //                        //call progress callback here if you need it
            //                    }
            //                case .failure(let encodingError):
            //                    print("Here is error...")
            //                    print("multipart upload encodingError: \(encodingError)")
            //                }
            //            }
            //
            //            let headers: HTTPHeaders =
  
            
        }else{
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        otp1TxtField.becomeFirstResponder()
        otp1TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        otp2TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        otp3TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        otp4TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        otp5TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        otp6TxtField.addTarget(self, action: #selector(textdidCgange(textfield:)), for: UIControl.Event.editingChanged)
        
    }
    
    func changeRootView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mainTabBar")
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    @objc func textdidCgange(textfield: UITextField){
        let text = textfield.text
        if text?.utf16.count == 1{
            switch textfield {
            case otp1TxtField:
                otp2TxtField.becomeFirstResponder()
                break
                
            case otp2TxtField:
                otp3TxtField.becomeFirstResponder()
                break
                
            case otp3TxtField:
                otp4TxtField.becomeFirstResponder()
                break
                
            case otp4TxtField:
                otp5TxtField.becomeFirstResponder()
                break
                
            case otp5TxtField:
                otp6TxtField.becomeFirstResponder()
                break
                
            case otp6TxtField:
                otp6TxtField.resignFirstResponder()
                break
                
            default:
                break
            }
        }else{
            
        }
        
    }
}
