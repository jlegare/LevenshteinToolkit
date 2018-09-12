@testset "Sanity Matrix/Array" begin
    @test distance_matrix([ ], [ ]) == 0

    @testset "Sanity Matrix/Array/Left" begin
        @test distance_matrix([ 1 ], [ ])     == 1
        @test distance_matrix([ 1 2 ], [ ])   == 2
        @test distance_matrix([ 1 2 3 ], [ ]) == 3
    end

    @testset "Sanity Matrix/Array/Right" begin
        @test distance_matrix([ ], [ 1 ])     == 1
        @test distance_matrix([ ], [ 1 2 ])   == 2
        @test distance_matrix([ ], [ 1 2 3 ]) == 3
    end

    @testset "Sanity Matrix/Array/Both" begin
        @test distance_matrix([ 1 ], [ 1 ])         == 0
        @test distance_matrix([ 1 ], [ 2 ])         == 1
        @test distance_matrix([ 1 2 ], [ 2 2 ])     == 1
        @test distance_matrix([ 1 2 3 ], [ 2 2 3 ]) == 1
        @test distance_matrix([ 1 2 3 ], [ 1 2 2 ]) == 1
    end
end

