public import Coder_Primitives
public import Either_Primitives

extension Binary.Coder: Coder.`Protocol` {

    public typealias Input = Byte.Input

    public typealias Buffer = [Byte]

    public typealias Failure = Either<Binary.Machine.Fault, Never>

    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Byte.Input) throws(Failure) -> Output {
        do throws(Binary.Machine.Fault) {
            return try self.decode(&input)
        } catch {
            throw .left(error)
        }
    }

    @inlinable
    public func serialize(_ output: Output, into buffer: inout [Byte]) {
        self.encode(output, &buffer)
    }
}
