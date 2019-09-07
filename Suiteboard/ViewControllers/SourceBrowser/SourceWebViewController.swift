//
//  SourceWebViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import ReactiveSwift
import UIKit
import WebKit

public final class SourceWebViewController: UIViewController {
    
    fileprivate let viewModel: SourceWebViewModelType = SourceWebViewModel()
    
    fileprivate var pendingRequests = [String: URLRequest]()
    @IBOutlet fileprivate weak var sourceWebView: WKWebView!
    @IBOutlet fileprivate weak var webBarToolbar: UIToolbar!
    @IBOutlet fileprivate weak var safariButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var reloadButton: UIBarButtonItem!
    
    fileprivate var lastRequest: URLRequest?
    
    fileprivate var gradientBar: BottomGradientLoadingBar!
    
    fileprivate var desktopSite: Bool = false {
        didSet {
            self.sourceWebView.customUserAgent = desktopSite ? UserAgent.desktopUserAgent() : nil
        }
    }
    
    public static func configureWith(initialRequest: URLRequest) -> SourceWebViewController {
        let vc = Storyboards.SourceBrowser.instantiate(SourceWebViewController.self)
        vc.viewModel.inputs.configureWith(initialRequest: initialRequest)
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sourceWebView.uiDelegate = self
        self.sourceWebView.navigationDelegate = self
        
        self.gradientBar = BottomGradientLoadingBar(height: 2.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.yellow, UIColor.black], isRelativeToSafeArea: true, onView: self.navigationController?.navigationBar)
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.sourceWebView.uiDelegate = nil
        self.sourceWebView.navigationDelegate = nil
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self.webBarToolbar
            |> UIToolbar.lens.backgroundColor .~ .black    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.webViewLoadRequest
            .observe(on: UIScheduler())
            .observeValues { [weak self] request in
                self?.sourceWebView.load(request)
                if let url = request.url, url.isFileURL {
                    self?.sourceWebView.loadFileURL(url, allowingReadAccessTo: url)
                }
        }
        
        self.viewModel.outputs.webIsLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] isLoading in
                if isTrue(isLoading) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.goToSafari
            .observe(on: QueueScheduler.main)
            .observeValues { urlSafari in
                UIApplication.shared.open(urlSafari, options: [:])
        }
        
        self.viewModel.outputs.reloadWeb
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.reload()
        }
    }
    
    // MARK: User Agent Spoofing
    
    private func resetSpoofedUserAgentIfRequired(_ webView: WKWebView, newURL: URL) {
        if webView.url?.host != newURL.host {
            webView.customUserAgent = nil
        }
    }
    
    private func restoreSpoofedUserAgentIfRequired(_ webView: WKWebView, newRequest: URLRequest) {
        let ua = newRequest.value(forHTTPHeaderField: "User-Agent")
        webView.customUserAgent =  ua != UserAgent.defaultUserAgent() ? ua : nil
    }
    
    fileprivate func reload() {
        let userAgent: String? = desktopSite ? UserAgent.desktopUserAgent() : nil
        if (userAgent ?? "") != sourceWebView?.customUserAgent {
            sourceWebView?.customUserAgent = userAgent
            return
        }
        
        if let _ = sourceWebView?.reloadFromOrigin() {
            print("reloaded zombified tab from origin")
            
        }
    }
    
    @discardableResult func loadRequest(_ request: URLRequest) -> WKNavigation? {
        if let webView = self.sourceWebView {
            lastRequest = request
            
            return webView.load(request)
        }
        return nil
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.reloadButtonTapped()
    }
    
    @IBAction func safariButtonTapped(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.safariButtonTapped()
    }
}

extension WKNavigationAction {
    var isAllowed: Bool {
        guard let url = request.url else {
            return true
        }
        
        return !url.isWebpage(includeDataURIs: false)
    }
}

extension SourceWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return self.sourceWebView
    }
}

extension SourceWebViewController: WKNavigationDelegate {
    
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.viewModel.inputs.webViewConfirm(true)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.viewModel.inputs.webViewConfirm(false)
        self.title = webView.title ?? ""
    }
    
    fileprivate func isStoreURL(_ url: URL) -> Bool {
        if url.scheme == "http" || url.scheme == "https" || url.scheme == "item-apps" {
            if url.host == "itunes.apple.com" {
                return true
            }
        }
        
        return false
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        /*
        if !navigationAction.isAllowed && navigationAction.navigationType != .backForward {
            
        }
        */
        
        if isStoreURL(url) {
            decisionHandler(.cancel)
            return
        }
        
        if ["http", "https", "data", "blob", "file"].contains(url.scheme) {
            if navigationAction.targetFrame?.isMainFrame ?? false {
                let requestUA = navigationAction.request.value(forHTTPHeaderField: "User-Agent") ?? ""
                if UserAgent.isDesktop(ua: requestUA) != self.desktopSite {
                    let _url: URL
                    // if the url has 'm.' or 'mobile.' in it, remove it.
                    if url.normalizedHost != url.host, let scheme = url.scheme, let fullpath = url.normalizedHostAndPath {
                        let desktopUrl = scheme + "://" + fullpath
                        _url = URL(string: desktopUrl) ??  url
                    } else {
                        _url = url
                    }
                    webView.load(URLRequest(url: _url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60) as URLRequest)
                }
            }
            pendingRequests[url.absoluteString] = navigationAction.request
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { openedURL in
            if !openedURL, navigationAction.navigationType == .linkActivated {
                let alert = UIAlertController(title: "Unable to Open URL", message: "Error Occured", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        decisionHandler(.cancel)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        if error.domain == "WebKitErrorDomain" && error.code == 102 {
            return
        }
        
        if checkIfWebContentProcessHasCrashed(webView, error: error as NSError) {
            return
        }
    }
    
    fileprivate func checkIfWebContentProcessHasCrashed(_ webView: WKWebView, error: NSError) -> Bool {
        if error.code == WKError.webContentProcessTerminated.rawValue && error.domain == "WebKitErrorDomain" {
            print("WebContent process has crashed. Trying to reload to restart it.")
            webView.reload()
            return true
        }
        
        return false
    }

    @objc fileprivate func safariButtonTapped() {
        
    }
    
    @objc fileprivate func reloadButtonTapped() {
        
    }
}

extension WKNavigationAction {
    
}

fileprivate let permanentURISchemes = ["aaa", "aaas", "about", "acap", "acct", "cap", "cid", "coap", "coaps", "crid", "data", "dav", "dict", "dns", "example", "file", "ftp", "geo", "go", "gopher", "h323", "http", "https", "iax", "icap", "im", "imap", "info", "ipp", "ipps", "iris", "iris.beep", "iris.lwz", "iris.xpc", "iris.xpcs", "jabber", "ldap", "mailto", "mid", "msrp", "msrps", "mtqp", "mupdate", "news", "nfs", "ni", "nih", "nntp", "opaquelocktoken", "pkcs11", "pop", "pres", "reload", "rtsp", "rtsps", "rtspu", "service", "session", "shttp", "sieve", "sip", "sips", "sms", "snmp", "soap.beep", "soap.beeps", "stun", "stuns", "tag", "tel", "telnet", "tftp", "thismessage", "tip", "tn3270", "turn", "turns", "tv", "urn", "vemmi", "vnc", "ws", "wss", "xcon", "xcon-userid", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "z39.50r", "z39.50s"]


extension URL {
    public func isWebpage(includeDataURIs: Bool = true) -> Bool {
        let schemes = includeDataURIs ? ["http", "https", "data"] : ["http", "https"]
        return scheme.map { schemes.contains($0) } ?? false
    }
    
    public var schemeIsValid: Bool {
        guard let scheme = scheme else { return false }
        return permanentURISchemes.contains(scheme.lowercased())
    }
    
    public func havingRemovedAuthorisationComponents() -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        urlComponents.user = nil
        urlComponents.password = nil
        if let url = urlComponents.url {
            return url
        }
        return self
    }
    
    public var normalizedHostAndPath: String? {
        return normalizedHost.flatMap { $0 + self.path }
    }
    
    public var normalizedHost: String? {
        // Use components.host instead of self.host since the former correctly preserves
        // brackets for IPv6 hosts, whereas the latter strips them.
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), var host = components.host, host != "" else {
            return nil
        }
        
        if let range = host.range(of: "^(www|mobile|m)\\.", options: .regularExpression) {
            host.replaceSubrange(range, with: "")
        }
        
        return host
    }

}
