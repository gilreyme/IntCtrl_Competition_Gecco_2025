%% MOEAparam
% Generates the required parameters to run the spMODEx algorithm.

%% Beta version 
% Follow on Twitter using #spMODEx
%
%%
%% Author
% Gilberto Reynoso-Meza (ORCID:0000-0002-8392-6225)
% http://www.researchgate.net/profile/Gilberto_Reynoso-Meza
% http://www.mathworks.es/matlabcentral/fileexchange/authors/289050
%
%% For announcements about new versions and / or bug fixing, please visit:
%
% Matlab Central File Exchange
% http://twitter.com/gilreyme , #spMODEx
%
%%
%% Overall Description
% This code generates parameters required to run the spMODEx algorithm.
%
% According to the requirements of the user, different mechanisms might be
% enabled here:
%
% DIVERSITY mechanism(s): 
%           (1) spherical prunning, release 2017.
%
% PERTINENCY mechanism(s): 
%           (1) global physical programming, release 2017.
%
% MANY-OBJECTIVES mechanism(s): 
%           (1) spherical prunning with preferences, release 2017.
%
% CONSTRAINT handling(2): 
%           (1) spherical prunning with preferences, release 2017.
%
% For detailed description of such mechanisms, relevant papers are
% referenced in ReadME.txt file.

%%
if ismac
    addpath(genpath('/MATLAB Drive/Published/SPIN_labs Optimisation/sp-MODEx/MainToolbox/spMODEx'));
elseif ispc
    addpath('C:\Users\greyn\MATLAB Drive\Published\SPIN_labs Optimisation\sp-MODEx\MainToolbox\spMODEx')
end

%% Variables regarding the multi-objective problem

spMODExDat.NOBJ = 3;                   % Number of decision objectives.
spMODExDat.PFrontSize=100;
spMODExDat.Alphas=10;

 
spMODExDat.NRES = 0;                   % Number of constraints plus
                                      % non-decision objectives. That is,
                                      % variables that are not used to
                                      % built the spherical grid, but used
                                      % in the norm computation.

spMODExDat.NVAR = 4;                  % Number of decision variables

spMODExDat.FieldD  = ...               % Optimization bounds
[0 2; 0 2; 0 2; 0 2];

spMODExDat.Initial = spMODExDat.FieldD; % Initialization bounds

spMODExDat.mop  =...
    str2func('CF');         % Cost Function



%%
%% Variables regarding the optimization algorithm (Differential Evolution)

spMODExDat.Xpop = 20;                 % Population size

spMODExDat.ScalingFactor = 0.5;       % Scaling factor

spMODExDat.CRrate= 0.5;               % Croosover Probability

spMODExDat.Recombination='binomial';  % binomial or lineal                                           
%
%%
%% Variables regarding spreading (spherical pruning)

spMODExDat.Strategy='SphP';           % 'Push' for a basic Dominance-based 
                                     % selection; 'SphP' for the spherical
                                     % pruning;

spMODExDat.Norm='euclidean';           % Norm to be used in Strategy='SphP';
                                     % It could be 'euclidean','manhattan',
                                     % 'infinite', 'physical' or 'custom'.
                                     % When using "custom" the user needs
                                     % to define his/her own custom
                                     % function to calculate the norm with
                                     % the format:
                                     % IndexesOUT=...
                                     %   CustomNorm(Front,Set,spMODEDat)
                                     
%
%%
%% Variables regarding pertinency (Global Physical Programming)
% The following values for each design objective (decision objective +
% non-decision objective) and constraint shall be defined:
%
% Physical Matrix Definition.
% HD Highly Desirable
% D  Desirable
% T  Tolerable
% U  Untolerable
% HU Highly Untolerable
%                                    HD  -      D -         T  -   U  -       HD
 spMODExDat.PhyMatrix{1} = [0.6  0.8  1  1.2  2   5;
                           0.6  0.8  1   1.2 2   5;
                            0.6  0.8  1   1.2  2   5];      
                       
% spMODExDat.PhyMatrix{1} = [.4*(FN)  .6*(FN)  .8*(FN)  1*FN  2*(FN)   5*(FN);
%                           .4*(FP)  .6*(FP)  .8*(FP)  1*FP  2*(FP)   5*(FP)];  
% The above is based on _Global Physical Programming_ and _Physical
% Programming_; both are used to state preferences when dealing with 
% several objectives. For more see the following:

% J. Sanchis, M. Mart�nez, X. Blasco, G. Reynoso. Modelling preferences in
% multi-objective engineering design. Engineering Applications of 
% Artificial Intelligence. Vol. 23, num. 8, pp. 1255 - 1264, 2010.
%
% and
%
% A. Messac. Physical programming: effective optimization for computational
% design. AIAA Journal 34 (1), 149 � 158, 1996
                      
spMODExDat.MaxAllowedNorm=...         % Tolerable vector is used as default.
    PhyIndex(spMODExDat.PhyMatrix{1}(:,4)',spMODExDat);
% When using the tolerable vector as default, the algorithm will look to
% approximate a Pareto front approximation with only Tolerable values.

%%
%% Regarding Constraint Handling (different for objectives bound)
%
% Constraints could be defined as additional objectives. For an example
% please refer to:
%
% G. Reynoso-Meza, X. Blasco, J. Sanchis, M. Mart�nez. Multiobjective 
% optimization algorithm for solving constrained single objective problems.
% Evolutionary Computation (CEC), 2010 IEEE Congress on. 18-23 July 2010
%
% In such case, we encourage to define a Pertinency vector (above) or the
% PhyMatrix cell (also above) accordingly.
%
%%
%% Execution Variables

spMODExDat.MAXGEN =500;              % Generation bound

spMODExDat.MAXFUNEVALS = 2e5;        % Function evaluations bound
spMODExDat.PobInitial=[];            % Initial population (if any)

spMODExDat.SaveResults='no';         % Write 'yes' if you want to 
                                    % save your results after the
                                    % optimization process;
                                    % otherwise, write 'no';

spMODExDat.Plotter='yes';            % 'yes' if you want to see some
                                    % a graph at each generation.

spMODExDat.SeeProgress='yes';        % 'yes' if you want to see some
                                    % information at each generation.
%
%%
%% Put here the variables required by your code (if any).
% These variables could be used in your cost function file and/or your
% custom norm.
%
spMODExDat.OptLog{1,1}={};
spMODExDat.OptLog{2,1}={};
spMODExDat.OptLog{3,1}={};

%
%% Release and bug report:
%
% October 2017: Initial release
