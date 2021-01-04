include("geometry.jl")
include("cell_data.jl")

import Base: rand,iterate,length
using Random
using StructTypes
using Parameters

"""
    Grid Dimensions

# Fields:
- `width`: number of columns (`q` cooridinate)
- `height`: number of rows (`r` coordinate)  
"""
struct GridDims
    width::Int
    height::Int
end

StructTypes.StructType(::Type{GridDims}) = StructTypes.Struct()

"""
    Grid

Rpresents a hexagonal grid. The coordinates are releted to 
cells as **odd-q**, see  [Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/)

### Params:
- `dims::GridDims`: dimensions of the grid
- `cells::Array{UInt64,2}`: packed cell data

"""
mutable struct Grid
    dims::GridDims
    cells::Array{UInt64,2}
    materials::Dict{UInt8,CellMaterial}
    top_colors::Dict{UInt8,String}

    Grid(dims::GridDims) = new(dims, Array{UInt64,2}(undef, dims.width, dims.height), Dict{UInt8,CellMaterial}(), Dict{UInt8,String}())
end

function get(grid::Grid, cell::Cell)
    return grid.cells[cell.q,cell.r]
end

function get(grid::Grid, q::Int, r::Int)
    return grid.cells[q,r]
end

function set!(grid::Grid, cell::Cell, p::UInt64)
    grid.cells[cell.q,cell.r] = p
end

"""
    Defines an rectangel inside the gfrid.
"""
@with_kw struct EdgeCells 
    q₀::Int = 1
    r₀::Int = 1
    q₁::Int
    r₁::Int
end

"""
i   terate(dims, state)

Iterates over the grid edge in clockwise direction starting 
at upper left corener.
"""
function iterate(rect::EdgeCells, state = (1, 0))
    edge = state[1]
    ind = state[2]
    ind == 0 && (ind = rect.q₀ - 1)
    if edge == 1
        if ind == rect.q₁
            edge = 2
            ind = rect.r₀ + 1
            q = rect.q₁
            r = ind
        else
            ind += 1 
            q = ind 
            r = rect.r₀
        end
    elseif edge == 2
        if ind == rect.r₁
            edge = 3
            ind = rect.q₁ - 1
            q = ind
            r = rect.r₁
        else
            ind += 1
            q = rect.q₁
            r = ind
        end
    elseif edge == 3
        if ind == rect.q₀
            edge = 4
            ind = rect.r₁ - 1
            q = rect.q₀
            r = ind 
        else
            ind -= 1
            q = ind
            r = rect.r₁
        end
    else
        if ind == rect.r₀ + 1
            return nothing
        else
            ind -= 1
            q = rect.q₀
            r = ind
        end          
    end
    return Cell(q, r), (edge, ind)
   
end

length(r::EdgeCells) = 2 * (r.q₁ - r.q₀) + 2 * (r.r₁ - r.r₀) 