// Copyright © 2017 Square1.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  Created by Roberto Prato on 03/12/2017.
//

import Foundation


public struct Pagination : Codable {
    
    static let NOPAGE = Pagination(currentPage: 0, total: 0, perPage: 15)
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case total = "total"
        case perPage = "per_page"
    }
    
    public var currentPage: Int
    public var total: Int = -1
    public var perPage: Int
    
    public var nextPage: Int {
        get {
            return self.currentPage + 1
        }
    }
    
    public var pageCount: Int {
        get {
            let count = self.total / self.perPage
            let mod = self.total % self.perPage
            return count + ((mod > 0) ? 1 : 0)
        }
    }
    
    public var hasNext : Bool {
        get {// if total < 0 , means we have never requested the first page so we don't know how many pages are there
            return self.total < 0 || self.currentPage < self.total
        }
    }
    
}
