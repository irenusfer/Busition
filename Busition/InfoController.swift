//
//  InfoController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import Firebase

class InfoController: UIViewController {

    var isBusiness: Bool?
    var user: User?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var workDaysLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var businessTypeLabel: UILabel!
    
    @IBAction func `return`(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustBusinessOrPrivate()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func adjustBusinessOrPrivate(){
        if let url = URL(string: (user?.imageURL)!){
            URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                    
                }
            }).resume()
        }
        if(isBusiness!){
            let businessUser = user as? BusinessUser
            nameLabel.text = businessUser?.businessName
            addressLabel.text = "Address: "+(businessUser?.address)!
            workDaysLabel.text = "Working Days: "
           BusinessUser.days.forEach({ (day) in
            if(businessUser?.workDays[day] == true){
                workDaysLabel.text?.append(day+",")
            }
           })
            businessTypeLabel.text = "Business Type: "+(businessUser?.businessType)!
        }else{
            let privateUser = user as? PrivateUser
            nameLabel.text = (privateUser?.firstName)!+" "+(privateUser?.lastName)!
            addressLabel.isHidden = true
            workDaysLabel.isHidden = true
            businessTypeLabel.isHidden = true
        }
        phoneNumberLabel.text = "Phone Number: "+(user?.phoneNumber)!
    }
}
