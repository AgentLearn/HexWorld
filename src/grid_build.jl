include("grid.jl")
using Parameters
using JSON3
using Distributions, PDMats, Random


abstract type GridBuilder end
StructTypes.StructType(::Type{GridBuilder}) = StructTypes.AbstractType()
StructTypes.subtypekey(::Type{GridBuilder}) = :type

function build_grid(builder::GridBuilder, manifest::Dict{String,String}, grid::Grid)
    @warn "Method not implemented for the type $(typeof(builder))"
    return manifest
end

@with_kw  struct OvalDescription
    direction::Float64
    distance::Float64
    q₋::Float64
    q₊::Float64
    r₋::Float64
    r₊::Float64
    radius::Float64 
    aplitude::Float64 
    freq::Float64 
end
StructTypes.StructType(::Type{OvalDescription}) = StructTypes.Struct()




"""
create_oval(f, rect, center:, grid, edge_p, inner_p)

Uses rays between each cell on the boundary of the rectangle `rect` and
the `center`, that is assumed to be inside the `rect`, and the function `f` to create a 
shape in the interior of the `rect`.
"""
function create_oval(f, rect::EdgeCells, center::Cell, grid::Grid, edge_p::UInt64, inner_p::UInt64)
    i = 1
    N = length(rect)
    c□ = convert(Cubic, center)
    for e in rect
        e□ = convert(Cubic, e)
        p = f(i, N)
        # println("$i,$N -> $p")
        s□ = cube_lerp(c□, e□, p)
        ray = cube_line_draw(c□, s□)
        s = convert(Cell, s□)
        set_edge = get(grid, s) != inner_p
        for r□ in ray
            r = convert(Cell, r□)
            set!(grid, r, inner_p)
        end
        set_edge && set!(grid, s, edge_p)

        i += 1
    end
end
