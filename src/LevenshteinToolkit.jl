module LevenshteinToolkit

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export distance_matrix
export distance_row
export draw
export nfa

include("matrix.jl")
include("row.jl")
include("automata.jl")

end
