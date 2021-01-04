include("cell.jl")

cube_distance(a::Cubic, b::Cubic) =  max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))

lerp(a,b,t) = a + (b - a) * t

struct FuzzyCubic
    x::Float64
    y::Float64
    z::Float64
end

function fuzzy_lerp(a::Cubic, b::Cubic, t::Float64)
    return FuzzyCubic(
        lerp(a.x, b.x, t),
        lerp(a.y, b.y, t),
        lerp(a.z, b.z, t)
    )
end



function cube_round(cube::FuzzyCubic)
    rx = round(cube.x)
    ry = round(cube.y)
    rz = round(cube.z)

    x_diff = abs(rx - cube.x)
    y_diff = abs(ry - cube.y)
    z_diff = abs(rz - cube.z)

    if x_diff > y_diff && x_diff > z_diff
        rx = -ry - rz
    elseif y_diff > z_diff
        ry = -rx - rz
    else
        rz = -rx - ry
    end

    return Cubic(rx, ry, rz)
end

cell_round(cell::Cell) = convert(Cell, cube_round(convert(Cubic, cell)))

cube_lerp(a::Cubic,b::Cubic,t::Float64) = cube_round(fuzzy_lerp(a, b, t))


function cube_line_draw(a::Cubic, b::Cubic)
    N = cube_distance(a, b)
    results = []
    for i in 0:N
        push!(results, cube_lerp(a, b, 1.0 / N * i))
    end
    return results
end

function cell_lerp(a::Cell, b::Cell, t::Float64)
    return convert(Cell, cube_lerp(convert(Cubic, a), convert(Cubic, b), t))
end
    
function cell_line_draw(a::Cell, b::Cell)
    cubes = cube_line_draw(convert(Cubic, a), convert(Cubic, b))
    return [convert(Cell, c) for c in cubes]
end

function cube_add(a::Cubic, b::Cubic)
    return Cubic(
        a.x + b.x,
        a.y + b.y,
        a.z + b.z
    )
end

function cube_scale(direction::Cubic, radius::Int)
    return Cubic(
        direction.x * radius,
        direction.y * radius,
        direction.z * radius
    )
end

cube_directions = [
    Cubic(+1, -1, 0), Cubic(+1, 0, -1), Cubic(0, +1, -1), 
    Cubic(-1, +1, 0), Cubic(-1, 0, +1), Cubic(0, -1, +1), 
]

function cube_direction(direction)
    return cube_directions[direction]
end

function cube_neighbor(cube, direction)
    return cube_add(cube, cube_direction(direction))
end

function cell_ring(cell::Cell, radius::Int)
    center = convert(Cubic, cell)
    ring = Array{Cell,1}()
    cube = cube_add(center, cube_scale(cube_direction(5), radius))
    for i in 1:6
        for j in 1:radius
            push!(ring, convert(Cell, cube))
            cube = cube_neighbor(cube, i)
        end
    end
    return ring
end