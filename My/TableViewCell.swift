//
//  TableViewCell.swift
//  My
//
//  Created by Daniel Tartaglia on 2/22/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TableViewCell: UITableViewCell {

	@IBOutlet weak var incrementButton: UIButton!
	@IBOutlet weak var decrementButton: UIButton!
	@IBOutlet weak var outputLabel: UILabel!

	func configure(sink: CellSink) {
		sink.sum
			.map { "\($0)" }
			.bindTo(outputLabel.rx.text)
			.disposed(by: bag)
	}

	let bag = DisposeBag()

}

extension TableViewCell: CellSource {
	var increment: Observable<Void> {
		return incrementButton.rx.tap.asObservable()
	}

	var decrement: Observable<Void> {
		return decrementButton.rx.tap.asObservable()
	}
}
