//
//  ActionViewController.swift
//  Extension
//
//  Created by Hudzilla on 23/11/2014.
//  Copyright (c) 2014 Hudzilla. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
	@IBOutlet weak var script: UITextView!

	var pageTitle = ""
	var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")

		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)

		if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
			if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
				itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList, options: nil) { [unowned self] (dict, error) in
					if dict != nil {
						let itemDictionary = dict as NSDictionary
						let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as NSDictionary

						self.pageTitle = javaScriptValues["title"] as String
						self.pageURL = javaScriptValues["URL"] as String

						dispatch_async(dispatch_get_main_queue()) { [unowned self] in
							self.title = self.pageTitle
						}
					}
				}
			}
		}
    }

	func adjustForKeyboard(notification: NSNotification) {
		let userInfo = notification.userInfo!

		let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
		let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)

		if notification.name == UIKeyboardWillHideNotification {
			script.contentInset = UIEdgeInsetsZero
		} else {
			script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
		}

		script.scrollIndicatorInsets = script.contentInset

		let selectedRange = script.selectedRange
		script.scrollRangeToVisible(selectedRange)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @IBAction func done() {
		let item = NSExtensionItem()
		let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": script.text]]
		let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList)
		item.attachments = [customJavaScript]

		extensionContext!.completeRequestReturningItems([item], completionHandler: nil)
    }

}
