//
//  ChartGroupedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 19/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public final class ChartPointsBarGroup<T: ChartBarModel> {
    let constant: ChartAxisValue
    let bars: [T]
    
    public init(constant: ChartAxisValue, bars: [T]) {
        self.constant = constant
        self.bars = bars
    }
}


public class ChartGroupedBarsLayer: ChartCoordsSpaceLayer {
    
    private let groups: [ChartPointsBarGroup<ChartBarModel>]
    
    private let barSpacing: CGFloat?
    private let groupSpacing: CGFloat?
    
    private let horizontal: Bool
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, groups: [ChartPointsBarGroup<ChartBarModel>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?) {
        self.groups = groups
        self.horizontal = horizontal
        self.barSpacing = barSpacing
        self.groupSpacing = groupSpacing
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    public override func chartInitialized(#chart: Chart) {
        
        let axis = self.horizontal ? self.yAxis : self.xAxis
        let groupAvailableLength = (axis.length  - (self.groupSpacing ?? 0) * CGFloat(self.groups.count)) / CGFloat(groups.count + 1)
        let maxBarCountInGroup = self.groups.reduce(CGFloat(0)) {maxCount, group in
            max(maxCount, CGFloat(group.bars.count))
        }
        
        let barWidth = ((groupAvailableLength - ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))) / CGFloat(maxBarCountInGroup))
        
        let barsGenerator = ChartBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: barWidth, barSpacing: self.barSpacing)
        
        let calculateConstantScreenLoc: (axis: ChartAxisLayer, index: Int, group: ChartPointsBarGroup) -> CGFloat = {axis, index, group in
            let totalWidth = CGFloat(group.bars.count) * barWidth + ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))
            let groupCenter = axis.screenLocForScalar(group.constant.scalar)
            let origin = groupCenter - totalWidth / 2
            return origin + CGFloat(index) * (barWidth + (self.barSpacing ?? 0)) + barWidth / 2
        }
        
        for group in self.groups {
            
            for (index, bar) in enumerate(group.bars) {
                
                let constantScreenLoc: CGFloat = {
                    if barsGenerator.direction == .LeftToRight {
                        return calculateConstantScreenLoc(axis: self.yAxis, index: index, group: group)
                    } else {
                        return calculateConstantScreenLoc(axis: self.xAxis, index: index, group: group)
                    }
                }()
                chart.addSubview(barsGenerator.generateView(bar, constantScreenLoc: constantScreenLoc, bgColor: bar.bgColor, animDuration: 0.5))
            }
        }
    }
}
