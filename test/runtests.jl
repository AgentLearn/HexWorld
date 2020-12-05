using HexWorld
using JSON3
using Test
using StaticArrays


@testset "HexWorld.jl" begin    
    @testset "Cell Geometry" begin
        @testset "Conversions between Cell to Cube" begin
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
    @testset "Cell Data" begin
        cd = CellData(1, 250, SVector{6,UInt8}([0,0,1,0,12,255]))
        pack::UInt64 = pack_cell_data(cd)
        @test cd == CellData(pack)
    end
    
    @testset "Grid" begin
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
            
            gb = GeologyBuilder(42)
            fb = ForestBuilder(11)
            builders = Array{GridBuilder,1}([gb, fb])
            manifest["builders"] = JSON3.write(builders)
            builders = JSON3.read(manifest["builders"], Array{GridBuilder,1})
            @test builders[1] == gb
            @test builders[2] == fb
        end
    end
end
