function paradigm = paradigm_merge_conditions(paradigm, merge_rules)

conditions = unique(paradigm.condition);
for icond=1:length(conditions)
    condition = conditions{icond};
    for irule=1:length(merge_rules)
        rule = merge_rules{irule};
        if ~isempty(regexp(condition, rule{2}, 'match'))
            selection = strcmp(paradigm.condition, condition);
            paradigm.condition(selection) = {rule{1}};
        end
   end
    
end

end

