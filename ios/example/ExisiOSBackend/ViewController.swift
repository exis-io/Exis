//
//  ViewController.swift
//  ExisiOSBackend
//
//  Created by damouse on 11/7/15.


import UIKit
import Riffle

class ViewController: UIViewController, RiffleDelegate {

    var app: RiffleDomain?
    var me: RiffleDomain?
    var container: RiffleDomain?


    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!

    //Send your request to your Swift backend!
    @IBAction func sendRequest(sender: AnyObject) {
        container!.call("hello", nameField.text!) { (response: String) -> () in
            print("There is someone out there!\nResponse: \(response)")
            self.helloLabel.text = response
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //This is your apps backend - Find it in Backend/main.swift
        //Change USERNAME to your username that you used to sign up with at my.exis.io
        app = RiffleDomain(domain: "xs.demo.USERNAME.helloworldswift")

        //Set up your domain
        me = RiffleDomain(name: "localagent", superdomain: app!)
        me!.delegate = self


        //Joining container with your token
        //Copy from: Auth() -> Authorized Key Management -> 'localagent' key
        me!.join("XXXXXXXXXXXXXX")
    }

    //Function called when joining backend ran successfuly
    func onJoin() {
        print("User joined!")
        print("Can anyone out there hear us!?")
        container = RiffleDomain(name: "container", superdomain: app!)
    }

    func onLeave() {
        print("Session left!")
    }
}

