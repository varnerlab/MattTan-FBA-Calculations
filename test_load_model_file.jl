# include the include -
include("Include.jl")

# setup path to model file -
path_to_model_file = joinpath(_PATH_TO_MODEL, "CoreCancerModel_v1.mat");
model_dict = model(path_to_model_file);

