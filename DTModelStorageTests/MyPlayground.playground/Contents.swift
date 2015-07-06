//: Playground - noun: a place where people can play

import UIKit

protocol ModelTransfer
{
    typealias CellModel
    
     func updateWithModel(model : CellModel)
}


class IntCell : UIView, ModelTransfer
{
    func updateWithModel(model: Int) {
        println("hi model \(model)")
    }
}

class StringCell : UIView, ModelTransfer
{
    func updateWithModel(model: String) {
        println(model)
    }
}

typealias anyBlock = (Any,Any) -> ()
var updateBlocks = [anyBlock]()

func registerCellClass<T:ModelTransfer>(cellType : T.Type)
{
    let type = T.CellModel.self
    let updateBlock: (Any,Any) -> Void = { view, model in
        (view as! T).updateWithModel(model as! T.CellModel)
    }
    updateBlocks.append(updateBlock)
}

//let ref = reflect(Int.self)
//let ref2 = reflect(String.self)
//
//var dict = [ref.summary : IntCell.self, ref2.summary : StringCell.self]
//////
//////
//let type = dict[reflect(5.dynamicType).summary]
//type!.dynamicType
//
//let view: UIView = StringCell()
//let model: Any = 5

registerCellClass(StringCell.self)
registerCellClass(IntCell.self)

updateBlocks[0](StringCell(),"56")
updateBlocks[1](IntCell(),42)

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


