function pfn = db_get_paradigm_fn(subject, cfg)
    pfn = fullfile(cfg.data_orig_dir, subject, 'bold', ... 
                   [subject '_paradigm.csv']);
end