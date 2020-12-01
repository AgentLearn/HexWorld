using HexWorld
using JSON3
using Test

@testset "HexWorld.jl" begin
    @testset "Cell Geopmetry" begin
        @testset "Conversions betseen Cell to Cube" begin
            cell = HexCell(12, 232)
            hex = convert(HexagonCubic, cell)
            cell2 = convert(HexCell, hex)
            @test cell == cell2
        end
        @testset "Cell Center" begin
            c1 = HexCell(1, 1)
            @test c1 !== nothing
            x11, y11 = center_loc(c1)
            @test x11 ≈ 1.0
            @test y11 ≈ sqrt(3) / 2
            x21, y21 = center_loc(HexCell(2, 1))
            @test x21 ≈ 3
            @test y21 ≈  sqrt(3)
            x42, y42 = center_loc(HexCell(4, 2))
            @test x42 ≈ 7
            @test y42 ≈ 2 * sqrt(3) 
        end
    end
    @testset "Grid" begin
        @testset "Build a Grid" begin
            manifest = Dict{String,String}()
            dims = GridDims(1_000, 1_000)
            manifest["grid_dim"] = JSON3.write(dims)
            @test dims == JSON3.read(manifest["grid_dim"], GridDims)
            rb = RiverBuilder(42)
            fb = ForestBuilder(11)
            builders = Array{GridBuilder,1}([rb, fb])
            # manifest["builders"] = JSON3.write(builders)
            # println(manifest["builders"])
            # builders = JSON3.read(manifest["builders"], Array{GridBuilder,1})
            # @test builders[1] == rb
            # @test builders[2] == fb
            grid = Grid(dims)
            mf = build_grid(rb, manifest, grid)
    
        end
    end
end
