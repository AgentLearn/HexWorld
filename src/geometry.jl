include("cell.jl")

cube_distance(a::Cubic, b::Cubic) =  max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))

lerp(a,b,t) = a + (b - a) * t

struct FuzzyCubic
    x::Float64
    y::Float64
    z::Float64
end

function cube_lerp(a::Cubic, b::Cubic, t::Float64)
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


function cube_linedraw(a, b)
    N = cube_distance(a, b)
    results = []
    for i in 0:N
        results.append(cube_round(cube_lerp(a, b, 1.0 / N * i)))
    end
    return results
end

function cell_lerp(a::Cubic, b::Cubic, t::Float64)
    return convert(Cell, cube_round(cube_lerp(a, b, t)))
end
    