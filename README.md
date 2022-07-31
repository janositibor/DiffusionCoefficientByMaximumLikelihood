# DiffusionCoefficientByMaximumLikelihood
Maximum likelihood based estimation of diffusion coefficient

01. Run the script Main.m in Matlab.
02. Define basic parameters of the measured trajectories.

![Input fields to define params](/info/01-DefineParams.png)

03. Choose directory for the trajectories.

![Input fields to define params](/info/02-BrowseDirectory.png)

The script read the directories recursively. Keep your trajectories in a logical directory structure. For example: 
 |- data
 
    |- E2
	
       |- 100pM
	   
       |  |-ctrl
	   
       |  |-treated
	   
       |- 100nM
	   
          |-ctrl
		  
          |-treated
		  

04. When the analysis completed, you will be informed.

![Motion blur](/info/03-Done.png)
		  
05. The output file contains the following:
 - The name of trajectory
 - The length of trajectory (in frames)
 - The diffusion coefficient (um^2/s) calculated by Maximum likelihood method
 - The localization error (nm) extracted by  by Maximum likelihood method
 - The diffusion coefficient (um^2/s) calculated by MSD method
 - The y-intercept (nm^2) Provided by MSD method
 - The crawled area (um^2, convex hull) 
 - The maximal distance (um)
 
The output files (Results_output.txt) are saved in each directory.

