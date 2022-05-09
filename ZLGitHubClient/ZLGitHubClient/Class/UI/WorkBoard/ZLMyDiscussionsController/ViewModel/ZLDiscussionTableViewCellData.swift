//
//  ZLDiscussionTableViewCellData.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2022/5/2.
//  Copyright © 2022 ZM. All rights reserved.
//

import UIKit
import ZLGitRemoteService

class ZLDiscussionTableViewCellData: ZLGithubItemTableViewCellData {
    
    typealias DiscussionData = SearchItemQuery.Data.Search.Node.AsDiscussion
    
    let data: DiscussionData
    
    init(data: DiscussionData) {
        self.data = data
        super.init()
    }
    
    override func getCellReuseIdentifier() -> String {
        return "ZLDiscussionTableViewCell"
    }

    override func getCellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }

    override func onCellSingleTap() {
        if let url = URL.init(string: data.url) {
            ZLUIRouter.navigateVC(key: ZLUIRouter.WebContentController,
                                  params: ["requestURL": url],
                                  animated: true)
        }
    }
    
    override func clearCache() {

    }
    
    override func bindModel(_ targetModel: Any?, andView targetView: UIView) {
        super.bindModel(targetModel, andView: targetView)
        if let cell = targetView as? ZLDiscussionTableViewCell {
            cell.fillWithData(viewData: self)
        }
    }
    
}

extension ZLDiscussionTableViewCellData: ZLDiscussionTableViewCellDataSourceAndDelegate {
    
    var repositoryFullName: String {
        data.repository.nameWithOwner
    }
    
    var title: String {
        data.title
    }
    
    var createTime: String {
        NSDate.getLocalStrSinceCurrentTime(withGithubTime: data.createdAt)
    }
    
    
    var upvoteNumber: Int {
        data.upvoteCount
    }
    
    var commentNumber: Int {
        data.comments.totalCount
    }
    
    func onClickRepoFullName() {
        if let url = URL(string: self.data.url) {
            if url.pathComponents.count >= 5 {
                if let vc = ZLUIRouter.getRepoInfoViewController(repoFullName: "\(url.pathComponents[1])/\(url.pathComponents[2])") {
                    self.viewController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func hasLongPressAction() -> Bool {
        if let _ = URL(string: data.url) {
            return true
        } else {
            return false
        }
    }

    func longPressAction(view: UIView) {
        guard let vc = viewController,
              let url = URL(string: self.data.url) else { return }
        view.showShareMenu(title: data.title, url: url, sourceViewController: vc)
    }
    
}
