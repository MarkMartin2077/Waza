//
//  WazaWidgetsBundle.swift
//  WazaWidgets
//
//  Created by Mark Martin on 2/28/26.
//

import WidgetKit
import SwiftUI

@main
struct WazaWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        NextClassWidget()
        TrainingTimerLiveActivity()
    }
}
