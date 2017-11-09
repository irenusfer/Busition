//
//  LoginController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    final var SIGN_IN: Int = 0
    final var REGISTER: Int = 1
    final var PRIVATE_PROFILE = 0
    final var BUSINESS_PROFILE = 1
    
    var password: String = ""
    var email: String = ""
    
    @IBOutlet weak var segmented_profile_type: UISegmentedControl!
    
    @IBOutlet weak var profileTypeView: UIStackView!
    
    @IBOutlet weak var segmented_signIn_register: UISegmentedControl!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBAction func submit(_ sender: UIButton) {
        if(getEmail()){
            if(getPassword()){
                if(segmented_signIn_register.selectedSegmentIndex == SIGN_IN){
                    print("At Sign In")
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if user != nil {
                            self.dismiss(animated: true, completion: nil)
                        }else{
                            
                        }
                    }
                }else{
                    print("At Register")
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        
                        if user != nil {
                            guard let uid = user?.uid else{
                                return
                            }
                            let ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid)
                            var values: [String: Any]?
                            values = [:]
                            User.data.forEach({ (data) in
                                values?[data] = ""
                            })
                            values?["Email"] = self.email
                            values?["Password"] = self.password
                            values?["UID"] = uid
                            if(self.segmented_profile_type.selectedSegmentIndex == self.PRIVATE_PROFILE){
                                print("private profile")
                                values?["Type"] = "Private"
                                PrivateUser.privateData.forEach({ (data) in
                                    values?[data] = ""
                                })
                            }else{
                                print("business profile")
                                values?["Type"] = "Business"
                                BusinessUser.businessData.forEach({ (data) in
                                    values?[data] = ""
                                })
                                BusinessUser.days.forEach({ (day) in
                                    values?[day] = "no"
                                })
                            }
                            ref.updateChildValues(values!)
                            print("Added new Account")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }else{
                //Print incorrect password pattern
                showToast(message: "Password is too short at least 8 digits")
            }
        }else{
            //Print incorrect Email pattern
            showToast(message: "Email should look like person@example.com")
        }
    }
    @IBAction func selectorChanged(_ sender: UISegmentedControl) {
        submitBtn.setTitle(segmented_signIn_register.titleForSegment(at: segmented_signIn_register.selectedSegmentIndex), for: .normal)
        profileTypeView.isHidden = !profileTypeView.isHidden
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailField.keyboardType = UIKeyboardType.emailAddress
        submitBtn.setTitle(segmented_signIn_register.titleForSegment(at: segmented_signIn_register.selectedSegmentIndex), for: .normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getEmail() -> Bool{
        email = emailField.text!
        return validateEmail(enteredEmail: email)
    }
    func getPassword() -> Bool{
        password = passwordField.text!
        return validatePassword(password)
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validatePassword(_ password : String) -> Bool{
        let passWordFormat = "[A-Z0-9a-z._%+-]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passWordFormat)
        return passwordTest.evaluate(with: password)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
