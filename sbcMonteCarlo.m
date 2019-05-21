% Monte Carlo analysis of sbc
%
% The user supplies prior probability distributions for inputs (assumptions)
% A Monte Carlo scheme is used to sample from those distributions, and the
% design that maximize profit for each sampled set of assumptions is
% found. 

clear
clc
rng default % Reset random number generator to make repeatable

%% Monte Carlo Values
n = 200;

%% Design values
dValue = 14;
pilot = 0; % Number of pilots (non-paying passengers)
nPax = 3;

%% Assumption distributions
a = struct(); 
i=1;
a(i).name = 'timeValue'; % Premium market value of time [$/s]
a(i).mean = 2.5/60;
a(i).std = 1/60;

i=i+1;
a(i).name = 'distanceValue';  % Ticket price charged per distance [$/m]
a(i).mean = 3.5/1000;
a(i).std = 0.5/1000;

i=i+1;
a(i).name = 'flightTimeValue'; % Ticket price per time [$/s]
a(i).mean = 0.25;
a(i).std = 0.05;

% Vehicle
i=i+1;
a(i).name = 'emptyFraction'; % Empty mass fraction
a(i).mean = 0.6;
a(i).std = 0.03;

i=i+1;
a(i).name = 'hoverEfficiency'; % Hover electical efficiency (motor+controller+line)
a(i).mean = 0.93*0.98*0.98;
a(i).std = 0.01;

i=i+1;
a(i).name = 'hoverKappa'; % Account for induced tip losses
a(i).mean = 1.1;
a(i).std = 0.02;

i=i+1;
a(i).name = 'areaRotorFraction'; % d-value area occupied by disk area
a(i).mean = 0.32;
a(i).std = 0.02;

i=i+1;
a(i).name = 'bladeCl'; % Blade average cl
a(i).mean = 0.7;
a(i).std = 0.05;

i=i+1;
a(i).name = 'bladeCd'; % Blade average cd
a(i).mean = 0.018;
a(i).std = 0.002;

i=i+1;
a(i).name = 'tipMach'; % Hover tip speed limit at sea level
a(i).mean = 0.45;
a(i).std = 0.02;

i=i+1;
a(i).name = 'cruiseEfficiency'; % Cruise electrical + prop efficiency (motor+controller+line+prop)
a(i).mean = 0.9*0.96*0.98*0.81;
a(i).std = 0.03;

i=i+1;
a(i).name = 'cruiseCl'; % Cruise lift coefficient
a(i).mean = 0.55;
a(i).std = 0.03;

i=i+1;
a(i).name = 'Cd0'; % Cruise parasite drag coefficient
a(i).mean = 0.045;
a(i).std = 0.005;

% %Propulsion System
i=i+1;
a(i).name = 'cellSpecificEnergy'; % Cruise parasite drag coefficient
a(i).mean = 300 * 3600;
a(i).std = 25 * 3600; % Current cells on low end, Amprius on high end

i=i+1;
a(i).name = 'integrationFactor'; % Cruise parasite drag coefficient
a(i).mean = 0.75;
a(i).std = 0.03;

i=i+1;
a(i).name = 'endOfLifeFactor'; % Cruise parasite drag coefficient
a(i).mean = 0.8;
a(i).std = 0.0;

i=i+1;
a(i).name = 'cycleLifeFactor'; % Cruise parasite drag coefficient
a(i).mean = 515;
a(i).std = 100; % Current values as optimistic

i=i+1;
a(i).name = 'depthDegradationRate'; % Cruise parasite drag coefficient
a(i).mean = 2;
a(i).std = 0.24; % Current values as optimistic

i=i+1;
a(i).name = 'reserveEnergyFactor'; % Reserve energy in pack (including unusable)
a(i).mean = 0.15;
a(i).std = 0.02;

% Mission specifications
i=i+1;
a(i).name = 'vHeadwind'; % Sizing headwind [m/s]
a(i).mean = 0;
a(i).std = 3;

i=i+1;
a(i).name = 'tHover'; % Time spent in hover [s]
a(i).mean = 3 * 60;
a(i).std = 0.5 * 60;

i=i+1;
a(i).name = 'tAlternate'; % Maximum time spent in alternate [s]
a(i).mean = 900; % 15 min
a(i).std = 150; % 2.5 min

i=i+1;
a(i).name = 'dAlternate'; % Maximum distance covered for an alternate [km]
a(i).mean = 15e3;
a(i).std = 5e3;

% Operations Specifications
i=i+1;
a(i).name = 'operatingTimePerDay'; % Hours of operation per day [s/day]
a(i).mean = 8 * 3600;
a(i).std = 1 * 3600;

i=i+1;
a(i).name = 'scheduledAvailabilityRate'; % Rate that vehicle is in scheduled operation
a(i).mean = 0.9;
a(i).std = 0.02;

i=i+1;
a(i).name = 'unscheduledAvailabilityRate'; % Rate that vehicle is available (e.g. weather)
a(i).mean = 0.9;
a(i).std = 0.02;

i=i+1;
a(i).name = 'padTurnAroundTime'; % Time between landing and takeoff [s]
a(i).mean = 5*60;
a(i).std = 60;

i=i+1;
a(i).name = 'deadheadRate'; % Percentage of trips that are deadhead
a(i).mean = 0.5;
a(i).std = 0.1;

i=i+1;
a(i).name = 'operatingCostFactor'; % Fraction of costs in addition to DOC and landing fees
a(i).mean = 1.5;
a(i).std = 0.1;

% Cost Specifications
i=i+1;
a(i).name = 'specificCellCost'; % Total pack specific cost [$/J]
a(i).mean = 400 / 3600 / 1000;
a(i).std = 200 / 3600 / 1000;

i=i+1;
a(i).name = 'costElectricity'; % Cost of electricty [$/J]
a(i).mean = 0.2 / 3600 / 1000;
a(i).std = 0.03 / 3600 / 1000;

i=i+1;
a(i).name = 'specificHullCost'; % Specific cost of the vehicle [$/kg]
a(i).mean = 550;
a(i).std = 50;

i=i+1;
a(i).name = 'depreciationRate'; % Annual depreciation rate [fraction of hull cost]
a(i).mean = 0.1;
a(i).std = 0.0;

i=i+1;
a(i).name = 'costLiabilityPerYear'; % Annual liability cost [$/year]
a(i).mean = 22000;
a(i).std = 2000;

i=i+1;
a(i).name = 'hullRatePerYear'; % Annual hull insurance rate [% of hull cost]
a(i).mean = 0.045;
a(i).std = 0.005;

i=i+1;
a(i).name = 'annualServicesFees'; % Annual fees for maintenance, navigation, datalink [$/year]
a(i).mean = 7700;
a(i).std = 2000;

i=i+1;
a(i).name = 'maintananceCostPerFH'; % Maintenance cost per FH [$/FH]
a(i).mean = 100;
a(i).std = 20;

i=i+1;
a(i).name = 'landingFee'; % Cost per landing
a(i).mean = 50;
a(i).std = 10;

i=i+1;
a(i).name = 'pilotCostRate'; % Annual pilot cost (including benefits)
a(i).mean = 280500;
a(i).std = 50000;

i=i+1;
a(i).name = 'trainingCostRate'; % Annual training cost
a(i).mean = 9900;
a(i).std = 2000;

% Customer Experience
i=i+1;
a(i).name = 'taxiDistanceRate'; % Taxi ticket price per km [$/m]
a(i).mean = 1.5/1000;
a(i).std = 0.25/1000;

i=i+1;
a(i).name = 'lastLegDistance'; % Distance to drive from helipad to destination [m]
a(i).mean = 3000;
a(i).std = 500;

i=i+1;
a(i).name = 'curbTime'; % Time to transfer from gate to curb [s]
a(i).mean = 16 * 60;
a(i).std = 3 * 60;

i=i+1;
a(i).name = 'unloadTime'; % Time to unload from taxi [s]
a(i).mean = 1 * 60;
a(i).std = 20;

i=i+1;
a(i).name = 'transferTime'; % Time to transfer from gate to helipad including security [s]
a(i).mean = 24 * 60;
a(i).std = 3 * 60;

i=i+1;
a(i).name = 'alightTime'; % Time to alight and get to curb [s]
a(i).mean = 4 * 60;
a(i).std = 1 * 60;

% Storage for inputs and outputs
inputs = cell(n,4 + 2 * length(a));
profitPerYear = zeros(n,1);
costPerFlightHour = zeros(n,1);
impliedValue = zeros(n,1);
range = zeros(n,1);
mass = zeros(n,1);
vCruise = zeros(n,1);
dischargeRate = zeros(n,1);
dischargeDepth = zeros(n,1);
outName={'profitPerYear';'costPerFlightHour';'impliedValue';'range';'massGross';'vCruise';'dischargeRate';'dischargeDepth'};
for i = 1:n
    inputs(i,1:4) = {'dValue',dValue,'pilot',pilot};
    for j = 1:length(a)
        inputs{i,2*j+3} = a(j).name;
        inputs{i,2*j+4} = a(j).mean + randn * a(j).std;
    end
    [profitPerYear(i),costPerFlightHour(i),impliedValue(i),range(i), mass(i), vCruise(i), dischargeRate(i), ...
        dischargeDepth(i)] = sbcOpt(nPax,inputs{i,:});
    if rem(i,n/100) == 0
        disp([num2str(i),' of ',num2str(n)]);
    end
end

% Compute correlations between inputs and outputs:
[~,nInputs] = size(inputs);
out = [profitPerYear,costPerFlightHour,impliedValue,range,mass,vCruise,dischargeRate,dischargeDepth];
inputs(isnan(out(:,1)),:)=[];
out(isnan(out(:,1)),:)=[];
meanOut = mean(out);
[~,nOutputs] = size(out);
r = zeros(nInputs/2,nOutputs);
for i = 1:2:nInputs
    in = cat(1,inputs{:,i+1});
    meanIn = mean(in);
    for j = 1:nOutputs
        tmp = cov(in,out(:,j));
        r((i-1)/2+1,j) = tmp(1,2) / (sqrt(tmp(1,1)) * sqrt(tmp(2,2)));
    end
end

for j = 1:nOutputs
    fprintf('\n');
    disp(['Correlations to ',outName{j},' > 0.2']);
    disp(['=====================================']);
    for i = 1:nInputs/2
        if abs(r(i,j)) > 0.2
            disp([inputs{1,2*i-1},': ',num2str(r(i,j))])
        end
    end
end

%% Plot histograms
%figuren('Results'); clf;

subplot(4,2,1); hold on;
hist(profitPerYear/1e6,100)
xlabel('Profit per vehicle per year [$M]')
grid on

subplot(4,2,2); hold on;
hist(range/1e3,100)
xlabel('Range [km]')
grid on

subplot(4,2,3); hold on;
hist(costPerFlightHour,100)
xlabel('Cost per flight hour [$]')
grid on

subplot(4,2,4); hold on;
hist(dischargeRate,100)
xlabel('Average Discharge Rate [C]')
grid on

subplot(4,2,5); hold on;
hist(mass,100)
xlabel('Mass [kg]')
grid on

subplot(4,2,6); hold on;
hist(impliedValue,0:0.25:100)
xlabel('Implied value [$ per minute saved]')
grid on
xlim([0,10]);

subplot(4,2,7); hold on;
hist(vCruise,100)
xlabel('Cruise Speed [m/s]')
grid on

subplot(4,2,8); hold on;
hist(dischargeDepth,100)
xlabel('Discharge Depth')
grid on



%% Show input/output scatter plots
% for i = 1:nInputs/2
%     
%     if rem(i-1,6) == 0
%         figuren(['Scatterplot ',num2str((i-1)/6+1)]); clf;
%     end
%     
%     for j = 1:nOutputs
%         subplotIdx = rem(i-1,6)*nOutputs+j;
%         subplot(6,8,subplotIdx); hold on;
%         plot(cat(1,inputs{:,2*i}),out(:,j),'.')
%         grid on
%         
%         if rem(subplotIdx,nOutputs) == 1
%             ylabel(inputs{1,2*i-1})
%         end
%         if subplotIdx / 8 > 5
%             xlabel(outName{j})
%         end
%     end
% end