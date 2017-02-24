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

	override func setUp() {
		super.setUp()
		source = MockSource()
		self._sink = sink(for: source)
		result = Sink(total: "", cells: [])
		let _ = _sink.subscribe(onNext: { value in
			self.result = value
		})
	}

	private var source: MockSource!
	private var _sink: Observable<Sink>!
	private var result: Sink!

	func testInitial() {
		XCTAssertEqual(result.total, "0")
		XCTAssertEqual(result.cells.count, 1)
		XCTAssertEqual(result.cells[0].sink.total, "0")
	}

	func testRemove() {
		source._remove.onNext(0)
		XCTAssertEqual(result.total, "0")
		XCTAssertEqual(result.cells.count, 0)
	}

	func testAdd() {
		source._add.onNext()
		XCTAssertEqual(result.total, "0")
		XCTAssertEqual(result.cells.count, 2)
	}

	func testCell() {
		let cell = MockCellSource()
		let id = ID()
		source._cells.onNext([id: cell])
		cell._increment.onNext()
		XCTAssertEqual(result.cells[0].sink.total, "1")
	}
}
/*
class MyTests: XCTestCase {

	override func setUp() {
		super.setUp()

		source = MockSource()
		sink = Sink(source: source)
		bag = DisposeBag()
	}

	private var source: MockSource!
	private var sink: Sink!
	private var bag: DisposeBag!

	func testInitialTotal() {
		var result: Int? = nil
		
		sink.total.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)
		
		XCTAssertEqual(result, 0)
	}

	func testInitialCells() {
		var result: [String]? = nil
		
		sink.cells.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)
		
		XCTAssertEqual(result ?? ["error"], [])
	}
	
	func testAddCell() {
		var result: [String]? = nil
		
		sink.cells.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)

		source._add.onNext()
		XCTAssert(result?.count == 1)
	}

	func testAddTwoCells() {
		var result: [String]? = nil
		
		sink.cells.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)
		
		source._add.onNext()
		source._add.onNext()
		XCTAssert(result?.count == 2)
	}

	func testAddTwoCellsRemoveOne() {
		var result: [String]? = nil
		
		sink.cells.subscribe(onNext: { value in
			result = value
		}).disposed(by: bag)
		
		source._add.onNext()
		source._add.onNext()
		let removed = result?[0] ?? "bad"
		source._remove.onNext(removed)
		XCTAssert(result?.count == 1)
		XCTAssert(result?.index(of: removed) == nil)
	}
}
*/
