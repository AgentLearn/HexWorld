include("forest.jl")

StructTypes.subtypes(::Type{GridBuilder}) = (geology_builder = GeologyBuilder, forest_builder = ForestBuilder)

# TDD

function build_test_manifest()
    manifest = Dict{String,String}()
    dims = GridDims(1400, 1000)
    manifest["grid_dim"] = JSON3.write(dims)

    cell_types = CellMaterial[]
    push!(cell_types, FlatCell(cell_id(cell_materials["water"], cell_properties["dark"]), "royalblue", 10000.))
    push!(cell_types, FlatCell(cell_id(cell_materials["water"], cell_properties["normal"]), "skyblue2", 3.0))
    push!(cell_types, FlatCell(cell_id(cell_materials["gras"], cell_properties["normal"]), "springgreen",  0.4))
    push!(cell_types, FlatCell(cell_id(cell_materials["sand"], cell_properties["normal"]), "wheat",  0.4))
    push!(cell_types, FlatCell(cell_id(cell_materials["road"], cell_properties["normal"]), "lightyellow4",  0.001))
    push!(cell_types, FlatCell(cell_id(cell_materials["mud"], cell_properties["normal"]), "goldenrod4",  0.1))

    push!(cell_types,TallCell(cell_id(cell_materials["tree"], cell_properties["dark"]),"forestgreen",
                WallMaterial[
                    WallMaterial(cell_id(cell_materials["tree"], cell_properties["dark"]), "brown")
                ]))
            
    
    manifest["materials"] = JSON3.write(cell_types)
    
    lakes = Array{OvalDescription,1}()

    lake = OvalDescription(
        direction = 0.7,
        distance = 0.3,
        q₋ = 0.2,
        q₊ = 0.25,
        r₋ = 0.1,
        r₊ = 0.1,
        radius = 0.7,
        aplitude = 0.3,
        freq = 6
        )
    push!(lakes, lake)
    lake = OvalDescription(
        direction = 0.4,
        distance = 0.5,
        q₋ = 0.2,
        q₊ = 0.25,
        r₋ = 0.2,
        r₊ = 0.1,
        radius = 0.7,
        aplitude = 0.3,
        freq = 15
        )
    push!(lakes, lake)
    manifest["lakes"] = JSON3.write(lakes)
  
    forests = Array{ForestDescription,1}()
    area = OvalDescription(
        direction = 0.1,
        distance = 0.5,
        q₋ = 0.2,
        q₊ = 0.45,
        r₋ = 0.3,
        r₊ = 0.63,
        radius = 0.7,
        aplitude = 0.3,
        freq = 15
        )
    forest = ForestDescription(area = area)
    push!(forests, forest)
    forest = ForestDescription(area = OvalDescription(
        direction = 0.8,
        distance = 0.6,
        q₋ = 0.2,
        q₊ = 0.5,
        r₋ = 0.1,
        r₊ = 0.38,
        radius = 0.7,
        aplitude = 0.3,
        freq = 7
        ))
    push!(forests, forest)

    manifest["forests"] = JSON3.write(forests)

    
    gb = GeologyBuilder(seed = 42)
    fb = ForestBuilder(11)
    builders = Array{GridBuilder,1}([gb, fb])
    manifest["builders"] = JSON3.write(builders)
    return Grid(dims), manifest
end



function build_test_grid()
    grid, manifest = build_test_manifest()
    builders = JSON3.read(manifest["builders"], Array{GridBuilder,1})
    for builder in builders
        manifest = build_grid(builder, manifest, grid);
    end
    return grid
end

# build_test_grid()
