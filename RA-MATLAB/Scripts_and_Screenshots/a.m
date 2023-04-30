% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/Users/vincentbeaulieu/Documents/MATLAB/ELEC_445/Final Project/RA-MATLAB/Scripts_and_Screenshots/a_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
