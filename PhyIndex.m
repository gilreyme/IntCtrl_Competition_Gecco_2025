%% PhyIndex
%
% Calculates the Physical Index for an objective vector.
%
% J  [OUT] : The objective Vector. J is a matrix with as many rows as
%            trial vectors in X and as many columns as objectives.
% Dat [IN] : Parameters defined in MOEAparam.m and updated in spMODE.m
%
% PhyIndexes [OUT] : The Physical Indexest. Calculated according the 
%                    Preferencences Matrix previously defined in 
%                    MOEAparam.

%%
%% Beta version 
% Copyright 2017
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
% This code implements a physical index calculation, according to:
%
% Reynoso-Meza, G., Sanchis, J., Blasco, X., & García-Nieto, S. (2014). 
% Physical programming for preference driven evolutionary multi-objective 
% optimization. Applied Soft Computing, 24, 341-362.
%
%%
%%
function PhyIndexes=PhyIndex(J,Dat)

Matrixes=size(Dat.PhyMatrix,2);
Population=size(J,1);
Nobj=size(J,2);
F=zeros(Population,Nobj);

offset=0.1*[0, 1, 2, 3, 4, 5];
delta=[0 0 0 0 0 0];

for i=2:6
    delta(1,i)=(Nobj+1)*(delta(1,i-1)+offset(1,i));
end

PhyIndexes=2*(offset(6)+delta(6))*ones(Population,1);

for matrixes=1:Matrixes
    Phy=Dat.PhyMatrix{matrixes};
    if size(Dat.PhyMatrix{matrixes},2)<6
        for i=size(Dat.PhyMatrix,2)+1:6
            Phy(:,i)=Dat.PhyMatrix{matrixes}(:,end);
        end
    else
        Phy=Dat.PhyMatrix{matrixes};
    end
    
    % HD Highly Desirable
    % D  Desirable
    % T  Tolerable
    % U  Untolerable
    % HU Highly Untolerable
    
    for population=1:Population
        for nobj=1:Nobj
            if J(population,nobj)>Phy(nobj,1) && J(population,nobj) <= Phy(nobj,2)     % We have a HD value
                F(population,nobj)=offset(1) + delta(1) + (offset(2)-offset(1))*((J(population,nobj)-Phy(nobj,1))/(Phy(nobj,2)-Phy(nobj,1)));
            elseif J(population,nobj)>Phy(nobj,2) && J(population,nobj) <= Phy(nobj,3) % We have a D value
                F(population,nobj)=offset(2) + delta(2) + (offset(3)-offset(2))*((J(population,nobj)-Phy(nobj,2))/(Phy(nobj,3)-Phy(nobj,2)));
            elseif J(population,nobj)>Phy(nobj,3) && J(population,nobj) <= Phy(nobj,4) % We have a T value
                F(population,nobj)=offset(3) + delta(3) + (offset(4)-offset(3))*((J(population,nobj)-Phy(nobj,3))/(Phy(nobj,4)-Phy(nobj,3)));
            elseif J(population,nobj)>Phy(nobj,4) && J(population,nobj) <= Phy(nobj,5) % We have an U value
                F(population,nobj)=offset(4) + delta(4) + (offset(5)-offset(4))*((J(population,nobj)-Phy(nobj,4))/(Phy(nobj,5)-Phy(nobj,4)));
            elseif J(population,nobj)>Phy(nobj,5) && J(population,nobj) <= Phy(nobj,6) % We have a HU value
                F(population,nobj)=offset(5) + delta(5) + (offset(6)-offset(5))*((J(population,nobj)-Phy(nobj,5))/(Phy(nobj,6)-Phy(nobj,5)));
            elseif J(population,nobj)>Phy(nobj,6)                                    % We have an uninteresting value
                F(population,nobj)=offset(6) + delta(6);
            end
        end
        PhyIndexes(population,1)=min(PhyIndexes(population,1),sum(F(population,:)));
    end
end
%%
%% Release and bug report:
%
% October 2017: Initial release
