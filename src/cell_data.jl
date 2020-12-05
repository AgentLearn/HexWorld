using StaticArrays
using Colors
using StructTypes
using JSON3


"""
CellWallType
 
Different wall types

**Allowed Values:** 1:16
"""
cell_materials = Dict{String,UInt8}(
    "tree" => 0x01,
    "bush" => 0x02,
    "wall" => 0x03,
    "rock" => 0x04,
    "water" => 0x05,
    "sand" => 0x06,
    "mud" => 0x07,
    "gras" => 0x08,
)


"""
CellProperty

Generic cell wall properties
"""
cell_properties = Dict{String,UInt8}(
    "normal" => 0x10,
    "light" => 0x20,
    "dark" => 0x30,
    "damaged" => 0x40,
    "shiny" => 0x50
)


"""
    cell_id(t, p:)

Creates wall id by or-ing type and property bits.
"""
cell_id(t::UInt8, p::UInt8) = p | t

"""
parse_cell_id(w)

Returns `Material Type` and `Property`
"""
parse_cell_id(w::UInt8) = w & 0x0F, w & 0xF0


"""
`WallMaterial` describes wall of a grid cell.

- `id`: composed of `CellWallType` and `CellProperty`
- `color`: refers to a collor in [`Color`](http://juliagraphics.github.io/Colors.jl/stable/namedcolors/) package.
"""
struct WallMaterial
    id::UInt8
    color::String
end
StructTypes.StructType(::Type{WallMaterial}) = StructTypes.Struct()


"""
    Materials used to describ cell's geometyr and physics.
    
Each material has an uniigue `id::UInt8` and `type::String` to identify
 the type of the material.
"""
abstract type CellMaterial end
StructTypes.StructType(::Type{CellMaterial}) = StructTypes.AbstractType()
StructTypes.subtypekey(::Type{CellMaterial}) = :type

struct FlatCell <: CellMaterial
    type::String
    id::UInt8
    top_color::String
    drag::Float64
end
FlatCell(
    id::UInt8,
    top_color::String,
    drag::Float64) = FlatCell("flat", id, top_color, drag)
StructTypes.StructType(::Type{FlatCell}) = StructTypes.Struct()

struct TallCell <: CellMaterial
    type::String
    id::UInt8
    top_color::String
    wall_data::Array{WallMaterial,1}
end
TallCell(
    id::UInt8,
    top_color::String,
    wall_data::Array{WallMaterial,1}) = TallCell("tall", id, top_color, wall_data)
StructTypes.StructType(::Type{TallCell}) = StructTypes.Struct()

StructTypes.subtypes(::Type{CellMaterial}) = (flat = FlatCell, tall = TallCell)




"""
Describes a Hexagonal Cell in a grid.
"""
struct CellData
    type::UInt8 
    heigth::UInt8
    walls::SVector{6,UInt8}
end
flat_cell_data(type::UInt8) = return CellData(type, 0x0, SVector{6,UInt8}(0x0 for i in 1:6))

function CellData(pack::UInt64)
    bytes = reinterpret(UInt8, [pack])
    t = bytes[1]
    h = bytes[2]
    ws = SVector{6,UInt8}(bytes[3:8])
    return CellData(t, h, ws)
end

pack_cell_data(c::CellData) = reinterpret(UInt64, [c])[1]
