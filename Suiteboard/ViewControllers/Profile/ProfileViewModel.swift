//
//  ProfileViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

public protocol ProfileViewModelInputs {
    
}

public protocol ProfileViewModelOutputs {
    
}

public protocol ProfileViewModelType {
    var inputs: ProfileViewModelInputs { get }
    var outputs: ProfileViewModelOutputs { get }
}

public final class ProfileViewModel: ProfileViewModelType, ProfileViewModelInputs, ProfileViewModelOutputs {
    
    
    public var inputs: ProfileViewModelInputs { return self }
    public var outputs: ProfileViewModelOutputs { return self }
}
