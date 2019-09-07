//
//  String+SupportedMedia.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 12/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation


extension String {
    
    func isSupportedMediaFormat() -> Bool {
        let options = NSRegularExpression.Options.dotMatchesLineSeparators.rawValue | NSRegularExpression.Options.caseInsensitive.rawValue
        return self.range(of: kSupportedFileExtensions, options: String.CompareOptions(rawValue: options)).hashValue != NSNotFound
    }
    
    
}
