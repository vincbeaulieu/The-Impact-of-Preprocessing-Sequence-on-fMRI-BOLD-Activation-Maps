function batch_spm_1st_level_full_pipeline()
%%
%                ELEC498 - fMRI practical work
%
%% ASSUME
% * SPM12 is installed
% * Data has been imported from raw to origin. See batch_import_data.m
% * The following file organization is assumed, from the root directory
%   of the study:
%     code/  <- common code
%     raw/   <- raw data
%     origin/ <- imported data
%     batch_import_data.m <- script to create "origin" from "raw"
%     batch_spm_1st_level_full_pipeline.m <- the current batch script
%
%% Process description
% This batch analyses one single subject (GH158) by running a full
% preprocessing pipeline and a basic GLM analysis.
% Treatment steps:
%   - slice timing
%   - motion corection (realign)
%   - coregistration of anatomy onto the mean functional image
%   - normalization of the coreg anat along with functional images
%     -> this is the best way to perform normalization because the anatomy
%        is finer and more contrasted so it better coregisters with the
%        template.
%   - reslicing of the coreg anatomy
%     -> this step could be performed within the previous one but then the
%        outputs would mix functional and anatomy images which is difficult
%        to handle when defining dependencies between steps.
%   - smoothing of functional image
%   - GLM specification, taking into account the input paradigm
%   - GLM estimation
%   - Contrasts computation
%   - Reporting, with pvalue correction and thresholding
%
%% Outputs:
%     spm_<date>.ps     <- reporting of preprocessing
%     treatment_single_subj_<params>/GH158
%         anat/preprocs/ <- cogeristered anatomy
%         bold/
%             preprocs/  <- all preprocessed functional images
%             procs/     <- GLM results (beta, contrasts, pdf reports)
%
% The GUI of SPM can then be used to review the results
                              
%% Pre-setup
toolbox_path = fullfile(pwd, 'code');
assert(exist(toolbox_path, 'dir') ~= 0);
addpath(toolbox_path);

config = options_set_defaults(pwd);

path_orig = pwd;

%% Inputs
% fMRI acquisition parameters
fmri_params.tr = 2.4; %sec.
fmri_params.ta = 0.0615; %sec
fmri_params.slice_order = 'interleaved_top_down'; %ascending_top_down, interleaved_down_top, interleaved_top_down

subject = 'GH158';

% Processing options
%   All option items in config.process will be used to name the treatment
%   output folder.
config.treatment_dir_prefix = 'treatment_single_subj_';
config.slice_timing_refslice = 'middle'; %'first', 'last'
config.con_mcc = 'none';
config.con_pthresh = 0.001;
config.con_extent = 10;

% Two scenarios for project IA
preproc_orders = {'slice_timing_1st', 'realing_1st'};

% Contrast definition
% Mapping of experimental conditions to their indexes
% 1: chkbd_h
% 2: chkbd_v
% 3: click_L_audio
% 4: click_L_video
% 5: click_R_audio
% 6: click_R_video
% 7: computation_audio
% 8: computation_video
% 9: sentence_audio
% 10: sentence_video
icon = 1;
config.contrasts(icon).name = 'audio-video';
config.contrasts(icon).convec = [-1 -1 1 -1 1 -1 1 -1 1 -1 0];
icon = icon + 1;
config.contrasts(icon).name = 'video-audio';
config.contrasts(icon).convec = [-1 -1 1 -1 1 -1 1 -1 1 -1 0] * -1;
icon = icon + 1;

%% SPM batch processing
spm('defaults', 'FMRI');
spm_jobman('initcfg');

config = db_init_treatment_dir(config);
func_preproc_dir = db_get_1st_level_func_preproc_dir(subject, config);
func_proc_dir = db_get_1st_level_func_proc_dir(subject, config);
anat_preproc_dir = db_get_1st_level_anat_preproc_dir(subject, config);

anat_img_fn = db_get_anat_fn_for_preproc(anat_preproc_dir, subject, config);
anat_img_fn1 = [anat_img_fn ',1'];

fmri_scan_fns = db_get_fmri_scans_for_preproc(func_preproc_dir, subject, config);
fmri_params = fmri_params_update(fmri_params, fmri_scan_fns{1});

paradigm = paradigm_load_csv(db_get_paradigm_fn(subject, config));

matlabbatch = {};
ijob = 1;

if ~isfield(config.process, 'slice_timing_refslice_index')
    % Convert option on the slice definition into actual slice index
    if strcmp(config.process.slice_timing_refslice, 'first')
        config.slice_timing_refslice_index = 1;
    elseif strcmp(config.process.slice_timing_refslice, 'middle')
        config.slice_timing_refslice_index = round(fmri_params.nslices/2);
    elseif strcmp(config.process.slice_timing_refslice, 'last')
        config.slice_timing_refslice_index = fmri_params.nslices;
    else
        throw(MException('PreProcParamError', ...
            'ref slice for slice timing can either be first, middle or last'));
    end
end

%% Slice timing
matlabbatch{ijob}.spm.temporal.st.scans = {fmri_scan_fns}';
matlabbatch{ijob}.spm.temporal.st.nslices = fmri_params.nslices;
matlabbatch{ijob}.spm.temporal.st.tr = fmri_params.tr;
matlabbatch{ijob}.spm.temporal.st.ta = fmri_params.ta;
matlabbatch{ijob}.spm.temporal.st.so = fmri_params.slice_order_indexes;
matlabbatch{ijob}.spm.temporal.st.refslice = config.slice_timing_refslice_index;
matlabbatch{ijob}.spm.temporal.st.prefix = 'a';
ijob_slice_timing = ijob; % Keep the job index to properly set dependency
ijob = ijob + 1;

%% Motion correction
matlabbatch{ijob}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{ijob_slice_timing}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{ijob}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{ijob}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{ijob}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{ijob}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{ijob}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{ijob}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
ijob_realign = ijob;
ijob = ijob + 1;

ijob_dep_coreg = ijob_realign;

%% Coregistration anat onto func
matlabbatch{ijob}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{ijob_dep_coreg}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{ijob}.spm.spatial.coreg.estwrite.source = {anat_img_fn1};
matlabbatch{ijob}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{ijob}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{ijob}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{ijob}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{ijob}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{ijob}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{ijob}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{ijob}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{ijob}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
ijob_coreg_anat2func = ijob;
ijob = ijob + 1;

%% Normalize functional images
matlabbatch{ijob}.spm.spatial.normalise.estwrite.subj.vol(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{ijob_coreg_anat2func}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{ijob}.spm.spatial.normalise.estwrite.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{ijob_realign}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(spm('Dir'), 'tpm/TPM.nii')};
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{ijob}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{ijob}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
    78 76 85];
matlabbatch{ijob}.spm.spatial.normalise.estwrite.woptions.vox = [3 3 3]; %TODO: get original func resolutiijob_coreg_anat2funcon
matlabbatch{ijob}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{ijob}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
ijob_norm_func = ijob;
ijob = ijob + 1;

%% Normalize anatomy
matlabbatch{ijob}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Normalise: Estimate & Write: Deformation (Subj 1)', substruct('.','val', '{}',{ijob_norm_func}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{ijob}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{ijob_coreg_anat2func}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{ijob}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
    78 76 85];
matlabbatch{ijob}.spm.spatial.normalise.write.woptions.vox = [1 1 1]; %TODO: get original anat resolution
matlabbatch{ijob}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{ijob}.spm.spatial.normalise.write.woptions.prefix = 'w';
ijob_norm_anat = ijob;
ijob = ijob + 1;

%% Spatial smoothing of func images
if ~isfield(config, 'spatial_smooth_fwhm')
    config.spatial_smooth_fwhm = fmri_params.voxel_size * 2;
end
matlabbatch{ijob}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{ijob_norm_func}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{ijob}.spm.spatial.smooth.fwhm = config.spatial_smooth_fwhm;
matlabbatch{ijob}.spm.spatial.smooth.dtype = 0;
matlabbatch{ijob}.spm.spatial.smooth.im = 0;
matlabbatch{ijob}.spm.spatial.smooth.prefix = 's';
ijob_smooth_func = ijob;
ijob = ijob + 1;

%% GLM specification
matlabbatch{ijob}.spm.stats.fmri_spec.dir = {func_proc_dir};
matlabbatch{ijob}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{ijob}.spm.stats.fmri_spec.timing.RT = fmri_params.tr;
matlabbatch{ijob}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{ijob}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{ijob_smooth_func}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
cond_names = unique(paradigm.condition);
for icond=1:length(cond_names)
    cond_name = cond_names{icond};
    selection = strcmp(paradigm.condition, cond_name);
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).name = cond_name;
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).onset = paradigm.onset(selection);
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).duration = paradigm.duration(selection);
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).tmod = 0;
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).cond(icond).orth = 1;
end
matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).multi = {''};
matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).multi_reg = {''};
matlabbatch{ijob}.spm.stats.fmri_spec.sess(1).hpf = 128;
matlabbatch{ijob}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{ijob}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{ijob}.spm.stats.fmri_spec.volt = 1;
matlabbatch{ijob}.spm.stats.fmri_spec.global = 'None';
matlabbatch{ijob}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{ijob}.spm.stats.fmri_spec.mask = {''};
matlabbatch{ijob}.spm.stats.fmri_spec.cvi = 'AR(1)';
ijob_glm_spec = ijob;
ijob = ijob + 1;

%% GLM estimation
matlabbatch{ijob}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{ijob_glm_spec}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{ijob}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{ijob}.spm.stats.fmri_est.method.Classical = 1;
ijob_glm_estim = ijob;
ijob = ijob + 1;


%% Contrasts
matlabbatch{ijob}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{ijob_glm_estim}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
for icon=1:length(config.contrasts)
    matlabbatch{ijob}.spm.stats.con.consess{icon}.tcon.name = config.contrasts(icon).name;
    matlabbatch{ijob}.spm.stats.con.consess{icon}.tcon.weights = config.contrasts(icon).convec;
    matlabbatch{ijob}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
end
matlabbatch{ijob}.spm.stats.con.delete = 1;
ijob_contrasts = ijob;
ijob = ijob + 1;

%% Reporting
matlabbatch{ijob}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{ijob_contrasts}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
for icon=1:length(config.contrasts)
    matlabbatch{ijob}.spm.stats.results.conspec(icon).titlestr = '';
    matlabbatch{ijob}.spm.stats.results.conspec(icon).contrasts = icon;
    matlabbatch{ijob}.spm.stats.results.conspec(icon).threshdesc = config.con_mcc;
    matlabbatch{ijob}.spm.stats.results.conspec(icon).thresh = config.con_pthresh;
    matlabbatch{ijob}.spm.stats.results.conspec(icon).extent = config.con_extent;
    matlabbatch{ijob}.spm.stats.results.conspec(icon).conjunction = 1;
    matlabbatch{ijob}.spm.stats.results.conspec(icon).mask.none = 1;
end
matlabbatch{ijob}.spm.stats.results.units = 1;
matlabbatch{ijob}.spm.stats.results.export{1}.pdf = true;
ijob = ijob + 1;

spm_jobman('serial', matlabbatch);
cd(path_orig);
end
