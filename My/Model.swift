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
	var cellSource: Observable<(id: ID, source: CellSource)> { get }
}

struct Sink {
	let total: String
	let cells: [(id: ID, sink: CellSink)]
}

private enum CellAction {
	case add
	case remove(Int)
}

func sink(for source: Source) -> Observable<Sink> {
	let cells = Observable.of(source.add.map { CellAction.add }, source.remove.map { CellAction.remove($0) }).merge()
		.scan(Array<(id: ID, sink: CellSink)>([(id: ID(), sink: CellSink(total: "0"))])) { cells, action in
			var result = cells
			switch action {
			case .remove(let index):
				result.remove(at: index)
			case .add:
				result.append((id: ID(), sink: CellSink(total: "0")))
			}
			return result
		}

	let cellSinks = source.cellSource.flatMap { (id, source) in cellSink(for: source).map { (id: id, sink: $0) }  }

	return Observable.combineLatest(cells, cellSinks) { cells, sinks -> [(id: ID, sink: CellSink)] in
		var result = cells
		if let index = cells.index(where: { $0.id == sinks.id }) {
			result[index].sink = sinks.sink
		}
		return result
	}
	.map { Sink(total: "0", cells: $0) }
	.startWith(Sink(total: "0", cells: [(id: ID(), sink: CellSink(total: "0"))]))
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
