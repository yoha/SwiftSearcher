//
//  MasterViewController.swift
//  SwiftSearcher
//
//  Created by Yohannes Wijaya on 11/3/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class MasterViewController: UITableViewController {
    
    // MARK: - Stored Properties

    var projects = Array<[String]>()
    var favorites = [Int]()

    // MARK: - Methods Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projects.append(["Project 1: Storm Viewer", "Constants and variables, UIImageView, NSFileManager, storyboards"])
        self.projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+=, ++, and --), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        self.projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, NSURL"])
        self.projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, NSURLRequest, UIToolbar, UIProgressView., key-value observing"])
        self.projects.append(["Project 5: Word Scramble", "NSString, closures, method return values, booleans, NSRange"])
        self.projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        self.projects.append(["Project 7: Whitehouse Petitions", "JSON, NSData, UITabBarController"])
        self.projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerate(), countElements(), find(), join(), property observers, range operators."])
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let savedFavorites = userDefaults.objectForKey("favorites") as? [Int] {
            self.favorites = savedFavorites
        }
        
        self.tableView.editing = true
        self.tableView.allowsSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Local Methods
    
    func deIndexItem(which: Int) {
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(["\(which)"]) { (error: NSError?) -> Void in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
            else {
                print("Search item successfully removed!")
            }
        }
        
    }
    
    func indexItem(which: Int) {
        let project = self.projects[which]
        
        let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        searchableItemAttributeSet.title = project.first!
        searchableItemAttributeSet.contentDescription = project[1]
        
        let searchableItem = CSSearchableItem(uniqueIdentifier: "\(which)", domainIdentifier: "com.hackingwithswift", attributeSet: searchableItemAttributeSet)
        searchableItem.expirationDate = NSDate.distantFuture()
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchableItem]) { (error: NSError?) -> Void in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
            else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func makeAttributedString(title title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.redColor()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.grayColor()]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSMutableAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.appendAttributedString(subtitleString)
        
        return titleString
    }
    
    func showTutorial(which: Int) {
        if let url = NSURL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let safariViewController = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            self.presentViewController(safariViewController, animated: true, completion: nil)
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let project = self.projects[indexPath.row]
        cell.textLabel?.attributedText = self.makeAttributedString(title: project.first!, subtitle: project.last!)
        
        cell.editingAccessoryType = self.favorites.contains(indexPath.row) ? UITableViewCellAccessoryType.Checkmark : .None
        
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            self.favorites.append(indexPath.row)
            self.indexItem(indexPath.row)
        }
        else {
            if let index = self.favorites.indexOf(indexPath.row) {
                self.favorites.removeAtIndex(index)
                self.deIndexItem(indexPath.row)
            }
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(self.favorites, forKey: "favorites")
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.showTutorial(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return self.favorites.contains(indexPath.row) ? UITableViewCellEditingStyle.Delete : .Insert
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

