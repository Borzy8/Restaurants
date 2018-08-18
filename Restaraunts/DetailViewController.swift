//
//  detailViewController.swift
//  Restaraunts
//
//  Created by Игорь on 27.11.15.
//  Copyright © 2015 Ihor Malovanyi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet var restaurantImageView: UIImageView!
    
    @IBOutlet var tableView:UITableView!
    
    var fetchResultController: NSFetchedResultsController?
    
    var restaurant: Restaurant!
    
    var restaurantImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Дополнительные действия после загрузки view
        restaurantImageView.image = UIImage(data: restaurant.image!)
        
        // Сменить цвет TableView
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.2)
        
        // Убрать разделители пустых ячеек
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Сменить цвет разделителей
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        
        // Сменить title в navigationBar
        title = restaurant.name
        
        // Самомасштабирование
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Послать рейтинг ресторану ***
        if let rating = restaurant.rating where rating != "" {
            rateButton.setImage(UIImage(named: restaurant.rating!), forState: UIControlState.Normal)
        } 
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Data Source Protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RestaurantDetailCell
        
        // Настройка ячейки
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = NSLocalizedString("Name", comment: "Name field")
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = NSLocalizedString("Type", comment: "Type field")
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = NSLocalizedString("Location", comment: "Location field")
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = NSLocalizedString("Phone number", comment: "Phone number field")
            cell.valueLabel.text = restaurant.phoneNumber
        case 4:
            cell.fieldLabel.text = NSLocalizedString("Been here", comment: "Been here field")
            if let isVisited = restaurant.isVisited?.boolValue {
            cell.valueLabel.text = isVisited ? NSLocalizedString("Yes", comment: "Yes field") : NSLocalizedString("No", comment: "No field")
            }
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    @IBAction func close(segue: UIStoryboardSegue) {
        if let retingVC = segue.sourceViewController as? RateViewController {
            if let rating = retingVC.rating {
                
                let fetchRequest = NSFetchRequest(entityName: "Restaurant")
                let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                    
                    
                    
                    do {
                        let results = try? managedObjectContext.executeFetchRequest(fetchRequest) as![Restaurant]
                        for restaurantObj in results! {
                            if restaurantObj.name == restaurant.name {
                                restaurantObj.setValue(rating, forKey: "rating")
                                try managedObjectContext.save()
                                rateButton.setImage(UIImage(named: rating), forState: UIControlState.Normal)
                                print("saved")
                            }
                        }
                        
                    } catch {
                        print(error)
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let destinationViewController = segue.destinationViewController as! MapViewController
            destinationViewController.restaurant = restaurant
        }
    }
    
    @IBAction func makeCall(sender: UIButton){
        if restaurant.phoneNumber == nil {
            let alertController = UIAlertController(title: "Error", message: "This restaurant doesn’t have number to call", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Unable to call \(restaurant.phoneNumber!)", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}
