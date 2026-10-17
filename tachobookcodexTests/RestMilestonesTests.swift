import Foundation
import Testing
@testable import tachobookcodex

struct RestMilestonesTests {
    private func instant(_ text: String) throws -> Date {
        try #require(ISO8601DateFormatter().date(from: text))
    }

    private func values(start: Date, now: Date) throws -> RestMilestones.Values {
        let result = RestMilestones.calculate(restStart: start, now: now)
        guard case let .calculated(values) = result else {
            Issue.record("Expected calculated milestones, got \(result)")
            throw UnexpectedResult()
        }
        return values
    }

    private struct UnexpectedResult: Error {}

    private func expectLocal(
        _ date: Date, zone: String, year: Int, month: Int, day: Int,
        hour: Int, minute: Int, offset: Int
    ) throws {
        let timeZone = try #require(TimeZone(identifier: zone))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        #expect(parts.year == year)
        #expect(parts.month == month)
        #expect(parts.day == day)
        #expect(parts.hour == hour)
        #expect(parts.minute == minute)
        #expect(parts.second == 0)
        #expect(timeZone.secondsFromGMT(for: date) == offset)
    }

    @Test("C01: absolute deadlines cross midnight and display in Berlin")
    func midnight() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let result = try values(start: start, now: start)
        #expect(result.nineHours.deadline == (try instant("2026-10-13T05:57:00Z")))
        #expect(result.elevenHours.deadline == (try instant("2026-10-13T07:57:00Z")))
        try expectLocal(result.nineHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 13, hour: 7, minute: 57, offset: 7200)
        try expectLocal(result.elevenHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 13, hour: 9, minute: 57, offset: 7200)
    }

    @Test("C02: exact and fractional boundaries for both milestones",
          arguments: [32_400.0, 39_600.0], [-1.0, -0.25, 0.0, 0.25, 1.0])
    func boundary(threshold: TimeInterval, offset: TimeInterval) throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let now = start.addingTimeInterval(threshold + offset)
        let result = try values(start: start, now: now)
        let milestone = threshold == 32_400 ? result.nineHours : result.elevenHours
        #expect(milestone.remaining == max(0, -offset))
        #expect(milestone.reached == (offset >= 0))
        #expect(result.elapsed == threshold + offset)
        if threshold == 32_400 && offset == 0 {
            #expect(result.elevenHours.remaining == 7200)
            #expect(!result.elevenHours.reached)
        }
    }

    @Test("C03: autumn DST uses elapsed seconds")
    func autumnDST() throws {
        let start = try instant("2026-10-24T22:00:00+02:00")
        let result = try values(start: start, now: instant("2026-10-25T02:00:00Z"))
        #expect(result.elapsed == 6 * 3600)
        #expect(result.nineHours.remaining == 3 * 3600)
        #expect(result.elevenHours.remaining == 5 * 3600)
        #expect(result.nineHours.deadline == (try instant("2026-10-25T05:00:00Z")))
        #expect(result.elevenHours.deadline == (try instant("2026-10-25T07:00:00Z")))
        try expectLocal(result.nineHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 25, hour: 6, minute: 0, offset: 3600)
        try expectLocal(result.elevenHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 25, hour: 8, minute: 0, offset: 3600)
    }

    @Test("C04: spring DST uses elapsed seconds")
    func springDST() throws {
        let start = try instant("2026-03-28T22:00:00+01:00")
        let result = try values(start: start, now: instant("2026-03-29T02:00:00Z"))
        #expect(result.elapsed == 5 * 3600)
        #expect(result.nineHours.remaining == 4 * 3600)
        #expect(result.elevenHours.remaining == 6 * 3600)
        #expect(result.nineHours.deadline == (try instant("2026-03-29T06:00:00Z")))
        #expect(result.elevenHours.deadline == (try instant("2026-03-29T08:00:00Z")))
        try expectLocal(result.nineHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 3, day: 29, hour: 8, minute: 0, offset: 7200)
        try expectLocal(result.elevenHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 3, day: 29, hour: 10, minute: 0, offset: 7200)
    }

    @Test("C05: Berlin and Kyiv presentation preserves instants and durations")
    func presentationTimeZone() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let now = try instant("2026-10-13T02:57:00+02:00")
        let berlin = try values(start: start, now: now)
        try expectLocal(berlin.nineHours.deadline, zone: "Europe/Kyiv",
                        year: 2026, month: 10, day: 13, hour: 8, minute: 57, offset: 10800)
        try expectLocal(berlin.elevenHours.deadline, zone: "Europe/Kyiv",
                        year: 2026, month: 10, day: 13, hour: 10, minute: 57, offset: 10800)
        let kyiv = try values(start: instant("2026-10-12T23:57:00+03:00"),
                              now: instant("2026-10-13T03:57:00+03:00"))
        #expect(kyiv == berlin)
        #expect(kyiv.elapsed == 14_400)
        #expect(kyiv.nineHours.remaining == 18_000)
        #expect(kyiv.elevenHours.remaining == 25_200)
    }

    @Test("C06: reconstructed saved instant gives the same result on repeated calls")
    func restoredTimestamp() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let saved = try JSONEncoder().encode(start)
        let restored = try JSONDecoder().decode(Date.self, from: saved)
        let now = try instant("2026-10-13T02:57:00+02:00")
        let result = try values(start: restored, now: now)
        #expect(result == (try values(start: start, now: now)))
        #expect(result == (try values(start: restored, now: now)))
        #expect(result.elapsed == 14_400)
        #expect(result.nineHours.remaining == 18_000)
        #expect(result.elevenHours.remaining == 25_200)
        #expect(!result.nineHours.reached)
        #expect(!result.elevenHours.reached)
    }

    @Test("C07: corrected rest start recomputes every value")
    func correctedStart() throws {
        let now = try instant("2026-10-13T02:57:00+02:00")
        let old = try values(start: instant("2026-10-12T22:57:00+02:00"), now: now)
        let corrected = try values(start: instant("2026-10-12T23:12:00+02:00"), now: now)
        #expect(corrected.nineHours.deadline == (try instant("2026-10-13T06:12:00Z")))
        #expect(corrected.elevenHours.deadline == (try instant("2026-10-13T08:12:00Z")))
        #expect(corrected.elapsed == 13_500)
        #expect(corrected.nineHours.remaining == 18_900)
        #expect(corrected.elevenHours.remaining == 26_100)
        #expect(corrected.nineHours.deadline != old.nineHours.deadline)
        #expect(corrected.elevenHours.deadline != old.elevenHours.deadline)
        try expectLocal(corrected.nineHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 13, hour: 8, minute: 12, offset: 7200)
        try expectLocal(corrected.elevenHours.deadline, zone: "Europe/Berlin",
                        year: 2026, month: 10, day: 13, hour: 10, minute: 12, offset: 7200)
    }

    @Test("C08: missing rest start is no-data")
    func missingStart() throws {
        let now = try instant("2026-10-13T02:57:00+02:00")
        #expect(RestMilestones.calculate(restStart: nil, now: now) == .noData)
    }

    @Test("C08: a future start is invalid, even by a fraction of a second",
          arguments: [0.25, 1.0, 3600.0])
    func futureStart(offset: TimeInterval) throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        #expect(RestMilestones.calculate(restStart: start, now: start.addingTimeInterval(-offset))
                == .invalidInput)
    }

    @Test("C09: timestamps alone yield duration milestones without regulatory history")
    func noHistoryRequired() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let result = try values(start: start, now: instant("2026-10-13T08:57:00+02:00"))
        #expect(result.elapsed == 36_000)
        #expect(result.nineHours.deadline == (try instant("2026-10-13T05:57:00Z")))
        #expect(result.elevenHours.deadline == (try instant("2026-10-13T07:57:00Z")))
        #expect(result.nineHours.remaining == 0)
        #expect(result.nineHours.reached)
        #expect(result.elevenHours.remaining == 3600)
        #expect(!result.elevenHours.reached)
        // The API returns time values only; eligibility, classification and counters
        // are outside its contract and require separate future integration tests.
    }

    @Test("C10: 30 hours stays the same rest, with no elapsed cap or automatic reset")
    func longRest() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let result = try values(start: start, now: instant("2026-10-14T04:57:00+02:00"))
        #expect(result.elapsed == 108_000)
        #expect(result.nineHours.deadline == (try instant("2026-10-13T05:57:00Z")))
        #expect(result.elevenHours.deadline == (try instant("2026-10-13T07:57:00Z")))
        #expect(result.nineHours.remaining == 0)
        #expect(result.elevenHours.remaining == 0)
        #expect(result.nineHours.reached)
        #expect(result.elevenHours.reached)
    }

    @Test("At the start: zero elapsed and both full durations remaining")
    func exactStart() throws {
        let start = try instant("2026-10-12T22:57:00+02:00")
        let result = try values(start: start, now: start)
        #expect(result.elapsed == 0)
        #expect(result.nineHours.remaining == 32_400)
        #expect(result.elevenHours.remaining == 39_600)
        #expect(!result.nineHours.reached)
        #expect(!result.elevenHours.reached)
    }
}
