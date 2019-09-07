//
//  URL+Helpers.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import MobileCoreServices



extension URL {
    
    var typeIdentifier: String? {
        let values = try? resourceValues(forKeys: [.typeIdentifierKey])
        return values?.typeIdentifier
    }
    
    var typeIdentifierFileExtension: String? {
        guard let type = typeIdentifier else {
            return nil
        }
        return URL.fileExtensionForUTType(type)
    }
    
    static func fileExtensionForUTType(_ type: String) -> String? {
        let fileExtension = UTTypeCopyPreferredTagWithClass(type as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue()
        return fileExtension as String?
    }
    
    var isImage: Bool {
        guard let uti = typeIdentifier else {
            return false
        }
        
        return UTTypeConformsTo(uti as CFString, kUTTypeImage)
    }
    
    var isPdf: Bool {
        if let uti = typeIdentifier {
            return UTTypeConformsTo(uti as CFString, kUTTypePDF)
        } else {
            return pathExtension.lowercased() == "pdf"
        }
    }
    
    var isGif: Bool {
        if let uti = typeIdentifier {
            return UTTypeConformsTo(uti as CFString, kUTTypeGIF)
        } else {
            return pathExtension.lowercased() == "gif"
        }
    }
}
