include("references.jl")
include("production.jl")

function main()
    references = read_references_from_file("./references.txt")
    R = length(references)
    alloc = prod_allocations_by_ref_and_nb_workers(references)
    prods = Production(rand(1:R, 150))
    nb_workers = 10
    make_times_calculation(prods, alloc[:, nb_workers], nb_workers)
    check_time(prods, alloc[:, nb_workers], nb_workers)
end
