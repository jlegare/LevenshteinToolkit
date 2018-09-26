## LevenshteinToolkit

[![Build Status](https://travis-ci.com/jlegare/LevenshteinToolkit.svg?branch=master)](https://travis-ci.com/jlegare/LevenshteinToolkit)
[![Coverage Status](https://coveralls.io/repos/github/jlegare/LevenshteinToolkit/badge.svg?branch=master)](https://coveralls.io/github/jlegare/LevenshteinToolkit?branch=master)

This is a sandbox of [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) implementations. 

```julia
using LevenshteinToolkit

distance_matrix("Saturday", "Sunday")
# ==> 3

distance_row("Saturday", "Sunday")
# ==> 3
```

The ``distance_matrix`` function will compute the Levenshtein distance between two strings by building a matrix of distances between the prefixes. The costs associated with deletion, insertion, and substitution can be tailored using the keyword arguments. The ``distance_row`` function is similar, but only keeps two matrix rows, thereby reducing the memory footprint. 

The ``nfa`` function builds a [non-deterministic finite automaton](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton) (NFA) that recognizes the set of words that are within a given Levenshtein distance from a word:

```julia
nfa_automaton = nfa("food", 2)
```

The ``draw`` function can be used to generate a [GraphViz](https://www.graphviz.org/) input file:

```julia
open(f -> draw(f, nfa_automaton), "nfa.dot", "w")
```
The resulting file can be rendered using the ``dot`` command-line tool:
```bash
dot -Tsvg nfa.dot -o nfa.svg
```

The ``dfa`` function builds a [deterministic finite automaton](https://en.wikipedia.org/wiki/Deterministic_finite_automaton) (DFA) from an NFA. 
```julia
dfa_automaton = dfa(nfa_automaton)
```
As for the case of NFAs, the ``draw`` function can be used to generate a GraphViz input file. 

