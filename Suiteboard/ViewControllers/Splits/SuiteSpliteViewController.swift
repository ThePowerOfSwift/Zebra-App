//
//  SuiteSpliteViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 11/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

@objc enum SuiteSplitViewControllerPrimaryColumnWidth: Int {
    case `default`
    case narrow
    case full
}

@objc enum SuiteSplitViewControllerCollapseMode: Int {
    case Automatic
    case AlwaysKeepDetail
}


public final class SuiteSpliteViewController: UISplitViewController {
    
    fileprivate static let navigationControllerRestorationIdentifier = "SuiteSplitViewDetailNavigationControllerRestorationID"
    fileprivate static let preferredDisplayModeModifiedRestorationKey = "SuiteSplitViewPreferredDisplayModeRestorationKey"
    
    @objc var collapseMode: SuiteSplitViewControllerCollapseMode = .Automatic
    @objc var fullScreenDisplayEnabled = true
    @objc var overrideTraitCollection: UITraitCollection? = nil
    
    @objc var suitePrimaryColumnWidth: SuiteSplitViewControllerPrimaryColumnWidth = .default
    {
        didSet {
            updateSplitViewForPrimaryColumnWidth()
        }
    }
    
    fileprivate var detailNavigationStackHasBeenModified = false
    
    public override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(preferredDisplayMode.rawValue, forKey: SuiteSpliteViewController.preferredDisplayModeModifiedRestorationKey)
        
        super.encodeRestorableState(with: coder)
    }
    
    public override func decodeRestorableState(with coder: NSCoder) {
        if let displayModeRawValue = coder.decodeObject(forKey: SuiteSpliteViewController.preferredDisplayModeModifiedRestorationKey) as? Int, let displayMode = UISplitViewController.DisplayMode(rawValue: displayModeRawValue) {
            preferredDisplayMode = displayMode
        }
        
        super.decodeRestorableState(with: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.delegate = self
        
        self.preferredDisplayMode = .allVisible
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateDimmingViewFrame()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in self.updateSplitViewForPrimaryColumnWidth()
            self.updateDimmingViewFrame()
        })
        
        if let _ = overridenTraitCollectionForDetailViewController,
            let detailViewController = viewControllers.last {
            setOverrideTraitCollection(detailViewController.traitCollection, forChild: detailViewController)
        }
    }
    
    public override var traitCollection: UITraitCollection {
        get {
            if let overrideTraitCollection = overrideTraitCollection {
                return UITraitCollection.init(traitsFrom: [super.traitCollection, overrideTraitCollection])
            }
            
            return super.traitCollection
        }
    }
    
    public override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        guard let collection = super.overrideTraitCollection(forChild: childViewController) else { return nil }
        
        if childViewController == viewControllers.last && shouldOverrideDetailViewControllerHorizontalSizeClass {
            return UITraitCollection(traitsFrom: [collection, UITraitCollection(horizontalSizeClass: .compact)])
        }
        
        let overrideCollection = UITraitCollection(horizontalSizeClass: self.traitCollection.horizontalSizeClass)
        return UITraitCollection(traitsFrom: [collection, overrideCollection])
    }
    
    public override var viewControllers: [UIViewController] {
        didSet {
            for viewController in viewControllers {
                if let viewController = viewController as? UINavigationController {
                    viewController.extendedLayoutIncludesOpaqueBars = true
                    
                    setOverrideTraitCollection(overrideTraitCollectionForDetailViewController, forChild: viewController)
                }
            }
        }
    }
    
    public override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        var detailVC = vc
        
        
        if !isCollapsed {
            detailVC = wrapViewControllerInNavigationControllerIfRequired(vc)
        }
        
        if let navigationController = viewControllers.first as? UINavigationController, traitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass: .compact)) {
            navigationController.show(vc, sender: sender)
            return
        }
        
        super.showDetailViewController(detailVC, sender: sender)
    }
    
    @objc func setPrimaryViewControllerHidden(_ hidden: Bool, animated: Bool = true) {
        guard fullScreenDisplayEnabled else { return }
        
        
        let updateDisplayMode = {
            self.preferredDisplayMode = (hidden) ? .primaryHidden : .allVisible
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                updateDisplayMode()
            }
        } else {
            updateDisplayMode()
        }
    }
    
    @objc func dimDetailViewController(_ dimmed: Bool) {
        if dimmed {
            if dimmingView.superview == nil {
                
            }
        }
    }
    
    @objc var topDetailViewController: UIViewController? {
        if isCollapsed {
            return (viewControllers.first as? UINavigationController)?.topViewController
        } else {
            return (viewControllers.first as? UINavigationController)?.topViewController
        }
    }
    
    
    @objc var rootDetailViewController: UIViewController? {
        guard isCollapsed else {
            return (viewControllers.last as? UINavigationController)?.viewControllers.first
        }
        
        guard let navigationController = viewControllers.first as? UINavigationController else {
            return nil
        }
        
        guard let index = navigationController.viewControllers.lastIndex(where: { $0 is SuiteSplitViewControllerDetailProvider }), navigationController.viewControllers.count > index + 1 else {
            return nil
        }
        
        return navigationController.viewControllers[index + 1]
    }
    
    @objc var dimsDetailViewControllerAutomatically = false {
        didSet {
            if !dimsDetailViewControllerAutomatically {
                dimDetailViewController(false)
            }
        }
    }
    
    // MARK: - Fileprivates Func
    
    fileprivate var shouldOverrideDetailViewControllerHorizontalSizeClass: Bool {
        return view.frame.width < UIScreen.main.bounds.width
    }
    
    fileprivate var overridenTraitCollectionForDetailViewController: UITraitCollection? {
        guard let detailViewController = viewControllers.last, shouldOverrideDetailViewControllerHorizontalSizeClass else {
            return nil
        }
        
        return UITraitCollection(traitsFrom: [detailViewController.traitCollection, traitCollection, UITraitCollection(horizontalSizeClass: .compact)])
    }
    
    fileprivate enum SuiteSplitViewControllerNarrowPrimaryColumnWidth: CGFloat {
        case portrait = 260
        case landscape = 360
        
        static func widthForInterfaceOrientation(_ orientation: UIInterfaceOrientation) -> CGFloat {
            if let windowFrame = UIApplication.shared.keyWindow?.frame {
                if windowFrame.width < UIScreen.main.bounds.width {
                    return self.portrait.rawValue
                }
            }
            
            if orientation.isPortrait || UIDevice.isUnzoomediPhonePlus() {
                return self.portrait.rawValue
            } else {
                return self.landscape.rawValue
            }
        }
    }
    
    fileprivate func updateDimmingViewFrame() {
        if dimmingView.superview != nil {
            dimmingView.frame = view.frame
            
            if view.userInterfaceLayoutDirection() == .leftToRight {
                dimmingView.frame.origin.x = primaryColumnWidth
            } else {
                dimmingView.frame.size.width = dimmingView.frame.size.width - primaryColumnWidth
            }
        }
    }
    
    fileprivate func updateSplitViewForPrimaryColumnWidth() {
        switch suitePrimaryColumnWidth {
        case .default:
            minimumPrimaryColumnWidth = UISplitViewController.automaticDimension
            maximumPrimaryColumnWidth = UISplitViewController.automaticDimension
            preferredPrimaryColumnWidthFraction = UISplitViewController.automaticDimension
        case .narrow:
            let orientation = UIApplication.shared.statusBarOrientation
            let columndWidth = SuiteSplitViewControllerNarrowPrimaryColumnWidth.widthForInterfaceOrientation(orientation)
            minimumPrimaryColumnWidth = columndWidth
            maximumPrimaryColumnWidth = columndWidth
            preferredPrimaryColumnWidthFraction = UIScreen.main.bounds.width / columndWidth
        case .full:
            maximumPrimaryColumnWidth = UIScreen.main.bounds.width
            preferredPrimaryColumnWidthFraction = 1.0
        }
    }
    
    fileprivate lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = .black
        return dimmingView
    }()
    
    
    fileprivate var overrideTraitCollectionForDetailViewController: UITraitCollection? {
        guard let detailViewController = viewControllers.last, shouldOverrideDetailViewControllerHorizontalSizeClass else {
            return nil
        }
        
        return UITraitCollection(traitsFrom: [detailViewController.traitCollection, UITraitCollection(horizontalSizeClass: .compact)])
    }
    
    @objc func setInitialPrimaryViewController(_ viewController: UIViewController) {
        var initialViewControllers = [viewController]
        
        if let navigationController = viewController as? UINavigationController,
            let rootViewController = navigationController.viewControllers.last,
            let detailViewController = initialDetailViewControllerForPrimaryViewController(rootViewController) {
            
            initialViewControllers.append(detailViewController)
            viewControllers = initialViewControllers
        } else {
            viewControllers = [viewController, UIViewController()]
        }
    }
    
    fileprivate func initialDetailViewControllerForPrimaryViewController(_ viewController: UIViewController) -> UIViewController? {
        guard let detailProvider = viewController as? SuiteSplitViewControllerDetailProvider, let detailViewController = detailProvider.initialDetailViewControllerForSplitView(self) else {
            return nil
        }
        
        return wrapViewControllerInNavigationControllerIfRequired(detailViewController)
    }
    
    
    fileprivate func wrapViewControllerInNavigationControllerIfRequired(_ viewController: UIViewController) -> UIViewController {
        var navigationController: UINavigationController!
        
        if let viewController = viewController as? UINavigationController {
            navigationController = viewController
        } else {
            navigationController = UINavigationController(rootViewController: viewController)
        }
        
        navigationController.delegate = self
        navigationController.extendedLayoutIncludesOpaqueBars = true
        
        return navigationController
    }
}

// MARK: - UISplitViewControllerDelegate

extension SuiteSpliteViewController: UISplitViewControllerDelegate {
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let primaryNavigationController = primaryViewController as? UINavigationController else {
            assertionFailure("Split view's primary view controller should be a navigation controller!")
            return nil
        }
        
        var viewControllers: [UIViewController] = []
        
        let separateViewControllersAtIndex: ((Int) -> Void) = { index in
            viewControllers = Array(primaryNavigationController.viewControllers.suffix(from: index))
            primaryNavigationController.viewControllers = Array(primaryNavigationController.viewControllers.prefix(upTo: index))
        }
        
        if let index = primaryNavigationController.viewControllers.firstIndex(where: { $0 is UINavigationController }) {
            
            separateViewControllersAtIndex(index)
        } else if let index = primaryNavigationController.viewControllers.lastIndex(where: { $0 is SuiteSplitViewControllerDetailProvider }) {
            separateViewControllersAtIndex(index + 1)
        }
        
        dimDetailViewControllerIfNecessary()
        
        if viewControllers.count == 0 {
            if let primaryViewController = primaryNavigationController.viewControllers.last, let detailViewController = initialDetailViewControllerForPrimaryViewController(primaryViewController) {
                return detailViewController
            }
        }
        
        if let firstViewController = viewControllers.first as? UINavigationController {
            return firstViewController
        } else {
            let navigationController = UINavigationController()
            navigationController.delegate = self
            navigationController.restorationIdentifier = SuiteSpliteViewController.navigationControllerRestorationIdentifier
            navigationController.viewControllers = viewControllers
            
            return navigationController
        }
    }
}


// MARK: - UINavigationControllerDelegate

extension SuiteSpliteViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController == viewControllers.first {
            
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        if !isViewHorizontallyCompact() {
            
            navigationController.navigationBar.fadeInNavigationItemsIfNecessary()
            
            if UIAccessibility.isReduceMotionEnabled {
                
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fullScreenDisplayEnabled else { return nil }
        
        var stack = navigationController.viewControllers
        if operation == .push {
            stack.removeLast()
        }
        
        let hasFullscreenViewControllersInStack = stack.filter({$0 is PrefersFullScreenDisplay}).count > 0
        let transitionInvolvesFullscreenViewController = toVC is PrefersFullScreenDisplay || fromVC is PrefersFullScreenDisplay
        let movingFromOrToFullscreen = !hasFullscreenViewControllersInStack && transitionInvolvesFullscreenViewController
        
        if !isViewHorizontallyCompact() && movingFromOrToFullscreen {
//            return UIViewControllerAnimatedTransitioning()
            return SuiteFullscreenNavigationTransition(operation: operation)
        }
        
        return nil
    }
    
    fileprivate func primaryNavigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            
            coordinator.notifyWhenInteractionChanges({ [weak self] context in
                if context.initiallyInteractive && context.isCancelled {
                    self?.dimDetailViewController(false)
                }
            })
        }
        
        dimDetailViewControllerIfNecessary()
    }
    
    fileprivate func detailNavigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            detailNavigationStackHasBeenModified = true
        }
        
        let hasFullScreenViewControllersInStack = navigationController.viewControllers.filter({$0 is PrefersFullScreenDisplay}).count > 0
        let isCurrentlyFullscreen = preferredDisplayMode != .allVisible
        
        if fullScreenDisplayEnabled && isCurrentlyFullscreen && !hasFullScreenViewControllersInStack {
            let performTransition = { (animated: Bool) in
                self.setPrimaryViewControllerHidden(false, animated: animated)
                
                if !animated && !self.isViewHorizontallyCompact() {
                    navigationController.navigationBar.fadeOutNavigationItems(animated: true)
                }
            }
            
            if UIAccessibility.isReduceMotionEnabled {
                performTransition(false)
            } else {
                performTransition(animated)
            }
        }
    }
    
    fileprivate func dimDetailViewControllerIfNecessary() {
        if let primaryNavigationController = viewControllers.first as? UINavigationController, dimsDetailViewControllerAutomatically && !isCollapsed {
            let shouldDim = primaryNavigationController.viewControllers.count == 1
            dimDetailViewController(shouldDim)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SuiteSpliteViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        func gestureIsValidInNavigationController(_ navigationController: UINavigationController) -> Bool {
            return gestureRecognizer.view == navigationController.view && navigationController.viewControllers.count > 1
        }
        
        if let primaryNavigationController = viewControllers.first as? UINavigationController,
            gestureIsValidInNavigationController(primaryNavigationController) {
            return true
        }
        
        if let detailNavigationController = viewControllers.last as? UINavigationController, gestureIsValidInNavigationController(detailNavigationController) && !isCollapsed {
            guard fullScreenDisplayEnabled else { return true }
            
            var stack = detailNavigationController.viewControllers
            let topViewController = stack.popLast()
            
            let currentlyFullscreen = topViewController is PrefersFullScreenDisplay
            let hasFullscreenViewControllersInStack = stack.filter({$0 is PrefersFullScreenDisplay}).count > 0
            
            let movingFromFullscreen = currentlyFullscreen && !hasFullscreenViewControllersInStack
            
            return !movingFromFullscreen
        }
        
        return false
    }
}

// MARK: - Misc

protocol PrefersFullScreenDisplay: class {}

@objc protocol SuiteSplitViewControllerDetailProvider{
    func initialDetailViewControllerForSplitView(_ splitView: SuiteSpliteViewController) -> UIViewController?
}


extension UINavigationBar {
    @objc func fadeOutNavigationItems(animated: Bool = true) {
        if let barTintColor = barTintColor {
            fadeNavigationItems(toColor: barTintColor, animated: animated)
        }
    }
    
    @objc func fadeInNavigationItemsIfNecessary(animated: Bool = true) {
        if tintColor != UIColor.white {
            fadeNavigationItems(toColor: UIColor.white, animated: animated)
        }
    }
    
    private func fadeNavigationItems(toColor color: UIColor, animated: Bool) {
        if animated {
            
            let fadeAnimation = CATransition()
            fadeAnimation.duration = 0.1
            fadeAnimation.type = CATransitionType.fade
            
            layer.add(fadeAnimation, forKey: "fadeNavigationBar")
        }
        
        titleTextAttributes = [.foregroundColor: color]
        tintColor = color
    }
}

extension UIViewController {
    
    public func isViewHorizontallyCompact() -> Bool {
        return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact
    }
}
