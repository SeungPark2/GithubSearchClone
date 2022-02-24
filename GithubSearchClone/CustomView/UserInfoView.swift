//
//  UserInfoView.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/23.
//

import UIKit

import Kingfisher

class UserInfoView: UIView {
    
    init(frame: CGRect, user: User) {
        super.init(frame: frame)
        
        self.downloadImage(with: user.imageURL)
        self.nameLabel.text = user.name
        self.companyButton.setTitle(user.company == "" ? "없음" : user.company,
                                    for: .normal)
        self.followerInfoButton.setTitle("\(user.followers) followers · " +
                                         "\(user.following) following",
                                         for: .normal)
        self.grayLineView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func downloadImage(with imageURL: String) {
        
        KF.url(URL(string: imageURL))
          .loadDiskFileSynchronously()
          .cacheMemoryOnly()
          .fade(duration: 0.25)
          .roundCorner(radius: .widthFraction(40))
          .onFailure { error in print(error.localizedDescription) }
          .set(to: self.userImageView)
    }
    
    private lazy var userImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.top(target: self,
                      targetPosition: .top,
                      constant: 20)
        imageView.leading(target: self,
                          targetPosition: .leading,
                          constant: 20)
        imageView.bottom(target: self,
                         targetPosition: .bottom,
                         constant: -20)
        imageView.width(constant: 80)
        
        return imageView
    }()
    
    private lazy var followerInfoButton: UIButton = {
       
        let button = UIButton()
                        .withFont(.systemFont(ofSize: 14))
                        .withTextColor(.white)
                        .withImage(UIImage(systemName: "person.fill"))
                        .withImageColor(.white)
                        .withAlignment(.leading)
                        .withTitlePadding(UIEdgeInsets(top: 0,
                                                       left: 4,
                                                       bottom: 0,
                                                       right: 0))
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        button.leading(target: self.userImageView,
                       targetPosition: .trailing,
                       constant: 16)
        button.trailing(target: self,
                        targetPosition: .trailing,
                        constant: -20)
        button.bottom(target: self.userImageView,
                      targetPosition: .bottom)
        button.height(constant: 20)
        
        return button
    }()
    
    private lazy var companyButton: UIButton = {
       
        let button = UIButton()
                        .withFont(.systemFont(ofSize: 14))
                        .withTextColor(.white)
                        .withImage(UIImage(systemName: "building"))
                        .withImageColor(.white)
                        .withAlignment(.leading)
                        .withTitlePadding(UIEdgeInsets(top: 0,
                                                       left: 4,
                                                       bottom: 0,
                                                       right: 0))

        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        button.leading(target: self.userImageView,
                       targetPosition: .trailing,
                       constant: 16)
        button.trailing(target: self,
                        targetPosition: .trailing,
                        constant: -20)
        button.bottom(target: self.followerInfoButton,
                      targetPosition: .top,
                      constant: -2)
        button.height(constant: 20)
        
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
       
        let label = UILabel()
                        .withFont(.systemFont(ofSize: 14))
                        .withTextColor(.white)
                        .withAlignment(.left)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.leading(target: self.userImageView,
                       targetPosition: .trailing,
                       constant: 16)
        label.trailing(target: self,
                        targetPosition: .trailing,
                       constant: -20)
        label.bottom(target: self.companyButton,
                      targetPosition: .top,
                     constant: -4)
        label.height(constant: 20)
        
        return label
    }()
    
    private lazy var grayLineView: UIView = {
        
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.leading(target: self,
                     targetPosition: .leading)
        view.trailing(target: self,
                      targetPosition: .trailing)
        view.bottom(target: self,
                    targetPosition: .bottom)
        view.height(constant: 1)
        
        return view
    }()
}
