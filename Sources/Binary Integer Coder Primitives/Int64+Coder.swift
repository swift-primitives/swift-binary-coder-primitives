public import Binary_Coder_Primitives
import Input_Primitives

extension Int64 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<Int64> {
        let parser: Binary.Machine.Parser<Int64> =
            switch endianness {
            case .little: Binary.Machine.i64leParser()
            case .big: Binary.Machine.i64beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
