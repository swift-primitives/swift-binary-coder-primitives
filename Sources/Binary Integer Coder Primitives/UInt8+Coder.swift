public import Binary_Coder_Primitives
import Input_Primitives

extension UInt8 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<UInt8> {
        Binary.Coder.machine(
            Binary.Machine.u8Parser(),
            encode: { value, output in
                output.append(Byte(value))
            }
        )
    }
}
