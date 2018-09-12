@testset "Cost Matrix/String" begin
    @test distance_matrix("ab", "aab", deletion = 2) == 1                # Should go with INSERTION instead of DELETION.
    @test distance_matrix("ab", "aab", deletion = 2, insertion = 2) == 2 # Could go with either.
    @test distance_matrix("abc", "bbc", substitution = 2) == 2           # DELETION + INSERTION = SUBSTITUTION
end

@testset "Cost Matrix/Array" begin
    @test distance_matrix([ 1 2 ], [ 1 1 2 ], deletion = 2) == 1                # Should go with INSERTION instead of DELETION.
    @test distance_matrix([ 1 2 ], [ 1 1 2 ], deletion = 2, insertion = 2) == 2 # Could go with either.
    @test distance_matrix([ 1 2 3 ], [ 2 2 3 ], substitution = 2) == 2          # DELETION + INSERTION = SUBSTITUTION
end
