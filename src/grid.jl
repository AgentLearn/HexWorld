include("cell_data.jl")
import Base: rand
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