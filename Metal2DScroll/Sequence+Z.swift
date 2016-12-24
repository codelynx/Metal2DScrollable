//
//	Sequence+Z.swift
//	ZKit [swift 3]
//
//	The MIT License (MIT)
//
//	Copyright (c) 2016 Electricwoods LLC, Kaz Yoshikawa.
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
//		pair() invokes closure with a paired items accoding to the sequence.
//		It is usuful to build another sequence of item[N-1], item[N] based from
//		the current sequence.
//
//	Usage:
//		let array = [1, 3, 4, 7, 8, 9]
//		let items = array.pair { "\($0.0)-\($0.1)" } // ["1-3", "3-4", "4-7", "7-8", "8-9"]
//


extension Sequence {

	@discardableResult
	func pair<T>(_ closure: (Self.Iterator.Element, Self.Iterator.Element) -> T ) -> [T] {
		var results = [T]()
		var previous: Self.Iterator.Element? = nil
		var iterator = self.makeIterator()
		while let item = iterator.next() {
			if let previous = previous {
				results.append(closure(previous, item))
			}
			previous = item
		}
		return results
	}

}



