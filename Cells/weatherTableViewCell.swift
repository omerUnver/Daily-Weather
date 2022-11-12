//
//  weatherTableViewCell.swift
//  Daily Weather
//
//  Created by M.Ömer Ünver on 13.11.2022.
//

import UIKit

class weatherTableViewCell: UITableViewCell {

    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var gunImageView: UIImageView!
    @IBOutlet weak var gunLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
