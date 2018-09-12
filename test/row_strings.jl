@testset "Sanity Row/String" begin
    @test distance_row("", "")    == 0

    @testset "Sanity Row/String/Left" begin
        @test distance_row("a", "")   == 1
        @test distance_row("ab", "")  == 2
        @test distance_row("abc", "") == 3
    end

    @testset "Sanity Row/String/Right" begin
        @test distance_row("", "a")   == 1
        @test distance_row("", "ab")  == 2
        @test distance_row("", "abc") == 3
    end

    @testset "Sanity Row/String/Both" begin
        @test distance_row("a", "a")     == 0
        @test distance_row("a", "b")     == 1
        @test distance_row("ab", "bb")   == 1
        @test distance_row("abc", "bbc") == 1
        @test distance_row("abc", "abb") == 1
    end
end

