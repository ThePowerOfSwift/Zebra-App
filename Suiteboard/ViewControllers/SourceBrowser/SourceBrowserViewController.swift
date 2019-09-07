//
//  SourceBrowserViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import ReactiveSwift
import UIKit
import WebKit

internal final class SourceBrowserViewController: WebViewController {
    
    fileprivate let viewModel: SourceBrowserViewModelType = SourceBrowserViewModel()
    
    fileprivate let loadingIndicator = UIActivityIndicatorView()
    
    internal static func configuredWith(source: String) -> SourceBrowserViewController {
        let vc = SourceBrowserViewController()
        vc.viewModel.inputs.configureWith(source: source)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Do any additional setup after loading the view.
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
            <> (SourceBrowserViewController.lens.webView.scrollView..UIScrollView.lens.delaysContentTouches) .~ false
            <> (SourceBrowserViewController.lens.webView.scrollView..UIScrollView.lens.canCancelContentTouches) .~ true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.loadWebViewRequest
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                _ = self?.webView.load($0)
        }
        
        self.viewModel.outputs.goBackToBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
        }
        
        self.viewModel.outputs.showErrorAlert
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                self?.present(
                    UIAlertController.genericError($0.localizedDescription),
                    animated: true,
                    completion: nil
                )
        }
    }
    
    internal func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
        decisionHandler(self.viewModel.outputs.decidedPolicyForNavigationAction)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.viewModel.inputs.webViewDidStartProvisionalNavigation()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.viewModel.inputs.webViewDidFinishNavigation()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.viewModel.inputs.webViewDidFailProvisionalNavigation(withError: error)
    }
}
