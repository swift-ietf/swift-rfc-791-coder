import Binary
public import Byte
public import Coder
public import Cursor
import Parser
public import RFC_791
import Serializer

extension RFC_791.FragmentOffset {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_791.FragmentOffset

        public typealias Failure = RFC_791.FragmentOffset.Error

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
            let value = (UInt16(high.bitPattern) << 8 | UInt16(low.bitPattern)) & 0x1FFF
            guard let offset = RFC_791.FragmentOffset(rawValue: value) else {
                preconditionFailure("A value masked to 13 bits is a valid fragment offset")
            }
            return offset
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.FragmentOffset.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
