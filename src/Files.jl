function loadfluxfile(path::String)::DataFrame
    return CVS.read(path, DataFrame);
end