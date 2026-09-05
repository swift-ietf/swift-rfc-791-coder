public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_791
import Binary_Serializable
import Parser
import Serializer

extension RFC_791.`Protocol` {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_791.`Protocol`

        public typealias Failure = RFC_791.`Protocol`.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard let byte = input.next() else {
                throw .empty
            }
            return Output(rawValue: byte.bitPattern)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Output.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_791.`Protocol`: Coder.Codable {}
