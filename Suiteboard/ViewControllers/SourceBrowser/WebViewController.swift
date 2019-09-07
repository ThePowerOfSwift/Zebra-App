//
//  WebViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 07/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit
import Prelude
import WebKit

internal class WebViewController: UIViewController {
    internal let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    
    override func loadView() {
        super.loadView()
        
        self.webView.configuration.suppressesIncrementalRendering = true
        self.webView.configuration.allowsInlineMediaPlayback = true
        self.webView.configuration.applicationNameForUserAgent = "Suiteboard"
        
        self.view.addSubview(self.webView)
        
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ]
        )
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
    }
}

extension WebViewController: WKUIDelegate {
    
}

extension WebViewController: WKNavigationDelegate {
    
}

extension WebViewController: UIScrollViewDelegate {
    
}

internal protocol WebViewControllerProtocol: UIViewControllerProtocol {
    var webView: WKWebView { get }
}

extension WebViewController: WebViewControllerProtocol {}

extension LensHolder where Object: WebViewControllerProtocol {
    internal var webView: Lens<Object, WKWebView> {
        return Lens(
            view: { $0.webView },
            set: { $1 }
        )
    }
}

extension Lens where Whole: WebViewControllerProtocol, Part == WKWebView {
    internal var scrollView: Lens<Whole, UIScrollView> {
        return Whole.lens.webView..Part.lens.scrollView
    }
}
