

@nospecialize

Base.findall(v::Symbol, x::Names) = _find_all_equal(v, Tuple(x))
@assume_effects :total function _find_all_equal(v::Symbol, x::Tuple{Vararg{Symbol}})
    inds = Int[]
    i = 1
    while i <= nfields(x)
        if getfield(x, i) === v
            push!(inds, i)
        end
        i += 1
    end
    (inds...,)
end

Base.findfirst(v::Union{Fix2{typeof(==),Symbol},Fix2{typeof(isequal),Symbol}}, x::Names) = findfirst(v.x, x)
@inline function Base.findfirst(v::Symbol, x::Names)
    i = _findfirst(v, Tuple(x))
    i === 0 ? nothing : i
end
@assume_effects :total function _findfirst(v::Symbol, x::Tuple{Vararg{Symbol}})
    i = 1
    while i <= nfields(x)
        getfield(x, i) === v && return i
        i += 1
    end
    return 0
end
Base.findnext(v::Union{Fix2{typeof(==),Symbol},Fix2{typeof(isequal),Symbol}}, x::Names, start::Int) = findnext(v.x, x, start)
@inline function Base.findnext(v::Symbol, x::Names, start::Int)
    # _findenext only checks upper bound, so we check lower bound here
    i = _findnext(v, Tuple(x), start < 1 ? 1 : start)  
    i === 0 ? nothing : i
end
@assume_effects :total function _findnext(v::Symbol, x::Tuple{Vararg{Symbol}}, start::Int)
    i = start
    while i <= nfields(x)
        getfield(x, i) === v && return i
        i += 1
    end
    return 0
end

## findlast
Base.findlast(v::Union{Fix2{typeof(==),Symbol},Fix2{typeof(isequal),Symbol}}, x::Names) = findlast(v.x, x)
@inline function Base.findlast(v::Symbol, x::Names)
    i = _findlast(v, Tuple(x))
    i === 0 ? nothing : i
end
@assume_effects :total function _findlast(v::Symbol, x::Tuple{Vararg{Symbol}})
    i = nfields(x)
    while i > 0
        getfield(x, i) === v && return i
        i -= 1
    end
    return 0
end

## findprev
Base.findprev(v::Union{Fix2{typeof(==),Symbol},Fix2{typeof(isequal),Symbol}}, x::Names, start::Int) = findprev(v.x, x, start)
@inline function Base.findprev(v::Symbol, x::Names, start::Int)
    # _findeprev only checks lower bound, so we check upper bound here
    t = Tuple(x)
    n = nfields(t)
    i = _findprev(v, t, start > n ? n : start)
    i === 0 ? nothing : i
end
@assume_effects :total function _findprev(v::Symbol, x::Tuple{Vararg{Symbol}}, start::Int)
    i = start
    while i > 0
        getfield(x, i) === v && return i
        i -= 1
    end
    return 0
end

@inline Base.in(v::Symbol, x::FieldVectorType) = _in(v, Tuple(x))
@assume_effects :total function _in(v::Symbol, x::Tuple{Vararg{Symbol}})
    i = nfields(x)
    while i > 0
        getfield(x, i) === v && return true
        i -= 1
    end
    return false
end

function Base.allequal(n::Names)
    if length(n) < 2
        return true
    else
        t = Tuple(n)
        return _findnext(getfield(t, 1), t, 2) === 2
    end
end

Base.allunique(::Names{()}) = true
Base.allunique(n::Names) = _all_unique_names(Tuple(n))
@assume_effects :total function _all_unique_names(x::Tuple{Vararg{Symbol}})
    i = nfields(x)
    while i > 0
        _findprev(getfield(x, i), x, i - 1) === 0 && return false
        i -= 1
    end
    return true
end

@specialize
