public import ASCII
import Byte
public import RFC_791

extension RFC_791.IPv4.Address: @retroactive ASCII.Parseable {}

extension RFC_791.IPv4.Address: @retroactive ASCII.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ address: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        let (a, b, c, d) = address.octets

        buffer.reserveCapacity(15)

        func appendDecimal(_ value: UInt8) {

            if value < 10 {
                buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ value))
                return
            }

            if value < 100 {
                let tens = value / 10
                let ones = value % 10
                buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ tens))
                buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ ones))
                return
            }

            let hundreds = value / 100
            let remainder = value % 100
            let tens = remainder / 10
            let ones = remainder % 10

            buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ hundreds))
            buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ tens))
            buffer.append(ASCII.Code(ASCII.Code.`0`.underlying &+ ones))
        }

        appendDecimal(a.bitPattern)
        buffer.append(ASCII.Code.period)
        appendDecimal(b.bitPattern)
        buffer.append(ASCII.Code.period)
        appendDecimal(c.bitPattern)
        buffer.append(ASCII.Code.period)
        appendDecimal(d.bitPattern)
    }
}
