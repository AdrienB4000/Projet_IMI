include("production.jl")
include("signal.jl")

#Getting list of existing references times
try
    existing_references = references
catch
    existing_references = read_references_from_file("./references.txt")
finally
    existing_references_times = (x -> sum(x.tasks) ).(existing_references)
end

function naive_strategy(signal::Signal)::Production
    return Production(signal.planning, 60)
end

function sorting_strategy1(signal::Signal)::Production
    y = signal.planning
    return Production( sort(y, by= i -> count(x->x==i, y)) , 60)
end

function sorting_strategy2(signal::Signal)::Production
    y = signal.planning
    return Production( sort(y, by= i -> existing_references_times[y[i]]) , 60)
end
