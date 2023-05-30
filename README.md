# MattTan-FBA-Calculations
Flux Balance Analysis calculations for the Matt Tan problem

## Installation 
This code requires [Julia](https://julialang.org/downloads/) version `1.9.x` or above. In addition, it uses several external packages. To install these packages, start the [REPL](https://docs.julialang.org/en/v1/stdlib/REPL/), e.g., from a Terminal window in [VSCode](https://code.visualstudio.com/download) in the root directory of the project (same directory as `Include.jl`) and issue the command:

```
julia> include("Include.jl")
```

This will download and compile the packages required for the project.

## Simulations
* The `runme-ctrl.jl` script will estimate the fluxes for the `0-48hr` window in the control case. The constraint file for this case is `FluxData-0-48-hr-v4-CTRL.csv`. Results are saved into the `sims` folder.
* The `runme-hcm.jl` script will estimate the fluxes for the `0-48hr` window in the control case. The constraint file for this case is `FluxData-0-48-hr-v4-HCM.csv`. Results are saved into the `sims` folder.


## Funding
The work described was supported by the [Center on the Physics of Cancer Metabolism at Cornell University](https://psoc.engineering.cornell.edu) through Award Number 1U54CA210184-01 from the [National Cancer Institute](https://www.cancer.gov). The content is solely the responsibility of the authors and does not necessarily represent the official views of the [National Cancer Institute](https://www.cancer.gov) or the [National Institutes of Health](https://www.nih.gov).