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

	let total: Observable<Int>
	private (set) var cells: Observable<[(id: ID, factory: CellSink.Factory)]> = Observable.just([])

	init(source: Source) {
		total = cellSinks.asObservable().map { $0.values.reduce(0) { $0.0 + $0.1 } }
		let adder = source.add.map { CellAction.add }
		let remover = source.remove.map { CellAction.remove($0) }
		cells = Observable.of(adder, remover).merge()
			.startWith(CellAction.add)
			.scan([]) { current, next in
			var result = current
			switch next {
			case .add:
				let id = ID()
				let factory: (CellSource) -> CellSink = { source in
					let sink = CellSink(initialValue: 0, source: source)
					sink.sum.subscribe(onNext: { (sum: Int) -> Void in
						self.cellSinks.value[id] = sum
					}).disposed(by: source.bag)
					return sink
				}

				result.append((id: id, factory: factory))
			case .remove(let index):
				let removed = result.remove(at: index)
				self.cellSinks.value.removeValue(forKey: removed.id)
			}
			return result
		}
	}

	private enum CellAction {
		case add
		case remove(Int)
	}
	private let cellSinks = Variable<[ID: Int]>([:])
}

public
protocol CellSource {
	var increment: Observable<Void> { get }
	var decrement: Observable<Void> { get }
	var bag: DisposeBag { get }
}

struct CellSink {
	typealias Factory = (CellSource) -> CellSink

	static func factory(initialValue: Int) -> (CellSource) -> CellSink {
		return { source in
			return CellSink(initialValue: initialValue, source: source)
		}
	}

	init(initialValue: Int, source: CellSource) {
		let add = source.increment.map { 1 }
		let subtract = source.decrement.map { -1 }
		sum = Observable.of(add, subtract).merge()
			.scan(initialValue, accumulator: { $0.0 + $0.1 })
			.startWith(initialValue)
			.debug()
	}

	let sum: Observable<Int>
}
