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
end

function work_needed(ref::Reference)
    return sum(ref.tasks)
end

function work_allocation(ref::Reference, nb_workers::Int)
    # This allocation tries to minimize the maximal time spent by a worker
    # Complexity in 2^nb_workers, to upgrade!
    work_time_per_worker = work_needed(ref)/nb_workers
    if nb_workers == 1
        return ([length(ref.tasks)], [sum(ref.tasks)])
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
