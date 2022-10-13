

@nospecialize

@inline function Base.union(x::Names, y::Names)
    _Names(_merge_sets(Tuple(unique(x)), Tuple(unique(x))))
end
@assume_effects :total function _merge_sets(x::Tuple{Vararg{Symbol}}, y::Tuple{Vararg{Symbol}})
    names = Symbol[x...]
    i = 1
    while i <= nfields(y) 
        y_i = getfield(y, i)
        if _in(y_i, x) === 0
            push!(names, y_i)
        end
        i += 1
    end
    (names...,)
end

Base.setdiff(x::Names, y::Names) = _setdiff(Tuple(unique(x)), Tuple(y))
@assume_effects :total function _setdiff(x::Tuple{Vararg{Symbol}}, y::Tuple{Vararg{Symbol}})
    names = Symbol[]
    i = 1
    while i <= nfields(x)
        x_i = getfields(x, i)
        if !_in(x_i, y)
            push!(names, x_i)
        end
        i += 1
    end
    (names...,)
end

Base.intersect(x::Names, y::Names) = Names(_intersect(Tuple(unqiue(x)), Tuple(y)))
@assume_effects :total function _intersect(x::Tuple{Vararg{Symbol}}, y::Tuple{Vararg{Symbol}})
    names = Symbol[]
    i = 1
    while i <= nfields(x)
        x_i = getfields(x, i)
        if _in(x_i, y)
            push!(names, x_i)
        end
        i += 1
    end
    (names...,)
end

Base.vcat(x::Names, y::Names) = _Names((Tuple(x)..., Tuple(y)...))

Base.issubset(x::Names, y::Names) = _issubset(Tuple(x), Tuple(y))
@assume_effects :total function _issubset(x::Tuple{Vararg{Symbol}}, y::Tuple{Vararg{Symbol}})
    i = nfields(x)
    while i > 0
        x_i = getfields(x, i)
        _in(x_i, y) || return false
        i -= 1
    end
    return true
end

Base.isdisjoint(x::Names, y::Names) = _isdisjoint(Tuple(x), Tuple(y))
@assume_effects :total function _isdisjoint(x::Tuple{Vararg{Symbol}}, y::Tuple{Vararg{Symbol}})
    i = nfields(x)
    while i > 0
        x_i = getfields(x, i)
        _in(x_i, y) && return false
        i -= 1
    end
    return true
end

@inline function Base.issetequal(x::Names, y::Names)
    xt = Tuple(x)
    yt = Tuple(x)
    _issubset(xt, yt) && _issubset(yt, xt)
end

@assume_effects :total function _make_unique(x::Tuple{Symbol,Vararg{Symbol}})
    names = [getfield(x, 1)]
    i = 2
    while i <= nfields(x)
        x_i = getfield(x, i)
        if _findprev(x_i, x, i - 1) === 0
            push!(names, x_i)
        end
        i += 1
    end
    (names...,)
end


@specialize

@inline Base.unique(x::Names) = allunique(x) ? x : Names(_make_unique(Tuple(x)))
