public import Binary_Parseable
public import Binary_Serializable
public import Byte
public import RFC_791

extension RFC_791.IPv4.Address: @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ address: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        let (a, b, c, d) = address.octets
        buffer.append(a)
        buffer.append(b)
        buffer.append(c)
        buffer.append(d)
    }
}

extension RFC_791.IPv4.Address {

    public init<Bytes: Swift.Collection>(binary bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count == 4 else {
            throw .invalidFormat("Expected 4 bytes, got \(bytes.count)")
        }

        var iterator = bytes.makeIterator()
        let a = iterator.next()!
        let b = iterator.next()!
        let c = iterator.next()!
        let d = iterator.next()!

        self.init(a, b, c, d)
    }
}

extension RFC_791.IPv4.Address: @retroactive Binary.Parseable {

    public static func parse<Source: RangeReplaceableCollection>(
        from source: inout Source
    ) throws(Binary.Parse.Failure) -> Self
    where Source.Element == Byte {
        guard source.count >= 4 else {
            throw .insufficient(needed: 4)
        }

        var iterator = source.makeIterator()
        let a = iterator.next()!
        let b = iterator.next()!
        let c = iterator.next()!
        let d = iterator.next()!
        source.removeFirst(4)

        return RFC_791.IPv4.Address(a, b, c, d)
    }
}
