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



function simulation( P::Vector{Production}, actu_prod, nb_employe, vision, ref::Vector{Reference} = references,tc_target::Array{Int64,1}=targets,max_nb_workers::Int64 =max_workers, T=12, tps_simul=tps_simul)
    print("enter")
    prod = deepcopy(P)
    signals =[]
    tps = 1
    #for p in prod
    #    print(nb_employe(p))
    #end
    for t in 1:tps_simul
        new_signal = Signal(T)
        actu_prod(prod::Vector{Production},new_signal)
        employe = []
        for i in 0:vision
            nb = nb_employe(prod[end-i],ref,tc_target,max_nb_workers)
            push!(employe,nb)
        end
        println("instant t ", t, " planning employés ", employe)
    end
end

