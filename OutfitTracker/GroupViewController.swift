//
//  GroupViewController.swift
//  OutfitTracker
//
//  Created by Pete Connor on 7/8/17.
//  Copyright © 2017 c0nman. All rights reserved.

import UIKit
import GoogleMobileAds

protocol GroupDelegate {
    func userDidPickGroup(group: String)
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GADBannerViewDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
        
    var groupList = [String]()
    let exampleGroupList = ["E.g. Family", "E.g. Friends", "E.g. Work"]
    var delegate: GroupDelegate? = nil
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-BoldItalic", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.rowHeight = 44.0
        
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        if let persistedGroupList = UserDefaults.standard.object(forKey: "groupList") {
            groupList = persistedGroupList as! [String]
        }
        
        let request = GADRequest()
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9017513021309308/6032231248"
        bannerView.rootViewController = self
        bannerView.load(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupList.count < 1 {
            return 3
        } else {
            return groupList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.textColor = .white
        if groupList.count < 1 {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = exampleGroupList[indexPath.row]
            cell.textLabel?.textColor = .gray
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 17.0)
        } else {
            print(groupList.count)
            cell.isUserInteractionEnabled = true
            cell.textLabel?.text = groupList[indexPath.row]
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 17.0)
            print("this just ran")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if (delegate != nil) {
            if let group = cell?.textLabel?.text {
            delegate!.userDidPickGroup(group: group)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if groupList.count < 1 {
            return
        } else {
        if editingStyle == .delete {
            groupList.remove(at: indexPath.row)
            UserDefaults.standard.set(groupList, forKey: "groupList")
            tableView.reloadData()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil && textField.text != "" {
            groupList.append(textField.text!)
            UserDefaults.standard.set(groupList, forKey: "groupList")
            tableView.reloadData()
            
        }
        textField.resignFirstResponder()
        textField.text = nil
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (textField.text?.count)! {
            return false
        }
        
        let newLength = (textField.text?.count)! + string.count - range.length
        
        return newLength <= 13
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.removeGestureRecognizer(tap)
        textField.text = nil
        textField.resignFirstResponder()
    }
}
