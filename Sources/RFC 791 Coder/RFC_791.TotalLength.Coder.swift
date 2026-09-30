public import Byte
public import Coder
public import Cursor
public import RFC_791
import Binary
import Parser
import Serializer

extension RFC_791.TotalLength {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_791.TotalLength

        public typealias Failure = RFC_791.TotalLength.Error

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
            let value = UInt16(high.bitPattern) << 8 | UInt16(low.bitPattern)
            guard let totalLength = RFC_791.TotalLength(rawValue: value) else {
                input.seek(to: start)
                throw .tooSmall(value)
            }
            return totalLength
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_791.TotalLength.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
