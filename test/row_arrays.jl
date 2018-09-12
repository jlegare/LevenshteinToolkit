@testset "Sanity Row/Array" begin
    @test distance_row([ ], [ ]) == 0

    @testset "Sanity Row/Array/Left" begin
        @test distance_row([ 1 ], [ ])     == 1
        @test distance_row([ 1 2 ], [ ])   == 2
        @test distance_row([ 1 2 3 ], [ ]) == 3
    end

    @testset "Sanity Row/Array/Right" begin
        @test distance_row([ ], [ 1 ])     == 1
        @test distance_row([ ], [ 1 2 ])   == 2
        @test distance_row([ ], [ 1 2 3 ]) == 3
    end

    @testset "Sanity Row/Array/Both" begin
        @test distance_row([ 1 ], [ 1 ])         == 0
        @test distance_row([ 1 ], [ 2 ])         == 1
        @test distance_row([ 1 2 ], [ 2 2 ])     == 1
        @test distance_row([ 1 2 3 ], [ 2 2 3 ]) == 1
        @test distance_row([ 1 2 3 ], [ 1 2 2 ]) == 1
    end
end
