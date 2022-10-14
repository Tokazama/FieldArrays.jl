
Pkg.activate(".")
using FieldArrays
using BenchmarkTools

function props2vec(x)
    out = Vector{eltype(x)}(undef, length(x))
    for (i, name) in enumerate(propertynames(x))
        out[i] = getproperty(x, name)
    end
    out
end

nt = (a = 1, b = 2, c = 3)
nv = NamedValues(a = 1, b = 2, c = 3)

props2vec(nt) == props2vec(nv)  # produce the same values

@time props2vec(nt)  # 0.000007 seconds (4 allocations: 176 bytes)
@time props2vec(nv)  # 0.000004 seconds (1 allocation: 80 bytes)

@btime props2vec($nt)  # 106.474 ns (4 allocations: 176 bytes)
@btime props2vec($nv)  # 29.383 ns (1 allocation: 80 bytes)
