import Binary_Integer_Coder_Primitives
import Binary_Parser_Primitives_Test_Support
import Testing

@testable import Binary_Coder_Primitives

// MARK: - Binary.Coder Tests

// Note: Binary.Coder<Value> is generic, so per [TEST-004] we use
// parallel namespace pattern instead of type extension pattern.

@Suite struct `Binary.Coder Tests` {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Binary.Coder Tests`.Unit {

    @Test
    func `decodeWhole decodes complete input`() throws {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )

        let value = try coder.decodeWhole([0x42])

        #expect(value == 0x42)
    }

    @Test
    func `decodePrefix consumes only needed bytes`() throws {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )
        var input = Byte.Input([0x42, 0xFF, 0xFF])

        let value = try coder.decodePrefix(&input)

        #expect(value == 0x42)
        #expect(input.count == 2)
    }

    @Test
    func `encodeToArray creates new array`() {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )

        let bytes = coder.encodeToArray(0x42)

        #expect(bytes == [0x42])
    }

    @Test
    func `encodeAppending appends to existing buffer`() {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )
        var buffer: [Byte] = [0x00, 0x01]

        coder.encodeAppending(0x42, to: &buffer)

        #expect(buffer == [0x00, 0x01, 0x42])
    }
}

// MARK: - EdgeCase Tests

extension `Binary.Coder Tests`.EdgeCase {

    @Test
    func `decodeWhole throws when bytes remain`() {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )

        #expect(throws: Binary.Machine.Fault.self) {
            try coder.decodeWhole([0x42, 0xFF])
        }
    }

    @Test
    func `decodeWhole throws on empty input when decode fails`() {
        let coder = Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in output.append(Byte(value)) }
        )

        #expect(throws: Binary.Machine.Fault.self) {
            try coder.decodeWhole([])
        }
    }

    @Test
    func `encode empty value produces empty array`() {
        let coder = Binary.Coder<Void>(
            decode: { _ throws(Binary.Machine.Fault) in () },
            encode: { _, _ in }
        )

        let bytes = coder.encodeToArray(())

        #expect(bytes.isEmpty)
    }
}

// MARK: - Integration Tests

extension `Binary.Coder Tests`.Integration {

    @Test
    func `round trip UInt16 little endian`() throws {
        let coder = UInt16.coder(endianness: .little)
        let original: UInt16 = 0x1234

        let encoded = coder.encodeToArray(original)
        let decoded = try coder.decodeWhole(encoded)

        #expect(decoded == original)
        #expect(encoded == [0x34, 0x12])
    }

    @Test
    func `round trip UInt32 big endian`() throws {
        let coder = UInt32.coder(endianness: .big)
        let original: UInt32 = 0xDEAD_BEEF

        let encoded = coder.encodeToArray(original)
        let decoded = try coder.decodeWhole(encoded)

        #expect(decoded == original)
        #expect(encoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    @Test
    func `sequential decode with prefix`() throws {
        let byteCoder = UInt8.coder(endianness: .big)
        var input = Byte.Input([0x01, 0x02, 0x03])

        let first = try byteCoder.decodePrefix(&input)
        let second = try byteCoder.decodePrefix(&input)
        let third = try byteCoder.decodePrefix(&input)

        #expect(first == 0x01)
        #expect(second == 0x02)
        #expect(third == 0x03)
        #expect(input.isEmpty)
    }
}
