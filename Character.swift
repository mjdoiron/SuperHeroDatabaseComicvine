//
//  Character.swift
//  SuperHeroDatabase
//
//  Created by Work on 4/13/17.
//  Copyright © 2017 mjdoiron. All rights reserved.
//

import Foundation
import UIKit

class Character {
    
    var hasBasicData = false
    var hasFullData = false
    
    //Basic Data
    var id = 0
    var name = ""
    var subname = ""
    var publisher:Publisher = .Marvel
    
    //Full Data
    var friends:[Character] = []
    var enemies:[Character] = []
    
    //Images
    var thumbnailURL: URL!
    var fullsizeURL: URL!
    
    var thumbnail: UIImage?
    var fullsizePic: UIImage?

    
    init(name: String, id: Int, publisher: Publisher, thumbnailURL: URL, fullSizeURL: URL) {
        set(name: name)
        self.id = id
        self.publisher = publisher
        self.thumbnailURL = thumbnailURL
        self.fullsizeURL = fullSizeURL
    }
    
    func set(name:String) {
        let nameArray = name.components(separatedBy: " (")
        self.name = nameArray[0]
        if nameArray.count > 1 {
            self.subname = "(" + nameArray[1]
        }
    }
}
