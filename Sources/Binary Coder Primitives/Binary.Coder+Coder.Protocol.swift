//
//  Binary.Coder+Coder.Protocol.swift
//  swift-binary-parser-primitives
//
//  Conforms Binary.Coder to Coder.Protocol.
//

public import Coder_Primitives
public import Either_Primitives

extension Binary.Coder: Coder.`Protocol` {
    public typealias Input   = Byte.Input
    public typealias Buffer  = [UInt8]
    public typealias Failure = Either<Binary.Bytes.Machine.Fault, Never>

    @inlinable
    public func parse(_ input: inout Byte.Input) throws(Failure) -> Output {
        do {
            return try self.decode(&input)   // stored closure, unchanged
        } catch {
            throw .left(error)
        }
    }

    @inlinable
    public func serialize(_ output: Output, into buffer: inout [UInt8]) {
        self.encode(output, &buffer)         // stored closure, unchanged
    }
}
