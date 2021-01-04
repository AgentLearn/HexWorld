include("grid_build.jl")



@with_kw struct GeologyBuilder <: GridBuilder
    type::String = "geology_builder"
    seed::Int
    island_radius::Float64 = 0.8
    island_aplitude::Float64 = 0.15
    island_freq::Float64 = 18.
end
StructTypes.StructType(::Type{GeologyBuilder}) = StructTypes.Struct()


function build_grid(builder::GeologyBuilder, manifest::Dict{String,String}, grid::Grid)
    grid.dims = JSON3.read(manifest["grid_dim"], GridDims)

    for material in JSON3.read(manifest["materials"], Array{CellMaterial,1})
        grid.materials[material.id] = material
        grid.top_colors[material.id] = material.top_color
    end

    deep_water = cell_id(cell_materials["water"], cell_properties["dark"])
    deep_water_p::UInt64 = pack_cell_data(flat_cell_data(deep_water))
    
    # sea first
    grid.cells .= deep_water_p

    # coast of the island
    sand = cell_id(cell_materials["sand"], cell_properties["normal"])
    sand_p::UInt64 = pack_cell_data(flat_cell_data(sand))

    grass = cell_id(cell_materials["gras"], cell_properties["normal"])
    grass_p::UInt64 = pack_cell_data(flat_cell_data(grass))

    # chose the center of the island
    Random.seed!(builder.seed)
    μ = [grid.dims.width / 2. ,grid.dims.height / 2.]
    Σ = PDiagMat([0.3 * grid.dims.width,0.4 * grid.dims.height])
    b = DiagNormal(μ, Σ)
    center_coord = Int.(round.(rand(b)))
    @info "Center of the island is $center_coord"
    center = Cell(center_coord[1], center_coord[2])
    manifest["island_center"] = JSON3.write(center)
    
    # create shoreline
    edge = EdgeCells(q₁ = grid.dims.width, r₁ = grid.dims.height)
    create_oval(
        (i, N) -> builder.island_radius + builder.island_aplitude * sin(builder.island_freq  * i / N),
        edge,
        center,
        grid,
        sand_p,
        grass_p
        )

    edge_cells = collect(edge)
    lakes = JSON3.read(manifest["lakes"], Array{OvalDescription,1})

    for lake in lakes
        e = edge_cells[Int(round(lake.direction * length(edge)))]
        c = cell_lerp(center, e, lake.distance)
        println(c)

        create_oval(
            (i, N) -> lake.radius + lake.aplitude * sin(lake.freq  * i / N),
            EdgeCells(
                q₀ = c.q - Int(round(lake.q₋ * grid.dims.width / 2.)),
                r₀ = c.r - Int(round(lake.r₋ * grid.dims.height / 2.)),
                q₁ = c.q + Int(round(lake.q₊ * grid.dims.width / 2.)),
                r₁ = c.r + Int(round(lake.r₊ * grid.dims.height / 2.))
            ),
            c,
            grid,
            sand_p,
            deep_water_p
        )
    end

    # add lakes

    return manifest
end

