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

		store = MockStore()
		source = MockSource()
		sink = Sink.factory(store: store)(source)
		bag = DisposeBag()
		resultCells = nil
		sink.total.subscribe(onNext: { value in
			self.resultTotal = value
		}).disposed(by: bag)
		sink.cells.subscribe(onNext: { value in
			self.resultCells = value
			for cell in self.resultCells! {
				let cellSource = MockCellSource()
				let _ = cell.factory(cellSource) // testing of cell sinks is done elsewhere.
				self.cellSources[cell.id] = cellSource
			}
		}).disposed(by: bag)
	}

	private var store: MockStore!
	private var source: MockSource!
	private var cellSources: [ID: MockCellSource] = [:]
	private var sink: Sink!
	private var bag: DisposeBag!
	private var resultTotal: Int?
	private var resultCells: [(id: ID, factory: CellSink.Factory)]?

	func testInitial() {
		// ensure that on startup, there is one cell and the total is 0.
		XCTAssertEqual(resultTotal, 0)
		XCTAssertEqual(resultCells?.count, 1)
	}

	func testIncrement() {
		// esnure that sending an increment on a cell will cause total to increase.
		cellSources.values.first!._increment.onNext()
		XCTAssertEqual(resultTotal, 1)
	}

	func testAddCell() {
		// ensure that sending an add signal will cause an extra cell to be generated.
		source._add.onNext()
		XCTAssertEqual(resultCells?.count, 2)
	}

	func testRemoveCell() {
		// ensure that sending a remove signal will cause the cell to be removed.
		let toRemove = resultCells?[0].id
		source._remove.onNext(0)
		XCTAssertEqual(resultCells?.count, 0)
		XCTAssertEqual(resultCells?.index(where: { toRemove == $0.id }), nil)
	}

	func testStoreData() {
		// ensure that sending an increment on a cell will get saved in the store.
		cellSources.values.first!._increment.onNext()
		XCTAssertEqual(store.totals.value, [1])
	}
}


class MyCellsModelTests: XCTestCase {
	
	func testInitialValue() {
		// ensure that provided initial values will be observed.
		let source = MockSource()
		let sink = Sink(initialValue: [1, 2, 3], source: source)
		let bag = DisposeBag()
		var resultTotal: Int? = nil
		var resultCells: [(id: ID, factory: CellSink.Factory)] = []

		sink.total.subscribe(onNext: { value in
			resultTotal = value
		}).disposed(by: bag)
		sink.cells.subscribe(onNext: { value in
			resultCells = value
			for cell in resultCells {
				let _ = cell.factory(MockCellSource())
			}
		}).disposed(by: bag)

		XCTAssertEqual(resultTotal, 6)
		XCTAssertEqual(resultCells.count, 3)
	}

}
