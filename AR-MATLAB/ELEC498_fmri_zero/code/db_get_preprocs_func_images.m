function func_fns = db_get_preprocs_func_images(subjects, prefix, iscan, cfg)

    func_fns = cell(length(subjects), 1);
    for isubj=1:length(subjects)
        func_fns{isubj} = fullfile(cfg.treatment_dir, subjects{isubj}, ...
                                 'bold', 'preprocs', ...
                                 sprintf([prefix subjects{isubj} '_bold_%03d.img'], iscan));
        assert(exist(func_fns{isubj}, 'file') ~= 0);
    end
end