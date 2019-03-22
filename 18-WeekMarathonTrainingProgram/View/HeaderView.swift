//
//  HeaderView.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/3/21.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func didTappedHeaderView(section:Int)
}

class HeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    var section = 0
    weak var delegate: HeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedHeader)))
    }
    
    @objc private func tappedHeader() {
        delegate?.didTappedHeaderView(section:section)
    }
    
}
