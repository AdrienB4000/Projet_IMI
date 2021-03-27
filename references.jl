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

function work_needed(ref::Reference)
    return sum(ref.tasks)
end
