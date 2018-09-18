module LevenshteinToolkit

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export distance_matrix
export distance_row
export nfa

include("matrix.jl")
include("row.jl")
include("nfa.jl")

end
