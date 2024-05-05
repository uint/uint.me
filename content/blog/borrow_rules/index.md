+++
title = "Rust's borrow rules: but why, really?"
description = "An explanation of what problems Rust's borrow rules prevent"
date = 2024-05-05
+++

{{ youtube(id="KVwP6nY4xgA") }}

## What are borrow rules?

These are the rules that say a piece of data may have either:

- many shared (immutable) references like `&T`, or
- one unique (mutable) reference like `&mut T`.

Any code that violates these rules will not compile.

## The Book sayeth...

According to [*The Rust Programming Language*](https://doc.rust-lang.org/book/), the
reason for these limitations is to prevent data races (see
[here](https://doc.rust-lang.org/stable/book/ch04-02-references-and-borrowing.html?highlight=data%20races#mutable-references)).

> The benefit of having this restriction is that Rust can prevent data races at
> compile time. A data race is similar to a race condition and happens when
> these three behaviors occur:
>
> - Two or more pointers access the same data at the same time.
> - At least one of the pointers is being used to write to the data.
> - There’s no mechanism being used to synchronize access to the data.

## When borrow rules help with data races

Alright, let's play along. Is there a situation where borrow rules help prevent
trouble around data races? The Book does not give us one, but let's try.

```rust
use std::thread;

fn main() {
    let mut v = 53;

    thread::scope(|s| {
        s.spawn(|| println!("{}", &v));
        s.spawn(|| {
            let ref_v = &mut v;
            *ref_v += 5;
        });
    });
}
```

This snippet runs two OS threads in parallel, both borrowing from the `v`
variable.

If we were able to run this, there would be a data race (does the first thread
read the variable before, during or after the second one writes to it?).
Thankfully, Rust prevents this from compiling.

In this particular case, borrow rules save us from data races. It's worth
noting, though, that not a lot of parallel code looks like this. Most commonly
we resort to other things to provide aliasing while saving us from data races,
like `Arc<Mutex<T>>` and whatnot.

## What about synchronous code?

```rust,linenos
fn main() {
    let mut v = vec![1, 2, 3];

    let ref_v = &v[..];
    let mut_v = &mut v;

    mut_v.push(4);
    println!("{:?}", ref_v);
}
```

Guess what happens if we try to run the code above?

```
error[E0502]: cannot borrow `v` as mutable because it is
also borrowed as immutable
```

But why? The code is fully synchronous. In synchronous code, data races don't
have any right to exist. If there's no danger, this just looks like some awful
case of the compiler being paranoid.

Let's break this apart. This is the point where you might like the visualization
in the
[video, starting at the 3:21 mark](https://youtu.be/KVwP6nY4xgA?si=ng2DuqbGFm3jU_8b&t=201).

Line `2` of the snippet above allocates a vector. In memory, a vector lives in
two places. First, we have a bunch of data on the stack: the pointer, capacity,
and length. The pointer points to the heap-allocated sequence of our three
numbers.

{{ bgimg(src="1.svg") }}

Line `4` creates a shared (immutable) reference to the heap-allocated data.

{{ bgimg(src="2.svg") }}

Line `5` creates a unique (mutable) reference to the stack-allocated vector
data.

{{ bgimg(src="3.svg") }}

Line `7` uses the mutable reference to append the number `4` to the vector.
Since there isn't enough capacity for this additional number, the vector has to
perform some acrobatics.

The vector finds a new chunk of memory - probably enough to hold 6 or so
numbers. The old data (`1, 2, 3`) is copied there, and `4` is appended.

{{ bgimg(src="4.svg") }}

The vector data on the stack is updated - the pointer, capacity and length all just changed.

{{ bgimg(src="5.svg") }}

Finally, the old heap-allocated data is freed since we don't need it around
anymore.

{{ bgimg(src="6.svg") }}

...wait. What was that shared reference from line `4` pointing to?

Oops.

## The real problem

Okay. So it seems that borrow rules apply in plain old synchronous code. What's
more, it seems they protect us from something nefarious.

The word we're looking for is not "data races". It's "aliasing".

Let's borrow
[Wikipedia's definition](<https://en.wikipedia.org/wiki/Aliasing_(computing)>).

> In computing, aliasing describes a situation in which a data location in
> memory can be accessed through different symbolic names in the program. Thus,
> modifying the data through one name implicitly modifies the values associated
> with all aliased names, which may not be expected by the programmer. As a
> result, aliasing makes it particularly difficult to understand, analyze and
> optimize programs.

In Rust, having multiple references around is a form of aliasing. The borrow
checker, then, is a mechanism that helps prevent nasty problems that tend to
come with this territory.
