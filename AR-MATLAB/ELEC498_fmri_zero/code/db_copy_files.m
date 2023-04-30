function files_out = db_copy_files(pat_in, dir_out, dry)
    if nargin < 3
        dry = 0;
    end
    
    fns_in = db_listdir(pat_in);
    files_out = cell(length(fns_in), 1);
    for ifn=1:length(fns_in)
        fn_in = fns_in{ifn};
        [rr, bfn_in, ee] = fileparts(fn_in);
        fn_out = fullfile(dir_out, [bfn_in ee]);
        
        if dry
            display([fn_in ' -> ' fn_out]);
        else
            copyfile(fn_in, fn_out);
        end
        files_out{ifn} = fn_out;
        
        if strcmp(ee, '.img')
            fn_hdr_in = fullfile(rr, [bfn_in '.hdr']);
            fn_hdr_out = fullfile(dir_out, [bfn_in '.hdr']);
            if exist(fn_hdr_in, 'file')
                if dry
                    display([fn_hdr_in ' -> ' fn_hdr_out]);
                else
                    copyfile(fn_hdr_in, fn_hdr_out);
                end
            end
        end
        
    end
end