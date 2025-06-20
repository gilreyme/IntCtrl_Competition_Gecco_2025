%% SphPruning
%
% Prune a set of multi-objective vectors using spherical coordinates.
%
% J  [OUT] : The objective Vector. J is a matrix with as many rows as
%            trial vectors in X and as many columns as objectives.
% X   [IN] : Decision Variable Vector. X is a matrix with as many rows as
%            trial vector and as many columns as decision variables.
% Dat [IN] : Parameters defined in MOEAparam.m and updated in spMODE.m
%
% PFront [OUT] : The Pruned Front. PFront is a matrix with as many rows
%                as vectors in PSet and as many columns as objectives.
% PSet   [OUT] : The Pruned Set. PSet is a matrix with as many rows as
%                vectors and as many columns as decision variables.
% Dat    [OUT] : Updated parameters
%

%%
%% Beta version 
% Copyright 2017
%
%%
%% Author
% Gilberto Reynoso-Meza (ORCID:0000-0002-8392-6225)
% http://www.researchgate.net/profile/Gilberto_Reynoso-Meza
% http://www.mathworks.es/matlabcentral/fileexchange/authors/289050
%
%%
%% For announcements about new versions and / or bug fixing, please visit:
%
% Matlab Central File Exchange
% http://twitter.com/gilreyme , #spMODEx
%
%%
%% Overall Description
% This code implements the spherical pruning described in:
%
% Reynoso-Meza G., Sanchis J., Blasco X., Martínez M. (2010) 
% Design of Continuous Controllers Using a Multiobjective Differential 
% Evolution Algorithm with Spherical Pruning. 
% In: Di Chio C. et al. (eds) Applications of Evolutionary Computation. 
% EvoApplications 2010. Lecture Notes in Computer Science, vol 6024. 
% Springer, Berlin, Heidelberg
% 
% It can be used with any set of solutions. Dominance is guaranted IIF
% the input set has only Pareto Optimal solutions.
%
function [PFront, PSet, Dat]=SphPruning(J,X,Dat)

% Reading variables from Dat
Nobj   = Dat.NOBJ;     % Number of objectives.
Nvar   = Dat.NVAR;     % Number of variables.
Nres   = Dat.NRES;     % Number of costraints.
Xpop   = (size(J,1));  % Population size.
Alphas = Dat.Alphas;   % Number of arcs in the grid.

% Updating variables
if strcmp(Dat.Norm,'physical')
    UpperLim = Dat.PhyMatrix{1}(:,4)';
    LowerLim = min([Dat.AnchorsY;Dat.PhyMatrix{1}(:,1)']);
else
    UpperLim = max([Dat.AnchorsY;]); % Look for extremes.
    LowerLim = min(Dat.AnchorsY);
end

% To be sure we have numbers to work on.
for n=1:size(UpperLim,2)
    if UpperLim(1,n)==LowerLim(1,n)
        UpperLim(1,n)=UpperLim(1,n)+1;
    end
    if isnan(UpperLim(1,n)) || isnan(LowerLim(1,n))
        disp('alarma NAN');
        pause;
    elseif isinf(UpperLim(1,n)) || isinf(LowerLim(1,n))
        disp('alarma INF');
        pause;
    end
    
end


Dat.ExtremesPFront(1,:) = UpperLim; % Update Extremes
Dat.ExtremesPFront(2,:) = LowerLim;

% Initalization
Normas = zeros(Xpop,1);


    %% CALCULATING SPHERICAL COORDINATES

Arcs = HypCar2HypSph(J(:,1:Nobj),Dat.ExtremesPFront(2,1:Nobj),Dat.ExtremesPFront(1,1:Nobj));

if size(Arcs,1)==1
    MaxArc=Arcs+1;
    MinArc=Arcs;
else
    MaxArc=max(Arcs);
    MinArc=min(Arcs);
end

for i=1:size(Arcs,2)
    if MaxArc(1,i)==MinArc(1,i)
        MaxArc(1,i)=MaxArc(1,i)+1;
    end
end

    %% DEFINING THE SIGHT RANGE
    
Sight = (MaxArc-MinArc)./Alphas;
Sight = (1./Sight);

    %% ASSIGNING SPHERICAL SECTORS TO POPULATION
    
for xpop=1:Xpop
    Arcs(xpop,:)=ceil(Sight(1,:).*Arcs(xpop,:));
end

    %% COMPUTING NORMS    
    
    
    if strcmp(Dat.Norm,'euclidean')
        for xpop=1:Xpop
            Normas(xpop,1) = ...
                norm((J(xpop,1:Nobj)-Dat.ExtremesPFront(2,1:Nobj)) ./ ...
                (Dat.ExtremesPFront(1,1:Nobj)-Dat.ExtremesPFront(2,1:Nobj)),2);
        end
    elseif strcmp(Dat.Norm,'manhattan')
        for xpop=1:Xpop
            Normas(xpop,1) = ...
                norm((J(xpop,1:Nobj)-Dat.ExtremesPFront(2,1:Nobj)) ./ ...
                (Dat.ExtremesPFront(1,1:Nobj)-Dat.ExtremesPFront(2,1:Nobj)),1);
        end
    elseif strcmp(Dat.Norm,'infinite')
        for xpop=1:Xpop
            Normas(xpop,1) = ...
                norm((J(xpop,1:Nobj)-Dat.ExtremesPFront(2,1:Nobj)) ./ ...
                (Dat.ExtremesPFront(1,1:Nobj) - ...
                Dat.ExtremesPFront(2,1:Nobj)),Inf);
        end
    elseif strcmp(Dat.Norm,'physical')
        for xpop=1:Xpop
            Normas(xpop,1)=PhyIndex(J(xpop,:),Dat);
        end
    else
        CustomNorm=str2func(Dat.Norm);
        Normas=CustomNorm(J,X,Dat);
    end
    
    
    

    %% PRUNING
    
k = 0;
Dominancia = zeros(Xpop,1);
PFront     = zeros(Xpop,Nobj+Nres);
PSet       = zeros(Xpop,Nvar);
Arcos      = zeros(Xpop,Nobj-1);


for xpop=1:Xpop
    Dominado=Dominancia(xpop,1);

    if isfield(Dat,'MaxAllowedNorm')==0 || isempty(Dat.MaxAllowedNorm)
       
    else
        if Normas(xpop,1)>Dat.MaxAllowedNorm
            Dominado=1;
            Dominancia(xpop,1)=1;
        end
    end
    
    
    if Dominado==0    
        for compara=1:Xpop
            if (Arcs(xpop,:)==Arcs(compara,:) )
                if (xpop~=compara)
                    if Normas(xpop,1)>Normas(compara,1)
                        Dominancia(xpop,1)=1;
                        break;
                    elseif Normas(xpop,1)<Normas(compara,1)
                        Dominancia(compara,1)=1;
                    elseif Normas(xpop,1)==Normas(compara,1)
                        if compara>xpop
                            Dominancia(compara,1)=1;
                        end
                    end
                end
            end
        end
    end
    
    if Dominancia(xpop,1)==0
        k=k+1;
        PFront(k,:)=J(xpop,:);
        PSet(k,:)=X(xpop,:);
        Arcos(k,:)=Arcs(xpop,:);
    end
end


if k==0
    if strcmp(Dat.Norm,'physical')
         Acomoda=sortrows([Normas,J,X]);
         PFront=Acomoda(1,2:Nobj+Nres+1);
         PSet=Acomoda(1,Nobj+Nres+2:end);
    else
        PFront=J;
        PSet=X;
    end
elseif k>Dat.PFrontSize
         Acomoda=sortrows([Normas,J,X]);
         PFront=Acomoda(1:Dat.PFrontSize,2:Nobj+Nres+1);
         PSet=Acomoda(1:Dat.PFrontSize,Nobj+Nres+2:end);
else

    PFront=PFront(1:k,:);
    PSet=PSet(1:k,:);
end

%%

%% Computing Spherical Coordinates
function Arcs=HypCar2HypSph(X,LowerLim,UpperLim)

Xpop  = size(X,1);
Nobj  = size(X,2);
Narcs = Nobj-1;
Arcs  = zeros(Xpop,Narcs);

for xpop = 1:Xpop
    X(xpop,:)=1+(X(xpop,:)-LowerLim)./(UpperLim-LowerLim);
    Arcs(xpop,1)=atan2(X(xpop,Nobj),X(xpop,Nobj-1));
    
    if Narcs>1
        for narcs=2:Narcs
            Arcs(xpop,narcs) = ...
                atan2(norm(X(xpop,(Nobj-narcs+1):Nobj)), ...
                X(xpop,Nobj-narcs));
        end
    end
    
    for narcs=1:Narcs
        if isnan(Arcs(xpop,narcs))==1
            Arcs(xpop,narcs)=0;
        end
        if isinf(Arcs(xpop,narcs))==1
            Arcs(xpop,narcs)=0;
        end
    end
end

Arcs=(360/(2*pi))*(Arcs);
%%
%% Release and bug report:
%
% October 2017: Initial release