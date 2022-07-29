# ReallyHugeNumbers.jl

A Julia package for working with really huge numbers.

The other package [`HugeNumbers.jl`](https://github.com/cjdoris/HugeNumbers.jl) provides a
number type `Huge` for working with huge numbers. It represents the number `x` by storing
`invhugen(x)`, which is the inverse of the function `hugen(x)`, which grows/shrinks
exponentially as `x` gets large/small.

This package exports the type `ReallyHuge` so that:
- `ReallyHuge(x) == x`
- `ReallyHuge(x, 1) == hugen(x)`
- `ReallyHuge(x, 2) == hugen(hugen(x))`
- and so on...

In all these cases, the number is represented by `x` and the "hugeness depth".

When the depth is 0, the number is `x` itself. A `Huge` number is equivalent to a
`ReallyHuge` number of depth 1. And higher depths allow us to represent super-expoentially
large or small numbers.

Operations between these numbers dynamically select an appropriate depth for the output.
For example, exponential functions will typically increase the depth and logarithmic
functions with typically decrease it.
