

include("references.jl")
include("production.jl")

function main()
    references = read_references_from_file("./references.txt")
    R = length(references)
    alloc = prod_allocations_by_ref_and_nb_workers(references)
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

main()