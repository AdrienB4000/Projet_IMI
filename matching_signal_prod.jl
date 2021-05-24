include("production.jl")
include("signal.jl")
include("references.jl")
include("stocks.jl")

#Getting list of existing references times


function naive_strategy(signal::Signal)::Production
    return Production(signal.planning, 1)
end

function sorting_strategy1(signal::Signal)::Production
    y = signal.planning
    return Production(sort(y, by= i -> -count(x->x==i, y)), 60)
end

function sorting_strategy2(signal::Signal)::Production
    y = signal.planning
    return Production( sort(y, by= i -> existing_references_times[y[i]]) , 60)
end

function actu_prod_USINE(prod::Vector{Production},new_signal::Signal, stocks_init::Stocks, T=12)
    P = deepcopy(prod)
    new_prod = naive_strategy(new_signal)
    append!(P,[new_prod])
    return P
end

function sorting_strategy_occurences(prod_cumulee_a_trier, next_prod)
    sort!(next_prod, by = i -> (-count(x->x==i, next_prod), i))
    if length(next_prod)>0
        last_time_protected = work_needed(references[next_prod[end]])
        sort!(prod_cumulee_a_trier, by = i -> (abs(last_time_protected - work_needed(references[prod_cumulee_a_trier[i]])), i))
        append!(next_prod, prod_cumulee_a_trier)
    else
        sort!(prod_cumulee_a_trier, by = i -> (-count(x->x==i, next_prod), i))
        append!(next_prod, prod_cumulee_a_trier)
    end
end

function sorting_strategy_duration(prod_cumulee_a_trier, next_prod)
    sort!(next_prod, by = i-> work_needed(references[i]))
    if length(next_prod)>0
        last_time_protected = work_needed(references[next_prod[end]])
        sort!(prod_cumulee_a_trier, by = i -> (abs(last_time_protected - work_needed(references[i])), i))
        append!(next_prod, prod_cumulee_a_trier)
    else
        work_needed_by_ref = [work_needed(r) for r in references]
        sort!(work_needed_by_ref)
        min_work_needed = work_needed_by_ref[1]
        max_work_needed = work_needed_by_ref[end]
        beginning_work_needed = rand(min_work_needed:max_work_needed)
        sort!(prod_cumulee_a_trier, by = i -> (abs(beginning_work_needed-work_needed(references[i])), i))
        append!(next_prod, prod_cumulee_a_trier)
    end
end
#print(actu_prod_USINE([Production([1]) for i in 1:12], Signal(1)))

function actu_prod_sort(prod::Vector{Production},signals::Vector{Signal},
    stocks_init::Stocks, vision::Int, sorting_strategy = sorting_strategy_occurences)
    new_prod_bloquee = prod[1:vision-1]
    prod_cumulee_a_trier = Int[]
    for k in vision:length(prod)
        append!(prod_cumulee_a_trier, prod[k].planning)
    end
    append!(prod_cumulee_a_trier, signals[end].planning)
    #On met déjà dans la prod qu'on bloque les réfs obligatoires
    stock = deepcopy(stocks_init)
    for k in 1:length(new_prod_bloquee)
        stock = Compute_Stocks_at_T_plus_1(signals[k], new_prod_bloquee[k], stock, R)
    end
    stock = Compute_Stocks_at_T_plus_1(signals[vision], Production(Int[]), stock, R)
    refs_manquantes = findall(x -> x<0, stock.stocks)
    if sum(-stock.stocks[refs_manquantes])>nb_ref_unite_tps
        println("Gros problème de simulation")
    end
    next_prod = [i for i in refs_manquantes for j in 1:-stock.stocks[i]]
    for k in next_prod
        deleteat!(prod_cumulee_a_trier, findfirst(x -> x==k, prod_cumulee_a_trier))
    end
    sorting_strategy(prod_cumulee_a_trier, next_prod)
    next_prods = [next_prod[(i-1)*nb_ref_unite_tps+1:i*nb_ref_unite_tps]
                  for i in 1:div(length(next_prod), nb_ref_unite_tps)]
    next_prods = [Production(planning) for planning in next_prods]
    append!(new_prod_bloquee, next_prods)
    return new_prod_bloquee
end
