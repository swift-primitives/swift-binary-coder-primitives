public import Binary_Coder_Primitives
import Input_Primitives

extension Int8 {

    @inlinable
    public static func coder(endianness: Binary.Endianness) -> Binary.Coder<Int8> {
        Binary.Coder.machine(
            Binary.Machine.i8Parser(),
            encode: { value, output in
                output.append(Byte(UInt8(bitPattern: value)))
            }
        )
    }
}
