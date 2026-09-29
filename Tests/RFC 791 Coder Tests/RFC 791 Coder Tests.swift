import Byte
import Byte
import Coder
import Coder
import Cursor
import Parser
import RFC_791
import RFC_791_Coder
import Serializer
import Testing

private typealias IPProtocol = RFC_791.`Protocol`

@Suite
struct `RFC 791 Coder Tests` {
    @Suite struct `IPv4 Address Tests` {}
    @Suite struct `Version Tests` {}
    @Suite struct `IHL Tests` {}
    @Suite struct `Type of Service Tests` {}
    @Suite struct `Precedence Tests` {}
    @Suite struct `Total Length Tests` {}
    @Suite struct `Identification Tests` {}
    @Suite struct `Flags Tests` {}
    @Suite struct `Fragment Offset Tests` {}
    @Suite struct `TTL Tests` {}
    @Suite struct `Protocol Tests` {}
    @Suite struct `Header Checksum Tests` {}
}

func bytes(_ values: UInt8...) -> [Byte] {
    values.map(Byte.init(bitPattern:))
}

extension `RFC 791 Coder Tests`.`IPv4 Address Tests` {

    @Test
    func `reads four network-order octets and stops`() throws {
        var input = bytes(192, 168, 1, 1, 0xFF)[...]
        let address = try RFC_791.IPv4.Address.coder.parse(&input)
        #expect(address.description == "192.168.1.1")
        #expect(input == bytes(0xFF)[...])
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.IPv4.Address.Error.empty) {
            try RFC_791.IPv4.Address.coder.parse(&input)
        }
    }

    @Test
    func `rejects fewer than four octets and restores the cursor`() {
        var input = bytes(192, 168, 1)[...]
        #expect(throws: RFC_791.IPv4.Address.Error.invalidFormat("Expected 4 bytes")) {
            try RFC_791.IPv4.Address.coder.parse(&input)
        }
        #expect(input.count == 3)
    }

    @Test
    func `round-trips through its wire form`() throws {
        let address = try RFC_791.IPv4.Address("10.0.0.255")
        #expect(try address.encoded() == bytes(10, 0, 0, 255))

        var input = try address.encoded()[...]
        #expect(try RFC_791.IPv4.Address(decoding: &input) == address)
    }
}

extension `RFC 791 Coder Tests`.`Version Tests` {

    @Test
    func `reads the version from the high nibble`() throws {
        var input = bytes(0x45)[...]
        #expect(try RFC_791.Version.coder.parse(&input) == .v4)
        #expect(input.isEmpty)
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.Version.Error.empty) {
            try RFC_791.Version.coder.parse(&input)
        }
    }

    @Test
    func `writes the version into the high nibble`() throws {
        #expect(try RFC_791.Version.v4.encoded() == bytes(0x40))
        #expect(try RFC_791.Version.v6.encoded() == bytes(0x60))
    }
}

extension `RFC 791 Coder Tests`.`IHL Tests` {

    @Test
    func `reads the header length from the low nibble`() throws {
        var input = bytes(0x45)[...]
        #expect(try RFC_791.IHL.coder.parse(&input) == .minimum)

        var maximum = bytes(0x4F)[...]
        #expect(try RFC_791.IHL.coder.parse(&maximum) == .maximum)
    }

    @Test
    func `rejects a header shorter than five words`() {
        var input = bytes(0x43)[...]
        #expect(throws: RFC_791.IHL.Error.tooSmall(3)) {
            try RFC_791.IHL.coder.parse(&input)
        }
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.IHL.Error.empty) {
            try RFC_791.IHL.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        let ihl = RFC_791.IHL(rawValue: 10)!
        #expect(try ihl.encoded() == bytes(0x0A))

        var input = try ihl.encoded()[...]
        #expect(try RFC_791.IHL(decoding: &input) == ihl)
    }
}

extension `RFC 791 Coder Tests`.`Type of Service Tests` {

    @Test
    func `reads precedence and flags from one octet`() throws {
        var input = bytes(0b0101_1100)[...]
        let tos = try RFC_791.TypeOfService.coder.parse(&input)
        #expect(tos.precedence == .immediate)
        #expect(tos.lowDelay && tos.highThroughput && tos.highReliability)
    }

    @Test
    func `rejects an octet with reserved bits set`() {
        var input = bytes(0b0000_0001)[...]
        #expect(throws: RFC_791.TypeOfService.Error.reservedBitsSet(Byte(bitPattern: 0b0000_0001))) {
            try RFC_791.TypeOfService.coder.parse(&input)
        }
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.TypeOfService.Error.empty) {
            try RFC_791.TypeOfService.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        let tos = RFC_791.TypeOfService(precedence: .flash, lowDelay: true)
        #expect(try tos.encoded() == bytes(0x70))

        var input = try tos.encoded()[...]
        #expect(try RFC_791.TypeOfService(decoding: &input) == tos)
    }
}

extension `RFC 791 Coder Tests`.`Precedence Tests` {

    @Test
    func `reads a precedence level`() throws {
        var input = bytes(0x03)[...]
        #expect(try RFC_791.Precedence.coder.parse(&input) == .flash)
    }

    @Test
    func `rejects a level above seven`() {
        var input = bytes(0x08)[...]
        #expect(throws: RFC_791.Precedence.Error.valueOutOfRange(Byte(bitPattern: 0x08))) {
            try RFC_791.Precedence.coder.parse(&input)
        }
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.Precedence.Error.empty) {
            try RFC_791.Precedence.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        #expect(try RFC_791.Precedence.immediate.encoded() == bytes(0x02))
        var input = bytes(0x07)[...]
        #expect(try RFC_791.Precedence(decoding: &input) == .networkControl)
    }
}

extension `RFC 791 Coder Tests`.`Total Length Tests` {

    @Test
    func `reads two big-endian octets`() throws {
        var input = bytes(0x05, 0xDC, 0xFF)[...]
        #expect(try RFC_791.TotalLength.coder.parse(&input) == .ethernetMTU)
        #expect(input == bytes(0xFF)[...])
    }

    @Test
    func `rejects a length below the minimum header and restores the cursor`() {
        var input = bytes(0x00, 0x10)[...]
        #expect(throws: RFC_791.TotalLength.Error.tooSmall(16)) {
            try RFC_791.TotalLength.coder.parse(&input)
        }
        #expect(input.count == 2)
    }

    @Test
    func `rejects a single octet and restores the cursor`() {
        var input = bytes(0x05)[...]
        #expect(throws: RFC_791.TotalLength.Error.insufficientBytes) {
            try RFC_791.TotalLength.coder.parse(&input)
        }
        #expect(input.count == 1)
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.TotalLength.Error.empty) {
            try RFC_791.TotalLength.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        #expect(try RFC_791.TotalLength.ethernetMTU.encoded() == bytes(0x05, 0xDC))

        var input = try RFC_791.TotalLength.minimumReassemblyBuffer.encoded()[...]
        #expect(try RFC_791.TotalLength(decoding: &input) == .minimumReassemblyBuffer)
    }
}

extension `RFC 791 Coder Tests`.`Identification Tests` {

    @Test
    func `reads two big-endian octets`() throws {
        var input = bytes(0x12, 0x34)[...]
        #expect(try RFC_791.Identification.coder.parse(&input) == 0x1234)
    }

    @Test
    func `rejects a single octet and restores the cursor`() {
        var input = bytes(0x12)[...]
        #expect(throws: RFC_791.Identification.Error.insufficientBytes) {
            try RFC_791.Identification.coder.parse(&input)
        }
        #expect(input.count == 1)
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.Identification.Error.empty) {
            try RFC_791.Identification.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        let identification: RFC_791.Identification = 0xABCD
        #expect(try identification.encoded() == bytes(0xAB, 0xCD))

        var input = try identification.encoded()[...]
        #expect(try RFC_791.Identification(decoding: &input) == identification)
    }
}

extension `RFC 791 Coder Tests`.`Flags Tests` {

    @Test
    func `reads the flags from the top three bits`() throws {
        var df = bytes(0b0100_0000)[...]
        #expect(try RFC_791.Flags.coder.parse(&df) == .dontFragment)

        var mf = bytes(0b0010_0000)[...]
        #expect(try RFC_791.Flags.coder.parse(&mf) == .moreFragments)

        var both = bytes(0b0110_0000)[...]
        #expect(try RFC_791.Flags.coder.parse(&both) == RFC_791.Flags(dontFragment: true, moreFragments: true))
    }

    @Test
    func `rejects an octet with the reserved bit set`() {
        var input = bytes(0b1000_0000)[...]
        #expect(throws: RFC_791.Flags.Error.reservedBitSet(Byte(bitPattern: 0b1000_0000))) {
            try RFC_791.Flags.coder.parse(&input)
        }
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.Flags.Error.empty) {
            try RFC_791.Flags.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        #expect(try RFC_791.Flags.dontFragment.encoded() == bytes(0b0100_0000))

        let both = RFC_791.Flags(dontFragment: true, moreFragments: true)
        var input = try both.encoded()[...]
        #expect(try RFC_791.Flags(decoding: &input) == both)
    }
}

extension `RFC 791 Coder Tests`.`Fragment Offset Tests` {

    @Test
    func `reads the low thirteen bits of two octets`() throws {
        var input = bytes(0x00, 0xB9)[...]
        #expect(try RFC_791.FragmentOffset.coder.parse(&input).rawValue == 185)

        var withFlags = bytes(0x40, 0xB9)[...]
        #expect(try RFC_791.FragmentOffset.coder.parse(&withFlags).rawValue == 185)

        var maximum = bytes(0x1F, 0xFF)[...]
        #expect(try RFC_791.FragmentOffset.coder.parse(&maximum) == .maximum)
    }

    @Test
    func `rejects a single octet and restores the cursor`() {
        var input = bytes(0x00)[...]
        #expect(throws: RFC_791.FragmentOffset.Error.insufficientBytes) {
            try RFC_791.FragmentOffset.coder.parse(&input)
        }
        #expect(input.count == 1)
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.FragmentOffset.Error.empty) {
            try RFC_791.FragmentOffset.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        #expect(try RFC_791.FragmentOffset(rawValue: 185)!.encoded() == bytes(0x00, 0xB9))
        #expect(try RFC_791.FragmentOffset.maximum.encoded() == bytes(0x1F, 0xFF))

        let offset = RFC_791.FragmentOffset(rawValue: 370)!
        var input = try offset.encoded()[...]
        #expect(try RFC_791.FragmentOffset(decoding: &input) == offset)
    }
}

extension `RFC 791 Coder Tests`.`TTL Tests` {

    @Test
    func `reads one octet`() throws {
        var input = bytes(64, 0xFF)[...]
        #expect(try RFC_791.TTL.coder.parse(&input) == .default64)
        #expect(input == bytes(0xFF)[...])
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.TTL.Error.empty) {
            try RFC_791.TTL.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        #expect(try RFC_791.TTL.default64.encoded() == bytes(64))

        var input = try RFC_791.TTL.default128.encoded()[...]
        #expect(try RFC_791.TTL(decoding: &input) == .default128)
    }
}

extension `RFC 791 Coder Tests`.`Protocol Tests` {

    @Test
    func `reads one octet`() throws {
        var tcp = bytes(0x06)[...]
        #expect(try IPProtocol.coder.parse(&tcp) == .tcp)

        var udp = bytes(0x11, 0x01)[...]
        #expect(try IPProtocol.coder.parse(&udp) == .udp)
        #expect(udp == bytes(0x01)[...])
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: IPProtocol.Error.empty) {
            try IPProtocol.coder.parse(&input)
        }
    }

    @Test
    func `round-trips every protocol number`() throws {
        for value: UInt8 in 0...255 {
            let proto = IPProtocol(rawValue: value)
            var input = try proto.encoded()[...]
            #expect(try IPProtocol(decoding: &input) == proto)
        }
    }
}

extension `RFC 791 Coder Tests`.`Header Checksum Tests` {

    @Test
    func `reads two big-endian octets`() throws {
        var input = bytes(0xB8, 0x61)[...]
        #expect(try RFC_791.HeaderChecksum.coder.parse(&input).rawValue == 0xB861)
    }

    @Test
    func `rejects a single octet and restores the cursor`() {
        var input = bytes(0xB8)[...]
        #expect(throws: RFC_791.HeaderChecksum.Error.insufficientBytes) {
            try RFC_791.HeaderChecksum.coder.parse(&input)
        }
        #expect(input.count == 1)
    }

    @Test
    func `rejects empty input`() {
        var input = bytes()[...]
        #expect(throws: RFC_791.HeaderChecksum.Error.empty) {
            try RFC_791.HeaderChecksum.coder.parse(&input)
        }
    }

    @Test
    func `round-trips`() throws {
        let checksum = RFC_791.HeaderChecksum(rawValue: 0x1234)
        #expect(try checksum.encoded() == bytes(0x12, 0x34))

        var input = try checksum.encoded()[...]
        #expect(try RFC_791.HeaderChecksum(decoding: &input) == checksum)
    }
}
