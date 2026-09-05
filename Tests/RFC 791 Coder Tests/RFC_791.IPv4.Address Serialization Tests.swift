import ASCII
import ASCII_Serializer
import Binary_Parseable
import Binary_Serializable
import Byte
import Byte_Standard_Library_Integration
import Parseable_ASCII
import RFC_791
import RFC_791_Coder
import Testing

@Suite
struct `RFC_791.IPv4.Address Serialization Tests` {

    @Test
    func `the binary sibling is four network-order octets`() throws {
        let address = try RFC_791.IPv4.Address("192.168.1.1")
        #expect(address.bytes == bytes(192, 168, 1, 1))

        var buffer: [Byte] = []
        address.serialize(into: &buffer)
        #expect(buffer == bytes(192, 168, 1, 1))
    }

    @Test
    func `the text sibling is dotted-decimal`() throws {
        let address = try RFC_791.IPv4.Address("192.168.1.1")
        #expect(String(decoding: address.serialized, as: UTF8.self) == "192.168.1.1")
        #expect(String(ascii: address) == address.description)

        var codes: [ASCII.Code] = []
        RFC_791.IPv4.Address.serialize(address, into: &codes)
        #expect(codes.map(\.byte) == [Byte](utf8: "192.168.1.1"))
    }

    @Test
    func `the two siblings are distinct representations`() throws {
        let address = try RFC_791.IPv4.Address("10.0.0.255")
        #expect(String(decoding: address.serialized, as: UTF8.self) == "10.0.0.255")
        #expect(address.bytes == bytes(10, 0, 0, 255))
    }

    @Test
    func `the text sibling parses back through ASCII.Parseable`() throws {
        let address = try RFC_791.IPv4.Address(ascii: [Byte](utf8: "172.16.0.1"))
        #expect(address.serialized == [Byte](utf8: "172.16.0.1"))
    }

    @Test
    func `the binary sibling parses back from exactly four octets`() throws {
        #expect(try RFC_791.IPv4.Address(binary: bytes(192, 168, 1, 1)).description == "192.168.1.1")
        #expect(throws: RFC_791.IPv4.Address.Error.invalidFormat("Expected 4 bytes, got 3")) {
            try RFC_791.IPv4.Address(binary: bytes(192, 168, 1))
        }
    }

    @Test
    func `Binary.Parseable consumes four octets and leaves the rest`() throws {
        var source = bytes(192, 168, 1, 1, 0xFF)
        let address = try RFC_791.IPv4.Address.parse(from: &source)
        #expect(address.description == "192.168.1.1")
        #expect(source == bytes(0xFF))
    }

    @Test
    func `Binary.Parseable rejects fewer than four octets`() {
        var source = bytes(192, 168, 1)
        #expect(throws: Binary.Parse.Failure.insufficient(needed: 4)) {
            try RFC_791.IPv4.Address.parse(from: &source)
        }
    }
}
