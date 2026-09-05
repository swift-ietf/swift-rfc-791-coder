# swift-rfc-791-coder

Wire coders for [swift-rfc-791](https://github.com/swift-ietf/swift-rfc-791): every RFC 791 header field and the IPv4 address get a `<Type>.Coder` over a byte cursor (the field's network-order octets), `Binary.Serializable` conformances, and for the address the dotted-decimal `ASCII.Parseable`/`ASCII.Serializable` text form and `Binary.Parseable`; the domain package stays a pure model.
