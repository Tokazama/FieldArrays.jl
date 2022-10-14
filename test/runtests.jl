using FieldArrays
using Test


t = (:x, :y, :y, :z, :z)
n = Names(:x, :y, :y, :z, :z)

findfirst(==(:y), n) == findfirst(==(:y), t)
findnext(==(:y), n, 2) == findnext(==(:y), t, 2)
findnext(==(:y), n, 3) == findnext(==(:y), t, 3)
findnext(==(:y), n, 4) == findnext(==(:y), t, 4)

findlast(==(:y), n) == findlast(==(:y), t)
findprev(==(:y), n, 3) == findprev(==(:y), t, 3)
findprev(==(:y), n, 2) == findprev(==(:y), t, 2)
findprev(==(:y), n, 1) == findprev(==(:y), t, 1)
