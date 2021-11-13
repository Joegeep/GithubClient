//
//  ZLIssueTimelineTableViewCellData.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2021/3/16.
//  Copyright © 2021 ZM. All rights reserved.
//

import UIKit

class ZLIssueTimelineTableViewCellData: ZLGithubItemTableViewCellData {
    
    typealias IssueTimelineData = IssueInfoQuery.Data.Repository.Issue.TimelineItem.Node
    
    let data : IssueTimelineData
    
    var attributedString : NSAttributedString?
    
    init(data : IssueTimelineData) {
        self.data = data
        super.init()
    }
    
    override func bindModel(_ targetModel: Any?, andView targetView: UIView) {
        super.bindModel(targetModel, andView: targetView)
        if let cell : ZLIssueTimelineTableViewCell = targetView as? ZLIssueTimelineTableViewCell {
            cell.fillWithData(data:self)
        }
    }
    
    
    override func getCellReuseIdentifier() -> String {
        return "ZLIssueTimelineTableViewCell";
    }
    
    override func getCellHeight() -> CGFloat {
        return UITableView.automaticDimension;
    }

}

extension ZLIssueTimelineTableViewCellData : ZLIssueTimelineTableViewCellDelegate {
    
    func getTimelineMessage() -> NSAttributedString {
        
        if let attributedString = attributedString {
            return attributedString
        }
        
        if let tmpdata = data.asAssignedEvent
        {
            var assignee : String? = nil
            if let bot = tmpdata.assignee?.asBot {
                assignee = bot.login
            } else if let user = tmpdata.assignee?.asUser {
                assignee = user.login
            } else if let mannequin = tmpdata.assignee?.asMannequin {
                assignee = mannequin.login
            } else if let org = tmpdata.assignee?.asOrganization {
                assignee = org.login
            }
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " assigned ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            string.append(NSAttributedString(string: assignee ?? "",
                                             attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor1")]))
            
            attributedString = string
            
            return string
        }
        else if let tmpdata = data.asClosedEvent
        {
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " closed issue",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            attributedString = string
            
            return string
        }
        else if let tmpdata = data.asCommentDeletedEvent {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " deleted comment",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            attributedString = string
            
            return string
            
        }
        else if let tmpdata = data.asCrossReferencedEvent
        {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            if tmpdata.target.asIssue != nil  {
                
                string.append(NSAttributedString(string: " referenced issue  \n\n ",
                                                 attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                              .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
                
                string.append(NSAttributedString(string: "\(tmpdata.target.asIssue?.title ?? "")",
                                                 attributes: [.font:UIFont.zlMediumFont(withSize: 14),
                                                              .foregroundColor:UIColor.label(withName: "ZLLabelColor2")]))
                
            }
            
            if tmpdata.target.asPullRequest != nil  {
                
                string.append(NSAttributedString(string: " referenced pull request  \n\n ",
                                                 attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                              .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
                
                string.append(NSAttributedString(string: "\(tmpdata.target.asPullRequest?.title ?? "")",
                                                 attributes: [.font:UIFont.zlMediumFont(withSize: 14),
                                                              .foregroundColor:UIColor.label(withName: "ZLLabelColor2")]))
                
            }
            
            attributedString = string
            
            return string
            
        }
        else if let tmpdata = data.asLabeledEvent
        {
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " added label ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            let color = ZLRGBValueStr_H(colorValue:tmpdata.label.color)
            string.append(NSAttributedString(string: "\(tmpdata.label.name)",
                                             attributes: [.font:UIFont.zlSemiBoldFont(withSize: 13),
                                                          .foregroundColor:UIColor.isLightColor(color) ? ZLRGBValue_H(colorValue: 0x333333) : UIColor.white,
                                                          .backgroundColor:color]))
            
            attributedString = string
            
            return string
            
        }
        else if let tmpdata = data.asLockedEvent{
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " locked issue ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asMilestonedEvent{
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " added milestone ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            string.append(NSAttributedString(string:tmpdata.milestoneTitle,
                                                    attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                 .foregroundColor:UIColor.label(withName: "ZLLabelColor1")]))

            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asPinnedEvent{
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " pinned issue ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))

            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asReferencedEvent {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " added a commit that referenced this issue \n\n ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            string.append(NSAttributedString(string: "\(tmpdata.nullableName?.messageHeadline ?? "")",
                                             attributes: [.font:UIFont.zlMediumFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor2")]))
            
            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asRenamedTitleEvent {
           
           let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                  attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                               .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
           
           string.append(NSAttributedString(string: " changed the title ",
                                            attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                         .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
                       
           string.append(NSAttributedString(string: "\(tmpdata.previousTitle) ",
                                            attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                         .foregroundColor:UIColor.label(withName: "ZLLabelColor2"),
                                                         .strikethroughStyle:NSUnderlineStyle.byWord]))
           
           string.append(NSAttributedString(string: "\(tmpdata.currentTitle)",
                                            attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                         .foregroundColor:UIColor.label(withName: "ZLLabelColor2")]))
           
           attributedString = string
           
           return string
           
       }
        
        else if let tmpdata = data.asReopenedEvent {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " reopened issue",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asUnlabeledEvent {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " removed label ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            let color = ZLRGBValueStr_H(colorValue:tmpdata.label.color)
            string.append(NSAttributedString(string: "\(tmpdata.label.name)",
                                             attributes: [.font:UIFont.zlSemiBoldFont(withSize: 13),
                                                          .foregroundColor:UIColor.isLightColor(color) ? ZLRGBValue_H(colorValue: 0x333333) : UIColor.white,
                                                          .backgroundColor:color]))
            
            attributedString = string
            
            return string
            
        }
        
        else if let tmpdata = data.asUnpinnedEvent {
            
            let string = NSMutableAttributedString(string:tmpdata.actor?.login ?? "",
                                                   attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                                                .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
            
            string.append(NSAttributedString(string: " unpinned issue ",
                                             attributes: [.font:UIFont.zlRegularFont(withSize: 14),
                                                          .foregroundColor:UIColor.label(withName: "ZLLabelColor4")]))
            
            attributedString = string
            
            return string
            
        }
        
        
        return NSAttributedString(string:data.__typename,
                                  attributes: [.font:UIFont.zlSemiBoldFont(withSize: 15),
                                               .foregroundColor:UIColor.label(withName: "ZLLabelColor1")])
    }
}
