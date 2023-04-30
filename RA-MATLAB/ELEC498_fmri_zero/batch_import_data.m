function batch_import_data()
% ELEC498 - fMRI practical work
% Importation script for the zero data set (single subject)
% 
% This script reorganizes and renames raw files in folder "raw" so that they
% can be easily read by subsequent SPM scripts
%
% Destination folder is "origin" and will have the following organization:
% origin/
%     anat/
%         <subject_name>_anat[.hdr,.img]
%            -> anatomy data
%     bold/
%         <subject_name>_bold_<scan_number>[.hdr,.img]
%            -> BOLD fMRI volume of data (1 every TR of 2.4s) 
%         <subject_name>_bold.csv 
%            -> timing of stimulation events
%% Usage:
%  - matlab current folder should be the same as this script
%  - type "batch_import_data"
%
% Note: at the end of the script, the script prints a 
% version of the paradigm where some experimental conditions have been 
% merged. This is a way of regrouping conditions together and find
% the average effect accross all regrouped conditions during the GLM.

toolbox_path = fullfile(pwd, 'code');
assert(exist(toolbox_path, 'dir') ~= 0);
addpath(toolbox_path);

dry = 0; % 1: don't import anything, just print operations 
         % (safer to start with that).
         % 0: do the files copy

cfg = options_set_defaults(pwd);
subjects = {'GH158'}; % subject tags to be looked for in raw folder 
                      % and to import

import_raw_data(subjects, cfg.data_raw_dir, cfg.data_orig_dir, dry);
pp = paradigm_load_csv(db_get_paradigm_fn(subjects{1}, cfg));

disp(' ');
disp('*** Full paradigm ***');
disp(' ');
paradigm_display(pp);

disp(' ');
disp('*** Paradigm with merged audio and video ***');
disp(' ');
ppm = paradigm_merge_conditions(pp, {{'video', '.*_video'}, ...
                                      {'audio', '.*_audio'}});
paradigm_display(ppm);
end