public import Byte
public import Coder
public import Cursor
public import RFC_791
import Binary
import Parser
import Serializer

extension RFC_791.Flags {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
            }
        }


        public typealias Output = RFC_791.Flags

        public typealias Failure = RFC_791.Flags.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard let byte = input.next() else {
                throw .empty
            }
            guard let flags = RFC_791.Flags(rawValue: byte.bitPattern >> 5) else {
                throw .reservedBitSet(byte)
            }
            return flags
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.Flags.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
