%% Interpretabilidad : Optimization PATH

%%

% Change default axes fonts.
set(0,'DefaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize', 14)
% Change default text fonts.
set(0,'DefaultTextFontname', 'Times New Roman')
set(0,'DefaultTextFontSize', 14)

%%

load WS_05;

XPOP=[];
Jdm=[];
Xdm=[];
for i=1:500
    XPOP=[XPOP; OUT.Param.OptLog{3,i}];
    idx=find(OUT.Param.OptLog{1,i}(:,3)==min(OUT.Param.OptLog{1,i}(:,3)));
    Jdm=[Jdm; OUT.Param.OptLog{1,i}(idx(1),1:3)];
    Xdm=[Xdm; OUT.Param.OptLog{1,i}(idx(1),4:7)];
end
size(XPOP)
%XPOP=unique(XPOP,'rows');
%Ytsne=tsne(XPOP(:,4:7));


%%
% scatter3(Ytsne(:,1),Ytsne(:,2),XPOP(:,2),20,XPOP(:,2),'filled')
% colormap(parula);

%%

%scatter3(XPOP(:,4),XPOP(:,6),XPOP(:,7),20,XPOP(:,2),'filled')
%colormap(parula);
%colorbar

%% PCA Childs

X=XPOP(:,4:7)-mean(XPOP(:,4:7));
[coeff, score, ~,~,explained]=pca(X);
[~,idx]=sortrows(-XPOP(:,2));
scatter(score(idx,1),score(idx,2),20,XPOP(idx,2),'filled');
colorbar
%% Path DM selection

Xdm_pca=Xdm-mean(XPOP(:,4:7));
score_new=Xdm_pca*coeff;
hold on;
plot(score_new(:,1),score_new(:,2),'-ks','MarkerEdgeColor','k');
xlabel('PC-1')
ylabel('PC-2')
saveas(gcf,'Landscape.png');

%% Parameter Evolution Child

for i=1:500
    Kp(:,i)=OUT.Param.OptLog{3,i}(:,4);
    Ki(:,i)=OUT.Param.OptLog{3,i}(:,5);
    Kd(:,i)=OUT.Param.OptLog{3,i}(:,6);
    Ka(:,i)=OUT.Param.OptLog{3,i}(:,7);
end

%boxplot(Kp)
plot(median(Kp),'k');
hold;
plot(median(Ki),'b');
plot(median(Kd),'r');
plot(median(Ka),'m');
xline(20,'LineWidth',2,'Color','g');

xlabel('Generation')
ylabel('Gain value')

legend({'Kp','Ki','Kd','Ka'},'Location','southeast')

saveas(gcf,'Parameter_Offspring.png');

%% Dominance Behavior

for i=1:500
    Kp(:,i)=OUT.Param.OptLog{2,i}(:,4);
    Ki(:,i)=OUT.Param.OptLog{2,i}(:,5);
    Kd(:,i)=OUT.Param.OptLog{2,i}(:,6);
    Ka(:,i)=OUT.Param.OptLog{2,i}(:,7);
end

%boxplot(Kp)
plot(median(Kp),'k');
hold;
plot(median(Ki),'b');
plot(median(Kd),'r');
plot(median(Ka),'m');
xline(20,'LineWidth',2,'Color','g');

xlabel('Generation')
ylabel('Gain value')

legend({'Kp','Ki','Kd','Ka'},'Location','southeast')

saveas(gcf,'Parameter_Parent.png');

%% 

PF=OUT.PFront;
plot(PF(:,1),PF(:,3),'dr','MarkerFaceColor','r');
xlabel('Frames played')
ylabel('Adversary score')
saveas(gcf,'PF.png');

%%

for i=1:500
    if min(OUT.Param.OptLog{1,i}(:,2))==-21
        display(num2str(i));
        break
    end
end

%% winning
% 19 -20 ; 18 - 29; 17 - 40; 16 - 157; 15 - 338 ; 14 - 148 ; 13 - 114;

for i=1:500
    idx=find(OUT.Param.OptLog{1,i}(:,3)==12);
    if ~isempty(idx)
        display(num2str(i));
        break
    end
end
