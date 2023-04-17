include("../Include.jl")

# load biophys constants -
path_to_biophys_file = joinpath(_PATH_TO_DATA, "default_bacteria.json")
bd = JSON.parsefile(path_to_biophys_file);

(vmax,_) = calculate_default_vmax(bd)