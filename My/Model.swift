//
//  Model.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation
import RxSwift


protocol Source: class {
	var add: Observable<Void> { get }
	var remove: Observable<Int> { get }
	var cellSources: Observable<(id: ID, source: CellSource)> { get }
}

struct Sink {
	let total: String
	let cellSinks: [(id: ID, sink: Observable<CellSink>?)]
}

private enum CellAction {
	case add
	case remove(Int)
	case configure((id: ID, source: CellSource))
}

func sink(for source: Source) -> Observable<Sink> {

	let total = Observable.just("0")
	
	let addCell = source.add.map { CellAction.add }
	let removeCell = source.remove.map { CellAction.remove($0) }
	let configureCell = source.cellSources.map { CellAction.configure($0) }
	let cellSinks = Observable.of(addCell, removeCell, configureCell).merge()
		.startWith(.add)
		.scan([]) { (cells, action) -> [(id: ID, sink: Observable<CellSink>?)] in
			var result = cells
			switch action {
			case .add:
				result.append((id: ID(), sink: nil))
			case .remove(let index):
				result.remove(at: index)
			case .configure(let (id, source)):
				if let index = cells.index(where: { $0.id == id }) {
					result[index] = (id: id, sink: cellSink(for: source))
				}
			}
			print(result.map { ($0.id, $0.sink != nil) })
			return result
		}
	
	return Observable.combineLatest(total, cellSinks) { Sink(total: $0, cellSinks: $1) }
}

protocol CellSource: class {
	var increment: Observable<Void> { get }
	var decrement: Observable<Void> { get }
}

struct CellSink {
	let total: String
}

func cellSink(for source: CellSource) -> Observable<CellSink> {
	let add = source.increment.map { 1 }
	let subtract = source.decrement.map { -1 }
	let sum = Observable.of(add, subtract).merge().scan(0) { $0.0 + $0.1 }
		.startWith(0)
		.map { "\($0)" }
	return sum.map { CellSink(total: $0) }
}
