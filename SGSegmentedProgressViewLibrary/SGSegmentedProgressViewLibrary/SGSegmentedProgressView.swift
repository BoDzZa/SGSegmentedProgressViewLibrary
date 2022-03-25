//
//  SGSegmentedProgressView.swift
//  SGSegmentedProgressViewLibrary
//
//  Created by Sanjeev Gautam on 07/11/20.
//

import UIKit

public final class SGSegmentedProgressView: UIView {
    
    public weak var delegate: SGSegmentedProgressViewDelegate?
    public weak var dataSource: SGSegmentedProgressViewDataSource?
    
    private var numberOfSegments: Int { get { return self.dataSource?.numberOfSegments ?? .zero } }
    private var segmentDuration: TimeInterval { get { return self.dataSource?.segmentDuration ?? 5 } }
    private var paddingBetweenSegments: CGFloat { get { return self.dataSource?.paddingBetweenSegments ?? 5 } }
    private var trackColor: UIColor { get { return self.dataSource?.trackColor ?? UIColor.red.withAlphaComponent(0.3) } }
    private var progressColor: UIColor { get { return self.dataSource?.progressColor ?? UIColor.red } }
    
    private var segments = [UIProgressView]()
    private var timer: Timer?
    
    private let PROGRESS_SPEED: Double = 1000
    private var PROGRESS_INTERVAL: Float {
        let value = (self.segmentDuration * PROGRESS_SPEED)
        let result = (Float(1/value))
        return result
    }
    private var TIMER_TIMEINTERVAL: Double {
        return (1/PROGRESS_SPEED)
    }
    
    private var stackView = UIStackView()
    
    // MARK:- Properties
    public private (set) var isPaused: Bool = false
    public private (set) var currentIndex: Int = .zero

    // MARK:- Initializer
    internal required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.drawSegments()
    }
    
    // MARK:- Private
    private func drawSegments() {
        for index in .zero..<self.numberOfSegments {
            let progressView = self.createProgressView()
            self.segments.append(progressView)
            
            if let cornerType = self.dataSource?.roundCornerType {
                switch cornerType {
                case .roundCornerSegments(let cornerRadious):
                    progressView.borderAndCorner(cornerRadious: cornerRadious, borderWidth: 0, borderColor: nil)
                case .roundCornerBar(let cornerRadious):
                    if index == .zero {
                        progressView.roundCorners(corners: [.topLeft, .bottomLeft], radius: cornerRadious)
                    } else if index == self.numberOfSegments-1 {
                        progressView.roundCorners(corners: [.topRight, .bottomRight], radius: cornerRadious)
                    }
                case .none:
                    break
                }
            }
        }
        
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = paddingBetweenSegments
        segments.forEach(stackView.addArrangedSubview(_:))
    }
    
    public func setupStackViewLayout() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: .zero).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .zero).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: .zero).isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func createProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.setProgress(.zero, animated: false)
        progressView.trackTintColor = self.trackColor
        progressView.tintColor = self.progressColor
        return progressView
    }
    
    // MARK:- Timer
    private func setUpTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: TIMER_TIMEINTERVAL, target: self, selector: #selector(animationTimerMethod), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func animationTimerMethod() {
        if self.isPaused { return }
        self.animateSegment()
    }
    
    // MARK:- Animate Segment
    private func animateSegment() {
        if self.currentIndex < self.segments.count {
            let progressView = self.segments[self.currentIndex]
            let lastProgress = progressView.progress
            let newProgress = lastProgress + PROGRESS_INTERVAL
            
            progressView.setProgress(newProgress, animated: false)
            
            if newProgress >= 1 {
                if self.currentIndex == self.numberOfSegments-1 {
                    self.delegate?.segmentedProgressViewFinished(finishedIndex: self.currentIndex, isLastIndex: true)
                } else {
                    self.delegate?.segmentedProgressViewFinished(finishedIndex: self.currentIndex, isLastIndex: false)
                }
                
                if self.currentIndex < self.numberOfSegments-1 {
                    self.currentIndex = self.currentIndex + 1
                    
                    let progressView = self.segments[self.currentIndex]
                    progressView.setProgress(.zero, animated: false)
                    
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    // MARK:- Actions
    public func start() {
        self.setUpTimer()
    }
    
    public func pause() {
        self.isPaused = true
    }
    
    public func resume() {
        self.isPaused = false
    }
    
    public func restart() {
        self.reset()
        self.start()
    }
    
    public func nextSegment() {
        if self.currentIndex < self.segments.count-1 {
            self.isPaused = true
            
            let progressView = self.segments[self.currentIndex]
            progressView.setProgress(1, animated: false)
            
            self.currentIndex = self.currentIndex + 1
            
            self.isPaused = false
            
            if self.timer == nil {
                self.start()
            } else {
                self.animateSegment()
            }
        }
    }
    
    public func previousSegment() {
        
        if self.currentIndex > .zero {
            self.isPaused = true
            
            let currentProgressView = self.segments[self.currentIndex]
            currentProgressView.setProgress(.zero, animated: false)
            
            self.currentIndex = self.currentIndex - 1
            
            let progressView = self.segments[self.currentIndex]
            progressView.setProgress(.zero, animated: false)
            
            self.isPaused = false
            
            if self.timer == nil {
                self.start()
            } else {
                self.animateSegment()
            }
        }
    }
    
    public func restartCurrentSegment() {
        self.isPaused = true
        
        let currentProgressView = self.segments[self.currentIndex]
        currentProgressView.setProgress(.zero, animated: false)
        
        self.isPaused = false
        
        if self.timer == nil {
            self.start()
        } else {
            self.animateSegment()
        }
    }
    
    public func reset() {
        self.isPaused = true
        
        self.timer?.invalidate()
        self.timer = nil
        
        for index in .zero..<numberOfSegments {
            let progressView = self.segments[index]
            progressView.setProgress(.zero, animated: false)
        }
        
        self.currentIndex = .zero
        self.isPaused = false
    }
    
    // MARK:- Set Progress Manually
    public func setProgressManually(index: Int, progressPercentage: CGFloat) {
        
        if index < self.segments.count && index >= .zero {
            self.timer?.invalidate()
            self.timer = nil
            
            self.currentIndex = index
            var percentage = progressPercentage
            if progressPercentage > 100 {
                percentage = 100
            }
            
            // converting into 0 to 1 for UIProgressView range
            percentage = percentage / 100
            
            let progressView = self.segments[self.currentIndex]
            progressView.setProgress(Float(percentage), animated: false)
        }
    }
}
