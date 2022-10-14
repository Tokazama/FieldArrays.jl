# FieldArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Tokazama.github.io/FieldArrays.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Tokazama.github.io/FieldArrays.jl/dev/)
[![Build Status](https://github.com/Tokazama/FieldArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Tokazama/FieldArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Tokazama/FieldArrays.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Tokazama/FieldArrays.jl)


__EXPERIMENTAL__

I've attempted to provide some minimal documentation, but it's currently aimed at helping me keep track of what I've done and capturing ideas that motivated various decisions.

* What is this?

  Types that act like arrays but their contents are more like type parameters.
  It's kind of like what would happen if you decomposed `NamedTuple` into as many primitive components as possible and then made them vectors so that people could easily use them.

* Why do this?

  `NamedTuple` is an anonymous struct type. We can have as many fields as we want, with any field names we want (so long as they are all unique). The common method of constructing a `NamedTuple` (e.g., `(field_name_1 = foo, field_name_2 = bar, ...)`) results in each field having a unique type parameter. Transparent access to field names and field types often allows Julia to generat code with little-to-no cost for accesing these fields. This typically occurs without any additional intervention from the user. The downside of this is that generic methods wil often create a new method when encountering a `NamedTuple` with any new field names or types (or the same names and types but in a different order). This balance between runtime performance and avoiding uncessary codegen is relevant to any parametric type, but `NamedTuple` is the perfect example because it's universally known among Julia users. This makes it somewhat easier to relate how this balance effects end users:
    
    1. Sometimes we intentionally avoid optimizing runtime performance. For example, I've personally ran into unexpected issue with runtime performance and inferrence when using `Base.setindex(::NamedTuple, ...)` and `merge(::NamedTuple, ...)`. Fully optimizing runtime performance of these methods for `NamedTuple` comes at the cost of increased compilation for casual use cases.
    2. Methods that return all available information place the burden of balancing the runtime-compiltion balnce on end users. The alternatives to this are wrapping highly paramtric return types in type unstable code or throwing out some info. A good example of this is how StatsModels.jl has to manage formula input and processing. Even if all the information provided could be inferred at compile time, the return type `Schema` is backed by a dictionary and results in type instabilities (see [this issue](https://github.com/JuliaStats/StatsModels.jl/issues/253)). However, it would be unreasonable to compile a new method for every single permutation of variables and data types when the only goal is to create a common key-value interface for models to consume data.

* The strategy

  1. Create a handful of types that provide as much compile time information as possibl (within reason).
  2. Give this types the `AbstractArray` interface so they're easy to use.
  3. Despecialize __all__ methods.
  4. Test performance against comparable things in `Base`.
  5. If we aren't doing at least as good as `Base` find out where we need to increase specialization.

The "benchmarks" directory contains some early attempts at making these results consumble.