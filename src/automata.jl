using DataStructures

import Base.isless
import Base.==

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
    index       ::Int64
    nfa_states  ::Set{NFAState}
    transitions ::Array{Tuple{Union{Char, AnythingBut}, Int64}}
end

struct DFA
    nfa    ::NFA
    start  ::DFAState
    states ::Array{DFAState}
    finals ::Set{DFAState}
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function ==(left::NFAState, right::NFAState)
    return left.seen == right.seen && left.errors == right.errors
end


function isless(left::NFAState, right::NFAState)
    return isless(left.seen, right.seen) || (isequal(left.seen, right.seen) && isless(left.errors, right.errors))
end


function DFAState(nfa_states::Set{NFAState})
    return DFAState(-1, nfa_states, [ ])
end


function DFAState(index::Int64, nfa_states::Set{NFAState})
    return DFAState(index, nfa_states, [ ])
end


function DFAState(dfa_state::DFAState, transitions::Array{Tuple{Union{Char, AnythingBut}, Int64}})
    return DFAState(dfa_state.index, dfa_state.nfa_states, transitions)
end


function check(dfa::DFA, word::String)
    function accepts(transition::Tuple{Char, Int64}, character::Char)
        return transition[1] == character
    end

    function accepts(transition::Tuple{AnythingBut, Int64}, character::Char)
        return character ∉ transition[1].excluded
    end

    state = dfa.start

    for character ∈ word
        for transition ∈ state.transitions
            if accepts(transition, character)
                state = dfa.states[transition[2]]
            end
        end
    end

    return state ∈ dfa.finals
end


function dfa(nfa::NFA)
    function ε_closure(initial_states::Set{NFAState})
        nfa_states = deepcopy(initial_states)

        while true
            i = length(nfa_states)
            for nfa_state ∈ nfa_states
                if Epsilon() ∈ keys(nfa.states[nfa_state])
                    union!(nfa_states, nfa.states[nfa_state][Epsilon()])
                end
            end

            if length(nfa_states) == i
                break
            end
        end

        return Set(nfa_states)
    end

    function intern!(original::DFAState, work_items::Array{Tuple{Bool, DFAState}, 1})::Int64
        offset = findfirst(t -> t[2].nfa_states == original.nfa_states, work_items)

        if offset == nothing
            interned = DFAState(length(work_items) + 1, original.nfa_states)

            push!(work_items, ( false, interned ))

            return interned.index

        else
            return offset
        end
    end

    function merge(original_transitions::Array{Tuple{Union{Char, AnythingBut}, Int64}})
        anything_but_transitions = filter(t -> typeof(t[1]) == AnythingBut, original_transitions)
        updated_transitions      = Array{Tuple{Union{Char, AnythingBut}, Int64}, 1}()

        if !isempty(anything_but_transitions)
            anything_but        = anything_but_transitions[1][1]
            anything_but_target = anything_but_transitions[1][2]

            for ( index, ( character, target ) ) ∈ enumerate(original_transitions)
                if character != anything_but && target == anything_but_target
                    delete!(anything_but.excluded, character)

                else
                    push!(updated_transitions, ( character, target ))
                end
            end
        end                        

        return updated_transitions
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

    function transition(dfa_state::DFAState, character::Char)
        set = Set{NFAState}()

        for nfa_state ∈ dfa_state.nfa_states
            union!(set, move(nfa_state, character))
        end

        return DFAState(set)
    end

    function transition(dfa_state::DFAState, others::AnythingBut)
        set = Set{NFAState}()

        for nfa_state ∈ dfa_state.nfa_states
            union!(set, move(nfa_state, others))
        end

        return DFAState(set)
    end

    characters = unique(nfa.word) # There isn't really any point in sorting them ... all it would accomplish is make the
                                  # output prettier.

    work_items = Array{Tuple{Bool, DFAState}, 1}()

    # Prime the process with the START state. Notice that the index of the START state is necessarily 1 because of this.
    #
    push!(work_items, ( false, DFAState(length(work_items) + 1, ε_closure(Set([ nfa.start ]))) ))

    index = 1

    while true
        index = findnext(t -> !t[1], work_items, index::Int64)

        if index == nothing
            break

        else
            transitions = Array{Tuple{Union{Char, AnythingBut}, Int64}, 1}()
            others      = AnythingBut(Set{Char}(characters))

            dfa_state = work_items[index][2]

            for character ∈ characters
                push!(transitions, ( character, intern!(transition(dfa_state, character), work_items) ))
            end
            push!(transitions, ( others, intern!(transition(dfa_state, others), work_items) ))

            dfa_state = DFAState(dfa_state, merge(transitions))
            work_items[index] = ( true, dfa_state )
        end
    end

    dfa_states = collect(map(t -> t[2], work_items))
    dfa_finals = Set(filter(dfa_state -> !isempty(intersect(dfa_state.nfa_states, nfa.finals)), dfa_states))

    return DFA(nfa, dfa_states[1], dfa_states, dfa_finals)
end


function nfa(word, maximum_error::Int64)
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

    automaton = NFA(word, NFAState(0, 0), OrderedDict{NFAState, OrderedDict{Union{Epsilon, Anything, Char}, Set{NFAState}}}(),
                    Set{NFAState}())

    for ( i, character ) ∈ zip(Iterators.countfrom(0), word)
        for error ∈ 0:maximum_error
            add(automaton, NFAState(i, error), character, NFAState(i + 1, error)) # Correct character.

            if error < maximum_error
                add(automaton, NFAState(i, error), Anything(), NFAState(i, error + 1))     # Delete a character.
                add(automaton, NFAState(i, error), Epsilon(), NFAState(i + 1, error + 1))  # Insert a character.
                add(automaton, NFAState(i, error), Anything(), NFAState(i + 1, error + 1)) # Substitute a character.
            end
        end
    end

    for error ∈ 0:maximum_error
        if error < maximum_error
            add(automaton, NFAState(length(word), error), Anything(), NFAState(length(word), error + 1))
        end

        accept(automaton, NFAState(length(word), error))
    end

    return automaton
end


function draw(dfa_state::DFAState, dfa_finals::Set{DFAState})
    drawn = IOBuffer(append = true)

    write(drawn, "   state$(dfa_state.index) [ label=")

    if isempty(dfa_state.nfa_states)
        write(drawn, "\"∅\"")

    else
        write(drawn, "<")
        for nfa_state ∈ sort(collect(dfa_state.nfa_states), lt = isless)
            write(drawn, "$(nfa_state.seen)<font point-size=\"11\"><sup>$(nfa_state.errors)</sup></font>")
        end
        write(drawn, ">")
    end

    if dfa_state ∈ dfa_finals
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

    for ( source, dfa_state ) ∈ enumerate(dfa.states)
        if !isempty(dfa.states[source].nfa_states)
            write(states, draw(dfa.states[source], dfa.finals))
        end

        for ( character, target ) ∈ dfa_state.transitions
            if !isempty(dfa.states[target].nfa_states)
                write(connections, "   state$(source) -> state$(target) [")
                write(connections, draw(character))
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


