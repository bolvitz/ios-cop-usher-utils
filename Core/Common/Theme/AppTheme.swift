//
//  AppTheme.swift
//  EventMonitor
//
//  Material Design 3 theme matching Android app
//

import SwiftUI

struct AppTheme {
    // Primary colors (Material 3 Purple)
    static let primary = Color(hex: "#6200EE")
    static let primaryVariant = Color(hex: "#3700B3")
    static let secondary = Color(hex: "#03DAC6")
    static let secondaryVariant = Color(hex: "#018786")

    // Background colors
    static let background = Color(hex: "#FFFFFF")
    static let surface = Color(hex: "#FFFFFF")
    static let error = Color(hex: "#B00020")

    // Text colors
    static let onPrimary = Color.white
    static let onSecondary = Color.black
    static let onBackground = Color.black
    static let onSurface = Color.black
    static let onError = Color.white

    // Additional colors
    static let success = Color(hex: "#66BB6A")
    static let warning = Color(hex: "#FFA726")
    static let info = Color(hex: "#42A5F5")

    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // Corner radius
    static let radiusS: CGFloat = 4
    static let radiusM: CGFloat = 8
    static let radiusL: CGFloat = 12
    static let radiusXL: CGFloat = 16

    // Typography
    static let headlineLarge = Font.system(size: 32, weight: .bold)
    static let headlineMedium = Font.system(size: 28, weight: .bold)
    static let headlineSmall = Font.system(size: 24, weight: .bold)
    static let titleLarge = Font.system(size: 22, weight: .semibold)
    static let titleMedium = Font.system(size: 16, weight: .medium)
    static let titleSmall = Font.system(size: 14, weight: .medium)
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)
}

// View modifiers for consistent styling
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.radiusL)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    func primaryButton() -> some View {
        self
            .font(AppTheme.labelLarge)
            .foregroundColor(AppTheme.onPrimary)
            .padding(.horizontal, AppTheme.spacingL)
            .padding(.vertical, AppTheme.spacingM)
            .background(AppTheme.primary)
            .cornerRadius(AppTheme.radiusM)
    }

    func secondaryButton() -> some View {
        self
            .font(AppTheme.labelLarge)
            .foregroundColor(AppTheme.primary)
            .padding(.horizontal, AppTheme.spacingL)
            .padding(.vertical, AppTheme.spacingM)
            .background(AppTheme.primary.opacity(0.1))
            .cornerRadius(AppTheme.radiusM)
    }
}
