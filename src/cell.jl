using Hexagons
import Base: convert, length, collect, iterate

"""
    HexCell

* `q`: column index, starting from `1`
* `r`: row index, starting from `1`

**Note:** 
1. `(1,1)` represents the upper left corner.
2. In [Hexagons](https://github.com/GiovineItalia/Hexagons.jl) notation this structure 
    would have been called `HexagonOffsetOddQ`

**Units:**
- length of a hexagon side is `1`
- width is `2`
- height is `sqrt(3)`
"""
struct HexCell <: Hexagons.Hexagon
    q::Int
    r::Int
end

function convert(::Type{HexagonCubic}, cell::HexCell)
    x = cell.q 
    z = cell.r - (cell.q >> 1)
    y = -x - z
    HexagonCubic(x, y, z)
end

function convert(::Type{HexCell}, hex::HexagonCubic)
    q = hex.x 
    r = hex.z + (hex.x >> 1)
    HexCell(q, r)
end

"""
    center_loc(cell)

Returns the `(x,y)` location of the center of the cell.
"""
function center_loc(cell::HexCell)
    x::Float64 = 2 * cell.q - 1 
    y::Float64 = (cell.r  - (cell.q & 1) / 2 ) * sqrt(3) 
    return x, y
end

"""
cemter_and_vertices_loc(cell)

Returns an `7 by 2` `Array{Float64,2}` where
the first row is the center of the cell and other 6 rows contain vertices.

Vertices are orthered counter-clockwise, starting with the right-most vertex.
"""
function cemter_and_vertices_loc(cell::HexCell)
    x0, y0 = center_loc(ceil)
    points = Array{Float64,2}(undef, 7, 2)
    points[1,1] = x0
    points[1,2] = y0
    for i in 0:5
        angle = 60 * i
        x = x0 + cosd(angle)
        y = y0 + sind(angle)
        points[i + 2,1] = x
        points[i + 2,2] = y
    end
    return points
end

get_vertex(x0::Float64, y0, i::Int) = (x0 + cosd(6 * i), y0 + sind(6 * i))

function get_vertex(cell::HexCell, i::Int)
    x0, y0 = center_loc(ceil)
    return get_vertex(x0, y0, i)
end