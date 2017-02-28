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


class MyCellsTests: XCTestCase {

	override func setUp() {
		super.setUp()

		source = MockSource()
		sink = Sink(source: source)
		bag = DisposeBag()
		resultCells = nil
		sink.total.subscribe(onNext: { value in
			self.resultTotal = value
		}).disposed(by: bag)
		sink.cells.subscribe(onNext: { value in
			self.resultCells = value
		}).disposed(by: bag)
	}

	private var source: MockSource!
	private var sink: Sink!
	private var bag: DisposeBag!
	private var resultTotal: Int?
	private var resultCells: [(id: ID, factory: CellSink.Factory)]?

	func testInitial() {
		XCTAssertEqual(resultTotal, 0)
		XCTAssertEqual(resultCells?.count, 1)
	}

	func testIncrement() {
		let cell = MockCellSource()
		let _ = resultCells![0].factory(cell)
		cell._increment.onNext()
		XCTAssertEqual(resultTotal, 1)
	}

	func testAddCell() {
		source._add.onNext()
		XCTAssertEqual(resultCells?.count, 2)
	}

	func testRemoveCell() {
		let toRemove = resultCells?[0].id
		source._remove.onNext(0)
		XCTAssertEqual(resultCells?.count, 0)
		XCTAssertEqual(resultCells?.index(where: { toRemove == $0.id }), nil)
	}

}


class MyCellsModelTests: XCTestCase {
	func testInitialValue() {
		let source = MockSource()
		let sink = Sink(initialValue: [1, 2, 3], source: source)
		let bag = DisposeBag()
		var resultTotal: Int = 0
		var resultCells: [(id: ID, factory: CellSink.Factory)] = []

		sink.total.subscribe(onNext: { value in
			resultTotal = value
			print("resultTotal: \(resultTotal)")
		}).disposed(by: bag)
		sink.cells.subscribe(onNext: { value in
			resultCells = value
		}).disposed(by: bag)

		XCTAssertEqual(resultTotal, 6)
		XCTAssertEqual(resultCells.count, 3)
	}
}
