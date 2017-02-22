//
//  MockSources.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation
import RxSwift
import My


struct MockSource: Source
{
	var add: Observable<Void> {
		return _add.asObservable()
	}

	let _add = PublishSubject<Void>()
}

struct MockCellSource: CellSource
{
	var increment: Observable<Void> { return _increment.asObservable() }
	var decrement: Observable<Void> { return _decrement.asObservable() }
	let bag = DisposeBag()

	let _increment = PublishSubject<Void>()
	let _decrement = PublishSubject<Void>()
}
