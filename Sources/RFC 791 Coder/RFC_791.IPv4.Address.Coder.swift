public import Byte
public import Coder
public import Cursor
public import Cursor
public import RFC_791
import Parser
import Serializer

extension RFC_791.IPv4.Address {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
            }
        }


        public typealias Output = RFC_791.IPv4.Address

        public typealias Failure = RFC_791.IPv4.Address.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            guard let a = input.next() else {
                throw .empty
            }
            guard let b = input.next(), let c = input.next(), let d = input.next() else {
                input.seek(to: start)
                throw .invalidFormat("Expected 4 bytes")
            }
            return RFC_791.IPv4.Address(a, b, c, d)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            let (a, b, c, d) = output.octets
            buffer.append(a)
            buffer.append(b)
            buffer.append(c)
            buffer.append(d)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
