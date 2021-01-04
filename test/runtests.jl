using HexWorld
using JSON3
using Test
using StaticArrays


@testset "HexWorld.jl" begin    
    @testset "Cell" begin
        @testset "Conversions between Cell to Cubic" begin
            cell = Cell(12, 232)
            hex = convert(Cubic, cell)
            cell2 = convert(Cell, hex)
            @test cell == cell2
        end
        @testset "Cell Center" begin
            c1 = Cell(1, 1)
            @test c1 !== nothing
            x11, y11 = center_loc(c1)
            @test x11 ≈ 1.0
            @test y11 ≈ sqrt(3) / 2
            x21, y21 = center_loc(Cell(2, 1))
            @test x21 ≈ 3
            @test y21 ≈  sqrt(3)
            x42, y42 = center_loc(Cell(4, 2))
            @test x42 ≈ 7
            @test y42 ≈ 2 * sqrt(3) 
        end
        @testset "Cell Geometry" begin
            c = Cell(4, 3)
            radius = 3
            ring = cell_ring(c, radius)
            @test length(ring) == radius * 6
            # for cell in ring
            #     println(cell)
            # end
        end
    end
    @testset "Cell Data" begin
        cd = CellData(0x1A, 250, SVector{6,UInt8}([0,0,1,0,12,255]))
        pack::UInt64 = pack_cell_data(cd)
        @test cd == CellData(pack)
    end
    
    @testset "Grid" begin
        @testset "Edge Cell" begin
            edges = EdgeCells(q₁ = 4, r₁ = 5)
            c = collect(edges)
            @test length(c) == length(edges)
            @test c[1] == Cell(1, 1)
            @test c[9] == Cell(3, 5)

            edges2 =  EdgeCells(q₀ = 11, q₁ = 14, r₁ = 5)
            c2 = collect(edges2)
            @test length(c2) == length(edges2)
            @test c2[1] == Cell(11, 1)
            @test c2[9] == Cell(13, 5)
            
            edges3 =  EdgeCells(q₀ = 11, r₀ = 21, q₁ = 14, r₁ = 25)
            c3 = collect(edges3)
            @test length(c3) == length(edges3)
            @test c3[1] == Cell(11, 21)
            @test c3[9] == Cell(13, 25)
        end
        @testset "Build a Grid" begin
            manifest = Dict{String,String}()
            dims = GridDims(1_000, 1_000)
            manifest["grid_dim"] = JSON3.write(dims)
            @test dims == JSON3.read(manifest["grid_dim"], GridDims)
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
            cell_types_c = JSON3.read(manifest["materials"], Array{CellMaterial,1})
            @test c1 == cell_types_c[1]
            # NOTE: the standard  c == c' test fails for instances created by the same code
            @test c2.id == cell_types_c[2].id
            @test c2.top_color == cell_types_c[2].top_color
            @test c2.wall_data == cell_types_c[2].wall_data
            
            gb = GeologyBuilder(seed = 42)
            fb = ForestBuilder(11)
            builders = Array{GridBuilder,1}([gb, fb])
            manifest["builders"] = JSON3.write(builders)
            builders = JSON3.read(manifest["builders"], Array{GridBuilder,1})
            @test builders[1] == gb
            @test builders[2] == fb
        end
    end
end
