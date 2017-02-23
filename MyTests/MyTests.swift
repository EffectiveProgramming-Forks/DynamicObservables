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
