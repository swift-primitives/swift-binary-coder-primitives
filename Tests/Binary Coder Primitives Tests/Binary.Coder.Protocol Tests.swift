import Binary_Integer_Coder_Primitives
import Binary_Parser_Primitives_Test_Support
import Either_Primitives
import Testing

@testable import Binary_Coder_Primitives

// MARK: - Binary.Coder.Protocol Tests
//
// Tests for Binary.Coder's Coder.Protocol-surface API.
//
// Exercises the refined `parse(_:)` and `serialize(_:into:)` methods
// directly (inherited via [FAM-006] from Parser.Protocol +
// Serializer.Protocol) with the unified
// `Either<Binary.Bytes.Machine.Fault, Never>` failure type.
//
// Note: Encode direction is infallible (Either<X, Never>), so callers
// can extract the parse-side fault unconditionally via .value (per
// Either+Never.swift in swift-either-primitives).

@Suite("Binary.Coder.Protocol")
struct BinaryCoderProtocolTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension BinaryCoderProtocolTests.Unit {

    @Test
    func `parse via Coder.Protocol surface decodes complete input`() throws {
        let coder = Binary.Coder.machine(
            Binary.Bytes.Machine.u8Parser(),
            encode: { value, output in output.append(value) }
        )
        var input = Byte.Input([0x42])

        let value = try coder.parse(&input)

        #expect(value == 0x42)
    }

    @Test
    func `serialize via Coder.Protocol surface appends bytes to buffer`() throws {
        let coder = Binary.Coder.machine(
            Binary.Bytes.Machine.u8Parser(),
            encode: { value, output in output.append(value) }
        )
        var buffer: [UInt8] = [0x00, 0x01]

        try coder.serialize(0x42, into: &buffer)

        #expect(buffer == [0x00, 0x01, 0x42])
    }

    @Test
    func `round-trip via Coder.Protocol surface preserves value`() throws {
        let coder = Binary.Coder.machine(
            Binary.Bytes.Machine.u8Parser(),
            encode: { value, output in output.append(value) }
        )

        var buffer: [UInt8] = []
        try coder.serialize(0xAB, into: &buffer)

        var input = Byte.Input(buffer)
        let reparsed = try coder.parse(&input)

        #expect(reparsed == 0xAB)
    }
}

// MARK: - EdgeCase Tests

extension BinaryCoderProtocolTests.EdgeCase {

    @Test
    func `parse via Coder.Protocol surface throws Either left on empty input`() throws {
        let coder = Binary.Coder.machine(
            Binary.Bytes.Machine.u8Parser(),
            encode: { value, output in output.append(value) }
        )
        var input = Byte.Input([])

        do {
            _ = try coder.parse(&input)
            Issue.record("Expected parse to throw on empty input")
        } catch let failure {
            // Failure is Either<Binary.Bytes.Machine.Fault, Never>.
            // Since Right == Never, .value extracts the Fault directly.
            let fault: Binary.Bytes.Machine.Fault = failure.value
            _ = fault
        }
    }
}
