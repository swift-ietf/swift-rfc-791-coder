public import Binary
public import Byte
public import RFC_791
import Binary

extension RFC_791.FragmentOffset: @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(value.rawValue, endianness: .big)
    }
}
