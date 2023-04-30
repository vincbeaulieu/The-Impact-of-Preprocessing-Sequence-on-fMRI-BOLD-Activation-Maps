function tt_folder = db_check_treatment_dir(cfg)
    if ~isfield(cfg, 'treatment_dir')
        throw(MException('DB_ERROR:treatmentFolderNotFound', ...
                         ['treatment folder not set. Consider running ' ...
                          'db_init_treatment_folder']));
    end
    tt_folder = cfg.treatment_dir;
end