function db_mkdir_safe(d)
if ~exist(d, 'dir')
    mkdir(d);
end
end