include("Include.jl")

# load the measurements file -
path_to_measurements_file = joinpath(_PATH_TO_DATA, "FluxData-24-48-hr.csv")
df = measurements(path_to_measurements_file)