//
//  MockSources.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation
import RxSwift
@testable import My

struct MockSource: Source
{
	var add: Observable<Void> {
		return _add.asObservable()
	}

	var remove: Observable<Int> {
		return _remove.asObservable()
	}

	var cells: Observable<[ID: CellSource]> {
		return _cells.asObservable()
	}

	let _add = PublishSubject<Void>()
	let _remove = PublishSubject<Int>()
	let _cells = PublishSubject<[ID: CellSource]>()
}

struct MockCellSource: CellSource
{
	var increment: Observable<Void> { return _increment.asObservable() }
	var decrement: Observable<Void> { return _decrement.asObservable() }
	let bag = DisposeBag()

	let _increment = PublishSubject<Void>()
	let _decrement = PublishSubject<Void>()
}
