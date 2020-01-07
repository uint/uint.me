+++
title = "Asterisks and dereferences and Derefs, oh my!"
date = 2020-01-07
+++

A few months back I read [the Book](https://doc.rust-lang.org/book/). Well,
I studied it for the second or maybe third time. Third's the charm, isn't it?

This read-through was different. Diligently, methodically, I worked through it.
The [Rust playground](https://play.rust-lang.org/) became a friend, helping me
grope around more complicated concepts like a maniacal scientist in a blindfold
until I arrived at the essence of truth. Eventually, I was done. And, for the
first time ever, I felt I had it. I got it. I did it.

I understood Rust.

. . . that impression lasted a few days. It was a good time. I shall remember it
fondly.

Now, delusions gone, I keep finding things that elude me. Oftentimes those
are matters beyond the scope of the Book. Sometimes they are very much within
said scope, and it's not that the Book fails to describe them in enough detail.
They are just non-trivial concepts that might prove confusing if you miss
a detail or two, or fall prey to wrong assumptions.

One of those things for me was the whole why and how behind `Deref` coercion and
`Deref` itself. I figured it might be worthwhile to compile all those bits
you need to understand to start "getting" it. And so: here we are.

# The `Deref` trait
Like most traits, implementing `Deref` is simple. We only have to provide the
target type, a `deref` method, and voilà!

```rs
struct Foo(String);

impl Deref for Foo {
    type Target = String;
    
    fn deref(&self) -> &Self::Target {
        let Foo(s) = self;
        s
    }
}
```

This, however, might give you pause. Where does this function signature come
from? You'd think `deref` is meant to take a type that acts as a sort of
container and return what's inside it. That's especially the case if you already
know `deref` is used for overloading the `*` operator. But instead, it takes a
reference to that "container" type and returns . . . a reference to the
contained type?

But then, we cannot have this function consume the value—we'll often want
to use it long after dereferencing it in some way. Likewise, we don't want to
return an owned value—we would have to either move it out of `&self` or clone
it. That's not what `deref` is for.

I've developed a way of thinking about `deref` that I like. A reference is,
essentially, information about where to find a value. If `Deref` is implemented
from type `T` to type `U`, then the logic `deref` describes is essentially this:

Given information about where to find a value of type `T`, give me information
about where to find the correspondent value of type `U`. What I'm going to do
with this information and whether I'm going to try consuming anything is up to
me, the user of the function.

# The asterisk
None of this would be complete without understanding how the `*` operator works.
Whenever we talk about dereferencing something, we're probably talking about
slapping an asterisk in front of it.

When you use it on some value `x`, there are two possible cases:
* `x` is a primitive
  [pointer type](https://doc.rust-lang.org/reference/types/pointer.html)—most
  likely a reference. In this case, `*` does **not** call the `Deref::deref`
  method. It's simply a basic, built-in dereference operation to access what the
  reference is pointing to.
* `x` is not a primitive pointer type. In this case, `*x` ends up "translated" to
  `*Deref::deref(&x)`. So we get our `&U` from `deref` and then dereference that
  to get a value of type `U`.

Note that when I mention *primitive* pointer types, I don't mean smart pointers.
If you look at the
[docs of a smart pointer](https://doc.rust-lang.org/std/boxed/struct.Box.html), 
you'll see it gets its dereference functionality from the `Deref` trait.

I'll not write about the first case—it's pretty straightforward and there
are enough examples in the Book.

I will, however, encourage you to play around with the second case. Given our
`Foo` struct:

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    let s: String = *foo; // *foo is equivalent to *Deref::deref(&foo)
}
```

What happens here is that first `deref` gets called, `&foo` is passed into it,
we get back a reference to the `String` inside `foo`, and then we dereference
that primitive reference to get our `String`.

And, of course, we cannot move the `String` out of `foo`. The compiler barfs.

```
error[E0507]: cannot move out of dereference of `Foo`
```

This works a little better:

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    let s: &String = &*foo;
    println!("{}", s);
}
```

Here we do the same, but rather than try to move the `String` out of `foo`, we
create a reference to it and store that reference. All is well again.

But hey, there's more. We know that the `String` type implements `Deref` as well,
with `str` as its target. Give it a try!

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    let s: &str = &**foo;
    println!("{}", s);
}
```

And then you could try and translate it to what it really means by hand:

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    let s: &str = &*Deref::deref(&*Deref::deref(&foo));
    println!("{}", s);
}
```

Whew!

# Deref coercion
`Deref` coercion means two things.

First of all, if type `T` implements `Deref<Target = U>`, then `T` implements
all immutable methods of `U` implicitly.

What this means is that our `Foo` implements most `String` and `str` methods for
free!

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    println!("{}", foo.contains("4")); // true
    println!("{}", foo.contains("a")); // false
    println!("{:?}", foo.as_bytes());  // [52, 50]
}
```

Secondly, `Deref` coercion means if you have a value of type `&T` and put it
in a place that requires a value of type `&U`, it will get implicitly converted
as long as it's possible to do so by calling `deref` a number of times.

So essentially, we can use our `foo` like so:

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    let s1: &String = &foo; // implicitly `Deref::deref(&foo)` or `&*foo`
    let s2: &str = &foo;    // implicitly `Deref::deref(Deref::deref(&foo))`
                            // or `&**foo`
    
    println!("{} {}", s1, s2);
}
```

And we don't have to worry about adding enough asterisks.

This and `Deref` itself is why it's so convenient to write functions that accept
`&str` rather than `String`—thanks to `Deref` coercion, we can pass a `&String`
to such a function and it will be coerced to a `&str`. Hell, we can now even
pass a `&Foo` to those.

```rs
fn main() {
    let foo = Foo(String::from("42"));
        
    prnt(&foo);
}

fn prnt(s: &str) {
    println!("{}", s);
}
```

# DerefMut
`DerefMut` is the mutable equivalent to `Deref`. You can only implement
`DerefMut` on types that implement `Deref`, but thanks to that you don't
have to specify the target type. All you need is to implement the
`deref_mut` method.

```rs
impl DerefMut for Foo {
    fn deref_mut(&mut self) -> &mut Self::Target {
        let Foo(s) = self;
        s
    }
}
```

And then you can use a dereference to mutate the contents of `foo`.

```rs
fn main() {
    let mut foo = Foo(String::from("42"));
        
    *foo = String::from("33");
    
    println!("{:?}", foo); // Foo("33")
}
```

`Deref` coercion applies to `DerefMut` as well. You can apply the same wizardry
analogically to `&mut T` types if they implement `DerefMut<Target = U>`.

You can also take advantage of the fact a mutable reference `&mut T` will get
coerced into an immutable reference `&T` in appropriate contexts.

# Where to go next?
For starters, here are some of my sources. They're all worth reviewing:
* [the dereference operator](https://doc.rust-lang.org/reference/expressions/operator-expr.html#the-dereference-operator)
* [Deref](https://doc.rust-lang.org/std/ops/trait.Deref.html)
* [DerefMut](https://doc.rust-lang.org/std/ops/trait.DerefMut.html)
* [pointer types](https://doc.rust-lang.org/reference/types/pointer.html)

And then, I think the best thing you can do is play around with all those
things until they start making sense and forming a coherent whole.

Happy hacking!