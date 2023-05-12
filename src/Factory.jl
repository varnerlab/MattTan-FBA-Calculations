function _build_stoichiometric_matrix(data::Dict{String,Any}; biomassfile::String="MDA_MB_231_ATCC-Biomass.csv")

    # initialize -
    S = Matrix(data["S"]);
    (number_of_species, _ ) = size(S)
    biomass_eqn = zeros(number_of_species)

    # load the biomass components dictionary -
    biomass_component_dictionary = _load_biomass_components_dict(joinpath(_PATH_TO_MODEL,biomassfile));

    # process each biomass component -
    for (component,stcoeff) ∈ biomass_component_dictionary

        # ok, so now we need to find the index of this component -
        index_of_species = find_index_of_species(data["mets"], component)

        # update the entry in the biomass_eqn -
        biomass_eqn[index_of_species] = stcoeff
    end

    # add the new *column* to the stoichometric array -
    stoichiometric_matrix = [S biomass_eqn]

    # return -
    return stoichiometric_matrix;
end

function _build_list_of_reactions(data::Dict{String,Any})::Array{String,1}

    # initialize -
    list_of_reactions = Array{String,1}();
    reactions = data["rxns"];

    # get rxns from the data -
    for reaction_symbol ∈ reactions
        push!(list_of_reactions,string(reaction_symbol))
    end

    # add growth to the end -
    push!(list_of_reactions,"growth")

    # return -
    return list_of_reactions
end

function _build_bounds_array(data::Dict{String,Any})::Array{Float64,2}

    # initialize -
    list_of_reactions = data["rxns"];
    number_of_reactions = length(list_of_reactions) + 1; # we add an extra reaction for cellmass 
    default_vmax = 170.37673846153842; # computed from biophys dictionary 

    # default flux bounds array -
    default_flux_bounds_array = zeros(number_of_reactions,2)
    lb = data["lb"] # lower bound -
    ub = data["ub"] # upper bound -
    for reaction_index = 1:number_of_reactions - 1
        default_flux_bounds_array[reaction_index,1] = lb[reaction_index]
        default_flux_bounds_array[reaction_index,2] = ub[reaction_index]
    end

    # add default growth rate constraint?
    default_flux_bounds_array[end,1] = 0.0
    default_flux_bounds_array[end,2] = 1.0

    (number_of_bounds, number_of_cols) = size(default_flux_bounds_array)
    flux_bounds_array = zeros(number_of_bounds,2)
    for bound_index = 1:number_of_bounds
        
        lower_bound = default_flux_bounds_array[bound_index,1]
        upper_bound = default_flux_bounds_array[bound_index,2]

        if (lower_bound!=0.0)
            flux_bounds_array[bound_index,1] = sign(lower_bound)*default_vmax
        end

        if (upper_bound!=0.0)
            flux_bounds_array[bound_index,2] = sign(upper_bound)*default_vmax
        end
    end

    # correct -
    idx_palsson = [13,40,82,83,87,266,275,303,206,385];
    palsson_vmax = 1000.0
    for idx ∈ idx_palsson

        lower_bound = default_flux_bounds_array[idx,1]
        upper_bound = default_flux_bounds_array[idx,2]

        if (lower_bound!=0.0)
            flux_bounds_array[idx,1] = sign(lower_bound)*palsson_vmax
        end

        if (upper_bound!=0.0)
            flux_bounds_array[idx,2] = sign(upper_bound)*palsson_vmax
        end

    end

    # return -
    return flux_bounds_array;
end

function build(modeltype::Type{MyCoreCancerModel}, path::String; 
    modelname::String="CoreCancerModel_v1", 
    biomassfile::String="MDA_MB_231_ATCC-Biomass.csv")::MyCoreCancerModel

    # build an empty core cancer model -
    model = MyCoreCancerModel();

    # load the MAT file -
    cobra_dictionary = _model(path, modelname=modelname);

    # add stuff to the empty model -
    model.S = _build_stoichiometric_matrix(cobra_dictionary, biomassfile=biomassfile);
    model.list_of_reactions = _build_list_of_reactions(cobra_dictionary)
    model.list_of_metabolites = cobra_dictionary["mets"]
    model.bounds = _build_bounds_array(cobra_dictionary);
 
    # return -
    return model;
end