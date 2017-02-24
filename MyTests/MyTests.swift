//
//  MyTests.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import My


class MyTest: XCTestCase {

	func testInitial() {
		let source = MockSource()
		let _sink = sink(for: source)
		var result: Sink? = nil
		let _ = _sink.subscribe(onNext: {
			result = $0
		})

		XCTAssertEqual(result?.total, "0")
		XCTAssertEqual(result?.cells.count, 1)

		let cellSource = MockCellSource()
		let _ = _sink.subscribe(onNext: {
			result = $0
		})
		source._cellSource.onNext((id: result!.cells[0], source: cellSource))
		XCTAssertEqual(result?.sinks.count, 1)
	}
}
