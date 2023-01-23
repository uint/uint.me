+++
title = "Experience"
+++

Below, you can glean some projects I dabbled in. Feel free to also check out my
[GitHub](https://github.com/uint).

### _jtd-derive_

[_jtd-derive_](https://github.com/uint/jtd-derive) is a tool for producing
[_JSON Typedef_](https://jsontypedef.com/) schemas from Rust types according to
how they'd be serialized by the [_Serde_](https://github.com/serde-rs/serde)
serialization framework.

_JSON Typedef_ is a schema format like _JSON Schema_, but far better optimized
for codegen. _jtd-derive_ is meant to make it simpler for Rust programmers to
generate _Typedef_ schemas without stepping out of the Rust world. Such schemas
can easily be integrated into a custom [IDL](https://en.wikipedia.org/wiki/IDL),
enabling advanced developer tooling and generic clients.

### _CosmWasm_

Over a year of work as a core maintainer of the
[_CosmWasm_](https://cosmwasm.com/) execution engine and framework. This is the
thing that enables smart contracts on many Cosmos blockchains.

The GitHub repo can be viewed [here](https://github.com/CosmWasm/cosmwasm).

### _serbia_

[_serbia_](https://github.com/uint/serbia) is an attribute macro that helps work
around [_Serde_](https://github.com/serde-rs/serde)'s limitation with regards to
(de)serializing arrays of length larger than 32.
