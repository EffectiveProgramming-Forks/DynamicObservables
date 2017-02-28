//
//  MyCellTests.swift
//  MyTests
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import My


class MyCellTests: XCTestCase {

	override func setUp() {
		super.setUp()

		cellSource = MockCellSource()
		cellSink = CellSink(initialValue: 0, source: cellSource)
		bag = DisposeBag()
	}

	private var cellSource: MockCellSource!
	private var cellSink: CellSink!
	private var bag: DisposeBag!

	func testInitialValue() {
		var result: Int? = nil
		cellSink.sum.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)

		XCTAssertEqual(result, 0)
	}

	func testIncrement() {
		var result: Int? = nil
		cellSink.sum.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)

		cellSource._increment.onNext()
		XCTAssertEqual(result, 1)
	}

	func testIncrementTwice() {
		var result: Int? = nil
		cellSink.sum.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)

		cellSource._increment.onNext()
		cellSource._increment.onNext()
		XCTAssertEqual(result, 2)
	}

	func testDecrement() {
		var result: Int? = nil
		cellSink.sum.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)

		cellSource._decrement.onNext()
		XCTAssertEqual(result, -1)
	}
}
