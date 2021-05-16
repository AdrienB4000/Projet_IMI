#=
simulation:
- Julia version: 1.6.0
- Author: cgris
- Date: 2021-04-12
=#

include("references.jl")
include("production.jl")
include("signal.jl")
include("matching_signal_prod.jl")
include("stocks.jl")



function simulation(P::Vector{Production}, actu_prod, nb_employe, vision, ref::Vector{Reference} = references,tc_target::Array{Int64,1}=targets,max_nb_workers::Int64 =max_workers, T=12, tps_simul=tps_simul)
    prod = deepcopy(P)
    signals =[]
    tps = 1
    tab_ttc = prod_allocations_cycle_time(ref,tc_target,max_workers)
    stock = Stocks(zeros(R), 0)
    signals = [Signal(P[i].planning, 1) for i in 1:T]
    #for p in prod
    #    print(nb_employe(p))
    #end
    for t in 1:tps_simul
        println("t ", t , " stock ", stock.stocks)
        last_prod = prod[1]
        last_signal = signals[1]
        println("Production de l'heure : ", last_prod)
        println("Demande de l'heure : ", last_signal)
        stock = Compute_Stocks_at_T_plus_1(last_signal, last_prod, stock, R)
        deleteat!(prod,1)
        deleteat!(signals,1)

        new_signal = Signal(rand(1:R, nb_ref_unite_tps), 1)
        push!(signals,new_signal)
        prod = actu_prod(prod::Vector{Production}, signals, stock, vision, sorting_strategy_duration)
        employe = []
        for i in 1:vision
            nb = nb_employe(prod[i],tab_ttc)
            push!(employe,nb)
        end
        println("instant t ", t, " planning employés ", employe)
        println("taille ", length(signals))
    end
end
