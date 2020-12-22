include("grid.jl")
include("cell_data.jl")

using Parameters
using JSON3
using Distributions, PDMats, Random



# rng = Random.MersenneTwister(42)


abstract type GridBuilder end
StructTypes.StructType(::Type{GridBuilder}) = StructTypes.AbstractType()
StructTypes.subtypekey(::Type{GridBuilder}) = :type

function build_grid(builder::GridBuilder, manifest::Dict{String,String}, grid::Grid)
    @warn "Method not implemented for the type $(typeof(builder))"
    return manifest
end

@with_kw struct GeologyBuilder <: GridBuilder
    type::String = "geology_builder"
    seed::Int
end
StructTypes.StructType(::Type{GeologyBuilder}) = StructTypes.Struct()


struct ForestBuilder <: GridBuilder
    type::String
    seed::Int
end
ForestBuilder(seed::Int) = ForestBuilder("forest_builder", seed)
StructTypes.StructType(::Type{ForestBuilder}) = StructTypes.Struct()


StructTypes.subtypes(::Type{GridBuilder}) = (geology_builder = GeologyBuilder, forest_builder = ForestBuilder)


function build_grid(builder::GeologyBuilder, manifest::Dict{String,String}, grid::Grid)
    grid.dims = JSON3.read(manifest["grid_dim"], GridDims)

    materials = Dict{UInt8,CellMaterial}()
    for material in JSON3.read(manifest["materials"], Array{CellMaterial,1})
        materials[material.id] = material
    end

    water_id = cell_materials["water"]
    deep_water = cell_id(water_id, cell_properties["dark"])
    deep_water_f::Float64 = pack_cell_data(flat_cell_data(deep_water))
    
    # sea first
    grid.cells .= deep_water_f

    # coast of the island
    sand_id = cell_materials["sand"]
    sand = cell_id(sand_id, cell_properties["normal"])
    sand_f::Float64 = pack_cell_data(flat_cell_data(sand))

    # chose the center of the island
    Random.seed!(builder.seed)
    μ = [grid.dims.width / 2. ,grid.dims.height / 2.]
    Σ = PDiagMat([0.2 * grid.dims.width  ,0.2 * grid.dims.height])
    b = DiagNormal(μ, Σ)
    center = Int.(round.(rand(b)))
    @info "Center of the island is $center"

    # create shoreline
    c = convert(Cubic, Cell(center[1], center[2]))
    edges = EdgeCells(grid.dims.width, grid.dims.height)
    for e in edges
        s = cell_lerp(c, convert(Cubic, e), 0.95)
        # println(Íe, s)
    end

    return manifest
end

# TDD

function build_test_manifest()
    manifest = Dict{String,String}()
    dims = GridDims(1_200, 1_000)
    manifest["grid_dim"] = JSON3.write(dims)
    c1::CellMaterial = FlatCell(
                cell_id(cell_materials["gras"], cell_properties["normal"]), 
                "springgreen", 
                0.4)
    c2::CellMaterial = TallCell(
                cell_id(cell_materials["tree"], cell_properties["dark"]),
                "forestgreen",
                WallMaterial[
                    WallMaterial(
                        cell_id(cell_materials["tree"], cell_properties["dark"]),
                        "brown"
                        )
                ])
            
    cell_types = CellMaterial[c1,c2]
    manifest["materials"] = JSON3.write(cell_types, )
    gb = GeologyBuilder(seed = 42)
    fb = ForestBuilder(11)
    builders = Array{GridBuilder,1}([gb, fb])
    manifest["builders"] = JSON3.write(builders)
    return gb, Grid(dims), manifest
end

gb, grid, manifest = build_test_manifest()
build_grid(gb, manifest, grid);
