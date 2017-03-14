//
//  AppDelegate.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import UIKit
import RxSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		UserDefaults.standard.register(defaults: ["totals": [0]])

		let totals = UserDefaults.standard.array(forKey: "totals") as! [Int]
		let controller = window?.rootViewController as! ViewController
		controller.factory = Sink.factory(initialValue: totals, store: self)
		return true
	}

}

extension AppDelegate: Store {

	func save(data: Observable<[Int]>) {
		_ = data.subscribe(onNext: { totals in
			UserDefaults.standard.set(totals, forKey: "totals")
		})
	}
}
