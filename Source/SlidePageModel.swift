//
//  PageScrollViewModel.swift
//  SlideController
//
//  Created by Evgeny Dedovets on 4/16/17.
//  Copyright © 2017 Touchlane LLC. All rights reserved.
//

public protocol SlideLifeCycleObjectProvidable: class {
    var lifeCycleObject: SlideLifeCycleObject { get }
}

open class SlidePageModel<T: SlideLifeCycleObject>: SlideLifeCycleObjectProvidable, Initializable {
    ///Internal LifeCycle Object
    private var object: T?
    
    ///Use to create model with prebuilt LifeCycle object
    public init(object: T) {
        self.object = object
    }
    
    // MARK: - InitializableImplementation
    required public init() { }
    
    // MARK: - SlideLifeCycleObjectProvidableImplementation
    open var lifeCycleObject: SlideLifeCycleObject { get { return buildObjectIfNeeded() } }
}

private typealias PrivateSlidePageModel = SlidePageModel
extension PrivateSlidePageModel  {
    ///Genarate LifeCycle object of specified type when needed
    func buildObjectIfNeeded() -> SlideLifeCycleObject {
        if let object = object {
            return object
        }
        object = T()
        return object!
    }
}
