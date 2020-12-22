include("geometry.jl")

import Base: rand,iterate,length
using Random
using StructTypes


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


"""
mutable struct Grid
    dims::GridDims
    cells::Array{Float64,2}
    Grid(dims::GridDims) = new(dims, Array{Float64,2}(undef, dims.width, dims.height))
end

struct EdgeCells 
    width::Int
    height::Int
end

"""
i   terate(dims, state)

Iterates over the grid edge in clockwise direction starting 
at upper left corener.
"""
function iterate(dims::EdgeCells, state = (1, 0))
    edge = state[1]
    ind = state[2]
    if edge == 1
        if ind == dims.width
            edge = 2
            ind = 2
            q = dims.width
            r = ind
        else
            ind += 1 
            q = ind 
            r = 1
        end
    elseif edge == 2
        if ind == dims.height
            edge = 3
            ind = dims.width - 1
            q = ind
            r = dims.height
        else
            ind += 1
            q = dims.width
            r = ind
        end
    elseif edge == 3
        if ind == 1
            edge = 4
            ind = dims.height - 1
            q = 1
            r = ind 
        else
            ind -= 1
            q = ind
            r = dims.height
        end
    else
        if ind == 2
            return nothing
        else
            ind -= 1
            q = 1
            r = ind
        end          
    end
    return Cell(q, r), (edge, ind)
   
end

length(dims::EdgeCells) = 2 * dims.width + 2 * dims.height - 4