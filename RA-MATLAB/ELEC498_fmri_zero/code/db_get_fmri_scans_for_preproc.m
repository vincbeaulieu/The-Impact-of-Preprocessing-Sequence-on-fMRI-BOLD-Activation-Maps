function func_fns = db_get_fmri_scans_for_preproc(func_preproc_dir, subject, cfg, prefix)

    if nargin < 4
        prefix = '';
    end
    func_pat = fullfile(cfg.data_orig_dir, subject, 'bold', ...
                        [prefix subject '_bold_*.img']);
    func_fns = db_copy_files(func_pat, func_preproc_dir);
    assert(~isempty(func_fns));
    for ifn=1:length(func_fns)
        assert(exist(func_fns{ifn}, 'file') ~= 0);
    end
end