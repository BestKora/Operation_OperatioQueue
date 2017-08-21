/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

public func slowAdd(_ input: (Int, Int)) -> Int {
  sleep(1)
  return input.0 + input.1
}

public func slowAddArray(_ input: [(Int, Int)],
                         progress: ((Double) -> (Bool))? = nil) -> [Int] {
  var results = [Int]()
  for pair in input {
    results.append(slowAdd(pair))
    if let progress = progress {
      if !progress(Double(results.count) / Double(input.count)) { return results }
    }
  }
  return results
}

private let workerQueue = DispatchQueue(label: "com.raywenderlich.slowsum", attributes: DispatchQueue.Attributes.concurrent)

public func asyncAdd_GCD(_ input: (Int, Int), completionQueue: DispatchQueue, completion:@escaping (Int) -> ()) {
  workerQueue.async {
    let result = slowAdd(input)
    completionQueue.async {
      completion(result)
    }
  }
}

private let additionQueue = OperationQueue()
public func asyncAdd_OpQ(lhs: Int, rhs: Int, callback: @escaping (Int) -> ()) {
  additionQueue.addOperation {
    sleep(1)
    callback(lhs + rhs)
  }
}
