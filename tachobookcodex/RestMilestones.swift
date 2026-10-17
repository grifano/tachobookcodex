import Foundation

/// Elapsed-time milestones for a single uninterrupted rest, independent of time zone.
/// Reaching a milestone does not determine legal eligibility, classify rest,
/// consume an allowance, end rest or start a shift.
nonisolated enum RestMilestones {
    enum Calculation: Equatable {
        case noData
        case invalidInput
        case calculated(Values)
    }

    struct Values: Equatable {
        let elapsed: TimeInterval
        let nineHours: Milestone
        let elevenHours: Milestone
    }

    struct Milestone: Equatable {
        let deadline: Date
        let remaining: TimeInterval
        let reached: Bool

        fileprivate init(start: Date, duration: TimeInterval, now: Date) {
            deadline = start.addingTimeInterval(duration)
            remaining = max(0, deadline.timeIntervalSince(now))
            reached = now >= deadline
        }
    }

    /// Recomputes from the supplied instants, including restored or corrected starts.
    /// Missing start is no-data; a start later than `now` is invalid input.
    static func calculate(restStart: Date?, now: Date) -> Calculation {
        guard let restStart else { return .noData }
        guard now >= restStart else { return .invalidInput }

        return .calculated(Values(
            elapsed: now.timeIntervalSince(restStart),
            nineHours: Milestone(start: restStart, duration: 9 * 3600, now: now),
            elevenHours: Milestone(start: restStart, duration: 11 * 3600, now: now)
        ))
    }
}
