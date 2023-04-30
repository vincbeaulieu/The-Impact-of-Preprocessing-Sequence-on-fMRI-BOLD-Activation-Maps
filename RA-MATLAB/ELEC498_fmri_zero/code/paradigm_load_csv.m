function paradigm = paradigm_load_csv(paradigm_fn)
    paradigm = readtable(paradigm_fn, 'ReadVariableNames', false, 'Delimiter', '\t');
    paradigm.Properties.VariableNames = {'session', 'condition', 'onset', 'duration'};
end
