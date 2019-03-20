//
//  HeaderViewCell.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/3/12.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func toggleSection(header: HeaderViewCell, section: Int)
}

class HeaderViewCell: UITableViewHeaderFooterView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static var identifier: String {
        return String(describing: self)
    }
    
}
