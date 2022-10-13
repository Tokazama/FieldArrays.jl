

@nospecialize

Base.getindex(x::FieldVectorType, ::Colon) = x
@propagate_inbounds Base.getindex(x::FieldVectorType, i::Integer) = getfield(Tuple(x), Int(i))
@propagate_inbounds function Base.getindex(x::FieldVectorType, i::FieldMasks)
    @boundscheck length(x) === length(i) || throw(BoundsError(x, i))
    unsafe_getindex(x, _masks2positions(i))
end
unsafe_getindex(x::Names, i::FieldIndices) = Names(_unsafe_getindex(Tuple(x), Tuple(i)))
@inline function _unsafe_getindex(x::Tuple{Vararg{Symbol}}, inds::NTuple{N,Int}) where {N}
    ntuple(i -> getfield(x, getfield(inds, i)), Val{N}())
end
_masks2positions(x::FieldMasks) = FieldIndices(_find_positions(Tuple(x)))
@assume_effects :total function _find_positions(t::Tuple{Vararg{Bool}})
    inds = Int[]
    i = 1
    while i <= nfields(t)
        if getfield(t, i)
            push!(inds, i)
        end
        i += 1
    end
    (inds...,)
end
@propagate_inbounds Base.getindex(x::NamedValues, i::Int) = getfield(x, :values)[i]
@propagate_inbounds Base.getproperty(x::NamedValues, i::Int) = getfield(x, :values)[i]

@propagate_inbounds function Base.getindex(x::NamedValues, i::Symbol)
    getfield(x, :values)[_findfirst(i, Tuple(getfield(x, :keys)))]
end
@propagate_inbounds @inline function Base.getproperty(x::NamedValues, s::Symbol)
    getfield(x, :values)[_findfirst(s, Tuple(getfield(x, :keys)))]
end

@propagate_inbounds function Base.setindex!(x::NamedValues, v, i::Int)
    setindex!(getfield(x, :values), v, i)
end
@inline function Base.get(x::NamedValues, i::Int, default)
    if 1 <= i && i <= nfields(Tuple(getfield(x, :keys)))
        return @inbounds(getfield(x, :values)[i])
    else
        return default
    end
end
@inline function Base.get(x::NamedValues, key::Symbol, default)
    i = _findfirst(key, Tuple(getfield(x, :keys)))
    i === 0 ? default : @inbounds(getfield(x, :values)[i])
end
@inline function Base.get(f::Union{Type,Function}, x::NamedValues, i::Int)
    if 1 <= i && i <= nfields(Tuple(getfield(x, :keys)))
        return @inbounds(getfield(x, :values)[i])
    else
        return f()
    end
end
@inline function Base.get(f::Union{Type,Function}, x::NamedValues, key::Symbol)
    i = _findfirst(key, Tuple(getfield(x, :keys)))
    i === 0 ? f() : @inbounds(getfield(x, :values)[i])
end

@propagate_inbounds function Base.setindex(x::Names, v::Symbol, i::Int)
    t = Tuple(x)
    if getfield(t, i) === v
        return x
    else
        return _Names(_unsafe_setindex(t, v, i))
    end
end
# `i` is inbounds and `x[i] != v`
@inline function _unsafe_setindex(x::NTuple{N,Symbol}, v::Symbol, i::Int) where {N}
    ntuple(j -> j === i ? v : getfield(x, j), Val{N}())
end

@specialize
