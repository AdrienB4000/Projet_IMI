include("production.jl")
include("signal.jl")
include("references.jl")

#Getting list of existing references times


function naive_strategy(signal::Signal)::Production
    return Production(signal.planning, 1)
end

function sorting_strategy1(signal::Signal)::Production
    y = signal.planning
    return Production( sort(y, by= i -> count(x->x==i, y)) , 60)
end

function sorting_strategy2(signal::Signal)::Production
    y = signal.planning
    return Production( sort(y, by= i -> existing_references_times[y[i]]) , 60)
end

function actu_prod_USINE(prod::Vector{Production},new_signal::Signal, T=12)
    P = deepcopy(prod)
    new_prod = naive_strategy(new_signal)
    push!(P,new_prod)
    return P
end
