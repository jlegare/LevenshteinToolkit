using LevenshteinToolkit
using Test

tests = [ "matrix_strings", "row_strings",
          "matrix_arrays",  "row_arrays",
          "matrix_costs",   "row_costs",
          "matrix_stress",  "row_stress" ]

for test ∈ tests
    include("$test.jl")
end

