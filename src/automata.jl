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
    start  ::State
    states ::OrderedDict{State, OrderedDict{Tuple{Union{Epsilon, Anything, Char}, State}, State}}
    finals ::Set{State}
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
        for ( j, on ) ∈ enumerate(keys(nfa.states[state]))
            if nfa.states[state][on] ∉ keys(index)
                target = nfa.states[state][on]
                k = length(index) + 1
                index[target] = k

                write(states, draw(target, k))
            end

            target = nfa.states[state][on]
            k = index[target]

            write(connections, "   state$i -> state$k [")
            write(connections, draw(on[1]))
            write(connections, " ];\n")
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


function nfa(word, maximum_error)
    function accept(nfa, state)
        push!(nfa.finals, state)
    end

    function add(nfa, from, on, to)
        if from ∉ keys(nfa.states)
            nfa.states[from] = OrderedDict{Tuple{Union{Epsilon, Anything, Char}, State}, State}()
        end

        nfa.states[from][( on, to )] = to
    end

    nfa = NFA(State(0, 0), OrderedDict{State, OrderedDict{Tuple{Union{Epsilon, Anything, Char}, State}, State}}(),
              Set{State}())

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

