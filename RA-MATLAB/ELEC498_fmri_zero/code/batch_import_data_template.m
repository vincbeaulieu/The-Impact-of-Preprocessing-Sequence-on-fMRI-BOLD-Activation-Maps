%% WARNING
%% This file is a template which is not intended to be run directly.
%% It should be copied to the data folder root and then the following
%% "Inputs" part should be adapted. This warning can then be removed.

%% Inputs
dry = 1; % 1: don't import anything, just print operations 
         % (safe to start with that).
         % 0: do the files copy

raw_input_folder = './raw'; % contains data imported from scanner
origin_dest_folder = './origin'; % destination with proper hierarchy
subjects = {}; % TODO: fill this with subject tags to be looked for 
               % in raw folder and to import
toolbox_path = ''; %TODO: put path to study toolbox, eg '../code/'

%% Processing
addpath(toolbox_path);
import_raw_data(subjects, raw_input_folder, origin_dest_folder, dry);