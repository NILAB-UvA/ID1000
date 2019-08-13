subs = dir('../../raw/ID*');
bids_dir = '../bids2';
for i = 1:numel(subs)
    fprintf(['\nProcessing ' subs(i).name]) 
    cdir = ['../../raw/' subs(i).name];
    dwidirs = dir([cdir '/*DTI*']);
    for ii = 1:numel(dwidirs)
        ccdir = [cdir '/' dwidirs(ii).name];
        nifti_name = dir([ccdir '/*.nii.gz']);
        nifti_name = nifti_name(1).name;
        runstr = strsplit(nifti_name, '_');
        runstr = runstr{2};
        runstr = strsplit(runstr, '.');
        runstr = runstr{1};
        scaninfo = [ccdir '/ScanInfo.mat'];
        si = load(scaninfo);
        si = si.ScanInfo;
        bvec = DTI_gradient_table_ID1000(si);
        % bvec = bvec';
        
        subname = strrep(subs(i).name, 'ID', 'sub-');
        fn = [bids_dir '/' subname '/dwi/' subname '_' runstr '_dwi.bvec'];
        fn
        dlmwrite(fn, bvec, ' ');
        
        fn = [bids_dir '/' subname '/dwi/' subname '_' runstr '_dwi.bval'];
        dlmwrite(fn, si.bVals', ' ');
 
    end;
end;