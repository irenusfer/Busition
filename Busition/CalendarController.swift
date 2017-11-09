//
//  CalendarController.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase

class CalendarController: UIViewController , UITableViewDelegate,UITableViewDataSource{
    
    var isBusiness: Bool?
    let formatter = DateFormatter()
    var events: [Event]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBAction func `return`(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        events = []
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCalendar()
    }
    
    func setupCalendar(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates{visibleDates in
            self.setupViewsOfCalendar(visibleDates: visibleDates)
        }
    }
    
    func setupViewsOfCalendar(visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    func handleCellTextColor(view: JTAppleCell? , cellState: CellState){
        guard let cell = view as? CustomCell else{
            return
        }
        if (cellState.isSelected){
            cell.dateLabel.textColor = UIColor.white
        }else{
            if(cellState.dateBelongsTo == .thisMonth){
                cell.dateLabel.textColor = UIColor.black
            }else{
                cell.dateLabel.textColor = UIColor.gray
            }
        }
    }
    func handleCellSelected(view: JTAppleCell? , cellState: CellState){
        guard let validCell = view as? CustomCell else{
            return
        }
        if(cellState.isSelected){
            validCell.selectedView.isHidden = false
        }else{
            validCell.selectedView.isHidden = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.events?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableCell", for: indexPath) as? CalenderTableCell
        let event = events?[indexPath.row]
        
        cell?.timeLabel.text = "\(event?.date ?? Date())"
        if(self.isBusiness)!{
            cell?.nameLabel.text = (event?.user?.firstName)!+" "+(event?.user?.lastName)!
            
            if let profileImageURL = event?.user?.imageURL{
                if let url = URL(string: profileImageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            cell?.pictureView?.image = UIImage(data: data!)
                            
                        }
                    }).resume()
                }
            }
        }else{
            if let profileImageURL = event?.business?.imageURL{
                if let url = URL(string: profileImageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            cell?.pictureView?.image = UIImage(data: data!)
                            
                        }
                    }).resume()
                }
            }
            cell?.nameLabel.text = event?.business?.businessName
        }
        return cell!
    }
}
extension CalendarController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 11 01")
        let endDate = formatter.date(from: "2018 12 31")
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
}
extension CalendarController: JTAppleCalendarViewDelegate{
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        handleCellSelected(view: cell , cellState: cellState)
        handleCellTextColor(view: cell , cellState: cellState)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell , cellState: cellState)
        handleCellTextColor(view: cell , cellState: cellState)
        
        let startDate = date.addingTimeInterval(60*60*2)
        let endDate = date.addingTimeInterval(60*60*2+60*60*24)
        
        self.events = []
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        Database.database().reference().child("Users").child(uid).child("Approved Requests").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let eventDate = Date(timeIntervalSince1970: (dictionary["Date"] as? TimeInterval)!)
                
                if(eventDate >= startDate && eventDate < endDate){
                    let user = PrivateUser()
                    user.firstName = dictionary["User First Name"] as? String
                    user.lastName = dictionary["User Last Name"] as? String
                    user.phoneNumber = dictionary["User Phone Number"] as? String
                    user.imageURL = dictionary["User Image URL"] as? String
                    
                    let business = BusinessUser()
                    business.businessName = dictionary["Business Name"] as? String
                    business.address = dictionary["Address"] as? String
                    business.businessType = dictionary["Business Type"] as? String
                    business.phoneNumber = dictionary["Business Phone Number"] as? String
                    business.imageURL = dictionary["Business Image URL"] as? String
                    
                    let event = Event()
                    event.user = user
                    event.business = business
                    event.date = eventDate
                    
                    self.events?.append(event)
                }
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell , cellState: cellState)
        handleCellTextColor(view: cell , cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(visibleDates: visibleDates)
    }
}
