//
//  Builder.swift
//  Waza
//
//  
//
import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}
