//
//  CharacterCell.swift
//  MarvelDatabase
//
//  Created by Work on 12/14/16.
//  Copyright © 2016 MJDoiron. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class CharacterCell: UITableViewCell {
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var publisherImageView: UIImageView!
    
    var character:Character?
    
    var downloadTask: URLSessionDataTask!
    
    func configure(for character: Character) {
        self.character = character
        nameLabel.text = character.name
        subNameLabel.text = character.subname
        
        if character.publisher == .Marvel {
            publisherImageView.image = #imageLiteral(resourceName: "marvelLogo")
        } else {
            publisherImageView.image = #imageLiteral(resourceName: "dcLogo")
        }
        
        if character.thumbnail != nil {
            characterImageView.image = character.thumbnail
        } else {
            Alamofire.request(character.thumbnailURL).responseData {
                response in
                if let error = response.result.error {
                    print(error)
                } else {
                    guard let image = UIImage(data: response.data!) else {
                        print("Couldnt covert data to image")
                        return
                    }
                    self.characterImageView.image = image
                    self.character!.thumbnail = image
                }
            }
        }
    }
    
    override func prepareForReuse() {
        characterImageView.image = nil
    }
}
