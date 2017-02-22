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


}
