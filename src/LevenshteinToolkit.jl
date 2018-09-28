module LevenshteinToolkit

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export distance_matrix
export distance_row

export dfa
export nfa

export check
export draw

include("matrix.jl")
include("row.jl")
include("automata.jl")

end
