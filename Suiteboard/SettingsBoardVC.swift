//
//  SettingsBoardVC.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import UIKit

class SettingsBoardVC: UIViewController {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 44
    }
    
    private func getToogleCell(indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "toggleCell")
        cell.textLabel?.text = "Get a Passcode"
        cell.textLabel?.numberOfLines = 0
        cell.accessoryView = PaddedSwitch(switchView: UISwitch())
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    private func moveFileFrom(filePath: NSString) {
        
        let fileName = filePath.lastPathComponent
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let libraryPath = searchPaths[0]
        var finalFilePath = libraryPath.appending(fileName)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: "finalFilePath") {
            var potentialFileName: String!
            let fileExtension = (fileName as NSString).pathExtension
            let rawFileName = (fileName as NSString).deletingPathExtension
            for x in 1...100 {
                potentialFileName = "\(rawFileName) \(x).\(fileExtension)"
                if !FileManager.default.fileExists(atPath: libraryPath.appending(potentialFileName)) {
                    break
                }
            }
            finalFilePath = libraryPath.appending(potentialFileName)
        }
        
        do {
            try fileManager.moveItem(atPath: String(filePath), toPath: finalFilePath)
        } catch {
            print("\(#function) \(error)")
        }
        
    }
}

extension SettingsBoardVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = getToogleCell(indexPath: indexPath)
        return cell
    }
}

extension SettingsBoardVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
