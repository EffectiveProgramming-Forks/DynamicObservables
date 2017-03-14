//
//  MockStore.swift
//  My
//
//  Created by Daniel Tartaglia on 3/14/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation
import RxSwift
@testable import My


class MockStore: Store {
	func save(data: Observable<[Int]>) {
		data.bindTo(totals).disposed(by: bag)
	}

	let totals = Variable<[Int]>([])
	let bag = DisposeBag()
}
