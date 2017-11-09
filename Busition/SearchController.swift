//
//  SearchController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import Firebase

class SearchController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    var users: [BusinessUser]?
    var requests: [Event]?
    var isBusiness: Bool?
    var searchDay: String?
    var selectedCellUser: BusinessUser?
    var selectedCellRequest: Event?
    var selectedDate: Date?
    let datePicker = UIDatePicker()
    var reqUser: PrivateUser?
    var obRef: UInt?
    var ref: DatabaseReference?
    
    @IBAction func `return`(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func search(_ sender: UIButton) {
        if(isBusiness!){
            
        }else{
            let f = DateFormatter()
            searchDay = f.weekdaySymbols[Calendar.current.component(.weekday, from: datePicker.date)-1]
            print(searchDay ?? "no date")
            users = []
            fetchUsers()
        }
    }
    @IBAction func requestOrApprove(_ sender: UIButton) {
        if(isBusiness!){
            if(selectedCellRequest != nil){
                approveRequest(request: selectedCellRequest!)
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(message: "No Request Selected")
            }
        }else{
            if(selectedCellUser != nil && selectedDate != nil){
                makeRequest(business: selectedCellUser!,date: selectedDate!)
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(message: "No Business Selected")
            }
        }
    }
    @IBAction func decline(_ sender: UIButton) {
        if(selectedCellRequest != nil){
            rejectRequest(request: selectedCellRequest!)
        }
    }
    
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        DispatchQueue.main.async {
            self.adjustBusinessOrPrivate()
        }
        if(isBusiness != nil && isBusiness!){
            requests = []
            fetchEvents()
        }else{
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users")
            ref?.keepSynced(true)
            obRef = ref?.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any]{
                    if(dictionary["UID"] as? String == uid){
                        let requestingUser = PrivateUser()
                        requestingUser.firstName = dictionary["First Name"] as? String
                        requestingUser.lastName = dictionary["Last Name"] as? String
                        requestingUser.phoneNumber = dictionary["Phone Number"] as? String
                        requestingUser.UID = dictionary["UID"] as? String
                        requestingUser.imageURL = dictionary["Profile Picture URL"] as? String
                        
                        self.reqUser = requestingUser
                    }
                }
            })

            users = []
            createDatePicker()
        }
    }
    
    func createDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePickingDate))
        toolbar.setItems([doneButton], animated: true)
        
        dayField.inputAccessoryView = toolbar
        dayField.inputView = datePicker
    }
    func donePickingDate(){
        dayField.text = "\(datePicker.date)"
        selectedDate = datePicker.date
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func adjustBusinessOrPrivate(){
        if(self.isBusiness != nil && self.isBusiness!){
            self.titleLabel.text = "Approve/Reject"
            self.searchBar.isHidden = true
            self.searchButton.isHidden = true
            self.dayField.isHidden = true
            self.dateLabel.isHidden = true
            self.button2.titleLabel?.text = "Approve"
        }else{
            button1.isHidden = true
            self.titleLabel.text = "Search/Schedule"
        }
    }
    func fetchUsers(){
        ref?.removeObserver(withHandle: obRef!)
        ref = Database.database().reference().child("Users")
        self.obRef = ref?.observe( .childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                if(dictionary["Type"] as? String == "Business"){
                    let newUser = BusinessUser()
                    newUser.address = dictionary["Address"] as? String
                    newUser.businessName = dictionary["Business Name"] as? String
                    newUser.businessType = dictionary["Business Type"] as? String
                    newUser.phoneNumber = dictionary["Phone Number"] as? String
                    newUser.imageURL = dictionary["Profile Picture URL"] as? String
                    newUser.UID = dictionary["UID"] as? String
                    BusinessUser.days.forEach({ (day) in
                        let dayCheck = dictionary[day] as? String
                        if(dayCheck == "yes"){
                            newUser.workDays[day] = true
                        }else{
                            newUser.workDays[day] = false
                        }
                    })
                    self.users?.append(newUser)
                }
            }
            self.users?.forEach({ (user) in
                if(self.searchBar.text != user.businessType || user.workDays[(self.searchDay)!] == false){
                    self.users?.remove(at: (self.users?.index(of: user))!)
                }
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.users == nil || (self.users?.count)! <= 0){
            if(self.requests != nil && (self.requests?.count)! >= 0){
                return (self.requests?.count)!
            }
        }
        return (self.users?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell
        
        if(self.isBusiness)!{
            if(self.requests == nil || self.requests! == []){
                return cell!
            }
            let request = self.requests?[indexPath.row]
            if let reqDate = request?.date{
                cell?.nameLabel.text = "\(reqDate)"
            }
            if let profileImageURL = request?.user?.imageURL{
                if let url = URL(string: profileImageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            cell?.photoView?.image = UIImage(data: data!)
                            
                        }
                    }).resume()
                }
            }
            
        }else{
            if(self.users == nil || self.users! == []){
                return cell!
            }
            let user = self.users?[indexPath.row]
            cell?.nameLabel.text = user!.businessName
            if let profileImageURL = user?.imageURL{
                if let url = URL(string: profileImageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            cell?.photoView?.image = UIImage(data: data!)
                            
                        }
                    }).resume()
                }
            }
        }
        cell?.infoButton.tag = indexPath.row
        cell?.infoButton.addTarget(self, action: #selector(cellButtonAction), for: .touchUpInside)
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isBusiness)!{
            self.selectedCellRequest = self.requests?[indexPath.row]
        }else{
            self.selectedCellUser = self.users?[indexPath.row]
        }
    }
    func cellButtonAction(sender: UIButton){
        if(self.isBusiness)!{
            self.performSegue(withIdentifier: "Info", sender: requests?[sender.tag].user)
        }else{
            self.performSegue(withIdentifier: "Info", sender: users?[sender.tag])
        }
    }
    
    func fetchEvents(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid).child("Requests")
        ref?.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let newEvent = Event()
                newEvent.date = Date(timeIntervalSince1970: (dictionary["Date"] as? TimeInterval)!)
                newEvent.UID = dictionary["Request UID"] as? String
                
                let requestUser = PrivateUser()
                requestUser.UID = dictionary["User UID"] as? String
                requestUser.firstName = dictionary["User First Name"] as? String
                requestUser.lastName = dictionary["User Last Name"] as? String
                requestUser.phoneNumber = dictionary["User Phone Number"] as? String
                requestUser.imageURL = dictionary["User Image URL"] as? String
                
                newEvent.user = requestUser
                
                self.requests?.append(newEvent)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func makeRequest(business: BusinessUser , date: Date){
        ref?.removeObserver(withHandle: obRef!)
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users")
        let requestUUID = UUID.init()
        var requestValues = [String:Any]()
        
        requestValues["User First Name"] = reqUser?.firstName
        requestValues["User Last Name"] = reqUser?.lastName
        requestValues["User Phone Number"] = reqUser?.phoneNumber
        requestValues["User UID"] = reqUser?.UID
        requestValues["User Image URL"] = reqUser?.imageURL
        
        requestValues["Date"] = date.timeIntervalSince1970
        
        requestValues["Business Name"] = business.businessName
        requestValues["Business Type"] = business.businessType
        requestValues["Business Phone Number"] = business.phoneNumber
        requestValues["Address"] = business.address
        requestValues["Business UID"] = business.UID
        requestValues["Business Image URL"] = business.imageURL
        
        requestValues["Request UID"] = requestUUID.uuidString
        
        
        ref?.child(uid).child("Requests").child(requestUUID.uuidString).updateChildValues(requestValues)
        ref = Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(business.UID!)
        ref?.child("Requests").child(requestUUID.uuidString).updateChildValues(requestValues)
    }
    func approveRequest(request: Event){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //1st input
        Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid).child("Requests").observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChild(request.UID!)){
                
                //Move to accepted requests
                Database.database().reference().child("Users").child(uid).child("Approved Requests").setValue(snapshot.value)
                Database.database().reference().child("Users").child((request.user?.UID)!).child("Approved Requests").setValue(snapshot.value)
                
                //Remove from previous path
                Database.database().reference().child("Users").child(uid).child("Requests").child(request.UID!).removeValue()
                Database.database().reference().child("Users").child((request.user?.UID)!).child("Requests").child(request.UID!).removeValue()
            }
        })
    }
    func rejectRequest(request: Event){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        Database.database().reference(fromURL: "https://busition-fcc73.firebaseio.com/").child("Users").child(uid).child("Requests").observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChild(request.UID!)){
                //Remove requests from firebase
                Database.database().reference().child("Users").child(uid).child("Requests").child(request.UID!).removeValue()
                Database.database().reference().child("Users").child((request.user?.UID)!).child("Requests").child(request.UID!).removeValue()
            }
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? InfoController
        destination?.isBusiness = !(self.isBusiness!)
        destination?.user = sender as? User
    }
}
