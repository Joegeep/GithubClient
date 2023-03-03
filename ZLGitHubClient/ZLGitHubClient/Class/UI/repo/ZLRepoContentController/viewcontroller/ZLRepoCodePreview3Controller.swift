//
//  ZLRepoCodePreview3Controller.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2020/7/14.
//  Copyright © 2020 ZM. All rights reserved.
//

import UIKit
import WebKit
import ZLUIUtilities
import ZLBaseUI
import ZLBaseExtension
import ZLGitRemoteService

/**
  *  利用 REST API 获取 md 内容 ； 代码使用markdown接口渲染
 */

class ZLRepoCodePreview3Controller: ZLBaseViewController {

    // model
    let contentModel: ZLGithubContentModel
    let repoFullName: String
    let branch: String

    var htmlStr: String?
    // view
    var webView: WKWebView?

    init(repoFullName: String, contentModel: ZLGithubContentModel, branch: String) {
        self.repoFullName = repoFullName
        self.contentModel = contentModel
        self.branch = branch
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: ZLUserInterfaceStyleChange_Notification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationArrived(notification:)), name: ZLUserInterfaceStyleChange_Notification, object: nil)

        self.setUpUI()

        let fileExtension = (URL.init(string: self.contentModel.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? "") as NSURL?)?.pathExtension ?? ""
        if fileExtension.lowercased() == "md" || fileExtension.lowercased() == "markdown" {
            self.sendQueryContentRequest()
        } else {
            self.sendRenderMakrdownRequest()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if ZLDeviceInfo.isIPhone() {
            guard let appdelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.allowRotation = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if ZLDeviceInfo.isIPhone() {
            guard let appdelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.allowRotation = false
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)

        if ZLDeviceInfo.isIPhone() {
            guard let navigationVC: ZLBaseNavigationController = self.navigationController as? ZLBaseNavigationController else {
                return
            }
            if size.height > size.width {
                // 横屏变竖屏
                self.setZLNavigationBarHidden(false)
                navigationVC.forbidGestureBack = false
            } else {
                self.setZLNavigationBarHidden(true)
                navigationVC.forbidGestureBack = true
            }
        }
    }

    func setUpUI() {
        self.title = self.contentModel.path

        self.zlNavigationBar.backButton.isHidden = false
        let button = UIButton.init(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: ZLIconFont.More.rawValue,
                                                     attributes: [.font: UIFont.zlIconFont(withSize: 30),
                                                                  .foregroundColor: UIColor.label(withName: "ICON_Common")]),
                                  for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.addTarget(self, action: #selector(onMoreButtonClick(button:)), for: .touchUpInside)

        self.zlNavigationBar.rightButton = button

        let wv = WKWebView(frame: CGRect.init())
        wv.backgroundColor = UIColor.clear
        wv.scrollView.backgroundColor = UIColor.clear

        self.contentView.addSubview(wv)
        wv.snp.makeConstraints({(make) in
            make.edges.equalToSuperview()
        })
        wv.uiDelegate = self
        wv.navigationDelegate = self

        self.webView = wv
    }

    func switchToWebVC() {

        if let url = URL.init(string: self.contentModel.html_url),
           let vc = ZLUIRouter.getVC(key: ZLUIRouter.WebContentController, params: ["requestURL": url]) {
            if var viewControllers = self.navigationController?.viewControllers,
               !viewControllers.isEmpty {
                viewControllers[viewControllers.count - 1] = vc
                self.navigationController?.setViewControllers(viewControllers, animated: false)
            }
        }
    }

    func openURL(url: URL?) {
        if let realurl = url {
            ZLUIRouter.openURL(url: realurl)
        }
    }

    @objc func onMoreButtonClick(button: UIButton) {

        guard let url = URL(string: self.contentModel.html_url) else {
            return
        }
        button.showShareMenu(title: url.absoluteString, url: url, sourceViewController: self )
    }

}

extension ZLRepoCodePreview3Controller {
    @objc func onNotificationArrived(notification: Notification) {
        if let html = self.htmlStr {
            self.startLoadCode(codeHtml: html)
        }
    }
}

extension ZLRepoCodePreview3Controller {

    func sendQueryContentRequest() {

        ZLProgressHUD.show()

        ZLServiceManager.sharedInstance.repoServiceModel?.getRepositoryFileHTMLInfo(withFullName: self.repoFullName,
                                                                                    path: self.contentModel.path,
                                                                                    branch: self.branch,
                                                                                    serialNumber: NSString.generateSerialNumber()) { [weak self] (resultModel: ZLOperationResultModel) in

            if resultModel.result == false {

                ZLProgressHUD.dismiss()
                self?.switchToWebVC()
                return
            }

            guard let data: String = resultModel.data as? String else {

                ZLProgressHUD.dismiss()
                self?.switchToWebVC()
                return
            }

            self?.htmlStr = data
            self?.startLoadCode(codeHtml: data)
        }
    }

    func sendRenderMakrdownRequest() {

        ZLProgressHUD.show()
        ZLServiceManager.sharedInstance.repoServiceModel?.getRepositoryFileRawInfo(withFullName: self.repoFullName,
                                                                                   path: self.contentModel.path,
                                                                                   branch: self.branch,
                                                                                   serialNumber: NSString.generateSerialNumber()) {[weak self] (resultModel: ZLOperationResultModel) in

            guard let self = self else { return }

            if resultModel.result == false {
                ZLProgressHUD.dismiss()
                self.switchToWebVC()
                return
            }

            guard let data: String = resultModel.data as? String else {
                ZLProgressHUD.dismiss()
                self.switchToWebVC()
                return
            }

            let code = "```\(self.getFileType(fileExtension: URL.init(string: self.contentModel.path)?.pathExtension ?? ""))\n\(data)\n```"

            ZLServiceManager.sharedInstance.additionServiceModel?.renderCodeToMarkdown(withCode: code, serialNumber: NSString.generateSerialNumber(), completeHandle: {[weak self](resultModel: ZLOperationResultModel) in

                guard let self = self else { return }

                if resultModel.result == false {

                    ZLProgressHUD.dismiss()
                    self.switchToWebVC()
                    return
                }

                guard let data: String = resultModel.data as? String else {

                    ZLProgressHUD.dismiss()
                    self.switchToWebVC()
                    return
                }

                let code = "<article class=\"markdown-body entry-content container-lg\" itemprop=\"text\">\(data)</article>"

                self.htmlStr = code
                self.startLoadCode(codeHtml: code)

            })
        }
    }

    func startLoadCode(codeHtml: String) {

        let htmlURL: URL? = Bundle.main.url(forResource: "github_style", withExtension: "html")

        let cssURL: URL?

        if #available(iOS 12.0, *) {
            if getRealUserInterfaceStyle() == .light {
                cssURL = Bundle.main.url(forResource: "github_style", withExtension: "css")
            } else {
                cssURL = Bundle.main.url(forResource: "github_style_dark", withExtension: "css")
            }
        } else {
            cssURL = Bundle.main.url(forResource: "github_style", withExtension: "css")
        }

        if let url = htmlURL {

            do {
                let htmlStr = try String.init(contentsOf: url)
                let newHtmlStr = NSMutableString.init(string: htmlStr)

                let range1 = (newHtmlStr as NSString).range(of: "<style>")
                if  range1.location != NSNotFound {
                    newHtmlStr.insert("<meta name=\"viewport\" content=\"width=device-width\"/>", at: range1.location)
                }

                if let tmoCSSURL = cssURL {
                    let cssStr = try String.init(contentsOf: tmoCSSURL)
                    let range = (newHtmlStr as NSString).range(of: "</style>")
                    if  range.location != NSNotFound {
                        newHtmlStr.insert(cssStr, at: range.location)
                    }
                }

                let range = (newHtmlStr as NSString).range(of: "</body>")
                if  range.location != NSNotFound {
                    newHtmlStr.insert(codeHtml, at: range.location)
                }

                self.webView?.loadHTMLString(newHtmlStr as String, baseURL: nil)

            } catch {
                ZLToastView.showMessage("load Code index html failed")
            }
        }
        ZLProgressHUD.dismiss()
    }

    func getFileType(fileExtension: String) -> String {
        let dic = ["cpp": "c++",
                   "m": "objc",
                   "mm": "objc",
                   "h": "c",
                   "hpp": "c++"]
        return dic[fileExtension] ?? fileExtension
    }
}

extension ZLRepoCodePreview3Controller: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlStr = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }

        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            
            if ZLCommonURLManager.openURL(urlStr: urlStr) {
                return
            }

            var url = URL(string: urlStr)
            if url?.host == nil {               // 如果是相对路径，组装baseurl
                url = (URL.init(string: self.contentModel.html_url) as NSURL?)?.deletingLastPathComponent
                url = URL(string: "\(url?.absoluteString ?? "" )\(urlStr)")
            }
        
            guard let appdelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.allowRotation = false

            self.openURL(url: url)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let download_url = self.contentModel.download_url {
            let baseURLStr = (URL.init(string: download_url) as NSURL?)?.deletingLastPathComponent?.absoluteString
            let addBaseScript = "let a = '\(baseURLStr ?? "")';let array = document.getElementsByTagName('img');for(i=0;i<array.length;i++){let item=array[i];if(item.getAttribute('src').indexOf('http') == -1){item.src = a + item.getAttribute('src');}}"

            webView.evaluateJavaScript(addBaseScript) { (_: Any?, _: Error?) in

            }
        }

    }

}
