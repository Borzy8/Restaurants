//
//  Restaurant.swift
//  Restaraunts
//
//  Created by Borzy on 04.08.18.
//  Copyright © 2018 Ihor Malovanyi. All rights reserved.
//

import Foundation
import CoreData


class Restaurant: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var location: String
    @NSManaged var isVisited: NSNumber?
    @NSManaged var image: NSData?
    @NSManaged var rating: String?
    @NSManaged var phoneNumber: String?


}
