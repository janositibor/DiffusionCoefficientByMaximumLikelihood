# DiffusionCoefficientByMaximumLikelihood
Maximum likelihood based estimation of diffusion coefficient

01. Run the script Main.m in Matlab.
02. Define basic parameters of the measured trajectories.

![Input fields to define params](/info/01-DefineParams.png)

03. Choose directory for the trajectories.

![Input fields to define params](/info/02-BrowseDirectory.png)

The script read the directories recursively. Keep your trajectories in a logical directory structure. For example: 

.
+-- _config.yml
+-- _drafts
|   +-- begin-with-the-crazy-ideas.textile
|   +-- on-simplicity-in-technology.markdown
+-- _includes
|   +-- footer.html
|   +-- header.html
+-- _layouts
|   +-- default.html
|   +-- post.html
+-- _posts
|   +-- 2007-10-29-why-every-programmer-should-play-nethack.textile
|   +-- 2009-04-26-barcamp-boston-4-roundup.textile
+-- _data
|   +-- members.yml
+-- _site
+-- index.html

+--data
    +--E2
        +--100pM
                ctrl
                treated
            100nM
                ctrl
                treated
		  
 |- data
    |- E2
       |- 100pM
       |  |-ctrl
       |  |-treated
       |- 100nM
          |-ctrl
          |-treated
		  
		  
├── data

    ├── E2
	
        ├── 100pM
		
		│   ├── ctrl
    
		│   ├── treated

        ├── 100nM
		
		    ├── ctrl
    
		    ├── treated



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

