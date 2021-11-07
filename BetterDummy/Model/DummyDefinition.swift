//
//  DummyDefinition.swift
//  BetterDummy
//
//  Created by @waydabber
//

class DummyDefinition {
  let aspectWidth, aspectHeight, multiplierStep, minMultiplier, maxMultiplier: Int
  let refreshRates: [Double]
  let description: String
  let addSeparatorAfter: Bool

  convenience init(_ aspectWidth: Int, _ aspectHeight: Int, _ step: Int, _ refreshRates: [Double], _ description: String, _ addSeparatorAfter: Bool = false) {
    let minX: Int = 720
    let minY: Int = 720
    let maxX: Int = 4096
    let maxY: Int = 4096
    let minMultiplier = max(Int(ceil(Float(minX) / (Float(aspectWidth) * Float(step)))), Int(ceil(Float(minY) / (Float(aspectHeight) * Float(step)))))
    let maxMultiplier = min(Int(floor(Float(maxX) / (Float(aspectWidth) * Float(step)))), Int(floor(Float(maxY) / (Float(aspectHeight) * Float(step)))))
    self.init(aspectWidth, aspectHeight, minMultiplier, maxMultiplier, step, refreshRates, description, addSeparatorAfter)
  }

  init(_ aspectWidth: Int, _ aspectHeight: Int, _ minMultiplier: Int, _ maxMultiplier: Int, _ step: Int, _ refreshRates: [Double], _ description: String, _ addSeparatorAfter: Bool = false) {
    self.aspectWidth = aspectWidth
    self.aspectHeight = aspectHeight
    self.minMultiplier = minMultiplier
    self.maxMultiplier = maxMultiplier
    self.multiplierStep = step
    self.refreshRates = refreshRates
    self.description = description
    self.addSeparatorAfter = addSeparatorAfter
  }
}
