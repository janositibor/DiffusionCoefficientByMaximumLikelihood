close all; %close all figures 
clear; %remove everything from workspace 
clc;

Mobility_path();

LOWER_LIMIT_FOR_FISHER=1001;
delimiterIn = '\t';
pixel=0.16; %160 nanometer
framelength=34.0; %34ms
R=1/6;
%R=0;
RAW_data_extension='*.dat';

switch R
	case 1/6
		MotionBlur=true;
	otherwise
		MotionBlur=false;
end

file = matlab.desktop.editor.getActiveFilename;
[ActiveDir,name,ext] = fileparts(file);
ParameterFileNameandPath=strcat(ActiveDir,'/params.mat');
if exist(ParameterFileNameandPath, 'file')==2
	load(ParameterFileNameandPath);
end

Title = 'Input parameters';
%%%% SETTING DIALOG OPTIONS
% Options.WindowStyle = 'modal';
Options.Resize = 'off';
Options.Interpreter = 'tex';
Options.CancelButton = 'on';
Options.ApplyButton = 'off';
Options.ButtonNames = {'OK','Cancel'}; %<- default names, included here just for illustration
Option.Dim = 1; % Horizontal dimension in fields
Prompt = {};
Formats = {};
DefAns = struct([]);

Prompt(1,:) = {'Pixel''s size (nm):', 'pixel',[]};
Formats(1,1).type = 'edit';
Formats(1,1).format = 'integer';
Formats(1,1).size = 80; % automatically assign the height
DefAns(1).pixel = 1000*pixel;

Prompt(2,:) = {'Exposure (ms):', 'framelength',[]};
Formats(2,1).type = 'edit';
Formats(2,1).format = 'float';
Formats(2,1).size = 80;
DefAns.framelength = framelength;

Prompt(3,:) = {'There is MotionBlur (continous exposure)' 'MotionBlur',[]};
Formats(3,1).type = 'check';
DefAns.MotionBlur = MotionBlur;

Prompt(4,:) = {'Extension:', 'RAW_data_extension',[]};
Formats(4,1).type = 'edit';
Formats(4,1).format = 'text';
Formats(4,1).size = 80; % automatically assign the height
DefAns.RAW_data_extension = RAW_data_extension;

Prompt(5,:) = {'Separator character:', 'delimiterIn',[]};
Formats(5,1).type = 'list';
Formats(5,1).style = 'radiobutton';
Formats(5,1).items = {'SPACE','TAB'};
Formats(5,1).format = 'text';
Formats(5,1).size = 80;
DefAns.delimiterIn = Formats(5,1).items{1};

disp('Please, define parameters for RAW data!');

[Answer,Cancelled] = Mobility_inputsdlg(Prompt,Title,Formats,DefAns,Options);

if Cancelled
  disp('User aborted execution!');
  msgbox('User aborted execution!','Error','error');
  return;
end

pixel=Answer.pixel/1000;
framelength=Answer.framelength/1000;
RAW_data_extension=Answer.RAW_data_extension;
if strcmp(Answer.delimiterIn,'TAB')
    delimiterIn='\t';
else
    delimiterIn=' ';
end

NewMotionBlur = Answer.MotionBlur;
MotionBlur=NewMotionBlur;
if MotionBlur
	R=1/6;
else
	R=0;
end


%datadir = uigetdir(ActiveDir);
datadir = uigetdir(pwd);

if datadir==0
disp('No directory was selected!');
  msgbox('No directory was selected!','Error','error');
  return
end
%disp('Moved on ...');
filelist = Mobility_rdir(strcat(datadir,'\**\*.'));
Dirs=filelist;
if length(Dirs)==0
	Dirs(1).name=datadir;
end	

for Dir = 1 : length(Dirs)
	clearvars OutputData;
	Dirname=Dirs(Dir).name
	oldfolder=cd(char(Dirname));
	datafiles = dir(RAW_data_extension);
	if length(datafiles)>0
		OutputData(1).name = '';
		OutputData(1).id = 0;
		OutputData(1).numoflines = 0;
		OutputData(1).D = 0;
		OutputData(1).x = [];
		OutputData(1).y = [];
		OutputData(1).z = [];
		OutputData(1).squareroute = [0];
		OutputData(1).diff_coeff = 0;
		OutputData(1).sigma = 0;
		OutputData(1).x_diff = [];
		OutputData(1).y_diff = [];
		OutputData(1).sum_od_diff = [];
		OutputData(1).area = 0;
		OutputData(1).max_distance = 0;
		OutputData(1).x1 = 0;
		OutputData(1).y1 = 0;
		OutputData(1).x2 = 0;
		OutputData(1).y2 = 0;
		OutputData(1).MSD = [];
		
		
		Tempdiff_coeff=[];  
		for i = 1 : length(datafiles)
			thisfilename = datafiles(i).name;  %just the name
			tempdata = transpose(importdata(thisfilename,delimiterIn));
			numoflines=size(tempdata,2);
			OutputData(i).name = thisfilename;
			OutputData(i).id = i;
			OutputData(i).numoflines = numoflines;
			
			tempx=tempdata(2,:)*pixel;
			tempy=tempdata(3,:)*pixel;
			
			OutputData(i).x_withnulls=tempx;
			OutputData(i).x=(tempx(2:numoflines));
			OutputData(i).x_diff=OutputData(i).x-OutputData(i).x_withnulls(1:numoflines-1);
			OutputData(i).y_withnulls=tempy;
			OutputData(i).y=(tempy(2:numoflines));
			OutputData(i).y_diff=OutputData(i).y-OutputData(i).y_withnulls(1:numoflines-1);
			OutputData(i).squareroute=OutputData(i).x_withnulls.^2+OutputData(i).y_withnulls.^2;
			OutputData(i).sum_od_diff=horzcat(OutputData(i).x_diff,OutputData(i).y_diff);
		end 
		if exist('output.txt', 'file')==2
			delete('output.txt');
		end
		diary('output.txt');	
		cd(oldfolder);
		options = optimset('MaxFunEvals',100000,'MaxIter',100000);
        for i = 1 : length(OutputData)
            [Crawled_area]=Mobility_Crawled_area_calculation(OutputData(i));
			OutputData(i).area = Crawled_area;
			[Max_distance,x1,y1,x2,y2]=Mobility_MaxDistance(OutputData(i));	
			OutputData(i).max_distance = Max_distance;
			OutputData(i).x1 = x1;
			OutputData(i).y1 = y1;
			OutputData(i).x2 = x2;
			OutputData(i).y2 = y2;
			
			%nev=OutputData(i).name
			
			ML=mle(OutputData(i).sum_od_diff);
			OutputData(i).ML_Mean = ML(1);
			OutputData(i).ML_Sigma = ML(2);
			
			initialD=(ML(2)^2)/(2*framelength);
			initialsigma=0.1; %0.1 microm
			
			initial_parameters = [initialD,initialsigma;
				initialD,2*initialsigma;
				initialD,1.5*initialsigma;
				initialD,0.5*initialsigma;
				0.75*initialD,initialsigma;
				0.75*initialD,2*initialsigma;
				0.75*initialD,1.5*initialsigma;
				0.75*initialD,0.5*initialsigma;
				0.5*initialD,initialsigma;
				0.5*initialD,2*initialsigma;
				0.5*initialD,1.5*initialsigma;
				0.5*initialD,0.5*initialsigma;
				0.25*initialD,initialsigma;
				0.25*initialD,2*initialsigma;
				0.25*initialD,1.5*initialsigma;
				0.25*initialD,0.5*initialsigma;
				];
			
			num_of_local_searches=size(initial_parameters,1);
			num_of_searches=1;
			if(OutputData(i).numoflines>LOWER_LIMIT_FOR_FISHER)
				fun = @(parameters)Mobility_lhFunctionFisher(parameters,R,framelength,OutputData(i).x_diff,OutputData(i).y_diff);
			else
				fun = @(parameters)Mobility_lhFunction(parameters,R,framelength,OutputData(i).x_diff,OutputData(i).y_diff);
			end
			
			One_traj_fittings= zeros(num_of_local_searches,3);
			parfor j = 1 : num_of_local_searches
				[best_parameters,fval]  = fminsearch(fun,initial_parameters(j,:),options);
				One_traj_fittings(j,:)=[best_parameters, fval];
			end
			One_traj_fittings=One_traj_fittings;
			OptimValues = One_traj_fittings(:,3);
			[MinValue,MinIndex] = min(OptimValues);
			best_parameters=[One_traj_fittings(MinIndex,1) One_traj_fittings(MinIndex,2) One_traj_fittings(MinIndex,3)];
			
			MSD_results=Mobility_MSDFunction(OutputData(i).x_withnulls,OutputData(i).y_withnulls,framelength);
			OutputData(i).MSD_D = MSD_results(1);
			OutputData(i).MSD_intercept = MSD_results(2);
			OutputData(i).diff_coeff = best_parameters(1);
			OutputData(i).sigma = best_parameters(2);
			Tempdiff_coeff(i)=best_parameters(1);
			Tempsigma(i)=OutputData(i).sigma;

			One_row_of_sum=[{strrep(OutputData(i).name,' ','_')} OutputData(i).numoflines OutputData(i).diff_coeff 1000*OutputData(i).sigma OutputData(i).MSD_D 1000*1000*OutputData(i).MSD_intercept OutputData(i).area OutputData(i).max_distance];
				
			if i == 1
				Summary=One_row_of_sum;
			else
				Summary = [Summary; One_row_of_sum];
			end
		end
		SummaryTransponated=Summary';
		oldfolder=cd(strcat(char(Dirname)));
		SummaryFilename=strcat('Results_output.txt');
		fid = fopen(SummaryFilename,'w');
		fprintf(fid,'Name.\tFrameNo.\tD(um2/s)\tEps(nm)\tMSD_D(um2/s)\tMSD_Intercept(nm2)\tArea(um2)\tMaxDistance(um)\n');
		fprintf(fid,'%s\t%.3d\t%.5f\t%.1f\t%.5f\t%.1f\t%.5f\t%.5f\n',SummaryTransponated{:});
			
		fclose(fid);
		diary off;
	end
	cd(oldfolder);
end
framelength=1000*framelength;
save(ParameterFileNameandPath,'pixel','framelength','delimiterIn','RAW_data_extension','MotionBlur');
disp('The analysis was successfully completed!');
msgbox('The analysis was successfully completed!','Done');
clear;