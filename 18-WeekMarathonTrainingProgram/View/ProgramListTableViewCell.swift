//
//  ProgramListTableViewCell.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ProgramListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
