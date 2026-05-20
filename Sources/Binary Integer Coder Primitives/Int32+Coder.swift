//
//  Int32+Coder.swift
//  swift-binary-coder-primitives
//
//  Binary coder for Int32 serialization.
//

public import Binary_Coder_Primitives
import Input_Primitives

extension Int32 {
    /// Returns a coder for reading/writing four bytes as `Int32`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let coder = Int32.coder(endianness: .big)
    ///
    /// // Decode
    /// let bytes: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFE]
    /// var input = Input.Slice(bytes[...])
    /// let value = try coder.decodePrefix(&input)
    /// // value == -2
    ///
    /// // Encode
    /// var output: [UInt8] = []
    /// coder.encodeAppending(-2, to: &output)
    /// // output == [0xFF, 0xFF, 0xFF, 0xFE] (big-endian)
    /// ```
    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<Int32> {
        let parser: Binary.Machine.Parser<Int32> =
            switch endianness {
            case .little: Binary.Machine.i32leParser()
            case .big: Binary.Machine.i32beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
