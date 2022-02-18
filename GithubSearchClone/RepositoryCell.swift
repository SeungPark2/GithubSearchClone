//
//  RepositoryCell.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    static let identifier: String = "RepositoryCell"
    
    func updateUI(repository: Repository) {
        
        self.repositNameAndOwnerLabel?.text = "\(repository.name)/" +
                                             "\(repository.owner.name)"
        self.repositIntroLabel?.text = repository.introduce
        
//        self.starCountLabel?.text =
        self.languageLabel?.text = repository.language
        self.licenseLabel?.text = repository.license.name
    }
    
    @IBOutlet private weak var repositNameAndOwnerLabel: UILabel?
    @IBOutlet private weak var repositIntroLabel: UILabel?
    @IBOutlet private weak var startButton: UIButton?
    
    @IBOutlet private weak var starCountLabel: UILabel?
    @IBOutlet private weak var languageLabel: UILabel?
    @IBOutlet private weak var licenseLabel: UILabel?
}
