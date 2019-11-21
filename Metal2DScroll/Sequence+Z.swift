//
//	Sequence+Z.swift
//	ZKit [swift 5]
//
//	The MIT License (MIT)
//
//	Copyright (c) 2019 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy 
//	of this software and associated documentation files (the "Software"), to deal 
//	in the Software without restriction, including without limitation the rights 
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//	copies of the Software, and to permit persons to whom the Software is 
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//
//	Description:
//		makePairs() create an array of tuples which is pair of (n), (n + 1) in sequence.
//		Make sure the sequence is finite.
//
//	Usage:
//		let array = [1, 3, 4, 7, 8, 9]
//		for (item1, item2) in array.makePairs() {
//			print("\(item1) - \(item2)")
//		}
//
//	Result:
//		1 - 3
//		3 - 4
//		4 - 7
//		7 - 8
//		8 - 9



extension Sequence {

	func makePairs() -> [(Self.Iterator.Element, Self.Iterator.Element)] {
		let array = self.map { $0 }
		return zip(array.dropLast(), array.dropFirst()).map { ($0, $1) }
	}

}




