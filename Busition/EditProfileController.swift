//
//  EditProfileController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var isBusiness: Bool?
    var days = ["sun": "Sunday", "mon": "Monday","tue": "Tuesday","wed": "Wednesday","thu": "Thursday","fri": "Friday","sat": "Saturday"]
    
    @IBAction func `return`(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profilePicturePick(_ sender: UIButton) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        if let imageData = UIImagePNGRepresentation(self.profileImageView.image!){
            // print to user - pick profile image!
            let storageRef = Storage.storage().reference().child("\(uid).png")
            storageRef.putData(imageData,metadata: nil ,completion: { (metadata, error) in
                if(error != nil){
                    print(error!)
                    return
                }
                let ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid)
                
                var values = [String: String]()
                if(self.phoneNumberField.text != ""){
                    if(self.validatePhone(enteredPhone: self.phoneNumberField.text!)){
                        values["Phone Number"] = self.phoneNumberField.text
                    }else{
                        self.showToast(message: "Invalid Phone")
                        return
                    }
                }
                if(self.isBusiness)!{
                    if(self.field2.text != ""){
                        values["Address"] = self.field2.text
                    }
                    if(self.field1.text != ""){
                        values["Business Name"] = self.field1.text
                    }
                    let dayButtonList = self.dayPickStack.arrangedSubviews as? [UIButton]
                    dayButtonList?.forEach({ button in
                        if(button.isSelected){
                            values[self.days[button.title(for: .normal)!]!] = "yes"
                        }else{
                            values[self.days[button.title(for: .normal)!]!] = "no"
                        }
                    })
                    if(self.businessTypeField.text != ""){
                        values["Business Type"] = self.businessTypeField.text
                    }
                }else{
                    if(self.field2.text != ""){
                        values["Last Name"] = self.field2.text
                    }
                    if(self.field1.text != ""){
                         values["First Name"] = self.field1.text
                    }
                }

                if let profilePictureURL = metadata?.downloadURL()?.absoluteString{
                    values["Profile Picture URL"] = profilePictureURL
                    print("Picture successfully input")
                }else{
                    print("error with picture")
                    return
                }
                ref.updateChildValues(values)
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: UITextField!
    @IBOutlet weak var businessTypeField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var dayPickStack: UIStackView!
    @IBOutlet weak var businessTypeStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustBusinessOrPrivate()
        phoneNumberField.keyboardType = UIKeyboardType.numberPad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled image pick")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            self.profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func adjustBusinessOrPrivate(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(snapshot.hasChild("Type")){
                let userDict = snapshot.value as! [String: Any]
                
                let type = userDict["Type"] as? String
                if(type == "Private"){
                    self.isBusiness = false
                    
                    self.label1.text = "First Name:"
                    self.label2.text = "Last Name:"
                    
                    self.dayPickStack.isHidden = true
                    self.businessTypeStack.isHidden = true
                }else{
                    self.label1.text = "Business Name:"
                    self.label2.text = "Address:"
                    self.isBusiness = true
                    
                    self.businessTypeStack.isHidden = false
                    self.dayPickStack.isHidden = false
                }
            }
        })
    }
    func validatePhone(enteredPhone:String) -> Bool {
        let phoneFormat = "[0-9]+\\-[0-9]{10}"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneFormat)
        return phonePredicate.evaluate(with: enteredPhone)
    }
    
    @IBAction func sun(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func mon(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func tue(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func wed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func thu(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func fri(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func sat(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
