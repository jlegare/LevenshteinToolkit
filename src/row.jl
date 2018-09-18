# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function distance_row(left, right; deletion = 1, insertion = 1, substitution = 1)
    function complete(left, right)
        previous = Array{Int64}(undef, length(right) + 1)
        current  = Array{Int64}(undef, length(right) + 1)

        for r ∈ 1:length(right) + 1
            @inbounds previous[r] = (r - 1) * insertion
        end

        for l ∈ 1:length(left)
            @inbounds current[1] = l * deletion

            for r ∈ 1:length(right)
                @inbounds current[r + 1] = min(previous[r + 1] + deletion,
                                               current[r] + insertion,
                                               previous[r] + (left[l] == right[r] ? 0 : substitution))
            end

            ( previous, current ) = ( current, previous )
        end

        return previous
    end

    if length(left) == 0
        return length(right)

    elseif length(right) == 0
        return length(left)

    else
        return complete(left, right)[end]
    end
end
