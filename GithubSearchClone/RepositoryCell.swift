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
        
        self.repoNameAndOwnerLabel?.text = "\(repository.owner.name)/" +
                                              "\(repository.name)"
        self.repoNameAndOwnerLabel?.changeTextColorAndFont(
            changeTexts: [repository.name],
            colors: [nil],
            fonts: [.boldSystemFont(ofSize: 16)]
        )
        self.repoIntroLabel?.text = repository.introduce
        
        self.starCountLabel?.text = repository.starCount?.convertToKilo() ?? "0"
        self.languageColorView?.backgroundColor = UIColor.colorBy(language: repository.language)
        self.languageLabel?.text = repository.language
        self.licenseLabel?.text = repository.license.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.languageColorView?.cornerRound()
    }
    
    @IBOutlet private weak var repoNameAndOwnerLabel: UILabel?
    @IBOutlet private weak var repoIntroLabel: UILabel?
    @IBOutlet private weak var startButton: UIButton?
    
    @IBOutlet private weak var starCountLabel: UILabel?
    @IBOutlet private weak var languageColorView: UIView?
    @IBOutlet private weak var languageLabel: UILabel?
    @IBOutlet private weak var licenseLabel: UILabel?
}
