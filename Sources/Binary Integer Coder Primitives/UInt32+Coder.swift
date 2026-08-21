public import Binary_Coder_Primitives
import Input_Primitives

extension UInt32 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<UInt32> {
        let parser: Binary.Machine.Parser<UInt32> =
            switch endianness {
            case .little: Binary.Machine.u32leParser()
            case .big: Binary.Machine.u32beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
