//
//  MainMenuController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import Firebase

class MainMenuController: UIViewController {

    var isBusiness: Bool?
    
    @IBAction func logOut(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
        goTo(identifier: "Login")
    }
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func toCalendar(_ sender: UIButton) {
        goTo(identifier: "Calendar")
    }
    @IBAction func toSearch(_ sender: UIButton) {
        goTo(identifier: "Search")
    }
    @IBAction func toEditProfile(_ sender: UIButton) {
        goTo(identifier: "Update Profile")
    }
    @IBOutlet weak var helloUserLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(goTo), with: "Login", afterDelay: 0.2)
        }else{
            adjustBusinessOrPrivate()
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            let ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let userDict = snapshot.value as! [String: Any]
                if(snapshot.hasChild("Business Name")){
                    let businessName = userDict["Business Name"] as? String
                    self.helloUserLabel.text = "Hello "+businessName!+"!"
                }else if(snapshot.hasChild("First Name") && snapshot.hasChild("Last Name")){
                    let firstName = userDict["First Name"] as? String
                    let lastName = userDict["Last Name"] as? String
                    self.helloUserLabel.text = "Hello "+firstName!+" "+lastName!+"!"
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goTo(identifier: String){
        self.performSegue(withIdentifier: identifier, sender: self)
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
                    self.searchButton.titleLabel?.text = "Search"
                }else{
                    self.isBusiness = true
                    self.searchButton.titleLabel?.text = "Requests"
                }
            }
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination is SearchController){
            let destination = segue.destination as? SearchController
            destination?.isBusiness = self.isBusiness
        }else if(segue.destination is CalendarController){
            let destination = segue.destination as? CalendarController
            destination?.isBusiness = self.isBusiness
        }
    }
}
