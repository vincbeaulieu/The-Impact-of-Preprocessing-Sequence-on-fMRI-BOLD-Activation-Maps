function db_import_imgs(pat_in, folder_out, dry)

IMG_EXTS = {'.img', '.hdr'};
 if nargin < 7
     suffix_func = @(fn) '';
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
        fn_out = fullfile(folder_data, [fbn_out suffix IMG_EXTS{iext}]);
        if dry
            display([fn_in ' -> ' fn_out]);
        else
            db_mkdir_safe(folder_data);
            copyfile(fn_in, fn_out);
        end
    end
end
end