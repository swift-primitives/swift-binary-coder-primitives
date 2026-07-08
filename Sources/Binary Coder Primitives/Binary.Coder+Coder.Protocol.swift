//
//  Binary.Coder+Coder.Protocol.swift
//  swift-binary-parser-primitives
//
//  Conforms Binary.Coder to Coder.Protocol.
//

public import Coder_Primitives
public import Either_Primitives

extension Binary.Coder: Coder.`Protocol` {
    /// Decoding reads from a read-only byte cursor.
    public typealias Input = Byte.Input
    /// Encoding appends to a mutable byte array.
    public typealias Buffer = [Byte]
    /// Decoding throws `Binary.Machine.Fault`; encoding never fails.
    public typealias Failure = Either<Binary.Machine.Fault, Never>

    /// Decodes a value from the byte cursor via the stored ``decode`` closure.
    ///
    /// - Parameter input: The byte cursor to decode from.
    /// - Returns: The decoded value.
    /// - Throws: `.left(Binary.Machine.Fault)` when decoding fails.
    @inlinable
    public func parse(_ input: inout Byte.Input) throws(Failure) -> Output {
        do throws(Binary.Machine.Fault) {
            return try self.decode(&input)  // stored closure, unchanged
        } catch {
            throw .left(error)
        }
    }

    /// Encodes the value into the byte buffer via the stored ``encode`` closure.
    ///
    /// - Parameters:
    ///   - output: The value to encode.
    ///   - buffer: The byte buffer to append to.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout [Byte]) {
        self.encode(output, &buffer)  // stored closure, unchanged
    }
}
