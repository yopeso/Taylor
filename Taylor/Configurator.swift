//
//  Configurator.swift
//  Taylor
//
//  Created by Andrei Raifura on 11/19/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import HockeySDK

struct Configurator {
    
    func configure() {
        startHockeyApp()
    }
    
    func startHockeyApp() {
        let HockeyAppID = "2ef85847b3c541d5b5644ae017ce6b1b"
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(HockeyAppID)
        BITHockeyManager.sharedHockeyManager().startManager()
    }
}
