clear;clc

%Input data range
nRange=50;
massGrossRange=linspace(1000,5000,nRange);  %Gross takeoff mass evaluation range [kg]
vCruiseRange=linspace(10,110,nRange);       %Cruise speed evaluation range [m/s]

[M,V]=meshgrid(massGrossRange,vCruiseRange); M=M'; V=V';
pilot=0;
nPax=2:5;
unit=ones(numel(M),1);
%Battery data
cellType='a';

switch lower(cellType)
    case 'a' %Advanced cells
        specificBatteryCost=660/3600/1000;
        specificBatteryCost=200/3600/1000;
        cellSpecificEnergy=325*3600;
        depthDegradationRate=3.662;
    case 'b' %Basic cells
        specificBatteryCost=250/3600/1000;
        cellSpecificEnergy=240*3600;
        depthDegradationRate=3.18;
end
inputs={'specificBatteryCost',specificBatteryCost,'cellSpecificEnergy',cellSpecificEnergy,'depthDegradationRate',depthDegradationRate};


for i=1:length(nPax)
    [P,R]=simpleBusinessCase(M(:),V(:),nPax(i),inputs{:},'out',{'profitPerYear';'range'});%,'dMission',dMission,'cellSpecificEnergy',340*3600,'cycleLifeFactor',1000,'specificBatteryCost',400/3600/1000);
    
    P=reshape(P,nRange,nRange)/1e6;
    R=reshape(R,nRange,nRange)/1e3;
    
    %Plot results
    if numel(R)>4
        %Plot contours of ticket price, GTOW, and profitability
        figure(1);
        if i==1; clf; end
        subplot(1,length(nPax),i); hold on;
        
        contour(V*3.6,R,M,'linewidth',2,'ShowText','on','linecolor',[1 0.9 0.9])
        contour(V*3.6,R,P,'linewidth',2,'ShowText','on')
        xlabel('Cruise speed [km/h]')
        ylabel('Range [km]')
        ylim([0 100])
        
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

%%
% nPax=2:5;
% dMission=linspace(20,70,20)*1000;
% massGrossRange=linspace(1000,5000,10);  %Gross takeoff mass evaluation range [kg]
% vCruiseRange=linspace(10,110,20);       %Cruise speed evaluation range [m/s]
% [M,V]=meshgrid(massGrossRange,vCruiseRange);
%
% lb=[0 0]; ub=[5000 200];
% options=optimoptions('fmincon','ScaleProblem','obj-and-constr','display','none');
% for i=1:length(nPax)
%     x0=[50 3000];
%     for j=1:length(dMission)
%         %Initial guess
%         P=simpleBusinessCase(M,V,nPax(i),'dMission',dMission(j),inputs{:});
%
%         if ~all(all(isnan(P)))
%             x0(1)=M(P(:)==max(P(:)));
%             x0(2)=V(P(:)==max(P(:)));
%
%             %For a given mission distance and vehicle mass, find the cruise speed
%             %that maximizes profit.
%             [x,p(j)]=fminsearch(@(x) -simpleBusinessCase(x(1),x(2),nPax(i),'dMission',dMission(j),inputs{:}),x0);
%             m(j)=x(1);
%             v(j)=x(2);
%             p(j)=-p(j);
%         else
%             m(j)=nan;
%             v(j)=nan;
%             p(j)=nan;
%         end
%     end
%     figure(2);
%     if i==1; clf; end
%     subplot(1,3,1); hold on; plot(dMission/1e3,m/1e3,'linewidth',2); ylabel('GTOW [ton]')
%     subplot(1,3,2); hold on; plot(dMission/1e3,p/1e6,'linewidth',2); ylabel('Annual profit per vehicle [$]')
%     subplot(1,3,3); hold on; plot(dMission/1e3,v*3.6,'linewidth',2); ylabel('Cruise Speed [km/h]')
% end
%
% for i=1:3
%     figure(2)
%     subplot(1,3,i)
%     xlabel('Trip Distance [km]')
%     legend('2 pax','3 pax','4 pax','5 pax')
%     grid on
% end