struct Reference
    number::Int
    tasks::Vector{Int}

    Reference(n, tasks)=new(n, tasks)
    Reference(n)=new(n, Int[])
end

function write_references_to_file(refs::Vector{Reference}, path::String)
    R=length(refs)
    str = "R $R"
    for ref in refs
        str *= "\n" * "r $(ref.number) t "
        for task in ref.tasks
            str *= "$task "
        end
    end
    open(path, "w") do file
        write(file, str)
    end
    return true
end

function read_reference_from_string(line::String)::Reference
    line_split = split(line)
    r = Reference(parse(Int, line_split[2]), parse.(Float64, line_split[4:end]))
    return r
end

function read_references_from_file(path::String)::Vector{Reference}
    data = open(path) do file
        readlines(file)
    end
    R = parse(Int, split(data[1])[2])
    references = [read_reference_from_string(data[i]) for i in 2:(1+R)]
    return references
end

function add_reference_to_file(ref::Reference, path::String)
    references = read_references_from_file(path)
    append!(references, [ref])
    write_references_to_file(references, path)
    return true
end

function work_needed(ref::Reference)::Int
    return sum(ref.tasks)
end

function work_allocation(ref::Reference, nb_workers::Int)::Tuple{Vector{Int}, Vector{Int}}
    # This allocation tries to minimize the maximal time spent by a worker
    # Complexity in 2^nb_workers, to upgrade!
    work_time_per_worker = work_needed(ref)/nb_workers
    if nb_workers == 1
        return ([length(ref.tasks)], [sum(ref.tasks)])
    elseif length(ref.tasks) == 0
        return (zeros(Int, nb_workers), zeros(Int, nb_workers))
    else
        first_separator = 0
        correspondant_work = 0
        while correspondant_work < work_time_per_worker
            first_separator += 1
            correspondant_work += ref.tasks[first_separator]
        end
        allocation1 = work_allocation(Reference(ref.number, ref.tasks[first_separator:end]), nb_workers-1)
        separators1 = append!([first_separator-1], allocation1[1])

        times_1 = append!([sum(ref.tasks[1:first_separator-1])], allocation1[2])
        allocation2 = work_allocation(Reference(ref.number, ref.tasks[first_separator+1:end]), nb_workers-1)
        separators2 = append!([first_separator], allocation2[1])
        times_2 = append!([sum(ref.tasks[1:first_separator])], allocation2[2])
        if maximum(times_1) < maximum(times_2)
            return separators1, times_1
        else
            return separators2, times_2
        end
    end
end

function prod_allocations_by_ref_and_nb_workers(references::Vector{Reference})::Array{Array{Int, 1}, 2}
    R = length(references)
    max_nb_workers = 15
    prod_allocations = Array{Array{Int, 1}, 2}(undef, R, max_nb_workers)
    for ref in 1:R
        for nb_workers in 1:max_nb_workers
            prod_allocations[ref, nb_workers] = work_allocation(references[ref], nb_workers)[2]
        end
    end
    return prod_allocations
end

function prod_allocations_cycle_time(references::Vector{Reference}, tc_target::Array{Int64,1})
    R = length(references)
    max_nb_workers = 15
    prod_allocations = prod_allocations_by_ref_and_nb_workers(references)
    prod_allocations_ttc = Array{Array{Int64, 1}, 1}(undef, R)
    ref_nb_workers = Array{Int64, 1}(undef, R)

    for ref in 1:R
        nb_workers = 1
        target_reached = 0
        while target_reached == 0 && nb_workers <= max_nb_workers
            if maximum(prod_allocations[ref,nb_workers]) <= tc_target[ref]
                prod_allocations_ttc[ref] = prod_allocations[ref,nb_workers]
                ref_nb_workers[ref] = nb_workers
                target_reached = 1
            else
                nb_workers += 1
            end
        end
    end
    return prod_allocations_ttc, ref_nb_workers
end
