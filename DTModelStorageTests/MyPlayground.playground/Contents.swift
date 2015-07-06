//: Playground - noun: a place where people can play

import UIKit

protocol AssociatedModelTransfer
{
    typealias CellModel
    
     func updateWithModel(model : CellModel)
}


class FooCell : UIView, AssociatedModelTransfer
{
    func updateWithModel(model: Int) {
        print("hi model \(model)")
    }
}

class BarCell : UIView, AssociatedModelTransfer
{
    func updateWithModel(model: String) {
        print(model)
    }
}

typealias anyBlock = (Any,Any) -> ()
var updateBlocks = [anyBlock]()

func map<T:AssociatedModelTransfer>(cellType : T.Type)
{
    let type = T.CellModel.self
    let updateBlock: (Any,Any) -> Void = { view, model in
        (view as! T).updateWithModel(model as! T.CellModel)
    }
    updateBlocks.append(updateBlock)
}

func updateWithModel<T:AssociatedModelTransfer>(cell: T, model: T.CellModel)
{
    cell.updateWithModel(model)
}

let ref = reflect(Int.self)
let ref2 = reflect(String.self)

var dict = [ref.summary : FooCell.self, ref2.summary : BarCell.self]
////
////
let type = dict[reflect(5.dynamicType).summary]
type!.dynamicType

let view: UIView = BarCell()
let model: Any = 5

map(BarCell.self)
map(FooCell.self)

updateBlocks[0](view,"56")

//let array = [AssociatedModelTransfer]()
//if BarCell.self is AssociatedModelTransfer
//{
//    
//}


//protocol ModelTransfer
//{
//    //    typealias CellModel
//
//    func updateWithModel<CellModel>(model : CellModel)
//}

//if let view = view
//{
//    updateWithModel(view, 5)
//}
//else {
//    print("cast failed")
//}

//
//if let cell = (FooCell() as AnyObject) as? ModelTransfer {
//    cell.updateWithModel("bar")
//}
//else {
//    type
//}



// SOLUTION FOR SWIFT 2 WITH GENERIC SUBCLASSES

//class DTTableViewCell<T> : UIView
//{
//    func updateWithModel(model : T) {
//
//    }
//
//    init () {
//        super.init(frame : CGRectZero)
//    }
//}
//
//class IntCell : DTTableViewCell<Int>
//{
//    override func updateWithModel(model: Int) {
//        print(model)
//        print("dasdsadsa")
//    }
//
//
//}
//
//class StringCell : DTTableViewCell<String>
//{
//    override func updateWithModel(model: String) {
//
//    }
//}
//func map<T>(type : DTTableViewCell<T>.Type){
//    let mirror = reflect(T)
//    mirror.summary
//    print(mirror.summary)
//}
//
//func update<T>(model: T)
//{
//    let view = IntCell() as UIView
////    let castedView = view as! DTTableViewCell<T>
////    print(reflect(T).summary)
////    castedView.updateWithModel(model)
//    if let castedView = view as? DTTableViewCell<T>{
//        castedView.updateWithModel(model)
//    }
//    else {
//        print("cast failed")
//    }
//}
//
//var typeArray = [IntCell.self, StringCell.self]
//
//update(4)
//
//map(IntCell.self)


