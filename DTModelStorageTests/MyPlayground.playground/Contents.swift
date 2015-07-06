//: Playground - noun: a place where people can play

import UIKit

var t = "sdfdsf"

protocol ModelTransfer
{
//    typealias CellModel

    func updateWithModel<CellModel>(model : CellModel)
}

class FooCell : UIView, ModelTransfer
{
    func updateWithModel<Int>(model: Int) {
        print("hi model \(model)")
    }
}

class BarCell : UIView, ModelTransfer
{
    func updateWithModel<String>(model: String) {

    }
}

let ref = reflect(Int.self)
let ref2 = reflect(String.self)

var dict = [ref.summary : FooCell.self, ref2.summary : BarCell.self]
////
////
let type = dict[reflect(5.dynamicType).summary]
type!.dynamicType


if let cell = (FooCell() as AnyObject) as? ModelTransfer {
    cell.updateWithModel("bar")
}
else {
    type
}



// SOLUTION FOR SWIFT 2 WITH GENERIC SUBCLASSES

//class DTTableViewCell<T> : UIView
//{
//    func updateWithModel<T>(model : T) {
//
//    }
//}
//
//class IntCell : DTTableViewCell<Int>
//{
//    func updateWithModel(model: Int) {
//
//    }
//}
//
//class StringCell : DTTableViewCell<String>
//{
//    func updateWithModel(model: String) {
//
//    }
//}
//func map<T>(type : DTTableViewCell<T>.Type){
//    let mirror = reflect(T)
//    mirror.summary
//}
//
//map(IntCell.self)
