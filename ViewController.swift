//
//  ViewController.swift
//  ImportContact
//
//  Created by steveluccy on 2019/12/8.
//  Copyright © 2019 steveluccy. All rights reserved.
//

import UIKit
import SwiftyContacts
import Contacts
import GRDB

// The shared database queue
var dbQueue: DatabaseQueue!

let kOffset = "offset"
let kCount = "count"

class ViewController: UIViewController {
    @IBOutlet weak var offsetTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    var count = 1000
    var offset = 0
    /**
      提示错误信息
     */
    fileprivate func alertErrorInfo(_ err: Error) {
        let alert = UIAlertController(title: "My Alert", message: "\(err)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            print("The \"Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func writeConfig(_ sender: UIButton) {
        if offsetTextField.text != nil {
           offset = Int(offsetTextField.text!) ?? offset
        }
        UserDefaults.init().set(offset, forKey: kOffset)        
        if countTextField.text != nil {
           count = Int(countTextField.text!) ?? count
        }
        UserDefaults.init().set(count, forKey: kCount)

    }
    /**
        导入联系人
     */
    @IBAction func importContact(_ sender: UIButton) {
        if offset == 0 {
            offset = UserDefaults.init().integer(forKey: kOffset)
        }
        if countTextField.text != nil {
            count = Int(countTextField.text!) ?? count
        }
        do {
             try dbQueue.read { db in
                let statement = try db.makeSelectStatement(sql: "SELECT * FROM Phones Order by id limit \(offset),\(count)")
                let users = try User.fetchAll(statement)
                for user in users {
                    let contact : CNMutableContact = CNMutableContact()
                    contact.givenName = "张燕\(user.PhoneNumber)"
                    let phone = CNPhoneNumber(stringValue:  user.PhoneNumber)
                    let phoneField = CNLabeledValue(label: CNLabelHome, value: phone)
                    contact.phoneNumbers = [phoneField]
                    addContact(Contact: contact) { (result) in
                       switch result{
                           case .Success(response: let bool):
                                if bool {
                                    print("Contact Sucessfully Added")
                                }
                                break
                           case .Error(error: let error):
                                self.alertErrorInfo(error)
                                break
                       }
                   }
                }
                offset += count
                UserDefaults.init().set(offset, forKey: kOffset)
            }
            offsetTextField.text = "\(offset)"
            
        } catch let err {
            alertErrorInfo(err)
        }
        
    }
    
    @IBAction func deleteContacts(_ sender: UIButton) {
        fetchContacts(completionHandler: { (result) in
            switch result{
                case .Success(response: let contacts):
                    for contact in contacts {
                       deleteContact(Contact: contact.mutableCopy() as! CNMutableContact) { (result) in
                       }
                    }
                break
                case .Error(error: let error):
                    self.alertErrorInfo(error)
                break
            }
        })
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        offset = UserDefaults.init().integer(forKey: kOffset)
        offsetTextField.text = "\(offset)"
        count = UserDefaults.init().integer(forKey: kCount)
        countTextField.text = "\(count)"
        requestAccess { (responce) in
               if responce{
                   print("Contacts Acess Granted")
               } else {
                   print("Contacts Acess Denied")
               }
        }
        authorizationStatus { (status) in
               switch status {
                   case .authorized:
                       print("authorized")
                       break
                   case .denied:
                       print("denied")
                       break
                   default:
                       break
                }
        }
        dbQueue = try! DatabaseQueue(path: Bundle.main.path(forResource: "result", ofType: "db")!)
    }
}

