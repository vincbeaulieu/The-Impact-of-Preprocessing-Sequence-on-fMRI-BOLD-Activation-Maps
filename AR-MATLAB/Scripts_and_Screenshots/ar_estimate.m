% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/Users/vincentbeaulieu/Documents/MATLAB/ELEC_445/Final Project/AR-MATLAB/Scripts_and_Screenshots/ar_estimate_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
