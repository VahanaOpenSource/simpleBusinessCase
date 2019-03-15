clear;clc

%Input data range
nRange=100;
massGrossRange=linspace(1000,5000,nRange);  %Gross takeoff mass evaluation range [kg]
vCruiseRange=linspace(10,110,nRange);       %Cruise speed evaluation range [m/s]

nDist=100;
dMission = linspace(1,100,nDist);

[M,V]=meshgrid(massGrossRange,vCruiseRange); M=M'; V=V';
pilot=0;
nPax=[2:5]-pilot;
unit=ones(numel(M),1);
%Technology State
technology='c';

switch lower(technology)
    case 'a' %Basic cells, EIS
        specificBatteryCost=350/3600/1000;
        cellSpecificEnergy=240*3600;
        cycleLifeFactor=315;
        specificHullCost=1360;
    case 'b' %Advanced cells, EIS
        specificBatteryCost=2000/3600/1000;
        cellSpecificEnergy=325*3600;
        cycleLifeFactor=315;
        specificHullCost=1360;
    case 'c' %Advanced cells, at scale
        specificBatteryCost=500/3600/1000;
        specificBatteryCost=250/3600/1000;
        cellSpecificEnergy=325*3600;
        cycleLifeFactor=750;
        specificHullCost=860;
        specificHullCost=550;
end
inputs={'specificBatteryCost',specificBatteryCost,'cellSpecificEnergy',cellSpecificEnergy,'pilot',pilot,'specificHullCost',specificHullCost,'cycleLifeFactor',cycleLifeFactor,'pilot',pilot,'dValue',16};

for i=1:length(nPax)
    
    [P,R,T,L,C]=simpleBusinessCase(repmat(M(:),1,nDist),repmat(V(:),1,nDist),nPax(i),...
        'dMission',repmat(dMission,nRange^2,1), ...
        inputs{:},'out',{'profitPerYear';'range';'costPerFlightHour';'lod';'aircraftCost';});
    
    P=reshape(P,nRange,nRange)/1e6;
    %R=reshape(R,nRange,nRange)/1e3;
    %T=reshape(T,nRange,nRange);
    %L=reshape(L,nRange,nRange);
    %C=reshape(C,nRange,nRange);
    
    %Plot results
    if numel(R)>4
        %Plot contours of ticket price, GTOW, and profitability
        figure(1);
        if i==1; clf; end
        subplot(1,length(nPax),i); hold on;
        %contour(V*3.6,M,C,'linewidth',2,'ShowText','on','linecolor',[0.9 0.9 1])
        contour(V*3.6,M,P,'linewidth',2,'ShowText','on')
        xlabel('Cruise speed [km/h]')
        ylabel('Range [km]')
        %ylim([0 80])
        
        title({'Annual profit per vehicle [$M]';[num2str(nPax(i),'%0.0f') ' pax + ' num2str(pilot,'%0.0f') ' pilot']})
        grid on
        
        %Keep color mapping the same between all figures
        if i==1
            clim=[min(min(P)) max(max(P))];
        else
            clim(1)=min(min(min(P)),clim(1));
            clim(2)=max(max(max(P)),clim(2));
        end
    end
end

%Harmonize plot colors
if numel(R)>4
    for i=1:length(nPax)
        figure(1);
        subplot(1,length(nPax),i);
        caxis(clim)
        colormap(parula)
    end
end