function con_fns = db_get_con_images(icon, subjects, cfg)

    con_fns = cell(length(subjects), 1);
    for isubj=1:length(subjects)
        con_fns{isubj} = fullfile(cfg.treatment_dir, subjects{isubj}, ...
                                 'bold', 'procs', ...
                                 sprintf('con_%04d.nii', icon));
        assert(exist(con_fns{isubj}, 'file') ~= 0);
    end
end