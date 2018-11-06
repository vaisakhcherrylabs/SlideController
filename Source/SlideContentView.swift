//
//  SlideContentView.swift
//  SlideController
//
//  Created by Evgeny Dedovets on 3/13/17.
//  Copyright © 2017 Touchlane LLC. All rights reserved.
//

import UIKit

final class SlideContentView: UIScrollView {
    private let slideDirection: SlideDirection
    private var containers: [SlideContainerView] = []
    
    ///Simple hack to be notified when layout completed
    var firstLayoutAction: (() -> Void)?
    internal private(set) var isLayouted = false
    
    ///Notifies on each size or content size update
    var changeLayoutAction: (() -> ())?
    private var previousSize: CGSize = .zero
    private var previousContentSize: CGSize = .zero
    
    /// - Parameter scrollDirection: indicates the target slide direction
    init(slideDirection: SlideDirection) {
        self.slideDirection = slideDirection
        super.init(frame: .zero)
        self.isPagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.isDirectionalLockEnabled = true
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard self.bounds.size != self.previousSize || self.contentSize != self.previousContentSize else {
            return
        }
        
        super.layoutSubviews()
        if !self.isLayouted {
            self.isLayouted = true
            self.firstLayoutAction?()
        }

        self.layoutContainers(direction: self.slideDirection)

        self.previousSize = self.bounds.size
        self.previousContentSize = self.contentSize
        self.changeLayoutAction?()
    }
    
    func hideContainers(at indices: [Int]) {
        let pages = containers
            .enumerated()
            .filter({ indices.contains($0.offset) })
            .map({ $0.element })
        for page in pages {
            page.hide(direction: slideDirection)
        }
    }
    
    func showContainers(at indices: [Int]) {
        let pages = containers
            .enumerated()
            .filter({ indices.contains($0.offset) })
            .map({ $0.element })
        for page in pages {
            page.show(direction: slideDirection)
        }
    }
    
    private func layoutContainers(direction: SlideDirection) {
        let size = self.bounds.size

        var scrollAxisOffset: CGFloat = 0
        for container in self.containers {
            let origin: CGPoint
            switch direction {
            case .horizontal:
                origin = CGPoint(x: scrollAxisOffset, y: 0)
                scrollAxisOffset += size.width
            case .vertical:
                origin = CGPoint(x: 0, y: scrollAxisOffset)
                scrollAxisOffset += size.height
            }

            container.view.frame = CGRect(origin: origin, size: size)
        }

        switch direction {
        case .horizontal:
            self.contentSize = CGSize(width: scrollAxisOffset, height: size.height)
        case .vertical:
             self.contentSize = CGSize(width: size.width, height: scrollAxisOffset)
        }
    }
}

private typealias ViewSlidableImplementation = SlideContentView
extension ViewSlidableImplementation: ViewSlidable {
    typealias View = UIView
    
    func appendViews(views: [View]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            let viewModel = SlideContainerView(view: view)
            self.containers.append(viewModel)
            self.addSubview(viewModel.view)
        }
        
        self.layoutContainers(direction: self.slideDirection)
    }

    func insertView(view: View, index: Int) {
        guard index < self.containers.count else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let viewModel = SlideContainerView(view: view)
        self.containers.insert(viewModel, at: index)
        self.addSubview(viewModel.view)
        
        self.layoutContainers(direction: self.slideDirection)
    }
    
    func removeViewAtIndex(index: Int) {
        guard index < self.containers.count else {
            return
        }
        
        let page = self.containers[index]
        self.containers.remove(at: index)
        page.view.removeFromSuperview()

        self.layoutContainers(direction: self.slideDirection)
    }
}
