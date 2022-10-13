

@nospecialize

function Base.showarg(io::IO, x::Names, toplevel)
    toplevel || print(io, "::")
    print(io, "Names")
end
function Base.showarg(io::IO, x::FieldIndices, toplevel)
    toplevel || print(io, "::")
    print(io, "FieldIndices")
end
Base.show(io::IO, x::FieldVectorType) = show(io, MIME"text/plain"(), x)
function Base.show(io::IO, m::MIME"text/plain", x::FieldVectorType)
    Base.showarg(io, x, true)
    show(io, m, Tuple(x))
end

#=
function Base.showarg(io::IO, x::NamedValues, toplevel)
    !toplevel && print(io, "::")
    print(io, "NamedValues(")
    Base.showarg(io, keys(x), false)
    print(io, ", ")
    Base.showarg(io, values(x), false)
    print(io, ")")
    nothing
end
#Base.show(io::IO, m::MIME"text/plain", x::NamedValues) = show(io, m, pairs(x))
function Base.show(io::IO, x::NamedValues)
    print(io, "NamedValues(")
    show(io, keys(x))
    print(io, ", ")
    show(io, values(x))
    print(io, ')')
end
Base.show(io::IO, x::NamedValues) = show(io, MIME"text/plain"(), x)
=#
function Base.show(io::IO, m::MIME"text/plain", x::NamedValues)
    ks = Tuple(getfield(x, :keys))
    vs = getfield(x, :values)
    n = nfields(ks)
    print(io, "NamedValues")
    #Base.showarg(io, x, true)
    print(io, "(")
    for i in 1:n
        print(io, "$(getfield(ks, i)) = ")
        show(io, @inbounds(vs[i]))
        if i !== n
            print(io, ", ")
        end
    end
    print(io, ")")
end

@specialize
