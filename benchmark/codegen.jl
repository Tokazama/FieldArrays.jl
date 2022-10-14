# The goal here is to have naively written functions generate less code without any
# additional work from the user. We use the same exmample from "benchamrk/iteration.jl"
#  (`props2vec`) so that runtim performance and decreased codegen aren't on conflict in
# generic user code.
Pkg.activate(".")
using FieldArrays
using MethodAnalysis

function props2vec(x)
    out = Vector{eltype(x)}(undef, length(x))
    for (i, name) in enumerate(propertynames(x))
        out[i] = getproperty(x, name)
    end
    out
end
# Initial generation of method instances
nt1 = (a = 1, b = 2, c = 3);
nv1 = NamedValues(Names((:a, :b, :c)), (1, 2, 3));
props2vec(nt1);
props2vec(nv1);
mi1 = methodinstances();
# Generate new methods for `NamedTuple`
nt2 = (a = "a", b = 2, c = 3);
props2vec(nt2);
mi2 = methodinstances();
# Generate new methods for `NamedValues`
nv2 = NamedValues(Names((:a, :b, :c)), ("a", 2, 3));
props2vec(nv2);
mi3 = methodinstances();
length(setdiff(mi2, mi1))  # 12
length(setdiff(mi3, mi2))  # 8


# Start new session and do sanity check, switching order we generate methods
# (`NamedValues` then `NamedTuple`)
Pkg.activate(".")
using FieldArrays
using MethodAnalysis

function props2vec(x)
    out = Vector{eltype(x)}(undef, length(x))
    for (i, name) in enumerate(propertynames(x))
        out[i] = getproperty(x, name)
    end
    out
end
# Initial generation of method instances
nt1 = (a = 1, b = 2, c = 3);
nv1 = NamedValues(Names((:a, :b, :c)), (1, 2, 3));
props2vec(nt1);
props2vec(nv1);
mi1 = methodinstances();
# Generate new methods for `NamedValues`
nv2 = NamedValues(Names((:a, :b, :c)), ("a", 2, 3));
props2vec(nv2);
mi2 = methodinstances();
# Generate new methods for `NamedTuple`
nt2 = (a = "a", b = 2, c = 3);
props2vec(nt2);
mi3 = methodinstances();
length(setdiff(mi2, mi1))  #  9
length(setdiff(mi3, mi2))  #  11
