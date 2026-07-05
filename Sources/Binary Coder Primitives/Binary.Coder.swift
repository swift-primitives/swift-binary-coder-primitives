//
//  Binary.Coder.swift
//  swift-binary-primitives
//
//  Witness-based bidirectional coder with separate decode/encode types.
//
//  Parsing input and printing output are different algebraic operations:
//  - Decoding: streaming + checkpoint/restore (Byte.Input)
//  - Encoding: mutable, insertable buffer ([Byte])
//
//  This witness separates these concerns cleanly.
//

public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Ownership_Shared_Primitive
public import Witness_Primitives

extension Binary {
    /// A witness for bidirectional binary coding with separate input/output types.
    ///
    /// Unlike `Parser.ParserPrinter` which requires the same `Input` type for both
    /// directions, `Coder` uses the appropriate type for each operation:
    /// - Decoding from `Byte.Input` (read-only cursor)
    /// - Encoding into `[Byte]` (mutable buffer)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let coder = Binary.Coder<UInt16>(
    ///     decode: { input in
    ///         let lo = try! input.advance()
    ///         let hi = try! input.advance()
    ///         return UInt16(hi) << 8 | UInt16(lo)
    ///     },
    ///     encode: { value, output in
    ///         output.append(Byte(UInt8(truncatingIfNeeded: value)))
    ///         output.append(Byte(UInt8(truncatingIfNeeded: value >> 8)))
    ///     }
    /// )
    ///
    /// let bytes: [Byte] = [0x34, 0x12]
    /// let value = try coder.decodeWhole(bytes)  // 0x1234
    /// let encoded = coder.encodeToArray(value)  // [0x34, 0x12]
    /// ```
    public struct Coder<Output>: Witness.`Protocol` {
        /// Decodes a value from a read-only byte cursor.
        public var decode: (inout Byte.Input) throws(Binary.Machine.Fault) -> Output

        /// Encodes a value into a mutable byte buffer.
        public var encode: (Output, inout [Byte]) -> Void

        /// Creates a coder with the given decode and encode operations.
        @inlinable
        public init(
            decode: @escaping (inout Byte.Input) throws(Binary.Machine.Fault) -> Output,
            encode: @escaping (Output, inout [Byte]) -> Void
        ) {
            self.decode = decode
            self.encode = encode
        }
    }
}

// MARK: - Execution Helpers

extension Binary.Coder {
    /// Decodes a value from a complete byte array, requiring all bytes consumed.
    ///
    /// - Parameter bytes: The bytes to decode.
    /// - Returns: The decoded value.
    /// - Throws: `Binary.Machine.Fault` if decoding fails or bytes remain.
    @inlinable
    public func decodeWhole(_ bytes: [Byte]) throws(Binary.Machine.Fault) -> Output {
        var input = Byte.Input(bytes)
        let value = try decode(&input)
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.count)
        }
        return value
    }

    /// Decodes a value from a byte input, consuming only what's needed.
    ///
    /// - Parameter input: The byte cursor to decode from.
    /// - Returns: The decoded value.
    /// - Throws: `Binary.Machine.Fault` if decoding fails.
    @inlinable
    public func decodePrefix(_ input: inout Byte.Input) throws(Binary.Machine.Fault) -> Output {
        try decode(&input)
    }

    /// Encodes a value to a new byte array.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: The encoded bytes.
    @inlinable
    public func encodeToArray(_ value: Output) -> [Byte] {
        var out: [Byte] = []
        encode(value, &out)
        return out
    }

    /// Encodes a value by appending to an existing byte buffer.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - buffer: The buffer to append to.
    @inlinable
    public func encodeAppending(_ value: Output, to buffer: inout [Byte]) {
        encode(value, &buffer)
    }
}

// MARK: - Machine Integration

extension Binary.Coder {
    /// Creates a coder from a Machine parser and an encode function.
    ///
    /// - Parameters:
    ///   - parser: The Machine parser for decoding.
    ///   - encode: The encode function.
    /// - Returns: A coder wrapping the parser.
    @inlinable
    public static func machine(
        _ parser: Binary.Machine.Parser<Output>,
        encode: @escaping (Output, inout [Byte]) -> Void
    ) -> Self {
        Self(
            decode: { input throws(Binary.Machine.Fault) in
                try parser.parse(&input)
            },
            encode: encode
        )
    }
}
