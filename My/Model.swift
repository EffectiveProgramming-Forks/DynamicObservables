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
	var remove: Observable<Int> { get }
}

class Sink {

	typealias Factory = (Source) -> Sink

	static func factory(initialValue: [Int]) -> Factory {
		return { source in
			return Sink(initialValue: initialValue, source: source)
		}
	}

	let total: Observable<Int>
	private (set) var cells: Observable<[(id: ID, factory: CellSink.Factory)]> = Observable.just([])

	var modelState: Observable<[Int]> {
		return cellSinks.asObservable().map { Array($0.values) }
	}

	init(initialValue: [Int] = [0], source: Source) {
		total = cellSinks.asObservable().map {
			let foo = $0.values.reduce(0) { $0.0 + $0.1 }
			return foo
		}

		let initialAdders = Observable.from(initialValue.map { CellAction.add(initialValue: $0) })

		let adder = source.add.map { CellAction.add(initialValue: 0) }
		let remover = source.remove.map { CellAction.remove($0) }
		cells = Observable.of(Observable.of(initialAdders, adder).concat(), remover).merge()
			.scan([]) { (current, next) -> [(id: ID, factory: CellSink.Factory)] in
			var result = current
			switch next {
			case .add(let initialValue):
				let id = ID()
				let factory = self.cellFactory(id: id, initialValue: initialValue)
				result.append((id: id, factory: factory))
			case .remove(let index):
				let removed = result.remove(at: index)
				self.cellSinks.value.removeValue(forKey: removed.id)
			}
			return result
		}
	}

	private enum CellAction {
		case add(initialValue: Int)
		case remove(Int)
	}

	private let cellSinks = Variable<[ID: Int]>([:])

	private func cellFactory(id: ID, initialValue: Int) -> (CellSource) -> CellSink {
		return { source in
			let sink = CellSink(initialValue: initialValue, source: source)
			sink.sum.subscribe(onNext: { (sum: Int) -> Void in
				self.cellSinks.value[id] = sum
			}).disposed(by: source.bag)
			return sink
		}
	}
}

public
protocol CellSource {
	var increment: Observable<Void> { get }
	var decrement: Observable<Void> { get }
	var bag: DisposeBag { get }
}

struct CellSink {
	typealias Factory = (CellSource) -> CellSink

	static func factory(initialValue: Int) -> Factory {
		return { source in
			return CellSink(initialValue: initialValue, source: source)
		}
	}

	init(initialValue: Int, source: CellSource) {
		let add = source.increment.map { 1 }
		let subtract = source.decrement.map { -1 }
		sum = Observable.of(add, subtract).merge()
			.startWith(initialValue)
			.scan(0, accumulator: { $0.0 + $0.1 })
	}

	let sum: Observable<Int>
}
