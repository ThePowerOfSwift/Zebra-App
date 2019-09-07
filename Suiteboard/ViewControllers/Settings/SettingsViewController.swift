//
//  SettingsViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 07/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import MessageUI
import Prelude
import ReactiveSwift
import UIKit

public final class SettingsViewController: UIViewController {
    
    fileprivate let viewModel: SettingsViewModelType = SettingsViewModel()
    
    @IBOutlet fileprivate weak var feedbackButton: UIButton!
    @IBOutlet fileprivate weak var zebraInputLabel: UILabel!
    @IBOutlet fileprivate weak var versionLabel: UILabel!
    @IBOutlet fileprivate weak var arenaButton: UIButton!
    
    public static func instantiate() -> SettingsViewController {
        let vc = Storyboards.Settings.instantiate(SettingsViewController.self)
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSettingsVC))
        cancelButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.feedbackButton.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        
        self.arenaButton.addTarget(self, action: #selector(arenaButtonTapped), for: .touchUpInside)
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.versionLabel.rac.text = self.viewModel.outputs.buildVersionText
        
        self.viewModel.outputs.goToFeedback
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                self?.goToContactThread()
        }
    }
    
    
    fileprivate func goToContactThread() {
        
        let version = AppEnvironment.current.mainBundle.version
        let shortVersion = AppEnvironment.current.mainBundle.shortVersionString
        let device = UIDevice.current.systemVersion
        
        let mailController = MFMailComposeViewController()
        mailController.setToRecipients([Secrets.Contacts.fieldReportEmail])
        mailController.setSubject("Zebra wants .... ")
        mailController.setMessageBody(
            "Please your feedback, request features, some bug, to improve this quality app!\n" +
            "---------------------------\n\n\n\n\n\n" +
            "\(version) | \(shortVersion) | \(device)\n\n",
            isHTML: false
        )
        
        mailController.mailComposeDelegate = self
        self.present(mailController, animated: true, completion: nil)
    }
    
    @objc fileprivate func feedbackButtonTapped() {
        self.viewModel.inputs.feedbackButtonTapped()
    }
    
    @objc fileprivate func arenaButtonTapped() {
        UIApplication.shared.open(URL(string: "https://are.na")!, options: [:], completionHandler: nil)
    }
    
    @objc fileprivate func dismissSettingsVC() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                        didFinishWith result: MFMailComposeResult,
                                        error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
