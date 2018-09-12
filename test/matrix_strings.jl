@testset "Sanity Matrix/String" begin
    @test distance_matrix("", "")    == 0

    @testset "Sanity Matrix/String/Left" begin
        @test distance_matrix("a", "")   == 1
        @test distance_matrix("ab", "")  == 2
        @test distance_matrix("abc", "") == 3
    end

    @testset "Sanity Matrix/String/Right" begin
        @test distance_matrix("", "a")   == 1
        @test distance_matrix("", "ab")  == 2
        @test distance_matrix("", "abc") == 3
    end

    @testset "Sanity Matrix/String/Both" begin
        @test distance_matrix("a", "a")     == 0
        @test distance_matrix("a", "b")     == 1
        @test distance_matrix("ab", "bb")   == 1
        @test distance_matrix("abc", "bbc") == 1
        @test distance_matrix("abc", "abb") == 1
    end
end

