function fmri_params = fmri_params_update(fmri_params, func_vol_fn)

hdr = spm_vol(func_vol_fn);

if ~isfield(fmri_params, 'nslices')
    fmri_params.nslices = hdr.dim(end);
end

if ~isfield(fmri_params, 'voxel_size')
    fmri_params.voxel_size = abs(diag(hdr.mat(1:3, 1:3)))';
end

if ~isfield(fmri_params, 'ta')
    fmri_params = fmri_params.tr / (fmri_params.nslices -1);
end

fwd_order = 1:fmri_params.nslices;
backwd_order = fmri_params.nslices:-1:1;
if strcmp(fmri_params.slice_order, 'ascending_down_top')
    fmri_params.slice_order_indexes = fwd_order;
elseif  strcmp(fmri_params.slice_order, 'ascending_top_down')
    fmri_params.slice_order_indexes = backwd_order;
else
    idx = 1;
    fmri_params.slice_order_indexes = zeros(size(fwd_order));
    for ii=1:round(fmri_params.nslices/2);
        if strcmp(fmri_params.slice_order, 'interleaved_down_top')
            fmri_params.slice_order_indexes(idx) = fwd_order(ii);
            if idx+1 <= fmri_params.nslices
                fmri_params.slice_order_indexes(idx+1) = backwd_order(ii);
            end
        elseif strcmp(fmri_params.slice_order, 'interleaved_top_down')
            fmri_params.slice_order_indexes(idx) = backwd_order(ii);
            if idx+1 <= fmri_params.nslices
                fmri_params.slice_order_indexes(idx+1) = fwd_order(ii);
            end
        end
        idx = idx + 2;
    end
end

end