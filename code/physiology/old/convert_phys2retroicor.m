cd /home/lsnoek1/projects/PIOP1/bids/code/physiology

PER_SLICE = 0;
RESP_ONLY = 0;
CARDIAC_ONLY = 0;

FAILED = {};
main_dir = '../../';
subs = dir(fullfile(main_dir, 'sub-*'));

for i=1:numel(subs)
    this_sub = fullfile(main_dir, subs(i).name);
    [~,sub_base,~] = fileparts(this_sub);
    
    physios = dir(fullfile(this_sub, 'func', '*physio.tsv.gz'));
    for ii=1:numel(physios)
       this_phys = fullfile(this_sub, 'func', physios(ii).name);
       this_func = strrep(this_phys,'recording-respcardiac_physio.tsv.gz', 'bold.nii.gz');
       [~,basename,~] = fileparts(this_phys);
       ricor_out = strrep(basename, 'physio.tsv','desc-retroicor_regressors.tsv');
       ricor_file = fullfile('../../derivatives/physiology', sub_base, 'physio', ricor_out);
       if exist(ricor_file, 'file') ~= 2
           nii = load_untouch_header_only(this_func);
           n_slices = nii.dime.dim(2);
           n_vols = nii.dime.dim(5);
           tr = nii.dime.pixdim(5);
           fprintf('Trying to create %s with %i vols and TR=%.3f...', ricor_file, n_vols, tr); 
           
           save_dir = fullfile('../../derivatives/physiology', sub_base, 'physio');
           try
               run_retroicor(this_phys, save_dir, n_slices, n_vols, tr, RESP_ONLY, CARDIAC_ONLY, PER_SLICE);
           catch
               fprintf('\n--------------\nFAILED!!! %s \n--------------\n\n', this_phys);
               FAILED{end+1} = this_phys;
           end
       else
           fprintf('%s already exists ... skipping!\n', ricor_file);
       end
    end
end

% just to check what's wrong
for i=4:numel(FAILED)
    this_phys = FAILED{i};
    [~,base,~] = fileparts(this_phys);
    tmp = strsplit(base, '_');
    sub_base = tmp{1};
    
    this_func = strrep(this_phys,'recording-respcardiac_physio.tsv.gz', 'bold.nii.gz');
    [~,basename,~] = fileparts(this_phys);
    ricor_out = strrep(basename, 'physio.tsv','desc-retroicor_regressors.tsv');
    ricor_file = fullfile('../../derivatives/physiology', sub_base, 'physio', ricor_out);

    nii = load_untouch_header_only(this_func);
    n_slices = nii.dime.dim(2);
    n_vols = nii.dime.dim(5);
    tr = nii.dime.pixdim(5);
    fprintf('Trying to create %s with %i vols and TR=%.3f...', ricor_file, n_vols, tr); 
           
    save_dir = fullfile('../../derivatives/physiology', sub_base, 'physio');
           
    run_retroicor(this_phys, save_dir, n_slices, n_vols, tr, RESP_ONLY, CARDIAC_ONLY, PER_SLICE);
end