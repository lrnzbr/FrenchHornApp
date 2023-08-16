//
//  AppFont.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/10/23.
//

import Foundation
import SwiftUI

enum AppFontSize {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case callout
    case subheadline
    case body
    case footnote
    case caption1
    case caption2

    public var size: CGFloat {
        switch self {
        case .largeTitle: return 34.0
        case .title1: return 28.0
        case .title2: return 22.0
        case .title3: return 20.0
        case .headline: return 17.0
        case .callout: return 16.0
        case .subheadline: return 15.0
        case .body: return 17.0
        case .footnote: return 13.0
        case .caption1: return 12.0
        case .caption2: return 11.0
        }
    }
}

enum AppFontWeight {
    case light
    case medium
    case regular
    case bold

    public var weight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .bold
        }
    }
}

struct AppFont {
    static let largeTitle = Font.largeTitle
    static let title1 = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let footnote = Font.footnote
    static let caption1 = Font.caption
    static let caption2 = Font.caption2

    public static func largeTitle(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.largeTitle.weight(fontWeight.weight)
    }

    public static func title1(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.title.weight(fontWeight.weight)
    }

    public static func title2(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.title2.weight(fontWeight.weight)
    }

    public static func title3(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.title3.weight(fontWeight.weight)
    }

    public static func headline(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.headline.weight(fontWeight.weight)
    }

    public static func callout(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.callout.weight(fontWeight.weight)
    }

    public static func subheadline(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.subheadline.weight(fontWeight.weight)
    }

    public static func body(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.body.weight(fontWeight.weight)
    }

    public static func footnote(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.footnote.weight(fontWeight.weight)
    }

    public static func caption1(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.caption.weight(fontWeight.weight)
    }

    public static func caption2(
        _ fontWeight: AppFontWeight = .regular
    ) -> Font {
        return Font.caption2.weight(fontWeight.weight)
    }
}

