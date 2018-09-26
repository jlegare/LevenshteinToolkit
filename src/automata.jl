using DataStructures

import Base.isless

# ----------------------------------------
# TYPES
# ----------------------------------------

struct Epsilon
end

struct Anything
end

struct AnythingBut
   excluded ::Set{Char}
end

struct NFAState
    seen   ::Int64
    errors ::Int64
end

struct NFA
    word   ::String
    start  ::NFAState
    states ::OrderedDict{NFAState, OrderedDict{Union{Epsilon, Anything, Char}, Set{NFAState}}}
    finals ::Set{NFAState}
end

struct DFAState
   states ::Set{NFAState}
end

struct DFA
    nfa    ::NFA
    start  ::DFAState
    states ::Dict{DFAState, Dict{Union{Char, AnythingBut}, DFAState}}
    finals ::Set{DFAState}
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function dfa(nfa::NFA)
    function ε_closure(initial_states::Set{NFAState})
        states = deepcopy(initial_states)

        while true
            i = length(states)
            for state ∈ states
                if Epsilon() ∈ keys(nfa.states[state])
                    union!(states, nfa.states[state][Epsilon()])
                end
            end

            if length(states) == i
                break
            end
        end

        return Set(states)
    end

    function intern(state::DFAState, states::Dict{DFAState, Tuple{Bool, Dict{Union{Char, AnythingBut}, DFAState}}})
        return (state ∈ keys(states)) ? states[state][2] : state
    end

    function merge!(targets::Dict{Union{Char, AnythingBut}, DFAState})
        for anything_but ∈ keys(targets)
            if typeof(anything_but) == AnythingBut
                for on ∈ filter(on -> on != anything_but, keys(targets))
                    if targets[on].states == targets[anything_but].states
                        delete!(targets, on)
                        if on ∈ anything_but.excluded && 
                            delete!(anything_but.excluded, on)
                        end
                    end
                end
                break
            end
        end

        return nothing # Just being explicit.
    end

    function move(state::NFAState, letter::Char)
        states = Set{NFAState}()

        if letter ∈ keys(nfa.states[state])
            union!(states, nfa.states[state][letter])
        end

        if Anything() ∈ keys(nfa.states[state])
            union!(states, nfa.states[state][Anything()])
        end

        return ε_closure(states)
    end

    function move(state::NFAState, others::AnythingBut)
        states = Set{NFAState}()

        if Anything() ∈ keys(nfa.states[state])
            union!(states, ε_closure(nfa.states[state][Anything()]))
        end

        # If STATE has a transition on a character that is not in AnythingBut, we need to include it here.
        #
        for letter ∈ setdiff(keys(nfa.states[state]), others.excluded)
            if letter == Anything() || letter == Epsilon()
                # EMPTY ... ignore these ones.

            else
                union!(states, ε_closure(nfa.states[state][letter]))
            end
        end

        return states
    end

    function transition(state::DFAState, letter::Char)
        set = Set{NFAState}()

        for nfa_state ∈ state.states
            union!(set, move(nfa_state, letter))
        end

        return DFAState(set)
    end

    function transition(state::DFAState, others::AnythingBut)
        set = Set{NFAState}()

        for nfa_state ∈ state.states
            union!(set, move(nfa_state, others))
        end

        return DFAState(set)
    end


    letters = unique(nfa.word)

    dfa = DFA(nfa, DFAState(ε_closure(Set([ nfa.start ]))), 
              Dict{DFAState, Dict{Union{Char, AnythingBut}, DFAState}}(), Set{DFAState}())

    dfa_states = Dict{DFAState, Tuple{Bool, Dict{Union{Char, AnythingBut}, DFAState}}}()
    dfa_states[dfa.start] = ( false, Dict{Union{Char, AnythingBut}, DFAState}() )

    while true
        targets = Dict{Union{Char, AnythingBut}, DFAState}()
        others  = AnythingBut(Set{Char}(letters))

        dfa_state = findfirst(t -> !t[1], dfa_states)

        if dfa_state == nothing
            break
        end

        for letter ∈ letters
            targets[letter] = intern(transition(dfa_state, letter), dfa_states)
        end
        
        targets[others] = intern(transition(dfa_state, others), dfa_states)

        merge!(targets)

        dfa_states[dfa_state] = ( true, targets )
        for target ∈ targets
            if findfirst(k -> k.states == target[2].states, collect(keys(dfa_states))) == nothing
                dfa_states[target[2]] = ( false, Dict{Union{Char, AnythingBut}, DFAState}() )
            end
        end
    end

    union!(dfa.finals, Set(filter(dfa_state -> !isempty(intersect(dfa_state.states, nfa.finals)), collect(keys(dfa_states)))))

    for dfa_state ∈ keys(dfa_states)
        dfa.states[dfa_state] = Dict{Union{Char, AnythingBut}, DFAState}()
        for on ∈ keys(dfa_states[dfa_state][2])
            dfa.states[dfa_state][on] = dfa_states[dfa_state][2][on]
        end
    end

    return dfa
end


function nfa(word, maximum_error)
    function accept(nfa, state)
        push!(nfa.finals, state)
    end

    function add(nfa, from, on, to)
        if from ∉ keys(nfa.states)
            nfa.states[from] = OrderedDict{Union{Epsilon, Anything, Char}, Set{NFAState}}()
        end

        if to ∉ keys(nfa.states)
            nfa.states[to] = OrderedDict{Union{Epsilon, Anything, Char}, Set{NFAState}}()
        end

        if on ∉ keys(nfa.states[from])
            nfa.states[from][on] = Set{NFAState}()
        end

        push!(nfa.states[from][on], to)
    end

    nfa = NFA(word, NFAState(0, 0), OrderedDict{NFAState, OrderedDict{Union{Epsilon, Anything, Char}, Set{NFAState}}}(),
              Set{NFAState}())

    for ( i, character ) ∈ zip(Iterators.countfrom(0), word)
        for error ∈ 0:maximum_error
            add(nfa, NFAState(i, error), character, NFAState(i + 1, error)) # Correct character.

            if error < maximum_error
                add(nfa, NFAState(i, error), Anything(), NFAState(i, error + 1))     # Delete a character.
                add(nfa, NFAState(i, error), Epsilon(), NFAState(i + 1, error + 1))  # Insert a character.
                add(nfa, NFAState(i, error), Anything(), NFAState(i + 1, error + 1)) # Substitute a character.
            end
        end
    end

    for error ∈ 0:maximum_error
        if error < maximum_error
            add(nfa, NFAState(length(word), error), Anything(), NFAState(length(word), error + 1))
        end

        accept(nfa, NFAState(length(word), error))
    end

    return nfa
end


function draw(state::DFAState, finals::Set{DFAState}, id::Int64)
    drawn = IOBuffer(append = true)

    write(drawn, "   state$(id) [ label=")

    if isempty(state.states)
        write(drawn, "\"∅\"")

    else
        write(drawn, "<")
        for nfa_state ∈ sort(collect(state.states), lt = isless)
            write(drawn, "$(nfa_state.seen)<font point-size=\"11\"><sup>$(nfa_state.errors)</sup></font>")
        end
        write(drawn, ">")
    end

    if state ∈ finals
        write(drawn, " penwidth = 3")
    end

    write(drawn, " ];\n")

    return String(take!(drawn))
end


function draw(state::NFAState, finals::Set{NFAState}, id::Int64)
    return ("   state$(id) [ label=\"($(state.seen), $(state.errors))\""
            * (state ∈ finals ? " penwidth = 3" : "")
            * " ];\n")
end


function draw(on::Char)
    return " label=<<I>$(on)</I>>"
end


function draw(on::Anything)
    return " label=<*>"
end


function draw(on::AnythingBut)
    if isempty(on.excluded)
        return " label=<*>"

    else
        drawn = IOBuffer(append = true)

        write(drawn, " label=< [⌃<I>")
        write(drawn, join(sort(collect(on.excluded))))
        write(drawn, "</I>] >")

        return String(take!(drawn))
    end
end


function draw(on::Epsilon)
    return " label=<&#949;>"
end


function draw(io::IO, nfa::NFA)
    states      = IOBuffer(append = true)
    connections = IOBuffer(append = true)
    ranks       = IOBuffer(append = true)

    index  = Dict{NFAState, Int64}()
    errors = Dict{Int64, Array{NFAState}}()

    for ( i, state ) ∈ enumerate(keys(nfa.states))
        write(states, draw(state, nfa.finals, i))
        index[state] = i
    end

    for ( i, state ) ∈ enumerate(keys(nfa.states))
        for on ∈ keys(nfa.states[state])
            for target ∈ nfa.states[state][on]
                if target ∉ keys(index)
                    k = length(index) + 1
                    index[target] = k

                    write(states, draw(target, nfa.finals, k))
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

    return nothing # Just being explicit.
end


function draw(io::IO, dfa::DFA)
    states      = IOBuffer(append = true)
    connections = IOBuffer(append = true)

    index = Dict{DFAState, Int64}()

    for ( i, state ) ∈ enumerate(keys(dfa.states))
        if !isempty(state.states)
            write(states, draw(state, dfa.finals, i))
        end
        index[state] = i
    end

    for ( i, state ) ∈ enumerate(keys(dfa.states))
        if state ∉ keys(index)
            k = length(index) + 1
            index[state] = k
        end

        for on ∈ keys(dfa.states[state])
            target = dfa.states[state][on]

            if !isempty(target.states)
                k = findfirst(t -> t.states == target.states, collect(keys(index)))
                if k == nothing
                    k = length(index) + 1
                    index[target] = k

                    write(states, draw(target, dfa.finals, k))
                end

                write(connections, "   state$i -> state$k [")
                write(connections, draw(on))
                write(connections, " ];\n")
            end
        end
    end

    write(io, "digraph g {\n")
    write(io, read(connections, String))
    write(io, read(states, String))
    write(io, "}")

    return nothing # Just being explicit.
end


function isless(left::NFAState, right::NFAState)
    return isless(left.seen, right.seen) || (isequal(left.seen, right.seen) && isless(left.errors, right.errors))
end


