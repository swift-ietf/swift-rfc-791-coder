public import Binary_Serializable
public import Byte
public import RFC_791
import Binary_Standard_Library_Integration
import Binary_Endianness

extension RFC_791.FragmentOffset: @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(value.rawValue, endianness: .big)
    }
}
