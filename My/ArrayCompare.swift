//
//  ArrayCompare.swift
//
//  Created by Daniel Tartaglia on Sep 10, 2015.
//  Inspired by http://www.swift-studies.com/blog/2015/5/15/swift-coding-challenge-incremental-updates-to-views
//

public func findDifferences<T : Hashable>(old: [T], new:[T], moveBlock: (_ from: Int, _ to: Int)->()) -> (insertions: [Int], removals: [Int])
{
	var insertionIndexs = [Int]()
	var removalIndexs = [Int]()
	var newPositions = [T : Int]()
	for index in 0 ..< new.count {
		newPositions[new[index]]=index
	}
	for oldPosition in 0 ..< old.count {
		let item = old[oldPosition]
		if let newPosition = newPositions[item] {
			if oldPosition != newPosition{
				moveBlock(oldPosition, newPosition)
			}
			newPositions.removeValue(forKey: item)
		} else {
			removalIndexs.append(oldPosition)
		}
	}
	for (_, position) in newPositions {
		insertionIndexs.append(position)
	}
	return (insertions: insertionIndexs, removals: removalIndexs)
}
