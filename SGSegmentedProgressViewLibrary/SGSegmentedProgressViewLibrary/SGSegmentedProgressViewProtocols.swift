//
//  SGSegmentedProgressViewProtocols.swift
//  SGSegmentedProgressViewLibrary
//
//  Created by Sanjeev Gautam on 07/11/20.
//

//
//  SGSegmentedProgressViewProtocols.swift
//  SGSegmentedProgressView
//
//  Created by Sanjeev Gautam on 27/05/20.
//  Copyright © 2020 SG. All rights reserved.
//

import UIKit

public protocol SGSegmentedProgressViewDelegate: AnyObject {
    func segmentedProgressViewFinished(finishedIndex: Int, isLastIndex: Bool)
}

public protocol SGSegmentedProgressViewDataSource: AnyObject {
    var numberOfSegments: Int { get }
    var segmentDuration: TimeInterval { get }
    var paddingBetweenSegments: CGFloat { get }
    var trackColor: UIColor { get }
    var progressColor: UIColor { get }
    var roundCornerType: SGCornerType { get }
}

public enum SGCornerType {
    case roundCornerSegments(cornerRadious: CGFloat)
    case roundCornerBar(cornerRadious: CGFloat)
    case none
}
