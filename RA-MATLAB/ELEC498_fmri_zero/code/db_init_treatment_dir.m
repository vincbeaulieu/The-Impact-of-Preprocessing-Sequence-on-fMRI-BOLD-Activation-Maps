function cfg = db_init_treatment_dir(cfg)
    tt_folder = fullfile(cfg.study_dir, ...
                        [cfg.treatment_dir_prefix ...
                         get_options_proc_tags(cfg)]);
    if ~exist(tt_folder, 'dir')
        mkdir(tt_folder);
    end
    
    cfg.treatment_dir = tt_folder;
end

function stags = get_options_proc_tags(opts)

stags = '';
opt_labels = fieldnames(opts.process);
tags = {};
for ilabel=1:length(opt_labels)
    opt_label = opt_labels{ilabel};
    toks = strsplit(opt_label, '_');
    if length(toks) > 1
        stmp = '';
        for itok=1:(length(toks)-1)
            stmp = [stmp toks{itok}(1)];
        end
        tags{end+1} = [stmp '.' toks{end}(1:min(5,length(toks{end})))];
    else
        tags{end+1} = toks{1}(1:2);
    end
    tags{end+1} = format_opt_val(opts.process.(opt_label));
end

stags = strjoin(tags, '_');
end

function sval = format_opt_val(opt_value)
    assert(~iscell(opt_value));
    if ischar(opt_value)
        sval = opt_value;
    else
        toks = {};
        flat_values = opt_value(:);
        for ival=1:numel(opt_value)
            val = flat_values(ival);
            if val == round(val)
                toks{end+1} = sprintf('%d', val);
            elseif isnumeric(opt_value)
                toks{end+1} = sprintf('%1.3f', val);
            else
                display('unhandled option value:');
                display(val);
            end
        end
        sval = strjoin(toks, '_');
    end
end