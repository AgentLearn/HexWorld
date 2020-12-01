include("cell_data.jl")
import Base: rand
using Random

using Distributions

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

"""
    Grid

Rpresents a hexagonal grid. The coordinates are releted to 
cells as **odd-q**, see  [Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/)


"""
mutable struct Grid
    dims::GridDims
end


mt = Random.MersenneTwister(42)
mutable struct GridBuilder <: Sampleable{Multivariate,Discrete}
end

function rand(rng::AbstractRNG, gb::GridBuilder)
    
end
