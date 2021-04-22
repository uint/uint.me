+++
title = "A guide to clean living"
date = 2021-04-22
+++

This aims to be (a list of my personal frustrations thinly veiled as) a comprehensive
self-help book for programmers who think they might be losing their grasp on sanity
in the rush of modern life.

You probably are.

# Don't use trait objects in structs
This is for [Rustaceans](https://www.urbandictionary.com/define.php?term=rustacean)
specifically.

Trait objects lead to downcasting. Downcasting leads to boilerplate. Boilerplate
leads to frustration. Frustration leads to self-loathing. Self-loathing leads
to madness. Madness leads to implementing an ad-hoc dynamic type system
in a language that wasn't created with dynamic typing in mind.

Take a deep breath. Meditate. Take a second to consider the wondrous harmony
achieved somewhere between traits, generics, and enums. Every morning, spend a few
minutes practicing mindful gratitude for the simple things.

# Avoid templating engines
They're not that great.

Especially avoid templating over config files. It is a downward spiral that easily
leads to feelings of loss of control and, further down the line, bitterness.

If your life currently involves a situation where templates are templated over
(because "it seemed a good idea to template over those Helm config values"),
consider that there is truly no shame in seeking therapy. Questioning the choices that
led you to this point might seem unhealthy and unproductive, but in this particular situation
it is likely an important - if difficult - bit of introspection to go through.

Remember - negative feelings are frequently there for a reason. Don't ignore them.
They're every bit as important as the good ones.

# "We want generalists!"
The only reason we may want it all is because we don't yet know what we want. The
enlightened few who gained that rare insight know they want for little.

Societies evolved naturally to allow for outsourcing work. It not only makes us
more efficient, but also allows a group of people to truly be more than the
sum of its parts.

Can a blacksmith fix your house in a pinch to keep it from collapsing? Quite likely.
But afterwards you will still want to visit the carpenter. Deep down you know
the blacksmith only applied a bandaid. You know true repair belongs to the appropriate
specialist, and carpentry is not as simple as it seems.

Experiencing a disaster after a disaster is not a sign everyone should get good at dousing
any kind of fire that could possibly happen. It is a sign there are deeper issues at play
and life has gotten out of control.

A team of jacks of all trades is no team at all.

# On cynicism
Many would deny the existence of beauty. "There are no good practices or clean code, there
is only achieving the business case." Yet these are often the same people who end up
bound by their own demons, who spend hours chained by fears they created themselves,
who are doing the devil's work of maintaining the unmaintainable.

Give that a ponder. Remember: we are all only humans at different stages of
enlightenment. Reach out gently and kindly to those who need it, but remember
to take care of yourself first while on the quest to help others. Should you
feel yourself getting sucked into their world of fear and self-loathing,
be ready to walk away without guilt.

When you deny the existence of soul and heart, you only hurt yourself.

# On "REST APIs"
Contrary to popular belief, a REST API is a very
[well](https://unixsheikh.com/articles/no-your-api-isnt-rest.html)
[defined](https://www.youtube.com/watch?v=pspy1H6A3FM)
[concept](https://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven).

It is probably not what you think it is, and its intended uses are not what
you're using it for, for REST APIs are about wondrous user-driven exploration
and not robots speaking to each other in pre-defined, contract-driven ways.

Forget about it. You probably want an RPC framework. Swagger and OpenAPI
effectively try to approach the truth of RPC being the way to enlightenment,
but without the self-awareness of that goal it all ends up
gnarled and twisted. Bending a fundamentally RESTful system such as HTTP
until it becomes a bad RPC solution is ripe for complications.

You don't sail a boat on sand. A convincing caricature of the truth is
a dangerous thing in and of itself.

Embrace Thrift and gRPC. Live cleanly. Set your mind free.

# What if it can't be tested locally?
Learn to say no. Setting boundaries is an important part of any human relationship.

Here is an example sentence you could practice saying:
"I would love to help you out with this project, but the maintenance strategy
and development workflow are unclear to me. I will be happy to do the work you're
asking for once we sort out testing it locally and in isolation from other
components."

A situation where any confidence in software actually working can only be gained
* after uploading it to a third-party platform, or
* by spinning up a VM on a corporate network, or
* after deploying a larger tangle of wildly interdependent things

is not compatible with the principles of clean living, and calls for a careful
step back and deep introspection.