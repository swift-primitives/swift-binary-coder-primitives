public import Binary_Coder_Primitives
import Input_Primitives

extension UInt64 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<UInt64> {
        let parser: Binary.Machine.Parser<UInt64> =
            switch endianness {
            case .little: Binary.Machine.u64leParser()
            case .big: Binary.Machine.u64beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
