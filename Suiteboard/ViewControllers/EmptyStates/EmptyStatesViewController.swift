//
//  EmptyStatesViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 11/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

public final class EmptyStatesViewController: UIViewController {
    
    @IBOutlet fileprivate weak var emptyStatesMainLabel: UILabel!
    
    public static func instantiate() -> EmptyStatesViewController {
        return Storyboards.EmptyStates.instantiate(EmptyStatesViewController.self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    public override func bindViewModel() {
        super.bindViewModel()
        
        
    }
}
