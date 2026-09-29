public import Byte
public import Coder
public import Cursor
public import RFC_791
import Binary
import Parser
import Serializer

extension RFC_791.Version {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_791.Version

        public typealias Failure = RFC_791.Version.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard let byte = input.next() else {
                throw .empty
            }
            return RFC_791.Version(rawValue: byte.bitPattern >> 4)!
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.Version.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_791.Version: Coder.Codable {}
