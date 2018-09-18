# ----------------------------------------
# TYPES
# ----------------------------------------

struct Epsilon
end

struct Anything
end

struct State
    seen   ::Int64
    errors ::Int64
end

struct Transition
    from ::State
    on   ::Union{Epsilon, Anything, Char}
    to   ::State
end

struct NFA
    start       ::State
    transitions ::Set{Transition}
    finals      ::Set{State}
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function nfa(word, maximum_error)
    function accept(nfa, state)
        push!(nfa.finals, state)
    end

    function add(nfa, from, on, to)
        push!(nfa.transitions, Transition(from, on, to))
    end

    nfa = NFA(State(0, 0), Set{Transition}(), Set{State}())

    for ( i, character ) ∈ zip(Iterators.countfrom(0), word)
        for error ∈ 0:maximum_error
            add(nfa, State(i, error), character, State(i + 1, error)) # Correct character.

            if error < maximum_error
                add(nfa, State(i, error), Anything(), State(i, error + 1))     # Delete a character.
                add(nfa, State(i, error), Epsilon(), State(i + 1, error + 1))  # Insert a character.
                add(nfa, State(i, error), Anything(), State(i + 1, error + 1)) # Substitute a character.
            end
        end
    end

    for error ∈ 0:maximum_error
        if error < maximum_error
            add(nfa, State(length(word), error), Anything(), State(length(word), error + 1))
        end

        accept(nfa, State(length(word), error))
    end

    return nfa
end

