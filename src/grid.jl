include("cell_data.jl")
import Base: rand
using Random
using StructTypes

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

StructTypes.StructType(::Type{GridDims}) = StructTypes.Struct()

"""
    Grid

Rpresents a hexagonal grid. The coordinates are releted to 
cells as **odd-q**, see  [Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/)


"""
mutable struct Grid
    dims::GridDims
end


# mt = Random.MersenneTwister(42)
# mutable struct GridBuilder <: Sampleable{Multivariate,Discrete}
# end

# function rand(rng::AbstractRNG, gb::GridBuilder)
    
# end

abstract type GridBuilder end
StructTypes.StructType(::Type{GridBuilder}) = StructTypes.AbstractType()
StructTypes.subtypekey(::Type{GridBuilder}) = :type

function build_grid(builder::GridBuilder, manifest::Dict{String,String}, grid::Grid)
    @warn "Method not implemented for the type $(typeof(builder))"
    return manifest
end

struct RiverBuilder <: GridBuilder
    type::String
    seed::Int
end
RiverBuilder(seed::Int) = RiverBuilder("river_builder", seed)
StructTypes.StructType(::Type{RiverBuilder}) = StructTypes.Struct()


struct ForestBuilder <: GridBuilder
    type::String
    seed::Int
end
ForestBuilder(seed::Int) = ForestBuilder("forest_builder", seed)
StructTypes.StructType(::Type{ForestBuilder}) = StructTypes.Struct()


StructTypes.subtypes(::Type{GridBuilder}) = (river_builder = RiverBuilder, forest_builder = ForestBuilder)

