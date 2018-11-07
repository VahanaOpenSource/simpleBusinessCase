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
nPax = 2;
dMission = 40e3;
nDesignValues = 4; %Number of above design values 

%% Assumption distributions
a = struct();
a(1).name = 'timeValue'; % Premium market value of time [$/s]
a(1).mean = 3;
a(1).std = 0.5;

a(2).name = 'distanceValue';  % Ticket price charged per distance [$/m]
a(2).mean = 3.5/1000;
a(2).std = 0.5/1000;

a(3).name = 'flightTimeValue'; % Ticket price per time [$/s]
a(3).mean = 0.25;
a(3).std = 0.05;

% Vehicle
a(4).name = 'emptyFraction'; % Empty mass fraction
a(4).mean = 0.6;
a(4).std = 0.02;

a(5).name = 'hoverEfficiency'; % Hover electical efficiency (motor+controller+line)
a(5).mean = 0.93*0.98*0.98;
a(5).std = 0.01;

a(6).name = 'hoverKappa'; % Account for induced tip losses
a(6).mean = 1.1;
a(6).std = 0.02;

a(7).name = 'areaRotorFraction'; % Rotor diameter normalized by d-value (ASSUMES 8 rotors for now)
a(7).mean = 0.32;
a(7).std = 0.02;

a(8).name = 'bladeCl'; % Blade average cl
a(8).mean = 0.7;
a(8).std = 0.05;

a(9).name = 'bladeCd'; % Blade average cd
a(9).mean = 0.018;
a(9).std = 0.002;

a(10).name = 'tipMach'; % Hover tip speed limit at sea level
a(10).mean = 0.45;
a(10).std = 0.03;

a(11).name = 'cruiseEfficiency'; % Cruise electrical + prop efficiency (motor+controller+line+prop)
a(11).mean = 0.9*0.96*0.98*0.81;
a(11).std = 0.03;

a(12).name = 'cruiseCl'; % Cruise lift coefficient
a(12).mean = 0.55;
a(12).std = 0.03;

a(13).name = 'Cd0'; % Cruise parasite drag coefficient
a(13).mean = 0.045;
a(13).std = 0.005;

% %Propulsion System
a(14).name = 'cellSpecificEnergy'; % Cruise parasite drag coefficient
a(14).mean = 300 * 3600;
a(14).std = 25 * 3600; % Current cells on low end, Amprius on high end

a(15).name = 'integrationFactor'; % Cruise parasite drag coefficient
a(15).mean = 0.75;
a(15).std = 0.03;

a(16).name = 'endOfLifeFactor'; % Cruise parasite drag coefficient
a(16).mean = 0.8;
a(16).std = 0.0;

a(17).name = 'depthDegradationRate'; % Cruise parasite drag coefficient
a(17).mean = 3.42;
a(17).std = 0.24; % Current values as optimistic

a(18).name = 'reserveEnergyFactor'; % Reserve energy in pack (including unusable)
a(18).mean = 0.15;
a(18).std = 0.02;

% Mission specifications
a(19).name = 'vHeadwind'; % Sizing headwind [m/s]
a(19).mean = 0;
a(19).std = 3;

a(20).name = 'tHover'; % Time spent in hover [s]
a(20).mean = 3 * 60;
a(20).std = 0.5 * 60;

a(21).name = 'tAlternate'; % Maximum time spent in alternate [s]
a(21).mean = 900; % 15 min
a(21).std = 150; % 2.5 min

a(22).name = 'dAlternate'; % Maximum distance covered for an alternate [km]
a(22).mean = 15e3;
a(22).std = 5e3;

% Operations Specifications
a(23).name = 'operatingTimePerDay'; % Hours of operation per day [s/day]
a(23).mean = 8 * 3600;
a(23).std = 1 * 3600;

a(24).name = 'scheduledAvailabilityRate'; % Rate that vehicle is in scheduled operation
a(24).mean = 0.9;
a(24).std = 0.02;

a(25).name = 'unscheduledAvailabilityRate'; % Rate that vehicle is available (e.g. weather)
a(25).mean = 0.9;
a(25).std = 0.02;

a(26).name = 'padTurnAroundTime'; % Time between landing and takeoff [s]
a(26).mean = 5*60;
a(26).std = 60;

a(27).name = 'deadheadRate'; % Percentage of trips that are deadhead
a(27).mean = 0.5;
a(27).std = 0.1;

a(28).name = 'operatingCostFactor'; % Fraction of costs in addition to DOC and landing fees
a(28).mean = 1.5;
a(28).std = 0.1;

% Cost Specifications
a(29).name = 'specificBatteryCost'; % Total pack specific cost [$/J]
a(29).mean = 400 / 3600 / 1000;
a(29).std = 200 / 3600 / 1000;

a(30).name = 'costElectricity'; % Cost of electricty [$/J]
a(30).mean = 0.2 / 3600 / 1000;
a(30).std = 0.03 / 3600 / 1000;

a(31).name = 'specificHullCost'; % Specific cost of the vehicle [$/kg]
a(31).mean = 550;
a(31).std = 50;

a(32).name = 'depreciationRate'; % Annual depreciation rate [fraction of hull cost]
a(32).mean = 0.1;
a(32).std = 0.0;

a(33).name = 'costLiabilityPerYear'; % Annual liability cost [$/year]
a(33).mean = 22000;
a(33).std = 2000;

a(34).name = 'hullRatePerYear'; % Annual hull insurance rate [% of hull cost]
a(34).mean = 0.045;
a(34).std = 0.005;

a(35).name = 'annualServicesFees'; % Annual fees for maintenance, navigation, datalink [$/year]
a(35).mean = 7700;
a(35).std = 2000;

a(36).name = 'maintananceCostPerFH'; % Maintenance cost per FH [$/FH]
a(36).mean = 100;
a(36).std = 20;

a(37).name = 'landingFee'; % Cost per landing
a(37).mean = 50;
a(37).std = 10;

a(38).name = 'pilotCostRate'; % Annual pilot cost (including benefits)
a(38).mean = 280500;
a(38).std = 50000;

a(39).name = 'trainingCostRate'; % Annual training cost
a(39).mean = 9900;
a(39).std = 2000;

% Customer Experience
a(40).name = 'taxiPriceRate'; % Taxi ticket price per km [$/m]
a(40).mean = 1.5/1000;
a(40).std = 0.25/1000;

a(41).name = 'lastLegDistance'; % Distance to drive from helipad to destination [m]
a(41).mean = 3000;
a(41).std = 500;

a(42).name = 'curbTime'; % Time to transfer from gate to curb [s]
a(42).mean = 16 * 60;
a(42).std = 3 * 60;

a(43).name = 'unloadTime'; % Time to unload from taxi [s]
a(43).mean = 1 * 60;
a(43).std = 20;

a(44).name = 'transferTime'; % Time to transfer from gate to helipad including security [s]
a(44).mean = 24 * 60;
a(44).std = 3 * 60;

a(45).name = 'alightTime'; % Time to alight and get to curb [s]
a(45).mean = 4 * 60;
a(45).std = 1 * 60;

% Storage for inputs and outputs
inputs = cell(n,6 + 2 * length(a));
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
    inputs(i,1:6) = {'dValue',dValue,'pilot',pilot,'dMission',dMission};
    for j = 1:length(a)
        inputs{i,2*j+5} = a(j).name;
        inputs{i,2*j+6} = a(j).mean + randn * a(j).std;
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
figuren('Results'); clf;

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
for i = 1:nInputs/2
    
    if rem(i-1,6) == 0
        figuren(['Scatterplot ',num2str((i-1)/6+1)]); clf;
    end
    
    for j = 1:nOutputs
        subplotIdx = rem(i-1,6)*nOutputs+j;
        subplot(6,8,subplotIdx); hold on;
        plot(cat(1,inputs{:,2*i}),out(:,j),'.')
        grid on
        
        if rem(subplotIdx,nOutputs) == 1
            ylabel(inputs{1,2*i-1})
        end
        if subplotIdx / 8 > 5
            xlabel(outName{j})
        end
    end
end