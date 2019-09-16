//
//  AlbumArtistTableViewCell.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/11/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit

class AlbumArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
