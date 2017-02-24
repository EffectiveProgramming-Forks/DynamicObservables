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

		let s = sink(for: self)
		s.map { $0.total }
			.bindTo(totalLabel.rx.text)
			.disposed(by: bag)

		s.map { $0.cells }
			.bindTo(tableView.rx.items(cellIdentifier: "Cell")) { (row, element, cell) in
				guard let cell = cell as? TableViewCell else { fatalError() }
				cell.configure(with: element.sink)
				self._cells.value[element.id] = cell
		}.disposed(by: bag)
	}

	let _cells = Variable<[ID: CellSource]>([:])
	let bag = DisposeBag()
}

extension ViewController: Source {
	var add: Observable<Void> {
		return addButton.rx.tap.asObservable()
	}

	var remove: Observable<Int> {
		return tableView.rx.itemDeleted.map { $0.row }.asObservable()
	}

	var cells: Observable<[ID: CellSource]> {
		return _cells.asObservable()
	}

}
