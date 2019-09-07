//
//  ViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 03/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit
import LocalAuthentication

class BoardFeedViewController: UIViewController {
    
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    private var context = LAContext()
    
    var visibleCellItems: [FeedCollectionViewCell] = []
    let imagesSample = ["irene-velvet", "yeri-velvet", "wendy-velvet", "irene2-velvet", "seulgi-velvet"]
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupBiometrics()
        
        self.settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        self.boardCollectionView.dataSource = self
    }
    
    private func setupBiometrics() {
        // Register for foreground notification to check biometric authentication
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { notification in
            var biometricError: NSError?
            
            if !Settings.getToggle() || !AppDelegate.needsAuthenticated {
                return
            }
            
            AppDelegate.needsAuthenticated = false
            
            self.context = LAContext()
            self.context.localizedReason = "Touch ID, Face ID or Passcode to continue to your board"
            self.context.localizedCancelTitle = "Cancel"
            
            if self.context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &biometricError) {
                self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: self.context.localizedReason) {
                    (success, _) in
                    DispatchQueue.main.async {
                        if success {
                            print("Success Biometric bla bla bla")
                        } else {
                            print("Something need to failed")
                        }
                    }
                }
            } else {
                // Disable them
            }
        }
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsBoardVC.init()
        let navVC = UINavigationController(rootViewController: settingsVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func calculateColumnWidth(frameWidth: CGFloat, columnSpacing: CGFloat, columnCount: Int) -> CGFloat {
        return floor((frameWidth - columnSpacing * CGFloat(columnCount - 1)) / CGFloat(columnCount))
    }

}

extension BoardFeedViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesSample.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionViewCell", for: indexPath) as! FeedCollectionViewCell
        cell.feedImageView.image = UIImage.gif(name: imagesSample[indexPath.item])!

        
        return cell
    }
}

extension BoardFeedViewController: UICollectionViewDelegateFlowLayout {
    
}
