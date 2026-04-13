//
//  DevSettingsView.swift
//  
//
//  
//
import SwiftUI

struct DevSettingsView: View {

    @State var presenter: DevSettingsPresenter

    var body: some View {
        List {
            abTestSection
            #if DEBUG
            xpMultiplierSection
            #endif
            authSection
            userSection
            deviceSection
        }
        .navigationTitle("Dev Settings")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButtonView
            }
        }
        .onFirstAppear {
            presenter.loadABTests()
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                presenter.onBackButtonPressed()
            }
    }
            
    private var abTestSection: some View {
        Section {
            Toggle("Bool Test", isOn: $presenter.boolTest)
                .onChange(of: presenter.boolTest, presenter.handleBoolTestChange)

            Picker("Enum Test", selection: $presenter.enumTest) {
                ForEach(EnumTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: presenter.enumTest, presenter.handleEnumTestChange)
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    #if DEBUG
    private var xpMultiplierSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("Override Streak: \(presenter.streakDaysLabel)")
                Slider(value: $presenter.xpOverrideStreakDays, in: 0...30, step: 1)
                    .tint(.wazaAccent)
                    .onChange(of: presenter.xpOverrideStreakDays) { _, _ in
                        presenter.handleStreakDaysChanged()
                    }
            }

            Toggle("Force Fire Round (2x)", isOn: $presenter.xpForceFireRound)
                .onChange(of: presenter.xpForceFireRound) { _, _ in
                    presenter.handleFireRoundChanged()
                }

            Toggle("Force Perfect Week (+25%)", isOn: $presenter.xpForcePerfectWeek)
                .onChange(of: presenter.xpForcePerfectWeek) { _, _ in
                    presenter.handlePerfectWeekChanged()
                }
        } header: {
            Text("XP Multiplier Overrides")
        } footer: {
            Text("Log a session after changing these to see the multiplier in action.")
        }
        .font(.caption)
    }
    #endif

    private var authSection: some View {
        Section {
            ForEach(presenter.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            ForEach(presenter.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            ForEach(presenter.utilitiesData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.devSettingsView(router: router)
    }
}

extension CoreBuilder {
    
    func devSettingsView(router: AnyRouter) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

}

extension CoreRouter {
    
    func showDevSettingsView() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView(router: router)
        }
    }

}
