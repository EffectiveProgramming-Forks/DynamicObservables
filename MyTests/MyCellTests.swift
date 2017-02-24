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
		source = MockCellSource()
		sink = cellSink(for: source)
		result = CellSink(total: "")
		let _ = sink.subscribe(onNext: { value in
			self.result = value
		})
	}

	private var source: MockCellSource!
	private var sink: Observable<CellSink>!
	private var result: CellSink!

	func testInitialValue() {
		XCTAssertEqual(result.total, "0")
	}

	func testIncrement() {
		source._increment.onNext()
		XCTAssertEqual(result.total, "1")

	}

	func testDecrement() {
		source._decrement.onNext()
		XCTAssertEqual(result.total, "-1")
	}

	func testIncrementThenDecrement() {
		source._increment.onNext()
		source._decrement.onNext()
		XCTAssertEqual(result.total, "0")
	}
}
