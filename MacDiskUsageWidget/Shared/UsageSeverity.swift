import Foundation

enum UsageSeverity: Equatable, Sendable {
    case normal
    case warning
    case critical

    init(fraction: Double) {
        let clamped = min(max(fraction, 0), 1)

        switch clamped {
        case ..<0.70:
            self = .normal
        case 0.70...0.85:
            self = .warning
        default:
            self = .critical
        }
    }
}
