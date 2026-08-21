public import Binary_Coder_Primitives
import Input_Primitives

extension Int16 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<Int16> {
        let parser: Binary.Machine.Parser<Int16> =
            switch endianness {
            case .little: Binary.Machine.i16leParser()
            case .big: Binary.Machine.i16beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
