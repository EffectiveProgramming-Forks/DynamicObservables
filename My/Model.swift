//
//  Model.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation
import RxSwift


public
protocol Source {
	var add: Observable<Void> { get }
}

struct Sink {

	let total: Observable<Int>
	let cells: Observable<[String]>
	private let cellSinks = Variable<[String: Int]>([:])

	func cellSinkFactory(id: String) -> (_ source: CellSource) -> CellSink {
		return { source in
			let sink: CellSink
			if let current = self.cellSinks.value[id] {
				sink = CellSink(id: id, initialValue: current, source: source)
			}
			else {
				sink = CellSink(id: id, initialValue: 0, source: source)
			}
			sink.sum.map { (sink.id, $0) }
				.subscribe(onNext: {
					self.cellSinks.value[$0.0] = $0.1
				}, onCompleted: {
					self.cellSinks.value.removeValue(forKey: sink.id)
				})
				.disposed(by: source.bag)
			return sink
		}
	}

	init(source: Source) {
		total = cellSinks.asObservable().map { $0.values.reduce(0) { $0.0 + $0.1 } }
		cells = source.add.map { NSUUID().uuidString }.scan([]) { $0.0 + [$0.1] }
	}
}

public
protocol CellSource {
	var increment: Observable<Void> { get }
	var decrement: Observable<Void> { get }
	var bag: DisposeBag { get }
}

struct CellSink {
	init(id: String, initialValue: Int, source: CellSource) {
		self.id = id
		let add = source.increment.map { 1 }
		let subtract = source.decrement.map { -1 }
		sum = Observable.of(add, subtract).merge()
			.scan(initialValue, accumulator: { $0.0 + $0.1 })
			.startWith(initialValue)
	}

	let id: String
	let sum: Observable<Int>
}
