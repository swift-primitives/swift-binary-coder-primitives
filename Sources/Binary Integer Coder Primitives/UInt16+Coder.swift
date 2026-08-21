public import Binary_Coder_Primitives
import Input_Primitives

extension UInt16 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<UInt16> {
        let parser: Binary.Machine.Parser<UInt16> =
            switch endianness {
            case .little: Binary.Machine.u16leParser()
            case .big: Binary.Machine.u16beParser()
            }
        return Binary.Coder.machine(parser) { value, output in
            let bytes = value.bytes(endianness: endianness)
            output.append(contentsOf: bytes)
        }
    }
}
