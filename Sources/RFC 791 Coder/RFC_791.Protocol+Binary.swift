public import Binary_Serializable
public import Byte
public import RFC_791

extension RFC_791.`Protocol`: @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(Byte(bitPattern: value.rawValue))
    }
}
