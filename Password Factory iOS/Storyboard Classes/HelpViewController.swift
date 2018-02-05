//
//  HelpViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 2/5/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

import Foundation
import WebKit

class HelpViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var loader: UIActivityIndicatorView?
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Help"
        
        loader = UIActivityIndicatorView.init(activityIndicatorStyle: .gray);
        loader?.startAnimating()
        loader?.hidesWhenStopped = true
        if let l = loader {
            let barItem = UIBarButtonItem.init(customView: l)
            navigationItem.rightBarButtonItem = barItem;
        }
        
        
        
        guard let myURL = URL(string: iOSHelpURL) else {
            return
        }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader?.stopAnimating()
    }
}
