//
//  ViewController.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {

	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var tableView: UITableView!

	var factory: Sink.Factory!

	override func viewDidLoad() {
		super.viewDidLoad()
		sink = factory(self)
		sink.total.map { "\($0)" }
			.bindTo(totalLabel.rx.text)
			.disposed(by: bag)
		
		sink.cells.subscribe(onNext: { newCells in
			self.tableView.beginUpdates()
			let diffs = findDifferences(old: self.cells.map { $0.id }, new: newCells.map { $0.id }, moveBlock: { (old, new) in
				let oldIndexPath = IndexPath(row: old, section: 0)
				let newIndexPath = IndexPath(row: new, section: 0)
				self.tableView.moveRow(at: oldIndexPath, to: newIndexPath)
			})
			let insertIndexPaths = diffs.insertions.map { IndexPath(row: $0, section: 0) }
			self.tableView.insertRows(at: insertIndexPaths, with: .automatic)

			let deleteIndexPaths = diffs.removals.map { IndexPath(row: $0, section: 0) }
			self.tableView.deleteRows(at: deleteIndexPaths, with: .automatic)
			self.cells = newCells
			self.tableView.endUpdates()
		}).disposed(by: bag)
	}

	var sink: Sink!
	var cells: [(id: ID, factory: CellSink.Factory)] = []
	let bag = DisposeBag()

	let cellRemover = PublishSubject<Int>()
}

extension ViewController: Source {
	var add: Observable<Void> { return addButton.rx.tap.asObservable() }
	var remove: Observable<Int> { return cellRemover.asObservable() }
}

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
		let cellSink = cells[indexPath.row].factory
		cell.configure(sink: cellSink(cell))
		return cell
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		cellRemover.onNext(indexPath.row)
	}
}
