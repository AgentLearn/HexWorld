using Makie
# using AbstractPlotting
# AbstractPlotting.inline!(true)
include("world.jl")


function create_poly(cells::Array{Cell,1})
    num_cells = length(cells)
    vertices = Array{Float64,2}(undef, 7 * num_cells, 2)
    simplices = Array{Int,2}(undef, 6 * num_cells, 3)
    id = 0
    for cell in cells
        points = cemter_and_vertices_loc(cell)
        center_i = 7 * id + 1
        for i in 0:6
            vertices[center_i + i,:] .= points[i + 1,:]
        end
        for t in 1:6
            simplices[6 * id + t,:] .= [center_i, center_i + t, center_i + 1 + mod(t, 6)]
        end
        id += 1
    end
    return vertices, simplices
end

grid = build_test_grid()



buckets = Dict{UInt8,Array{Cell,1}}()
for id in keys(grid.top_colors)
    buckets[id] = Array{Cell,1}()
    println(id)
end



for q in 1:grid.dims.width
    for r in 1:grid.dims.height
        cell_data = CellData(grid.cells[q,r])
        id = cell_data.type
        push!(buckets[id], Cell(q, r))
    end
end

scene = Scene()

for id in keys(grid.top_colors)
    println("for $id: num cells is $(length(buckets[id]))")
    length(buckets[id]) == 0 && continue

    vertices, edges = create_poly(buckets[id])
    poly!(vertices, edges, color = grid.top_colors[id], strokecolor = (:black, 0.6), strokewidth = .1)
end
display(scene)
