function [listing] = listdir(d)
    ld = dir(d);
    if ~isempty(ld)
        for i=1:length(ld)
            listing{i} = fullfile(fileparts(d), ld(i).name);
        end
    else
        listing = struct([]);
    end
end