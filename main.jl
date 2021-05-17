

include("references.jl")
include("production.jl")
include("signal.jl")
include("matching_signal_prod.jl")
include("simulation.jl")
include("simulation_plots.jl")

#git

function main1()
    max_nb_workers = 15
    references = read_references_from_file("./references.txt")
    R = length(references)
    alloc = prod_allocations_by_ref_and_nb_workers(references, max_nb_workers)
    nb_ref_to_produce = 200
    prods = Production(rand(1:R, nb_ref_to_produce))
    nb_workers = 12
    mt1 = make_times_calculation(prods, alloc[:, nb_workers], nb_workers)
    println(prods)
    println(end_time(mt1))
    println(pourcentage_temps_travaille(prods, references, mt1))
    prod_triee = production_equivalente_triee(prods, references)
    mt2 = make_times_calculation(prod_triee, alloc[:, nb_workers], nb_workers)
    println(prod_triee)
    println(end_time(mt2))
    println(pourcentage_temps_travaille(prod_triee, references, mt2))
    prod_triee_rev = production_equivalente_triee(prods, references, true)
    mt3 = make_times_calculation(prod_triee_rev, alloc[:, nb_workers], nb_workers)
    println(prod_triee_rev)
    println(end_time(mt3))
    println(pourcentage_temps_travaille(prod_triee_rev, references, mt3))
end

function main()
    # max_nb_workers = max_workers
    prod_init = [Production(rand(1:R, nb_ref_unite_tps),1) for i in 1:12]
    println(length(prod_init))
    stocks_simul, production_simul, signaux_simul, staffing = simulation(prod_init, actu_prod_sort, nb_employe_USINE, 6)
    return stocks_simul
end
