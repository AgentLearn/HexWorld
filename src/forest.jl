include("geography.jl")

@with_kw struct ForestDescription
    area::OvalDescription
    trees_pdf::Array{Float64,1} = [0.1,0.4,.3,.2]
end
StructTypes.StructType(::Type{ForestDescription}) = StructTypes.Struct()


function count_cells(grid::Grid, bounds::EdgeCells, id::UInt8, heigh_min::UInt8)
    count = 0
    for q in bounds.q₀:bounds.q₁
        for r in bounds.r₀:bounds.r₁
            cell_data = CellData(get(grid, q, r))
            if cell_data.type == id && cell_data.heigth >= heigh_min
                count += 1
            end
        end
    end
    return count
end

struct ForestBuilder <: GridBuilder
    type::String
    seed::Int
end
ForestBuilder(seed::Int) = ForestBuilder("forest_builder", seed)
StructTypes.StructType(::Type{ForestBuilder}) = StructTypes.Struct()

function build_grid(builder::ForestBuilder, manifest::Dict{String,String}, grid::Grid)
    edge = EdgeCells(q₁ = grid.dims.width, r₁ = grid.dims.height)
 
    mud = cell_id(cell_materials["mud"], cell_properties["normal"])
    mud_p::UInt64 = pack_cell_data(flat_cell_data(mud, 0xA))

    edge_cells = collect(edge)
    center = JSON3.read(manifest["island_center"], Cell)
    println(center)
    forests = JSON3.read(manifest["forests"], Array{ForestDescription,1})
    for forest in forests
        e = edge_cells[Int(round(forest.area.direction * length(edge)))]
        c = cell_lerp(center, e, forest.area.distance)
        fores_edge = EdgeCells(
            q₀ = c.q - Int(round(forest.area.q₋ * grid.dims.width / 2.)),
            r₀ = c.r - Int(round(forest.area.r₋ * grid.dims.height / 2.)),
            q₁ = c.q + Int(round(forest.area.q₊ * grid.dims.width / 2.)),
            r₁ = c.r + Int(round(forest.area.r₊ * grid.dims.height / 2.))
        )

        create_oval(
            (i, N) -> forest.area.radius + forest.area.aplitude * sin(forest.area.freq  * i / N),
            fores_edge,
            c,
            grid,
            mud_p,
            mud_p
        )

        # add trees
        N = count_cells(grid, fores_edge, mud, 0xA)
        T = N / 7
        println(" \n forest has $N cells, needs $T trees.")
        pdf = Int.(round.(T .*  forest.trees_pdf))
        println(pdf)

        
    end
    return manifest
end