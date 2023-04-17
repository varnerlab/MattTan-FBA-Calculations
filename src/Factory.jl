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
 
    # return -
    return model;
end