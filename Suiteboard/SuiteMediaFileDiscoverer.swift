//
//  SuiteMediaFileDiscoverer.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 12/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import Dispatch

protocol SuiteMediaFileDiscovererDelegate: class {
    func mediaFilesFoundRequiringAdditionToStorageBackground(foundFiles: [String])
    func mediaFileAdded(filePath: String, loading: Bool)
    func mediaFileChanged(filePath: String, size: CUnsignedLongLong)
    func mediaFileDeleted(filePath: String)
}

class SuiteMediaFileDiscoverer: NSObject {
    
    
    public var directoryPath: String = ""
    public var directoryFiles: [String] = []
    public var addedFilesMapping: [String: Int] = [:]
    public let filterResultsForPlayability = true
    
    private var directorySource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: Int32(DispatchSource.FileSystemEvent.link.rawValue), eventMask: .write, queue: DispatchQueue(label: ""))
    
    weak var delegate: SuiteMediaFileDiscovererDelegate?
    
    
    public func directoryDidChange() {
        let foundFiles = self.directoryFiles
        
        if self.directoryFiles.count > foundFiles.count { // File was deleted
            let filterPredicate = NSPredicate(format: "not (self in %@)", foundFiles)
            let deletedFiles = (self.directoryFiles as NSArray).filtered(using: filterPredicate) as! [String]
            
            for fileName in deletedFiles {
                // notifyFileDeleted
                self.delegate?.mediaFileDeleted(filePath: fileName)
            }
        } else if self.directoryFiles.count < foundFiles.count {
            let filterPredicate = NSPredicate(format: "not (self in %@)", foundFiles)
            let addedFiles = (self.directoryFiles as NSArray).filtered(using: filterPredicate) as! [String]
            
            for fileName in addedFiles {
                var isDirectory = ObjCBool(false)
                var directoryPath = self.directoryPath
                let filePath = directoryPath.appending(fileName)
                
                guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory) else { return }
                
                if !isDirectory.boolValue {
                    if self.filterResultsForPlayability {
                        if fileName.isSupportedMediaFormat() {
                            // Notify File Added
                            self.delegate?.mediaFileAdded(filePath: fileName, loading: true)
                        }
                    } else {
                        self.addedFilesMapping[fileName] = 0
                        // Notify File Added
                        self.delegate?.mediaFileAdded(filePath: fileName, loading: true)
                    }
                } else if isDirectory.boolValue {
                    let files = try! FileManager.default.contentsOfDirectory(atPath: filePath)
                    for file in files {
                        let fullFilePath = directoryPath.appending(file)
                        
                        guard FileManager.default.fileExists(atPath: fullFilePath, isDirectory: &isDirectory) else { return }
                        
                        if isDirectory.boolValue || !(filePath as NSString).lastPathComponent.elementsEqual("Documents") {
                            var folderPath = filePath.replacingOccurrences(of: directoryPath, with: "")
                            if !folderPath.elementsEqual("") {
                                folderPath = folderPath.appending("/")
                            }
                            let path = folderPath.appending(file)
                            self.addedFilesMapping[path] = 0
                            // Notify File Added
                            self.delegate?.mediaFileAdded(filePath: path, loading: true)
                        }
                    }
                }
            }
        }
        
        self.directoryFiles = foundFiles
    }
    
    public func updateMediaList() {
        
        let directoryPath = self.directoryPath
        var foundFiles = try! FileManager.default.contentsOfDirectory(atPath: directoryPath)
        var filePaths: [String] = []
        var fileURL: URL?
        while foundFiles.count != 0 {
            let fileName = foundFiles.first!
            let filePath = directoryPath.appending(fileName)
            foundFiles.removeLast()
            
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory) else { return }
            
            if !isDirectory.boolValue {
                if self.filterResultsForPlayability {
                    if fileName.isSupportedMediaFormat() {
                        filePaths.append(filePath)
                        
                        fileURL = URL(fileURLWithPath: filePath)
                        fileURL?.setTemporaryResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                    }
                } else {
                    filePaths.append(filePath)
                    
                    fileURL = URL(fileURLWithPath: filePath)
                    fileURL?.setTemporaryResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                }
            } else {
                if let files = try? FileManager.default.contentsOfDirectory(atPath: filePath) {
                    for file in files {
                        let fullFilePath = directoryPath.appending(file)
                        
                        guard FileManager.default.fileExists(atPath: fullFilePath, isDirectory: &isDirectory) else { return }
                        
                        if isDirectory.boolValue {
                            var folderPath = filePath.replacingOccurrences(of: directoryPath, with: "")
                            if folderPath != "" {
                                folderPath = folderPath.appending("/")
                            }
                            let path = folderPath.appending(file)
                            foundFiles.append(path)
                        }
                    }
                }
            }
            
        }
    }
    
    public func startDiscovering() {
        
        let folderDescriptor = open(self.directoryPath, O_EVTONLY)
        
        self.directorySource.setEventHandler(handler: {
            DispatchQueue.main.async {
                self.directoryDidChange()
            }
        })
        self.directorySource.setCancelHandler(handler: {
            close(folderDescriptor)
        })
        self.directorySource.resume()
    }
    
    public func stopDiscovering() {
        self.directorySource.cancel()
    }
}
