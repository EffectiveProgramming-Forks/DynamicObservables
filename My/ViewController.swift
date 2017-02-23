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

	override func viewDidLoad() {
		super.viewDidLoad()
		sink = Sink(source: self)
		sink.total.map { "\($0)" }
			.bindTo(totalLabel.rx.text)
			.disposed(by: bag)
		
		sink.cells.subscribe(onNext: {
			self.cells = $0
			self.tableView.reloadData()
		}).disposed(by: bag)
	}

	var sink: Sink!
	var cells: [String] = []
	let bag = DisposeBag()

	let cellRemover = PublishSubject<String>()
}

extension ViewController: Source {
	var add: Observable<Void> { return addButton.rx.tap.asObservable() }
	var remove: Observable<String> { return cellRemover.asObservable() }
}

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
		cell.configure(sink: sink.cellSink(id: cells[indexPath.row], source: cell))
		return cell
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		cellRemover.onNext(cells[indexPath.row])
	}
}
