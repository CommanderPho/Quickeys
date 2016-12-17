//
//  PastebinAPI.swift
//  Quickeys
//
//  Created by Alex Rosenfeld on 12/14/16.
//  Copyright © 2016 Alex Rosenfeld. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation
import SystemConfiguration

class PastebinAPI {
    
    var API_KEY = ""
    var player: AVAudioPlayer?
    
    init() {
        API_KEY = valueForAPIKey(named: "API_KEY")
    }
    
    let url = NSURL(string: "http://pastebin.com/api/api_post.php")
    
    func valueForAPIKey(named keyname:String) -> String {
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }
    
    func postPasteRequest(urlEscapedContent: String) {
        
        var request = URLRequest(url: URL(string: "http://pastebin.com/api/api_post.php")!)
        request.httpMethod = "POST"
        let postString = "api_paste_code=\(urlEscapedContent)&api_dev_key=\(API_KEY)&api_option=paste&api_paste_private=1&api_paste_expire_date=N"
        request.httpBody = postString.data(using: .utf8)
        if Reachability.isInternetAvailable() {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    NSLog("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    NSLog("statusCode should be 200, but is \(httpStatus.statusCode)")
                    NSLog("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                
                let pasteBoard = NSPasteboard.general()
                pasteBoard.clearContents()
                if (responseString?.contains("pastebin.com"))! {
                    NSLog(responseString!)
                    pasteBoard.setString(responseString!, forType: NSStringPboardType)
                } else if (responseString?.contains("maximum"))! {
                    self.playFunkSound()
                    NSLog(responseString!)
                    pasteBoard.setString("http://pastebin.com", forType: NSStringPboardType)
                } else {
                    self.playFunkSound()
                    NSLog(responseString!)
                    pasteBoard.setString("http://pastebin.com", forType: NSStringPboardType)
                }
            }
            task.resume()
        } else {
            playFunkSound()
        }
    }
    
    func playFunkSound() {
        let url = Bundle.main.url(forResource: "Funk", withExtension: "aiff")!
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            guard let player = self.player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
}
