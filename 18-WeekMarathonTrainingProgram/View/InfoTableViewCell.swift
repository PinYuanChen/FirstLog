//
//  InfoTableViewCell.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/3/20.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellBackgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        cellBackgroundView.layer.shadowOpacity = 0.8
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cellBackgroundView.layer.shadowRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
