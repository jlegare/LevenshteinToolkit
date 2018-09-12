@testset "Cost Row/String" begin
    @test distance_row("ab", "aab", deletion = 2) == 1                # Should go with INSERTION instead of DELETION.
    @test distance_row("ab", "aab", deletion = 2, insertion = 2) == 2 # Could go with either.
    @test distance_row("abc", "bbc", substitution = 2) == 2           # DELETION + INSERTION = SUBSTITUTION
end

@testset "Cost Row/Array" begin
    @test distance_row([ 1 2 ], [ 1 1 2 ], deletion = 2) == 1                # Should go with INSERTION instead of DELETION.
    @test distance_row([ 1 2 ], [ 1 1 2 ], deletion = 2, insertion = 2) == 2 # Could go with either.
    @test distance_row([ 1 2 3 ], [ 2 2 3 ], substitution = 2) == 2          # DELETION + INSERTION = SUBSTITUTION
end
