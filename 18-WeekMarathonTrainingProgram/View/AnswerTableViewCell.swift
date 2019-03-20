//
//  AnswerTableViewCell.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/3/12.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
