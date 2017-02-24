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
	let cells: [ID]
	let sinks: [ID: Observable<CellSink>]
}

private enum CellAction {
	case add
	case remove(Int)
}

func sink(for source: Source) -> Observable<Sink> {
	let firstID = ID()

	let total = Observable.just("0")
	let cells = Observable.of(source.add.map { CellAction.add }, source.remove.map { CellAction.remove($0) }).merge()
		.scan(Array<ID>([firstID])) { cells, action in
			var result = cells
			switch action {
			case .remove(let index):
				result.remove(at: index)
			case .add:
				result.append(ID())
			}
			return result
		}.startWith([firstID])

	let cellSinks: Observable<[ID: Observable<CellSink>]> = source.cellSource.map { (id, source) in [id: cellSink(for: source)] }.startWith([:])

	return Observable<Sink>.combineLatest(total, cells, cellSinks) { (total, cells, sinks) -> Sink in
		return Sink(total: total, cells: cells, sinks: sinks)
	}
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
