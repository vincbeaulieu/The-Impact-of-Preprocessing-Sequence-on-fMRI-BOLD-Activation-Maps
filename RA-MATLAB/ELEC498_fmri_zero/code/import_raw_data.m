function import_raw_data(subjects, folder_in, folder_out, dry)

if nargin < 4
    dry = 1;
end

for isubj=1:length(subjects)
    subject_tag = subjects{isubj};
    
    if strcmp(subject_tag, 'GH158')
        % Import anatomy
        import_imgs(subject_tag, folder_in, 't1_%s_3T_siemens', ...
            folder_out, 'anat', dry);
    end
    % Import functional
    if strcmp(subject_tag, 'GH158')
        func_prefix = '';
    else
        func_prefix = 'ra';
    end
    import_imgs(subject_tag, folder_in, 't2epi_%s_3T_siemens*', ...
                folder_out, 'bold', dry, ...
                @(fn) sprintf('_%03d', str2double(fn(end-9:end-4))), ...
                func_prefix);
    % Import paradigm
    paradigm_fn_in = fullfile(folder_in, sprintf('t2epi_%s_3T_siemens_paradigm_full.csv', subject_tag));
    paradigm_fn_out = fullfile(folder_out, subject_tag, ...
                               'bold', sprintf('%s_paradigm.csv', subject_tag));
    if dry
        display([paradigm_fn_in ' -> ' paradigm_fn_out]);
    else
        copyfile(paradigm_fn_in, paradigm_fn_out);
    end
end
end


function import_imgs(subject_tag, folder_in, raw_pat_in, folder_out, ...
                     modality_out, dry, suffix_func, prefix)

IMG_EXTS = {'.img', '.hdr'};
 if nargin < 7
     suffix_func = @(fn) '';
 end
 
 if nargin < 8
     prefix = '';
 end
 
fbn_in = sprintf(raw_pat_in, subject_tag);
fbn_out = [subject_tag '_' modality_out];

folder_data = fullfile(folder_out, subject_tag, modality_out);
for iext=1:length(IMG_EXTS)
    fn_pat_in = fullfile(folder_in, [fbn_in IMG_EXTS{iext}]);
    fns_in = db_listdir(fn_pat_in);
    for ifn=1:length(fns_in)
        fn_in = fns_in{ifn};
        suffix = suffix_func(fn_in);
        fn_out = fullfile(folder_data, [prefix fbn_out suffix IMG_EXTS{iext}]);
        if dry
            display([fn_in ' -> ' fn_out]);
        else
            db_mkdir_safe(folder_data);
            copyfile(fn_in, fn_out);
        end
    end
end
end

