import SwiftUI

@MainActor
protocol SessionEntryRouter: GlobalRouter {
    // No navigation needed — sheet dismisses itself on save
}

extension CoreRouter: SessionEntryRouter { }
