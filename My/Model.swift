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
	var remove: Observable<String> { get }
}

struct Sink {

	let total: Observable<Int>
	let cells: Observable<[String]>

	func cellSink(id: String, source: CellSource) -> CellSink {
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

	init(source: Source) {
		total = cellSinks.asObservable().map { $0.values.reduce(0) { $0.0 + $0.1 } }
		let adder = source.add.map { CellAction.add(NSUUID().uuidString) }
		let remover = source.remove.map { CellAction.remove($0) }
		cells = Observable.of(adder, remover).merge().scan([]) { current, next in
			var result = current
			switch next {
			case .add(let id):
				result.append(id)
			case .remove(let id):
				if let index = result.index(of: id) {
					result.remove(at: index)
				}
			}
			return result
		}.startWith([])
	}

	private enum CellAction {
		case add(String)
		case remove(String)
	}
	private let cellSinks = Variable<[String: Int]>([:])
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
