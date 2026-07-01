# Binary Coder Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-binary-coder-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-binary-coder-primitives/actions/workflows/ci.yml)

A witness for bidirectional binary coding that gives each direction its natural type — decoding streams from a `Byte.Input` cursor, encoding appends into a mutable `[Byte]` buffer. One `Binary.Coder<Output>` value holds both directions, so a format's round-trip symmetry lives in a single value instead of two parallel implementations that drift apart.

Parser-printer designs that force one `Input` type onto both directions make encoding awkward: a read-only streaming cursor is the wrong shape for building output. `Binary.Coder` splits the concerns — decode gets the checkpointing cursor, encode gets the appendable buffer — and the eight fixed-width integers ship ready-made coders with explicit endianness.

---

## Key Features

- **Asymmetric directions** — decode from `Byte.Input` (read-only streaming cursor), encode into `[Byte]` (mutable, appendable buffer); neither direction pays for the other's shape.
- **Typed throws end-to-end** — decoding throws `Binary.Machine.Fault`, never an untyped error; encoding is total and does not throw.
- **Machine-parser lifting** — `Binary.Coder.machine(_:encode:)` reuses any existing `Binary.Machine.Parser` as the decode half, so a format parsed once is coded without a second decoder.
- **Fixed-width integer coders** — `UInt8` through `UInt64` and `Int8` through `Int64` provide `coder(endianness:)` with explicit big/little endianness at the call site.
- **Whole vs. prefix decoding** — `decodeWhole` rejects trailing bytes for framed payloads; `decodePrefix` consumes only what it needs for sequential wire formats.

---

## Quick Start

```swift
import Binary_Coder_Primitives
import Binary_Integer_Coder_Primitives

// Ready-made fixed-width coders — endianness is explicit, never ambient.
let coder = UInt32.coder(endianness: .big)

let encoded = coder.encodeToArray(0xDEAD_BEEF)   // [0xDE, 0xAD, 0xBE, 0xEF]
let decoded = try coder.decodeWhole(encoded)     // 0xDEADBEEF — throws if bytes remain

// Sequential wire decoding: decodePrefix consumes only what it needs.
var input = Byte.Input([0x12, 0x34, 0x99])
let word = try UInt16.coder(endianness: .big).decodePrefix(&input)  // 0x1234
// input still holds [0x99] for the next field
```

Custom formats lift an existing machine parser into a coder, adding only the encode half:

```swift
import Binary_Coder_Primitives

let tag = Binary.Coder.machine(Binary.Machine.u8Parser()) { value, output in
    output.append(Byte(value))
}

var frame: [Byte] = []
tag.encodeAppending(0x02, to: &frame)   // append into an existing buffer
let roundTripped = try tag.decodeWhole(frame)  // 0x02
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-binary-coder-primitives.git", branch: "main")
]
```

Add a product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Binary Integer Coder Primitives", package: "swift-binary-coder-primitives")
    ]
)
```

Use the `Binary Coder Primitives` product instead when you only build custom coders and do not need the integer surface. The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Binary Coder Primitives` | `Binary.Coder<Output>`, the execution helpers (`decodeWhole`, `decodePrefix`, `encodeToArray`, `encodeAppending`), the machine-parser lift, and the generic coder-seam conformance; re-exports the byte-input and machine-parser vocabulary | Building custom coders for your own formats |
| `Binary Integer Coder Primitives` | `coder(endianness:)` on the eight fixed-width integer types | Ready-made integer coders; pulls in the core product |

Decoding throws `Binary.Machine.Fault` throughout — `decodeWhole` additionally rejects unconsumed trailing bytes. `Binary.Coder` also conforms to the ecosystem's generic coder seam (`parse(_:)` / `serialize(_:into:)`), so it composes with code written against `Coder.Protocol`.

---

## Related Packages

- [`swift-binary-parser-primitives`](https://github.com/swift-primitives/swift-binary-parser-primitives) — the `Byte.Input` cursor and `Binary.Machine` parsers the decode half runs on.
- [`swift-coder-primitives`](https://github.com/swift-primitives/swift-coder-primitives) — the generic `Coder.Protocol` seam this coder conforms to.
- [`swift-witness-primitives`](https://github.com/swift-primitives/swift-witness-primitives) — the witness vocabulary `Binary.Coder` is built on.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
