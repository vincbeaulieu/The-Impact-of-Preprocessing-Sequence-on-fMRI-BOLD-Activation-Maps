function anat_fn = db_get_anat_fn_for_preproc(anat_preproc_dir, subject, cfg)

    anat_bfn = [subject '_anat.img'];
    anat_fn_orig = fullfile(cfg.data_orig_dir, subject, 'anat', anat_bfn);
    anat_fn = fullfile(anat_preproc_dir, anat_bfn);
    copyfile(anat_fn_orig, anat_fn);
    
    anat_hdr_bfn = [subject '_anat.hdr'];
    anat_hdr_fn_orig = fullfile(cfg.data_orig_dir, subject, 'anat', anat_hdr_bfn);
    anat_hdr_fn = fullfile(anat_preproc_dir, anat_hdr_bfn);
    copyfile(anat_hdr_fn_orig, anat_hdr_fn);

end