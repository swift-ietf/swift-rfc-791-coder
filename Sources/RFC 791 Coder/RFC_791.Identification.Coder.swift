public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_791
import Binary_Serializable
import Parser
import Serializer

extension RFC_791.Identification {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_791.Identification

        public typealias Failure = RFC_791.Identification.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            guard let high = input.next() else {
                throw .empty
            }
            guard let low = input.next() else {
                input.seek(to: start)
                throw .insufficientBytes
            }
            return RFC_791.Identification(rawValue: UInt16(high.bitPattern) << 8 | UInt16(low.bitPattern))
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.Identification.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_791.Identification: Coder.Codable {}
