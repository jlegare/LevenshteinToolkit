using DataStructures

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

struct NFA
    word   ::String
    start  ::State
    states ::OrderedDict{State, OrderedDict{Union{Epsilon, Anything, Char}, OrderedSet{State}}}
    finals ::Set{State}
end

struct DFA
    nfa      ::NFA
    alphabet ::Array{Union{Char, Anything}, 1}
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function draw(io::IO, nfa::NFA)
    function draw(state::State, id::Int64)
        return ("   state$(id) [ label=\"($(state.seen), $(state.errors))\""
                * (state ∈ nfa.finals ? " penwidth = 3" : "")
                * " ];\n")
    end

    function draw(on::Char)
        return " label=<<I>$(on)</I>>"
    end

    function draw(on::Anything)
        return " label=<*>"
    end

    function draw(on::Epsilon)
        return " label=<&#949;>"
    end

    states      = IOBuffer(append = true)
    connections = IOBuffer(append = true)
    ranks       = IOBuffer(append = true)

    index  = Dict{State, Int64}()
    errors = Dict{Int64, Array{State}}()

    for ( i, state ) ∈ enumerate(keys(nfa.states))
        write(states, draw(state, i))
        index[state] = i
    end

    for ( i, state ) ∈ enumerate(keys(nfa.states))
        for on ∈ keys(nfa.states[state])
            for target ∈ nfa.states[state][on]
                if target ∉ keys(index)
                    k = length(index) + 1
                    index[target] = k

                    write(states, draw(target, k))
                end

                k = index[target]

                write(connections, "   state$i -> state$k [")
                write(connections, draw(on))
                write(connections, " ];\n")
            end
        end
    end

    # Grouping up nodes on error values can make for a cleaner graph. It should be possible to do this in a more concise
    # fashion, but for now I think this is easier to read.
    #
    for state ∈ keys(index)
        if state.errors ∉ keys(errors)
            errors[state.errors] = [ ]
        end
        push!(errors[state.errors], state)
    end

    for error ∈ keys(errors)
        write(ranks, "   { rank = same;")
        for state ∈ errors[error]
            write(ranks, " state$(index[state]);")
        end
        write(ranks, "}\n")
    end

    write(io, "digraph g {\n")
    write(io, read(connections, String))
    write(io, read(states, String))
    write(io, read(ranks, String))
    write(io, "}")

    return nothing
end


function dfa(nfa::NFA)
    function ε_closure(initial_states::Set{State})
        states = copy(initial_states)

        i = length(states)
        while true
            for state ∈ states
                if Epsilon() ∈ keys(nfa.states[state])
                    union!(states, nfa.states[state][Epsilon()])
                end
            end

            if length(states) == i
                break
            end
            i = length(states)
        end

        return states
    end

    dfa = DFA(nfa, union(sort(unique(nfa.word)), [ Anything() ]))

    start = ε_closure(Set([ nfa.start ]))

    return dfa
end


function nfa(word, maximum_error)
    function accept(nfa, state)
        push!(nfa.finals, state)
    end

    function add(nfa, from, on, to)
        if from ∉ keys(nfa.states)
            nfa.states[from] = OrderedDict{Union{Epsilon, Anything, Char}, OrderedSet{State}}()
        end

        if on ∉ keys(nfa.states[from])
            nfa.states[from][on] = OrderedSet{State}()
        end

        push!(nfa.states[from][on], to)
    end

    nfa = NFA(word, State(0, 0), OrderedDict{State, OrderedDict{Union{Epsilon, Anything, Char}, OrderedSet{State}}}(), Set{State}())

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

