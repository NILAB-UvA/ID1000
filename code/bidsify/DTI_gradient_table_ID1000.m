function [obOrs] = DTI_gradient_table_creator_Philips_RelX(ScanInfo)
%
%
%

DTI_studio = 'y';
grad_choice = 'user-defined';
patient_orientation = 'sp';
patient_position = 'hf';
slice_orientation = 'tra';
foldover = 'AP';
fat_shift = 'P';
ap = ScanInfo.angAP;
fh = ScanInfo.angFH;
rl = ScanInfo.angRL;
scan_date(1) = str2num(ScanInfo.StudyDate(1:4));
scan_date(2) = str2num(ScanInfo.StudyDate(5:6));
scan_date(3) = str2num(ScanInfo.StudyDate(7:8));
release = 'Rel_11.x';
nvolumes = 33;
nslices = ScanInfo.nSlices;
A=ScanInfo.slice_index;
As = sortrows(A,[6 5 4 2 42 43 3 1]);
bOrs=As(1:nslices:end,46:48);
index = find(As(1:nslices:end,34)==0);
bOrs(index,:) = [];
bOrs(33,:) = [];
sort_images  = 'y';
par_version = '4.2';
clear A As;
[input_table,final_table] = angulation_correction_Achieva(grad_choice,patient_orientation,patient_position,slice_orientation,foldover,fat_shift,ap,fh,rl,'NA.txt','n',DTI_studio,scan_date,release,nvolumes,bOrs,sort_images,par_version); 
clear input_table;
final_table(33,:)  = [];
final_table = [0 0 0; final_table]';
obOrs(1,:) = final_table(3,:);
obOrs(2,:) = final_table(1,:)*-1;
obOrs(3,:) = final_table(2,:);

% ============================================================
% ============================================================
% START OF ANGULATION CORRECTION
% ============================================================
% ============================================================
function [input_table,Ang_corrected_table] = angulation_correction_Achieva(grad_choice,patient_orientation,patient_position,slice_orientation,foldover,fat_shift,ap,fh,rl,filename,doWrite,DTI_studio,scan_date,release,nvolumes,supplied_grad_file,sort_images,par_version); 

% ==============================
% HEADER
% ==============================

% Name:     angulation_correction_Achieva.m (2nd generation of rotation_ovp.m)

% Reduced form of angulatoin_correction.m

% Author:   Jonathan Farrell, 
%           F.M. Kirby Research Center for Functional Brain Imaging
%           Room G25
%           Kennedy Krieger Institute
%           Baltimore, MD 21218

% Email:         JonFarrell@jhu.edu

% Creation Date: February 2, 2005

% ================================
% UPDATES:
% ================================

% April 4, 2006 |  Replaced scanner input with release input.  Entered the Philips Rel1.5 gradient tables for the
% 		   yes overplus option and changed the coordinate system accordingly.

% July 29, 2006 | Replaced Rel1.5 with Rel_1.5 to avoid confusion with l
% (L) and 1 (one)  looking similar.

% July 29 2006 | added supplied_grad_file

% November 2, 2006 | In the angulation_correction section I was normalizing all vectors, 
% but if the 0,0,0 vector was provided (when using the user-defined opeion), then a NaN was produced. 
% I now skip over any 0,0,0 or 100,100,100 vectors during the normalization step.  I also no
% longer append the 0,0,0 vector to the begining of the user-defined table.  I trust that the
% user will provide it.

% December 13, 2006 | I added Rel_2.0 and Rel_2.1 to the list of supported
% Philips software releases.  I also added the option to sort or not to 
% sort the images.  if you sort the images then the b=0 volume as the 
% first volume and the mean DWI volume as the last.  If you choose not to
% sort the images, the b=0 is the 2nd last, then mean DWI is the last.
% The new input paramter is Astruct.sort_images = 'y', or 'n'. Since
% sorting the images is customary, I will set a default of 'y' if you fail
% to provide an input for Astruct.sort_images.

% April 11, 2007 | do not enter the b=0 volume as part of your user defined
% table

% July 20, 2007 | corrected Tang and rev_Tang (see comment for main
% program)

% November 13, 2007 | added support for Rel 2.5

% December 29, 2007 | Fixed bug regarding Releaes 2.5 yes overplus gradient tables
% I had forgotten to add Rel_2_5 to the list of checks when I assign the space as
% XYZ (pre release 1.2) or LPH (release 1.2 and later, including release 2.5).
% The release 2.5 yes overplus tables were incorrectly assigned as XYZ space,
% when they should in fact be LPH space.  Incorrect colormaps will have their red and 
% green colors interchanged and fiber tracking will be incorrect. 

% disp(['The date of your scan is : ' num2str(scan_date) ' in [yyyy mm dd]'])

% convert the user given scan date to a days format
scan_date = datenum(scan_date);

% Convert the angles in degrees into radians
ap = ap*2*pi/(360);
fh = fh*2*pi/(360);
rl = rl*2*pi/(360);

% Definition of Philips Master Gradient Table for YES-OVERPLUS and
% NO-Overplus.  The Philips documentation indicates that the Yes-overplus tables change
% with release 1.5. 

if (strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))  
	IDIFF_SCHEME_LOW_OVERPLUS =    [-0.4714,-0.9428,-0.9428;...
			     		-0.9428,-0.4714, 0.9428;...
			     		 0.9428,-0.9428, 0.4714;...
					-1.0000,-1.0000, 0.0000;...
					 0.0000,-1.0000, 1.0000;...
					 1.0000, 0.0000, 1.0000];


	IDIFF_SCHEME_MEDIUM_OVERPLUS = [-0.7071,-0.7071,-1.0000;...
					-0.7071,-0.7071, 1.0000;...
					 1.0000,-1.0000, 0.0000;...
					-0.1561,-0.9999,-0.9879;...
					 0.4091,-0.9894,-0.9240;...
					 0.8874,-0.4674,-0.9970;...
					 0.9297,-0.3866,-0.9930;...
					-0.9511,-0.7667,-0.7124;...
					 0.9954,-0.6945, 0.7259;...
					-0.9800,-0.3580, 0.9547;...
					-0.9992,-1.0000, 0.0392;...
					-0.3989,-0.9999, 0.9171;...
					 0.4082,-0.9923, 0.9213;...
					 0.9982,-0.9989, 0.0759;...
					 0.9919,-0.2899, 0.9655];


	if strcmpi(release,'Rel_2.5')
		% Philips changed one direction (11th from bottom) from [1.00000,-0.66820, 0.74400] to [-1.00000,-1.00000, 0.01110].
		
		IDIFF_SCHEME_HIGH_OVERPLUS =   [-0.70710,-0.70710,-1.00000;...
						-0.70710,-0.70710, 1.00000;...
						 1.00000,-1.00000, 0.00000;...
						-0.92390,-0.38270,-1.00000;...
						-0.29510,-0.95550,-1.00000;...
						 0.02780,-0.99960,-1.00000;...
						 0.59570,-0.80320,-1.00000;...
						 0.97570,-0.21910,-1.00000;...
						-0.92420,-0.38280,-0.99970;...
						-0.41420,-1.00000,-0.91020;...
						 0.41650,-0.99900,-0.91020;...
						 0.72830,-0.68740,-0.99850;...
						 1.00000,-0.41420,-0.91020;...
						-1.00000,-0.66820,-0.74400;...
						-0.66820,-1.00000,-0.74400;...
						 0.78560,-0.91070,-0.74400;...
						 1.00000,-0.66820,-0.74400;...
						-1.00000,-1.00000,-0.00030;...
						-1.00000,-0.66820, 0.74400;...
						 1.00000,-0.66820, 0.74400;...
						 0.66820,-1.00000, 0.74400;...
						-1.00000,-1.00000, 0.01110;...
						-0.90000,-0.60130, 0.91020;...
						-0.99850,-0.99850, 0.07740;...
						-0.41420,-1.00000, 0.91020;...
						 0.41420,-1.00000, 0.91020;...
						 1.00000,-1.00000, 0.01110;...
						 1.00000,-0.41420, 0.91020;...
						-0.99880,-0.99880, 0.06920;...
						 0.04910,-0.99880, 1.00000;...
						 0.99990,-0.99990, 0.01630;...
						 1.00000, 0.00000, 1.00000];
	else
		IDIFF_SCHEME_HIGH_OVERPLUS =   [-0.70710,-0.70710,-1.00000;...
						-0.70710,-0.70710, 1.00000;...
						 1.00000,-1.00000, 0.00000;...
						-0.92390,-0.38270,-1.00000;...
						-0.29510,-0.95550,-1.00000;...
						 0.02780,-0.99960,-1.00000;...
						 0.59570,-0.80320,-1.00000;...
						 0.97570,-0.21910,-1.00000;...
						-0.92420,-0.38280,-0.99970;...
						-0.41420,-1.00000,-0.91020;...
						 0.41650,-0.99900,-0.91020;...
						 0.72830,-0.68740,-0.99850;...
						 1.00000,-0.41420,-0.91020;...
						-1.00000,-0.66820,-0.74400;...
						-0.66820,-1.00000,-0.74400;...
						 0.78560,-0.91070,-0.74400;...
						 1.00000,-0.66820,-0.74400;...
						-1.00000,-1.00000,-0.00030;...
						-1.00000,-0.66820, 0.74400;...
						 1.00000,-0.66820, 0.74400;...
						 0.66820,-1.00000, 0.74400;...
						 1.00000,-0.66820, 0.74400;...
						-0.90000,-0.60130, 0.91020;...
						-0.99850,-0.99850, 0.07740;...
						-0.41420,-1.00000, 0.91020;...
						 0.41420,-1.00000, 0.91020;...
						 1.00000,-1.00000, 0.01110;...
						 1.00000,-0.41420, 0.91020;...
						-0.99880,-0.99880, 0.06920;...
						 0.04910,-0.99880, 1.00000;...
						 0.99990,-0.99990, 0.01630;...
						 1.00000, 0.00000, 1.00000];
	
	end

elseif ~(strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
	IDIFF_SCHEME_LOW_OVERPLUS = [0.9428,-0.4714,0.9428;...
                        	     0.4714,-0.9428,-0.9428;...
                        	     0.9428,0.9428,-0.4714;...
                        	     1.0,-1.0,0.0;...
                        	     1.0,0.0,-1.0;...
                        	     0.0,1.0,-1.0];


	IDIFF_SCHEME_MEDIUM_OVERPLUS = [0.7071,-0.7071,1.0000;...
                                	0.7071,-0.7071,-1.0000;...
                                	1.0000,1.0000,0.0000;...
                                	0.9999,-0.1561,0.9879;...
                                	0.9894,0.4091,0.9240;...
                                	0.4674,0.8874,0.9970;...
                                	0.3866,0.9297,0.9930;...
                                	0.7667,-0.9511,0.7124;...
                                	0.6945,0.9954,-0.7259;...
                                	0.3580,-0.9800,-0.9547;...
                                	1.0000,-0.9992,-0.0392;...
                                	0.9999,-0.3989,-0.9171;...
                                	0.9923,0.4082,-0.9213;...
                                	0.9989,0.9982,-0.0759;...
                                	0.2899,0.9919,-0.9655];

	IDIFF_SCHEME_HIGH_OVERPLUS = [0.3827,-0.9239,1.0000;...
                        	      0.9555,-0.2951,1.0000;...
                        	      0.9996,0.0278,1.0000;...
                        	      0.8032,0.5957,1.0000;...
                        	      0.2191,0.9757,1.0000;...
                        	      0.3828,-0.9242,0.9997;...
                        	      0.7071,-0.7071,1.0000;...
                        	      1.0000,-0.4142,0.9102;...
                        	      0.9990,0.4165,0.9102;...
                        	      0.6874,0.7283,0.9985;...
                        	      0.4142,1.0000,0.9102;...
                        	      0.6682,-1.0000,0.7440;...
                        	      1.0000,-0.6682,0.7440;...
                        	      0.9107,0.7856,0.7440;...
                        	      0.6682,1.0000,0.7440;...
                        	      1.0000,-1.0000,0.0003;...
                        	      1.0000,1.0000,0.0000;...
                        	      0.6682,-1.0000,-0.7440;...
                        	      0.6682,1.0000,-0.7440;...
                        	      1.0000,0.6682,-0.7440;...
                        	      0.6682,1.0000,-0.7440;...
                        	      0.6013,-0.9000,-0.9102;...
                        	      0.9985,-0.9985,-0.0774;...
                        	      1.0000,-0.4142,-0.9102;...
                        	      1.0000,0.4142,-0.9102;...
                        	      1.0000,1.0000,-0.0111;...
                        	      0.4142,1.0000,-0.9102;...
                        	      0.5624,-0.8269,-1.0000;...
                        	      0.9988,-0.9988,-0.0692;...
                        	      0.9988,0.0491,-1.0000;...
                        	      0.9999,0.9999,-0.0163;...
                        	      0.0000,1.0000,-1.0000];						
end				
				
IDIFF_SCHEME_LOW_NO_OVERPLUS = [1.0,0.0,0.0;...
                                0.0,1.0,0.0;...
                                0.0,0.0,1.0;...
                               -0.7044,-0.0881,-0.7044;...
                                0.7044,0.7044,0.0881;...
                                0.0881,0.7044,0.7044];
                        
IDIFF_SCHEME_MEDIUM_NO_OVERPLUS = [1.0,0.0,0.0;...
                                   0.0,1.0,0.0;...
                                   0.0,0.0,1.0;...
                                  -0.1789,-0.1113,-0.9776;...
                                  -0.0635,0.3767,-0.9242;...
                                   0.710,0.0516,-0.7015;...
                                   0.6191,-0.4385,-0.6515;...  
                                   0.2424,0.7843,-0.5710;...
                                  -0.2589,-0.6180,-0.7423;...
                                  -0.8169,0.1697,-0.5513;...
                                  -0.8438,0.5261,-0.1060;...
                                  -0.2626,0.9548,-0.1389;...
                                   0.0001,0.9689,0.2476;...
                                   0.7453,0.6663,0.0242;...
                                   0.9726,0.2317,0.0209]; 


IDIFF_SCHEME_HIGH_NO_OVERPLUS = [1.0,0.0,0.0;...
                                 0.0,1.0,0.0;...
                                 0.0,0.0,1.0;...
                                -0.0424,-0.1146,-0.9925;...
                                 0.1749,-0.2005,-0.9639;...
                                 0.2323,-0.1626,-0.9590;...
                                 0.3675,0.0261,-0.9296;...
                                 0.1902,0.3744,-0.9076;...
                                -0.1168,0.8334,-0.5402;...
                                -0.2005,0.2527,-0.9466;...
                                -0.4958,0.1345,-0.8580;...
                                -0.0141,-0.6281,-0.7780;...
                                -0.7445,-0.1477,-0.6511;...
                                -0.7609,0.3204,-0.5643;...
                                -0.1809,0.9247,-0.3351;...
                                -0.6796,-0.4224,-0.5997;...
                                 0.7771,0.4707,-0.4178;...
                                 0.9242,-0.1036,-0.3677;...
                                 0.4685,-0.7674,-0.4378;...
                                 0.8817,-0.1893,-0.4322;...
                                 0.6904,0.7062,-0.1569;...
                                 0.2391,0.7571,-0.6080;...
                                -0.0578,0.9837,0.1703;...
                                -0.5368,0.8361,-0.1135;...
                                -0.9918,-0.1207,-0.0423;...
                                -0.9968,0.0709,-0.0379;...
                                -0.8724,0.4781,-0.1014;...
                                -0.2487,0.9335,0.2581;...
                                 0.1183,0.9919,-0.0471;...
                                 0.3376,0.8415,0.4218;...
                                 0.5286,0.8409,0.1163;...
                                 0.9969,0.0550,-0.0571]; 

                             
% read in the supplied user defined gradient table.  It should have no more
% than 4 columns, with white space seperations.  ie.  0: 1.000 1.000 1.000 or 1.000 1.000 1.000
if strcmpi(grad_choice,'user-defined')
     % disp(['This option is new, if it crashes, check the format of your supplied file']);
    % HSS  IDIFF_SCHEME_USERDEFINED = load(supplied_grad_file);
    IDIFF_SCHEME_USERDEFINED = supplied_grad_file;
    if size(IDIFF_SCHEME_USERDEFINED,2) > 4;
        error('The supplied gradient table file has more than 4 columns')
    elseif size(IDIFF_SCHEME_USERDEFINED,2) == 4;
        IDIFF_SCHEME_USERDEFINED = IDIFF_SCHEME_USERDEFINED(:,2:4);
    elseif size(IDIFF_SCHEME_USERDEFINED,2) == 3;

    end
    supplied_nvolumes = size(IDIFF_SCHEME_USERDEFINED,1);
end

if strcmpi(grad_choice,'user-defined')
    num2str(nvolumes-1);
    num2str(supplied_nvolumes);
    if ((nvolumes-1) == supplied_nvolumes)
        in = IDIFF_SCHEME_USERDEFINED;
        in_txt = 'IDIFF_SCHEME_USERDEFINED';
        % disp('Based on the number of volumes in the par file, and the gradient table you provided')
        % disp('The directions manually entered in the user defined field were used')
         space = 'LPH';
    else
        disp('You should not enter the 0,0,0 volume in the user-defined table you provide')
        error(['Your number of DWI volumes, ' num2str(nvolumes-1) ' in the data and the lines ' num2str(supplied_nvolumes) ' in your supplied user defined grad file ' supplied_grad_file ' are in conflict'])
    end
elseif strcmpi(grad_choice,'yes-ovp-low')
    if nvolumes == 8 % assumes 6 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_LOW_OVERPLUS;
        in_txt = 'IDIFF_SCHEME_LOW_OVERPLUS';
        disp('Based on the information you provided and the number of volumes in the par file')
        disp('The low directional resolution, gradient overplus yes, table was used')
	if ~(strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
        	space = 'XYZ';
	elseif (strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
		space = 'LPH';
	end
	disp(['from release ' release ' which is defined in ' space ' space'])
    else
        error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])       
    end
elseif strcmpi(grad_choice,'yes-ovp-medium')
    if nvolumes == 17 % assumes 15 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_MEDIUM_OVERPLUS;
        in_txt = 'IDIFF_SCHEME_MEDIUM_OVERPLUS';
	disp('Based on the information you provided and the number of volumes in the par file')
        disp('The medium directional resolution, gradient overplus yes, table was used')
        if ~(strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
        	space = 'XYZ';
	elseif (strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
		space = 'LPH';
	end
	disp(['from release ' release ' which is defined in ' space ' space'])
    else
       error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])
    end
elseif strcmpi(grad_choice,'yes-ovp-high')
    if nvolumes == 34 % assumes 32 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_HIGH_OVERPLUS; 
        in_txt = 'IDIFF_SCHEME_HIGH_OVERPLUS';
        disp('Based on the information you provided and the number of volumes in the par file')
        disp('The high directional resolution, gradient overplus yes, table was used')
        if ~(strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
        	space = 'XYZ';
	elseif (strcmpi(release,'Rel_1.5') | strcmpi(release,'Rel_1.7') | strcmpi(release,'Rel_2.0') | strcmpi(release,'Rel_2.1') | strcmpi(release,'Rel_2.5'))
		space = 'LPH';
	end
	disp(['from release ' release ' which is defined in ' space ' space'])
    else
        error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])
    end   
elseif strcmpi(grad_choice,'no-ovp-low')
    if nvolumes == 8 % assumes 6 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_LOW_NO_OVERPLUS;
        in_txt = 'IDIFF_SCHEME_LOW_NO_OVERPLUS';
        disp('Based on the information you provided and the number of volumes in the par file')
        disp('The low directional resolution, gradient overplus no, table was used')
        space = 'MPS';
	disp(['from release ' release ' which is defined in ' space ' space'])
    else
        error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])
    end
elseif strcmpi(grad_choice,'no-ovp-medium')
    if nvolumes == 17 % assumes 15 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_MEDIUM_NO_OVERPLUS;
        in_txt = 'IDIFF_SCHEME_MEDIUM_NO_OVERPLUS';
        disp('Based on the information you provided and the number of volumes in the par file')
        disp('The medium directional resolution, gradient overplus no, table was used')
        space = 'MPS';
	disp(['from release ' release ' which is defined in ' space ' space'])
    else
        error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])
    end
elseif strcmpi(grad_choice,'no-ovp-high')
    if nvolumes == 34 % assumes 32 directions + 1 b0 + 1 mean DWI
        in = IDIFF_SCHEME_HIGH_NO_OVERPLUS;
        in_txt = 'IDIFF_SCHEME_HIGH_NO_OVERPLUS';
        disp('Based on the information you provided and the number of volumes in the par file')
        disp('The high directional resolution, gradient overplus no, table was used')
	space = 'MPS';
	disp(['from release ' release ' which is defined in ' space ' space'])
        
    else
        error(['Your number of volumes, ' num2str(nvolumes) ' and grad_choice of ' grad_choice ' are in conflict'])
    end
end

% Define some storage matrices
out = zeros(size(in));
rev_out = zeros(size(in));

% ==========================================================
% TRANSFORMATION DEFINITIONS 
% ==========================================================

% Transformations and reverse transformatins that we will use
% Definitions for these matrices were taken from Philips documentation

if strcmpi(patient_orientation,'sp')
    Tpo = [1,0,0;0,1,0;0,0,1];
    rev_Tpo = [1,0,0;0,1,0;0,0,1];
elseif strcmpi(patient_orientation,'pr')
    Tpo = [-1,0,0;0,-1,0;0,0,1];
    rev_Tpo = [-1,0,0;0,-1,0;0,0,1];  
elseif strcmpi(patient_orientation,'rd')
    Tpo = [0,-1,0;1,0,0;0,0,1];
    rev_Tpo = [0,1,0;-1,0,0;0,0,1];
elseif strcmpi(patient_orientation,'ld')
    Tpo = [0,1,0;-1,0,0;0,0,1];
    rev_Tpo = [0,-1,0;1,0,0;0,0,1];
end

if strcmpi(patient_position,'ff')
    Tpp = [0,-1,0;-1,0,0;0,0,1];
    rev_Tpp = [0,-1,0;-1,0,0;0,0,-1];
elseif strcmpi(patient_position,'hf')
    Tpp = [0,1,0;-1,0,0;0,0,-1];
    rev_Tpp = [0,-1,0;1,0,0;0,0,-1];
end

Tpom = Tpo*Tpp;
rev_Tpom = rev_Tpp*rev_Tpo;
    
% Definitions for Trl,Tap,Tfh and Tang
Trl = [1,0,0; 0, cos(rl), -sin(rl);0,sin(rl),cos(rl)];
Tap = [cos(ap),0,sin(ap); 0,1,0; -sin(ap),0,cos(ap)];
Tfh = [cos(fh),-sin(fh),0; sin(fh),cos(fh),0; 0,0,1];
Tang = Trl*Tap*Tfh;

rev_Trl = [1,0,0; 0, cos(rl), sin(rl);0,-sin(rl),cos(rl)];
rev_Tap = [cos(ap),0,-sin(ap); 0,1,0; sin(ap),0,cos(ap)];
rev_Tfh = [cos(fh),sin(fh),0;-sin(fh),cos(fh),0;0,0,1];
rev_Tang = rev_Tfh*rev_Tap*rev_Trl;

% Definitions for Tsom
if strcmpi(slice_orientation,'sag')
    Tsom = [0,0,-1;0,-1,0;1,0,0];
    rev_Tsom = [0,0,1;0,-1,0;-1,0,0];
elseif strcmpi(slice_orientation,'cor')
    Tsom = [0,-1,0;0,0,1;1,0,0];
    rev_Tsom = [0,0,1;-1,0,0;0,1,0];
elseif strcmpi(slice_orientation,'tra')
    Tsom = [0,-1,0; -1,0,0; 0,0,1];
    rev_Tsom = [0,-1,0;-1,0,0;0,0,1];
end

% Definitions for Tprep_par Tprep_per & Tfsd_m, Tfsd_p, Tfsd_s

Tprep_par = [1,0,0;0,1,0;0,0,1];
rev_Tprep_par = [1,0,0;0,1,0;0,0,1];
Tprep_per = [0,-1,0;1,0,0;0,0,1];
rev_Tprep_per = [0,1,0;-1,0,0;0,0,1];

Tfsd_m = [-1,0,0;0,1,0;0,0,1];
rev_Tfsd_m = [-1,0,0;0,1,0;0,0,1];
Tfsd_p = [1,0,0;0,-1,0;0,0,1];
rev_Tfsd_p = [1,0,0;0,-1,0;0,0,1];
Tfsd_s = [1,0,0;0,1,0;0,0,-1];
rev_Tfsd_s = [1,0,0;0,1,0;0,0,-1];

if strcmpi(slice_orientation,'tra')
    if strcmpi(foldover,'AP')
        Tprep = Tprep_per;
        rev_Tprep = rev_Tprep_per;
        if strcmpi(fat_shift,'A')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        elseif strcmpi(fat_shift,'P')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        end
    elseif strcmpi(foldover,'RL')
        Tprep = Tprep_par;
        rev_Tprep = rev_Tprep_par;
        if strcmpi(fat_shift,'R')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        elseif strcmpi(fat_shift,'L')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        end
    end
    
elseif strcmpi(slice_orientation,'cor')
    if strcmpi(foldover,'FH')
        Tprep = Tprep_per;
        rev_Tprep = rev_Tprep_per;
        if strcmpi(fat_shift,'F')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        elseif strcmpi(fat_shift,'H')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        end
    elseif strcmpi(foldover,'RL')
        Tprep = Tprep_par;
        rev_Tprep = rev_Tprep_par;
        if strcmpi(fat_shift,'R')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        elseif strcmpi(fat_shift,'L')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        end
    end
    
elseif strcmpi(slice_orientation,'sag')
    if strcmpi(foldover,'FH')
        Tprep = Tprep_per;
        rev_Tprep = rev_Tprep_per;
        if strcmpi(fat_shift,'F')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        elseif strcmpi(fat_shift,'H')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        end
    elseif strcmpi(foldover,'AP')
        Tprep = Tprep_par;
        rev_Tprep = rev_Tprep_par;
        if strcmpi(fat_shift,'A')
            Tfsd = Tfsd_p;
            rev_Tfsd = rev_Tfsd_p;
        elseif strcmpi(fat_shift,'P')
            Tfsd = Tfsd_m;
            rev_Tfsd = rev_Tfsd_m;
        end
    end
end

% ==========================================
% END OF PHILIPS TRANSFORMATION DEFINITIONS
% ==========================================

% Transformation needed to go from Philips NWV coordinate space to DTIstudio
% coordinate space
DTIextra = [0,-1,0;-1,0,0;0,0,1];
rev_DTIextra = [0,-1,0;-1,0,0;0,0,1];

% ======================================
% APPLICATION OF THE TRANSFORMATIONS
% ======================================
if strcmpi(space,'LPH')
    for i = 1:length(in)
        if strcmpi(DTI_studio,'n')
            out(i,:) = (rev_Tsom*rev_Tang*in(i,:)')';
            message = 'Ang_corrected_table is a NVW pixel space compatible table from LPH origin';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (Tang*Tsom*out(i,:)')';
        elseif strcmpi(DTI_studio,'y')
            out(i,:) = (DTIextra*rev_Tsom*rev_Tang*in(i,:)')';
            message = 'Ang_corrected_table is a DTIstudio compatible table from LPH origin';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (Tang*Tsom*rev_DTIextra*out(i,:)')';
        end
	end
    %disp(message)
    
elseif strcmpi(space,'XYZ')
	for i = 1:length(in)
        if strcmpi(DTI_studio,'n')
            out(i,:) = (rev_Tsom*rev_Tang*Tpom*in(i,:)')';
            message = 'Ang_corrected_table is a NVW pixel space compatible table from XYZ origin';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (rev_Tpom*Tang*Tsom*out(i,:)')';
        elseif strcmpi(DTI_studio,'y')
            out(i,:) = (DTIextra*rev_Tsom*rev_Tang*Tpom*in(i,:)')';
            message = 'Ang_corrected_table is a DTIstudio compatible table from XYZ origin ';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (rev_Tpom*Tang*Tsom*rev_DTIextra*out(i,:)')';
        end
    end
    %disp(message)
elseif strcmpi(space,'MPS')
    for i = 1:length(in)
        if strcmpi(DTI_studio,'n')
            out(i,:) = (Tprep*Tfsd*in(i,:)')';
            message = 'Ang_corrected_table is a NVW pixel space compatible table from MPS origin';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (rev_Tfsd*rev_Tprep*out(i,:)')';
        elseif strcmpi(DTI_studio,'y')
            out(i,:) = (DTIextra*Tprep*Tfsd*in(i,:)')';
            message = 'Ang_corrected_table is a DTIstudio compatible table from MPS origin';
            % to check things, apply the reverse transformation to go
            % from out back to in
            rev_out(i,:) = (rev_Tfsd*rev_Tprep*rev_DTIextra*out(i,:)')';
        end
    end
end
   
% Normalize the non zero vectors
for ii = 1:length(out)
	if ((out(ii,1) == 0) & (out(ii,2) == 0) & (out(ii,3) == 0))
		out(ii,:) = out(ii,:);
	elseif ((out(ii,1) == 100) & (out(ii,2) == 100) & (out(ii,3) == 100))
		out(ii,:) = out(ii,:);
	else
		out(ii,:) = (1/norm(out(ii,:)))*out(ii,:);
	end
end

% The User Defined option does not produce a mean DWI volume in the rec file    
if strcmpi(in_txt,'IDIFF_SCHEME_USERDEFINED')
    if strcmpi(sort_images,'n')
        if (strcmpi(par_version,'4.1') | strcmpi(par_version,'4.2'))
            out = [0,0,0; out]; 
            % the b=0 volume is first sub volume and must be listed first
            % to work with DTIstudio
        elseif strcmpi(par_version,'4')
            out = [0,0,0; out]; 
            % the b=0 volume is first sub volume and must be listed first
            % to work with DTIstudio
        elseif strcmpi(par_version,'3')
            error('Sorry, I have no idea how V3 worked with sort images = no')
        else
            error('unsupported and unknown par file vesion, must be 3, 4, 4.1 or 4.2')
        end      
    elseif strcmpi(sort_images,'y')
        if (strcmpi(par_version,'4.1') | strcmpi(par_version,'4.2'))
            out = [out; 0,0,0]; 
            % the b=0 volume is the last volume
        elseif (strcmpi(par_version,'3') | strcmpi(par_version,'4'))
            out = [0,0,0; out]; 
            % the b=0 volume is the first volume
        else
           error('unsupported and unknown par file vesion, must be 3, 4, 4.1 or 4.2')
        end     
    end
% All The Philips Tables produce a mean DWI volume in the rec file 
else
    if strcmpi(sort_images,'n')
        if (strcmpi(par_version,'4.1') | strcmpi(par_version,'4.2'))
            out = [0,0,0; out; 100,100,100]; 
            % the b=0 volume is first sub volume and must be listed first
            % to work with DTIstudio
        elseif strcmpi(par_version,'4')
             out = [0,0,0; out; 100,100,100]; 
            % the b=0 volume is first sub volume and must be listed first
            % to work with DTIstudio
        elseif strcmpi(par_version,'3')
            error('Sorry, I have no idea how V3 worked with sort images = no')
        else
            error('unsupported and unknown par file vesion, must be 3, 4, 4.1 or 4.2')
        end
    elseif strcmpi(sort_images,'y')
         if (strcmpi(par_version,'4.1') | strcmpi(par_version,'4.2'))
            out = [out; 0,0,0; 100,100,100]; 
            % the b=0 volume is the 2nd last complete volume
        elseif (strcmpi(par_version,'3') | strcmpi(par_version,'4'))
            out = [0,0,0; out; 100,100,100]; 
            % the b=0 volume is the first complete volume
        else
           error('unsupported and unknown par file vesion, must be 3, 4, 4.1 or 4.2')
        end
    end
end

input_table = in;
Ang_corrected_table = out;

% =========================================================
% ========================================================
% END OF ANGULATION CORRECTION
% ========================================================
% ========================================================


% =========================================================
% ========================================================
% START OF REGISTRATION CORRECTION
% ========================================================
% ========================================================
function [T_and_Ang_corrected_table] = registration_correction(xfm_air_directory, name, Ang_corrected_table);

% August 2, 2006 | added fullfile and strtrim
% August 30, 2006 | added check for slash on xfm_air_direcotry


% add check to make sure xfm_air_directory has a slash at the end
if strcmpi(xfm_air_directory(end),'/')

else
	xfm_air_directory = [xfm_air_directory '/'];
end

disp(['Looking in ' xfm_air_directory ' for ' name '*.xfm or ' name '*.air files'])
% If there are .xfm files in the folder
if ~isempty(dir([xfm_air_directory name '*.xfm']))
    B = dir([xfm_air_directory name '*.xfm']);
	xfm_files = char(B.name);
	xfm_files = unique(xfm_files,'rows');
	
    % check that the gradient dynamics are ordered in 1 to n order
    % so that they can be used to transform the matching line in the
    % gradient table.  Note that issorted checks ASCII order. As the
    % xfm_files should only differ in the dynamic number, this should work.
    
    if ~issorted(xfm_files,'rows')
        disp('files were not sorted...so sorting was done')
        xfm_files = sortrows(xfm_files);
    end
    
	transforms = zeros([size(xfm_files,1) 16]);
    
	for ii = 1:size(xfm_files,1)
        %[xfm_files(ii,:)]
		transforms(ii,:) = textread(fullfile(xfm_air_directory, strtrim(xfm_files(ii,:))),'%f')';
	end
    
    xfm_air_files = xfm_files;
    
elseif ~isempty(dir([xfm_air_directory name '*.air']))
    B = dir([xfm_air_directory name '*.air']);
	air_files = char(B.name);
	air_files = unique(air_files,'rows');
    
    % check that the gradient dynamics are ordered in 1 to n order
    % so that they can be used to transform the matching line in the
    % gradient table.  Note that issorted checks ASCII order. As the
    % xfm_files should only differ in the dynamic number, this should work.
    
    if ~issorted(air_files,'rows')
        disp('files were not sorted...so sorting was done')
        air_files = sortrows(air_files);
    end
    
    transforms = zeros([size(air_files,1) 16]);
    
    for ii = 1:size(air_files,1)
        [air_files(ii,:)]
    	matrix = scanair_internal(fullfile(xfm_air_directory, strtrim(air_files(ii,:))));
        transforms(ii,:) = matrix(:)';
    end 
    xfm_air_files = air_files;
end

% Check the dimensions of the Ang_corrected_table and transforms
if size(Ang_corrected_table,1) ~= size(transforms,1)
    disp(['The size of the gradient table is' num2str(size(Ang_corrected_table,1)) 'by' num2str(size(Ang_corrected_table,2))])
    disp(['The size of the gradient table is' num2str(size(transforms,1)) 'by' num2str(size(transforms,2))])
    error('The number of rows in the transform matrix and the gradient table do not match')     
end

% need a line to make sure we don't normalize the mean DWI volume which we
% want to label with 100,100,100.
Ang_corrected_table
for j = 1:size(transforms,1)
    % reshape to a 4 by 4 matrix and take the Transpose
    T = reshape(transforms(j,:),[4 4])';
    % Only keep the rotations, disgard the translations
    T = T(1:3,1:3);
    if (all(Ang_corrected_table(j,:) == 100))
        T_and_Ang_corrected_table(j,:) = [100,100,100];
    end
    
    if all(~Ang_corrected_table(j,:))
        T_and_Ang_corrected_table(j,:) = [0,0,0];
    end
    
    if (~(all(Ang_corrected_table(j,:) == 100)) & (~all(~Ang_corrected_table(j,:))))
    
        T_and_Ang_corrected_table(j,:) = (T*Ang_corrected_table(j,:)')';
        % normalize the new direction
        if ~((T_and_Ang_corrected_table(j,1) == 0) & (T_and_Ang_corrected_table(j,2) == 0) & (T_and_Ang_corrected_table(j,3)==0))
            T_and_Ang_corrected_table(j,:) = (1/norm(T_and_Ang_corrected_table(j,:)))*T_and_Ang_corrected_table(j,:);
        end
    end
end
    
% =========================================================
% ========================================================
% END OF REGISTRATION CORRECTION
% ========================================================
% ========================================================

function [nrows, ncols, nslices, nechoes, ndynamics, nphases, A, header, par_version] = int_getPARinfo(filename_par)
%  addapted from Craig Jones's parseHeader - Parse a Philips PAR file for some important parameters
%

%  Craig Jones (craig@mri.jhu.edu)  
%  20040616 - fixed up reading in the header for stupid Windoze boxes
%  Jonathan Farrell (JonFarrell@jhu.edu)
%  20050628 - added the examination date, patient_position, and preparation_direction to the output header
%  20061213 - added code to read in V4.1 par files
%  20070411 - fixed code to return 3, 4 or 4.1 for par version
%  20071113 - fixed parsing statements for #  sl in v4.2 par files

nrows = 0; ncols = 0; nslices = 0; nechoes = 0; ndynamics = 0; A = []; header = []; par_version = 0;

header.filename = filename_par;

line = '';
fp = fopen(filename_par, 'rt');

if( fp == -1 )
	if( isunix )
		person = getenv('USER');
	elseif( ispc )
		person = getenv('USERNAME');
	else
		person = 'matlab user';
	end

	disp(sprintf('readrec:  I''m sorry, %s, the file %s does not exist', getenv('USER'), filename_par));
	return;
end

firstheader = 1;
par_version = 0;

%line = fgetl(fp);
while( 1 )
    line = fgetl(fp);

   if ((strncmp('#sl', line, 3) == 1) | (strncmp('# sl', line, 3) == 1)| (strncmp('#  sl ', line, 6))), break, end;
        
    if( firstheader & line(1) == '#' ) 
        % look for V4.1 or something similar
		[s,f] = regexp(line, '\w*[vV][0-9]\.\w*');
		if( ~isempty(s) )
            par_version = str2num( line(s(end)+1:f(end)) );
        else
            % look for V4 or V3 or something similar
            [s,f] = regexp(line, '\w*[vV][0-9]\w*');
            if( ~isempty(s) )
                par_version = str2num( line(s(end)+1:f(end)) );
            end
        end
	end

	%% We are not the in first header any more
    if ( strncmp('#', line, 1) ~= 1) 
		firstheader = 0;
	end
    
    %%  Look for off center values
    if( findstr('Off Centre ', line) > 0 )
        aa = line(findstr(':', line)+1:end);
       	header.off_center = str2num(aa);
		header.annotation = 'ap fh rl';
    end

    %%  Look for off center angulation
    if( findstr('Angulation ', line) > 0 )
        aa = line(findstr(':', line)+1:end);
       	header.angulation = str2num(aa);
    end

    %%  Look for the FOV
    if( findstr('FOV (', line) > 0 )
        aa = line(findstr(':', line)+1:end);
       	header.fov = str2num(aa);
    end

    %%  Look for number of rows and columns
    if( findstr('Recon resolution', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2num(aa);
        nrows = aa(1);  ncols = aa(2);
		header.recon_resolution = aa;
    end

    %%  Look for number of slices
    if( findstr('number of slices', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2num(aa);
        nslices = aa(1);
    end

    %%  Look for number of slices
    if( findstr('number of cardiac phases', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2num(aa);
        nphases = aa(1);
    end
    
    % ---------------------
    % added by Jonathan Farrell
    %%  Look for the Examination date
    if( findstr('Examination date/time', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = strrep(aa,'.',' ');
        aa = strrep(aa,'/',' ');
        aa = str2num(aa);
        header.examination_date = [aa(1) aa(2) aa(3)];
        header.date_annotation = '[yyyy mm dd]';
    end
    
    if par_version > 3
        if ( findstr('Patient position', line) > 0 )
            aa = line(findstr(':', line)+1:end);
            header.patient_position = aa;
        end
        
        if ( findstr('Preparation direction', line) > 0 )
            aa = line(findstr(':', line)+1:end);
            header.preparation_direction = aa;
        end  
    end
    
    % ---------------------------
end

line = fgetl(fp);

A = [];
ii = 1;
while( 1 )

    line = fgetl(fp);
    if( length(line) < 2 ), break; end
    
    A(ii,:) = str2num(line);
    ii = ii + 1;
end

ndynamics = length(unique(A(:,3)));
nechoes = length(unique(A(:,2)));

%  Added for the new PAR files.
if( nrows == 0 )
	nrows = A(1,10);
	ncols = A(1,11);
end

fclose(fp);

% =========================================================
% ========================================================
% START OF .AIR FILE READ IN FUNCTION
% ========================================================
% ========================================================

function [matrix] = scanair_internal(airfile)

% ==========================================
% HEADER
% ==========================================

% Name: scanair_internal.m

% Author:   Jonathan Farrell ( JonFarrell@jhu.edu )
%           F.M. Kirby Research Center for Functional Brain Imaging
%           Room G25
%           Kennedy Krieger Institute
%           Baltimore, MD 21218

% Creation Date:  October 10, 2005

% History of Updates:


% ========================================
% PURPOSE:  
% ========================================

% to mimic the scanair function provided by AIR, but do it in matlab to
% make it OS system (unix vs windows) independent

% The equivilant code using the AIR scanair package would be
% airfile = '/home/jfarrell/matlab_jon/img_1_0.air'
% [d,A] = unix(sprintf(['/usr/local/air5.2.5/scanair_16u ' airfile ' -r']));
% matrix = str2num(A(strfind(A,'[')+1:strfind(A,']')-1))       
% transforms(1,:) = matrix(:)'

% ========================================
% BEGIN CODE:  
% ========================================
endian = 'l';
fid = fopen(airfile,'rb',endian);
e = fread(fid,[4 4],'double');
s_file = fgets(fid, 128);
s_bits = fread(fid,1,'uint32'); % This is the number of bits per pixel in the dataset

% if the bits are not reasonable, try the other endian format
if (s_bits ~= 16)
    disp('Bits per pixel for little endian is not 16, ... Trying other endian')
    fclose(fid);
    endian = setdiff(['l','b'],endian); 
    fid = fopen(airfile,'rb',endian);
    e = fread(fid,[4 4],'double');
    s_file = fgets(fid, 128);
    s_bits = fread(fid,1,'uint32'); % This is the number of bits per pixel in the dataset
    if (s_bits ~= 16)
        error('Tried little and big endian, could not match bits per pixel of 16 critea')
    else
        disp(['Used ' endian ' endian format'])
    end
end

s_xdim = fread(fid,1,'uint32');
s_ydim = fread(fid,1,'uint32');
s_zdim = fread(fid,1,'uint32');
s_xsize = fread(fid,1,'double');
s_ysize = fread(fid,1,'double');
s_zsize = fread(fid,1,'double'); 

r_file = fgets(fid, 128);
r_bits = fread(fid,1,'uint32'); % This is the number of bits per pixel in the dataset
r_xdim = fread(fid,1,'uint32');
r_ydim = fread(fid,1,'uint32');
r_zdim = fread(fid,1,'uint32');
r_xsize = fread(fid,1,'double');
r_ysize = fread(fid,1,'double');
r_zsize = fread(fid,1,'double'); 

% to put the .air matrix in real world units in mm
% this should give the same result as the 'r' option when using the AIR
% based scanair function.  The real world transformation coordinates in mm
% make the most sense when thinking about how to correct the gradient
% tables.

pixel_size_s = min([s_xsize,s_ysize,s_zsize]);
matrix = e;
for j = 1:3
    for i = 1:4
        matrix(i,j) = matrix(i,j)/pixel_size_s;
    end
end
for j = 1:4
    matrix(1,j) = matrix(1,j)*r_xsize;
    matrix(2,j) = matrix(2,j)*r_ysize;
    matrix(3,j) = matrix(3,j)*r_zsize;
end

% =========================================================
% ========================================================
% END OF .AIR FILE READ IN FUNCTION
% ========================================================
% ========================================================
