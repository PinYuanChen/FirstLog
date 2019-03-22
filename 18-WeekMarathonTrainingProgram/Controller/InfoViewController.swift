//
//  InfoViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/26.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetUp(target: self)
        self.navigationItem.title = "FAQ"
        tableView.register(AnswerTableViewCell.nib, forCellReuseIdentifier: AnswerTableViewCell.identifier)
        let headerNib = UINib.init(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeaderView")
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        headerView.delegate = self
        headerView.section = section
        return headerView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if faqArray[section].isExpanded {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AnswerTableViewCell.identifier, for: indexPath) as? AnswerTableViewCell {
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }

}

extension InfoViewController: HeaderViewDelegate {
    func didTappedHeaderView(section:Int) {
        let isExpanded = faqArray[section].isExpanded
        faqArray[section].isExpanded = !isExpanded
        var indexPaths = [IndexPath]()
        let indexPath = IndexPath(row: 0, section: section)
        indexPaths.append(indexPath)
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
}
