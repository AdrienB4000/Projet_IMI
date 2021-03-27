include("references.jl")
using StatsBase

struct Production
    planning::Vector{Int}
    time_to_produce::Int

    Production(planning, time_to_produce)=new(planning, time_to_produce)
    Production(planning)=new(planning, 60)
end

function check_needs(needs::Vector{Int}, prod::Production)::Bool
    cum_prods = countmap(prod.planning)
    for key in keys(cum_prods)
        if needs[key] > cum_prods[key]
            return false
        end
    end
    return true
end

function make_times_calculation(prod::Production, prod_allocations::Array{Array{Int, 1}, 1}, nb_workers::Int)::Array{Int, 2}
    make_times = Array{Int, 2}(undef, length(prod.planning),nb_workers)
    make_times[1, :] = cumsum(prod_allocations[prod.planning[1]])
    for p in 2:length(prod.planning)
        make_times[p, 1] = max(make_times[p-1, 2],
                               make_times[p-1, 1] + prod_allocations[prod.planning[p]][1])
        for n in 2:nb_workers-1
            make_times[p, n] = max(make_times[p-1, n+1],
                                   max(make_times[p, n-1], make_times[p-1, n]) + prod_allocations[prod.planning[p]][n])
        end
        make_times[p, nb_workers] = max(make_times[p, nb_workers-1], make_times[p-1, nb_workers]) + prod_allocations[prod.planning[p]][nb_workers]
    end
    return make_times
end

function check_time(prod::Production, prod_allocations::Array{Array{Int, 1}, 1}, nb_workers::Int)::Bool
    make_times = make_times_calculation(prod, prod_allocations, nb_workers)
    return make_times[length(prod.planning), nb_workers]/60 < prod.time_to_produce
end
