

foo(x) = eltype(x)
bar(x) = length(x)

using MethodAnalysis

struct Foo{X}
    x::X
end

@nospecialize
has_trait(T::Type) = false
has_trait(T::Type{<:Foo}) = true
@specialize

has_trait(typeof(Foo(1)))
has_trait(typeof(Foo("a")))

methodinstances(has_trait)

do_something_with_trait(x) = has_trait(typeof(x)) ? "success" : "failure"

do_something_with_trait(Foo(1))
do_something_with_trait(Foo("a"))

methodinstances(has_trait)
