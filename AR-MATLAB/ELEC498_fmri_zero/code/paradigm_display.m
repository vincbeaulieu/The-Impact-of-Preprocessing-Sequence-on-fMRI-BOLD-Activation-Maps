function disp_paradigm( paradigm )
%DISP_PARADIGM Summary of this function goes here
%   Detailed explanation goes here
conditions = unique(paradigm.condition);
for icond=1:length(conditions)
    condition = conditions{icond};
    selection = strcmp(paradigm.condition, condition);
    disp(condition);
    %display('onsets:');
    onsets = sort(paradigm.onset(selection));
    durations = paradigm.duration(selection);
    sonsets = 'onsets: ';
    sdurations = 'durations: ';
    for ions=1:length(onsets)
        sonsets = [sonsets sprintf('%1.2f ', onsets(ions))];
        sdurations = [sdurations sprintf('%1.2f ', durations(ions))];
    end
    disp(sonsets);
    disp(sdurations);
    disp(' ');
end

end

