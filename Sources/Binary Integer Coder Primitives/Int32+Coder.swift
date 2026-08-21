public import Binary_Coder_Primitives
import Input_Primitives

extension Int32 {

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
