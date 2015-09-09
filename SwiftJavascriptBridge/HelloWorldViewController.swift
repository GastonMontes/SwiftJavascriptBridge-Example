//
//  HelloWorldViewController.swift
//  SwiftJavascriptBridge
//
//  Created by Gaston Montes on 7/9/15.
//  Copyright © 2015 Gaston Montes. All rights reserved.
//

import UIKit
import WebKit

class HelloWorldViewController: UIViewController, WKScriptMessageHandler {
    
    // MARK: - Constants.
    private let kNibName: String                    = "HelloWorldViewController"
    private let kHelloWorldHTMLFileURL             = "https://dl.dropboxusercontent.com/u/64786881/HelloWorldJS.html"
    private let kHelloWorldHTMLFileNameType         = "html"
    private let kHelloWorldCallBackHandlerName      = "callbackHandler";
    private let kObjectiveCSaysHelloToJSHandlerName = "objectiveCSaysHello()";
    
    // MARK: - Vars.
    private var jsWebView: WKWebView?
    
    // MARK: - IBOutlets properties.
    @IBOutlet weak private var recievedTextView : UITextView!;
    @IBOutlet weak private var replyTextView : UITextView!;
    @IBOutlet weak private var logTextView : UITextView!;
    
    // MARK: - View life cycle methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearTextViews()
        self.initializeWebView()
    }
    
    // MARK: - Set up components.
    private func clearTextViews() {
        self.recievedTextView.text  = "";
        self.replyTextView.text     = "";
        self.logTextView.text       = "";
    }
    
    // MARK: - Buttons Actions.
    @IBAction private func sayHelloToJSAction(sender : UIButton) {
        self.replyTextView.text = ""
        self.sayHelloToJS()
    }
    
    @IBAction private func clearLogButtonAction(sender : UIButton) {
        self.logTextView.text = "";
    }
    
    // MARK: - Private methods.
    private func sayHelloToJS() {
        self.logText("Swift says: Hello Javascript! How Are You?", timeStamp:NSDate().timeIntervalSince1970)
        let jsFunctionName: String = String(kObjectiveCSaysHelloToJSHandlerName)
        self.jsWebView!.evaluateJavaScript(jsFunctionName, completionHandler:{ (response : AnyObject?, error: NSError?) -> Void in
            if (error == nil) {
                self.logText("Swift says: JS confirmation message recieved", timeStamp: NSDate().timeIntervalSince1970)
            } else {
                print("Error: " + String(error))
            }
        })
    }
    
    private func timeStampString(timeStamp: Double!) -> String {
        let newDate = NSDate(timeIntervalSince1970:timeStamp)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm:ss.SSS"
        return formatter.stringFromDate(newDate)
    }
    
    private func logText(textToLog: String!, timeStamp: Double!) {
        let stringToLog: String = String(self.timeStampString(timeStamp) + " - " + textToLog)
        self.logTextView.text = String(stringToLog + "\n" + self.logTextView.text)
    }
    
    // MARK: - Initialization.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:kNibName, bundle:NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initializeWebView() {
        let url = NSURL(string: kHelloWorldHTMLFileURL)
        let request = NSURLRequest(URL: url!)
        
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.addScriptMessageHandler(self, name:kHelloWorldCallBackHandlerName)
        
        self.jsWebView = WKWebView(frame:self.view.bounds, configuration:theConfiguration)
        
        self.logText("Swift says: Loading HTML page.", timeStamp:NSDate().timeIntervalSince1970)
        self.jsWebView!.loadRequest(request)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let messageDictionary   = message.body as! NSDictionary;
        let messageFunctionName = messageDictionary["function"] as! String
        
        let messageSelector: Selector = Selector(messageFunctionName)
        
        if (self.respondsToSelector(messageSelector)) {
            self.performSelector(messageSelector, withObject: messageDictionary)
        } else {
            print("SE LLAMÓ DESDE JAVASCRIPT UNA FUNCIÓN QUE EN SWIFT NO EXISTE")
        }
    }
    
    // MARK: - Response call back methods.
    func jsSaysHelloWorld(messageDictionary: NSDictionary) {
        let nowDate: NSDate = NSDate();
        
        let messageDate = messageDictionary["date"] as! NSNumber
        let messageText = messageDictionary["message"] as! String
        
        self.logText(String(messageText), timeStamp:messageDate.doubleValue / 1000)
        self.logText("Swift says: 'Hello World' message from JS recieved correctly.", timeStamp:nowDate.timeIntervalSince1970)
        
        self.recievedTextView.text = messageText;
    }
    
    func jsWantsToLogData(messageDictionary: NSDictionary) {
        let messageDate = messageDictionary["date"] as! NSNumber
        let messageText = messageDictionary["message"] as! String
        self.logText(String(messageText), timeStamp:messageDate.doubleValue / 1000)
    }
}
