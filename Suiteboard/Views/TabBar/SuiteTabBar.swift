//
//  SuiteTabBar.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 03/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

protocol SuiteTabBarDelegate: class {
    func tabBar(_ tabBar: SuiteTabBar, didSelect item: TabBarItem)
}

class SuiteTabBar: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    struct Size {
        static let itemHeight: CGFloat = 56
        
        
        static private func calculateHeight() -> CGFloat {
            return 56
        }
        
        static private func calculateTopOffset() -> CGFloat {
            return 0
        }
    }
    
    weak var delegate: SuiteTabBarDelegate?
    
    var selectedTab: TabBarItem? {
        didSet {
            for button in tabbarButtons {
                button.isSelected = false
            }
            
            guard let selectedTab = selectedTab,
                let index = tabs.index(of: selectedTab)
            else { return }
            tabbarButtons[index].isSelected = true
        }
    }
    
    var tabs: [TabBarItem] = [] {
        didSet { arrangeTabs() }
    }
    
    var buttonFrames: [CGRect] { return tabbarButtons.map { $0.frame } }
    private var tabbarButtons: [UIButton] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }
    
    convenience init() {
        self.init(frame: .zero)
        privateInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }
    
    private func privateInit() {
        self.backgroundColor = UIColor.black
        self.isOpaque = true
        self.tintColor = .black
        self.clipsToBounds = true
    }
    
    private func arrangeTabs() {
        for button in tabbarButtons {
            button.removeFromSuperview()
        }
        
        tabbarButtons = tabs.map { tab in
            let button = UIButton()
            return button
        }
    }
    
    @objc private func tappedTabbarButton(_ sender: UIButton) {
        guard let delegate = delegate, let index = tabbarButtons.index(of: sender) else { return }
        let tab = tabs[index]
        selectedTab = tab
        delegate.tabBar(self, didSelect: tab)
    }
}
