import Binary
public import Byte
public import Coder
public import Cursor
import Parser
public import RFC_791
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
            guard let version = RFC_791.Version(rawValue: byte.bitPattern >> 4) else {
                preconditionFailure("A 4-bit value is a valid IP version")
            }
            return version
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.Version.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
