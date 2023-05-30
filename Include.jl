# setup paths -
const _ROOT = pwd();
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_MODEL = joinpath(_ROOT, "model");
const _PATH_TO_SIMS = joinpath(_ROOT, "sims");

# load external packages -
import Pkg; Pkg.activate("."); Pkg.instantiate();
using JuMP
using GLPK
using Distributions
using Statistics
using LinearAlgebra
using MAT
using JSON
using CSV
using DataFrames
using MathOptInterface
using Logging

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Files.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Compute.jl"))
include(joinpath(_PATH_TO_SRC, "Utility.jl"))
