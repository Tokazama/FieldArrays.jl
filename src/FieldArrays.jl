module FieldArrays

using Base: @propagate_inbounds, Fix2

@static if isdefined(Base, Symbol("@assume_effects"))
    using Base: @assume_effects
else
    macro assume_effects(_, ex)
        :(Base.@pure $(ex))
    end
end

export
    NamedValues,
    Names

@nospecialize

# TODO document Names
struct Names{names} <: AbstractVector{Symbol}
    Names(::Tuple{}) = new{()}()
    Names(x::Tuple{Vararg{Symbol}}) = new{x}()
    Names(x::Vararg{Symbol}) = new{x}()
end

# TODO doc FieldMasks
struct FieldMasks{masks} <: AbstractVector{Bool}
    FieldMasks(m::Tuple{Vararg{Bool}}) = new{m}()
end

# TODO doc FieldIndices
struct FieldIndices{positions} <: AbstractVector{Int}
    FieldIndices(x::Tuple{Vararg{Int}}) = new{x}()
end

# TODO doc NamedValues
struct NamedValues{K<:Names,V}
    keys::K
    values::V

    global _NamedValues(ks::Names, vs::Union{AbstractVector,Tuple}) = new{typeof(ks),typeof(vs)}(ks, vs)
    function NamedValues(ks::Names, vs::Union{AbstractVector,Tuple})
        @assert eachindex(ks) == eachindex(ks)
        _NamedValues(ks, vs)
    end
    @inline function NamedValues(; kwargs...)
        x = getfield(kwargs, :data)
        _NamedValues(Names(keys(x)), (x...,))
    end
end

_values_type(x::NamedValues) = typeof(getfield(x, :values))
_values_type(T::Type{<:NamedValues}) = fieldtype(T, :values)

const FieldVectorType{names} = Union{Names{names},FieldIndices{names},FieldMasks{names}}

Base.Tuple(::Names{names}) where {names} = names
Base.Tuple(::FieldIndices{indices}) where {indices} = indices
Base.Tuple(::FieldMasks{masks}) where {masks} = masks
Base.Tuple(x::NamedValues) = Tuple(getfield(x, :values))

Base.keytype(x::Union{Type{<:NamedValues},NamedValues}) = Symbol
Base.valtype(x::Union{Type{<:NamedValues},NamedValues}) = eltype(_values_type(x))
Base.eltype(x::Union{Type{<:NamedValues},NamedValues}) = eltype(_values_type(x))
Base.eltype(x::Union{Type{<:FieldMasks},FieldMasks}) = Bool
Base.eltype(x::Union{Type{<:FieldIndices},FieldIndices}) = Int
Base.eltype(x::Union{Type{<:Names},Names}) = Symbol
Base.IndexStyle(::Union{Type{<:FieldVectorType},FieldVectorType}) = IndexLinear()
Base.IndexStyle(::Union{Type{<:NamedValues},NamedValues}) = IndexLinear()
function Base.IteratorSize(x::Union{Type{<:NamedValues},NamedValues})
    Base.IteratorSize(_values_type(x))
end

Base.values(x::NamedValues) = getfield(x, :values)
Base.keys(x::NamedValues) = getfield(x, :keys)
@inline Base.haskey(x::NamedValues, key::Symbol) = _in(key, Tuple(getfield(x, :keys)))

Base.firstindex(::Union{FieldVectorType,NamedValues}) = 1
Base.lastindex(x::Union{FieldVectorType,NamedValues}) = length(x)
Base.axes(x::FieldVectorType) = axes(Tuple(x))
Base.eachindex(x::NamedValues) = eachindex(getfield(x, :keys))
Base.length(x::FieldVectorType) = nfields(Tuple(x))
Base.length(x::NamedValues) = length(getfield(x, :keys))
Base.first(x::FieldVectorType) = getfield(Tuple(x), 1)
Base.last(x::FieldVectorType) = last(Tuple(x))
Base.isempty(::FieldVectorType{()}) = true
Base.isempty(::FieldVectorType) = false
Base.isempty(x::NamedValues) = isempty(getfield(x, :keys))
Base.empty(::FieldIndices) = FieldIndices()
Base.empty(::Names) =  Names()  
function Base.empty(x::NamedValues)
    _NamedValues(empty(getfield(x, :keys)), empty(getfield(x, :keys)))
end

Base.iterate(::FieldVectorType{()}) = nothing
Base.iterate(::FieldVectorType{()}, state::Int) = nothing
@inline Base.iterate(x::FieldVectorType) = (getfield(Tuple(x), 1), 2)
@inline function Base.iterate(x::FieldVectorType, state::Int)
    t = Tuple(x)
    nfields(t) < state ? nothing : (getfield(t, state), state + 1)
end
@inline Base.iterate(@nospecialize(x::NamedValues)) = iterate(getfield(x, :values))
@inline function Base.iterate(@nospecialize(x::NamedValues), state::Int)
    iterate(getfield(x, :values), state)
end

@specialize


include("indexing.jl")
include("sets.jl")
include("find.jl")
include("show.jl")

end
