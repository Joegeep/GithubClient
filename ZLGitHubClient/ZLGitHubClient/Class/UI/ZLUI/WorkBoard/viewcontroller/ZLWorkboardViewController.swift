//
//  ZLWorkboardViewController.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2020/11/20.
//  Copyright © 2020 ZM. All rights reserved.
//

import UIKit

class ZLWorkboardViewController: ZLBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ZLLocalizedString(string: "Workboard", comment: "")
        
        let baseView = ZLWorkboardBaseView.init()
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints({make in
            make.edges.equalToSuperview()
        })
        
        self.viewModel = ZLWorkboardBaseViewModel(viewController:self)
        self.viewModel.bindModel(nil, andView: baseView)
        
        
    }
}
