+++
title = "About me"
+++

I love [Rust](https://rust-lang.org/). If you have any Rusty things to do,
do [contact me](mailto:uint@lavabit.com). I'm looking for clients, commissions,
contracts, part-time work, and so forth.

```rs
enum Answer {
    Yes,
    Maybe,
}

fn should_uint_be_contacted(things_to_do: &[&str]) -> Answer {
    match things_to_do.iter().find(|s| s.contains("rust")) {
        Some(_) => Answer::Yes,
        _ => Answer::Maybe,
    }
}
```

Here's my
* [CV](https://github.com/uint/cv/releases/download/latest/cv.pdf) *([source](https://github.com/uint/cv))*,
* [LinkedIn](https://www.linkedin.com/in/tomasz-kurcz-a20828164/), and
* [GitHub](https://github.com/uint).
