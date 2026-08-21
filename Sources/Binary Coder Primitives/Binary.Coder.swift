public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Ownership_Shared_Primitive
public import Witness_Primitives

extension Binary {

    public struct Coder<Output>: Witness.`Protocol` {

        public var decode: (inout Byte.Input) throws(Binary.Machine.Fault) -> Output

        public var encode: (Output, inout [Byte]) -> Void

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

extension Binary.Coder {

    @inlinable
    public func decodeWhole(_ bytes: [Byte]) throws(Binary.Machine.Fault) -> Output {
        var input = Byte.Input(bytes)
        let value = try decode(&input)
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.count)
        }
        return value
    }

    @inlinable
    public func decodePrefix(_ input: inout Byte.Input) throws(Binary.Machine.Fault) -> Output {
        try decode(&input)
    }

    @inlinable
    public func encodeToArray(_ value: Output) -> [Byte] {
        var out: [Byte] = []
        encode(value, &out)
        return out
    }

    @inlinable
    public func encodeAppending(_ value: Output, to buffer: inout [Byte]) {
        encode(value, &buffer)
    }
}

extension Binary.Coder {

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
