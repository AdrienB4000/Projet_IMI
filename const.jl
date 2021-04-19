#=
const:
- Julia version: 1.6.0
- Author: cgris
- Date: 2021-04-19
=#

include("references.jl")

const nb_ref_unite_tps = 100
const tps_simul = 144 #unité de temps (heure)
const max_workers = 10
const references = read_references_from_file("./references.txt")
const R = length(references)
const targets = rand(25:35,R)