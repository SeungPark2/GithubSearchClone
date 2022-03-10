//
//  UserInfoView.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/23.
//

import UIKit

import Kingfisher
import SnapKit

class UserInfoView: UIView {
    
    init(frame: CGRect, user: User) {
        super.init(frame: frame)
        
        self.addViews()
        self.viewsMakeConstraints()
        self.updateData(with: user)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func addViews() {
        
        self.addSubview(self.userImageView)
        self.addSubview(self.followerInfoButton)
        self.addSubview(self.companyButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.grayLineView)
    }
    
    private func viewsMakeConstraints() {
        
        self.userImageView.snp.makeConstraints {
            
            $0.top.leading.bottom.equalToSuperview().offset(20)
            $0.width.equalTo(80)
        }
        
        self.followerInfoButton.snp.makeConstraints {
            
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.userImageView.snp.bottom).offset(20)
            $0.height.equalTo(20)
        }
        
        self.companyButton.snp.makeConstraints {
            
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.followerInfoButton.snp.top).offset(-2)
            $0.height.equalTo(20)
        }
        
        self.nameLabel.snp.makeConstraints {
            
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.companyButton.snp.top).offset(-4)
            $0.height.equalTo(20)
        }
        
        self.grayLineView.snp.makeConstraints {
            
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func updateData(with user: User) {
        
        self.downloadImage(with: user.imageURL)
        self.nameLabel.text = user.name
        self.companyButton.setTitle(user.company == "" ? "없음" : user.company,
                                    for: .normal)
        self.followerInfoButton.setTitle("\(user.followers) followers · " +
                                         "\(user.following) following",
                                         for: .normal)
        self.grayLineView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
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
    
    private let userImageView = UIImageView()
    private let grayLineView = UIView()
    
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

        return button
    }()
    
    private lazy var nameLabel: UILabel = {
       
        let label = UILabel()
                        .withFont(.boldSystemFont(ofSize: 18))
                        .withTextColor(.white)
                        .withAlignment(.left)
        
        return label
    }()
}
