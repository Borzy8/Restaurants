//
//  DiscoverTableViewController.swift
//  Restaraunts
//
//  Created by Borzy on 07.08.18.
//  Copyright © 2018 Ihor Malovanyi. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var restaurants: [CKRecord] = []
    var imageCache: NSCache = NSCache()
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getRecordsFromCloud()
        
//        spinner.hidesWhenStopped = true
//        spinner.center = view.center
//        view.addSubview(spinner)
//        spinner.startAnimating()
        
        //refresh control
        
//        refreshControl = UIRefreshControl()
//        refreshControl?.backgroundColor = UIColor.whiteColor()
//        refreshControl?.tintColor = UIColor.grayColor()
//        refreshControl?.addTarget(self, action: "getRecordsFromCloud", forControlEvents: UIControlEvents.ValueChanged)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }
    
    func getRecordsFromCloud() {
        
        var newRestaurantsFromCloud: [CKRecord] = []
        
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: false)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .VeryHigh
        queryOperation.resultsLimit = 50
        
        queryOperation.recordFetchedBlock = {(record: CKRecord!)-> Void in
            if let restaurantRecord = record {
                newRestaurantsFromCloud.append(restaurantRecord)
            }
        
        }
        
        queryOperation.queryCompletionBlock = {(cursor: CKQueryCursor?, error: NSError?) -> Void in
        
            if let error = error {
                print(error)
            }
            print("Success")
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.restaurants = newRestaurantsFromCloud 
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                self.refreshControl?.endRefreshing()
            }
        
        }
        
        publicDatabase.addOperation(queryOperation)
        
//        publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {(result, error) -> Void in
//        
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            if let result = result {
//                self.restaurants = result
//                NSOperationQueue.mainQueue().addOperationWithBlock() {
//                        self.tableView.reloadData()
//                }
//                
//            }
//        })
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("id", forIndexPath: indexPath) as! DiscoverTableViewCell

        // Configure the cell...
        let restaurant = restaurants[indexPath.row]
        
        cell.nameLabel?.text = restaurant.objectForKey("name") as?  String
        
        cell.customImageView.image = UIImage(named: "photoalbum")
        //cache
        
        if let imageUrl = imageCache.objectForKey(restaurant.recordID) as? NSURL {
            cell.customImageView?.image = UIImage(data: NSData(contentsOfURL: imageUrl)!)
            
        } else {
            // iCloud
            let publicDataBase = CKContainer.defaultContainer().publicCloudDatabase
            let fetchRecordImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordImageOperation.desiredKeys = ["photo"]
            fetchRecordImageOperation.queuePriority = .VeryHigh
            
            fetchRecordImageOperation.perRecordCompletionBlock = {(record: CKRecord?, recordId: CKRecordID?, error: NSError?) -> Void in
                
                if let error = error {
                    print(error)
                }
                
                if let restaurantRecord = record {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if let imageAsset = restaurantRecord.objectForKey("photo") as? CKAsset {
                            cell.customImageView?.image = UIImage(data: NSData(contentsOfURL: imageAsset.fileURL)!)
                            self.imageCache.setObject(imageAsset.fileURL, forKey: restaurantRecord.recordID)
                        }
                    }
                }
            }
            publicDataBase.addOperation(fetchRecordImageOperation)

        }
                return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
