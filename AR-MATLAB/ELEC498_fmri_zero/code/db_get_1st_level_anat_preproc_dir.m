function preproc_dir = db_get_1st_level_anat_preproc_dir(subject, cfg)
    treatment_dir = db_check_treatment_dir(cfg);
    preproc_dir = fullfile(treatment_dir, subject, ...
        'anat', 'preprocs');
    if ~exist(preproc_dir, 'dir')
        mkdir(preproc_dir);
    end
end