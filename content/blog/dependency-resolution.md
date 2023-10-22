+++
title = "What every Rustacean should know about dependency resolution"
draft = true
date = 2024-11-26
+++

Who's got time to think up introductions to articles? Let's go!

## `Cargo.toml` includes dependency version ranges

The version numbers you add to your `Cargo.toml`'s dependency declarations don't
denote specific versions of crates. They denote ranges. While it's possible to
be very explicit about the range and put down something like `>=1.0.1, <1.2.5`,
that's not needed most of the time. If you simply input a specific version such
as `1.1.1`, you're actually using a shorthand for "anything that's
backwards-compatible with 1.1.1", or `>=1.1.1, <2.0.0`. That's usually what we
want.

Note that manually bumping a version number from `1.1.1` to `1.2.3` in
`Cargo.toml` is not exactly the same as performing an update. What it is,
really, is making the range of accepted versions narrower - you're going from
`>=1.1.1, <2.0.0` to `>=1.2.3, <2.0.0`. When wanting to update to a
backwards-compatible new version, the more "proper" way of upgrading is to type
`cargo update` and, if applicable, commit the `Cargo.lock` file.

[The Cargo Book has a section fully describing the version requirement syntax.](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html)

## A goal of library maintenance should be to keep dependency requirements broad

It's not to keep them "up to date" by bumping the version numbers in
`Cargo.toml`'s `dependencies` section; as described in the previous section,
that's just narrowing the ranges. We want them as broad as possible. This is a
gotcha that shows up a lot in projects.

By broadening those ranges we minimize the risk of irksome
dependency-version-conflict related bugs.

### You can test your dependency version requirements

So you're maintaining a library. You want to keep your dependency version
requirements broad. How do you make sure they really work?

It would be far too much effort to test every combination of dependency
versions, but a good smoke test is to simply test the lowest and highest
possible dep versions.

To test the minimal ones, try something like this:

```
rm Cargo.lock
cargo +nightly test -Zdirect-minimal-versions
```

To test the "maximal" ones, run `cargo update`, then test.

If they both pass, chances are your library is just fine.

You can add minimal and maximal CI jobs like
[these ones](https://github.com/CosmWasm/cw-storage-plus/blob/18d73ba9881340d9f0ff4e2560d6128e5380f4cc/.circleci/config.yml#L79-L131),
and run them periodically. You probably don't want them to block PRs - the jobs
might start failing randomly when a new dependency version is released or an old
one yanked.

## Rust goes beyond _Semantic Versioning 2.0_

Officially, SemVer 2.0 states versions before `1.0.0` don't have to follow any
breaking/non-breaking convention. It's the wild west out there.

The Rust ecosystem attaches some semantics to those "unstable" versions. When
developing Rust libs, you should always consider the leftmost non-zero digit to
denote a breaking change, meaning something like `0.1.2 -> 0.2.0` also signals
breakage in the _Cargo_ world.

If you're not yet familiar with Semantic Versioning, you might want to
[read up](https://semver.org/) at some point!

## `cargo tree`

If you need to glean the current dependency tree for your Rust project (e.g. to
troubleshoot dependency conflicts), `cargo tree` is your friend!

Even better, `cargo tree -d` can help you identify duplicates, specifically.

## Rust is not immune to dependency conflict problems

If dependency resolution fails to choose one crate version due to conflicting
requirements, it will simply link two different versions of it. This can work
fine, even if it might end up bloating the binary size.

This is no silver bullet though. Say there's a `foo` dependency in your project
and a `bar` dependency, which transitively depends on a different version of
`foo` and even uses types from `foo` in its API. You try to create a value of
type `foo::Foo`. You then try to feed that value to function
`bar::prnt(foo: &Foo)`. Here's what's likely to happen:

![a screenshot showing a type mismatch error](../type_conflict.png)

There are two definitions of the struct baked into the application, and as far
as Rust is concerned, they're incompatible with each other, even though
identical.

The solution is usually to reconcile the versions somehow.

While we're on the subject, if you're a library,
[here's a trick to minimize this problem](https://github.com/dtolnay/semver-trick)
for your consumers.

### Committing `Cargo.lock` for libs can make sense

There's this long-standing recommendation to only commit `Cargo.lock` for
binaries, not libraries. This is what the Rust Foundation preached for a time.

The thing is, the supposed downside of committing `Cargo.lock` for libraries -
the idea it would lock dependents of your library to very specific versions of
your dependencies - is not a thing.

When resolving dependencies for a build, **the only `Cargo.lock` file the
toolchain considers is the one the immediate project has**, not anything
dependencies might have checked in.

In fact, committing the `Cargo.lock` for a library has some benefits. Primarily,
this means CI will not suddenly start failing because of a random dependency
update - we want it to fail only when the code changes in a pull request
introduced problems.

And to give some credibility to this, the
[Rust Foundation recently changed their stance on this](https://blog.rust-lang.org/2023/08/29/committing-lockfiles.html).

### Specifying MSRV

TODO

### Which changes are breaking?

[There's a rather official list](https://doc.rust-lang.org/cargo/reference/semver.html)
of what should and should not be considered a breaking change when developing
Rust libraries. Some of these are just recommendations, but honestly - most of
these are things you're expected to stick to as a good citizen of the Rust
ecosystem.
