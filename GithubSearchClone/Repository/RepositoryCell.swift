//
//  RepositoryCell.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

protocol RepoStarDelegate: AnyObject {
    
    func didTapStar(with index: Int)
}

class RepositoryCell: UITableViewCell {
    
    // MARK: -- Public Properties
    
    static let identifier: String = "RepositoryCell"
    
    weak var repoStarDelegate: RepoStarDelegate?
    
    // MARK: -- Public Method
    
    func updateUI(repository: Repository, index: Int) {
        
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
        
        self.startButton?.setImage(repository.isAddedStart ?
                                   UIImage(systemName: "star.fill") :
                                   UIImage(systemName: "star"),
                                   for: .normal)
        
        self.index = index
    }
    
    // MARK: -- Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.languageColorView?.cornerRound()
    }
    
    // MARK: -- Private Method
    
    @IBAction private func didTapStar(_ sender: UIButton) {
        
        guard let index = index else {
            
            return
        }
        
        self.repoStarDelegate?.didTapStar(with: index)
    }
    
    // MARK: -- Private Properties
    
    private var index: Int? = nil
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var repoNameAndOwnerLabel: UILabel?
    @IBOutlet private weak var repoIntroLabel: UILabel?
    @IBOutlet private weak var startButton: UIButton?
    
    @IBOutlet private weak var starCountLabel: UILabel?
    @IBOutlet private weak var languageColorView: UIView?
    @IBOutlet private weak var languageLabel: UILabel?
    @IBOutlet private weak var licenseLabel: UILabel?
}
