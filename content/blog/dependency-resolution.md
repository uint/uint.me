+++
title = "Rust's dependency resolution"
date = 2023-10-22
draft = true
+++

# Rust's dependency resolution

## The problem

Given the appearance of a typical `Cargo.toml` file, it's easy for Rustaceans to
assume the whole deal of choosing dependency versions is simple: you slap a
specific version in there and done, that version is used.

In reality, the dependencies you explicitly specify are not the only
dependencies your project uses. There are transitive dependencies as well - the
dependencies of your dependencies.

If you explicitly declare `rand 0.8.5` and `log 0.4.10` as your dependencies,
you'll end up with `log` being declared twice, with different version numbers
attached. That's because `rand 0.8.5` itself also has `log` as a dependency with
the number `0.4.4` attached. How does Rust handle that?

## Specifying version requirements

One piece of the puzzle is the realization that the version numbers you add to
your `Cargo.toml`'s dependency declarations don't denote specific versions of
crates. They denote ranges. While it's possible to be very explicit about the
range and input something like `>=1.0.1, <1.2.5`, that's not needed most of the
time. If you simply input a specific version such as `1.1.1`, you're actually
using a shorthand for "anything that's backwards-compatible with 1.1.1", or
`>=1.1.1, <2.0.0`. That's usually what we want.

Note that manually bumping a version number from `1.1.1` to `1.2.3` in
`Cargo.toml` is not exactly the same as performing an update. What it is,
really, is making the range of accepted versions narrower - you're going from
`>=1.1.1, <2.0.0` to `>=1.2.3, <2.0.0`. When wanting to update to a
backwards-compatible new version, the more "proper" way of upgrading is to type
`cargo update` and, if applicable, commit the `Cargo.lock` file.

[The Cargo Book has a section fully describing the valid syntax for specifying version requirements.](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html)

## `Cargo.lock`

The first time you compile a new project, a `Cargo.lock` file gets created. This
is where a snapshot of dependency resolution is saved - all the exact version
numbers of all the dependencies in your project. The next time you compile your
project, rather than resolve everything all over again, `cargo` will simply use
the versions saved in the `Cargo.lock` file.

This is useful for reproducible builds. There are numerous reasons why these may
be desired, but a common one is that while developing a feature, you will likely
want to run tests over and over again. If a dependency sneakily updates between
test runs, the tests might start failing for no fault of your own. You can
likely imagine how frustrating debugging something like that can be - or perhaps
you already have that experience.

## Dependency resolution

When you build your project, dependency resolution might happen. It can be
pictured like this:

1. Fetch the index of all Rust crates currently available on crates.io.
2. Check if `Cargo.lock` is present. If it is, use the saved versions and skip
   steps 3-5.
3. Collect all dependencies (direct and transitive) for your project, along with
   all their version requirements.
4. For each dependency, try to find a version that satisfies all the
   requirements from different places.
   - If multiple versions satisfy requirements, choose the newest.
   - If no version can satisfy all the requirements, link multiple versions -
     maybe version `1.2.3` can satisfy the requirements in `my-crate`, but
     version `2.0.1` can satisfy the ones in `other-persons-crate`.
5. Save the resolved version numbers to `Cargo.lock`.
6. Build the project, downloading and linking the resolved versions of
   dependencies.

## Semantic versioning

[Semantic Versioning](https://semver.org/) is a versioning scheme. A semantic
version usually has three components separated by dots - the MAJOR version, the
MINOR version, and the PATCH version, in that order.

Whenever you release a new version of your API, you're supposed to be careful
about which component you bump. As long as you've already released your `1.0.0`
(meaning your API is stabilized), bumping the MAJOR number means there was a
backwards incompatible change to the API and existing code using it is likely to
break. Bumping the MINOR means functionality was added in a backwards-compatible
way, and PATCH means you made backwards-compatible bug fixes.

This is the gist, but if SemVer is not something you're familiar with, I
recommend getting familiar with the more
[in-depth specification](https://semver.org/).

Rust expands on this a little bit. Officially, SemVer 2.0 states versions before
`1.0.0` don't have to follow any breaking/non-breaking convention. It's the wild
west out there. The Rust ecosystem always considers the leftmost non-zero digit
to denote a breaking change, meaning both

## Resolving dependency conflicts

## Library development best practices

### Keeping dependency versions broad

### Semver trick

### Committing `Cargo.lock`

### Testing min-max builds

### Specifying MSRV
