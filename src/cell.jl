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