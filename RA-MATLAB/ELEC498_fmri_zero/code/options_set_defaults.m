function opts = options_set_defaults(study_dir)

% data basing
opts.study_dir = study_dir;
opts.data_orig_dir = fullfile(study_dir, 'origin');
opts.data_raw_dir = fullfile(study_dir,'raw');
opts.clean_all_before = 0;
opts.treatment_dir_prefix = 'treatment_';

% processing
opts.process.slice_timing_refslice = 'middle';

end