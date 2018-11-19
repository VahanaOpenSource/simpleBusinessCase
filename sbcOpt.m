% Call simpleBusinessCase.m and optimize to maximize profit

% Objective: maximize profit per year
% Design variables: massGross, vCruise
% Parameters: nPax

function [profitPerYearOpt,costPerFlightHourOpt,impliedValueOpt,rangeOpt, massGrossOpt, vCruiseOpt, ...
    dischargeRateOpt, dischargeDepthOpt] = sbcOpt(nPax,varargin)

%x0 = [2000, 50];
lb = [500, 20];
ub = [10000, 150];

[M,V]=meshgrid(linspace(lb(1),ub(1),10),linspace(lb(2),ub(2),10));
P=simpleBusinessCase(M,V,nPax,varargin{:});

if ~all(isnan(P(:)))
    x0(1)=M(P(:)==max(P(:)));
    x0(2)=V(P(:)==max(P(:)));

options = optimset('display','none');

[xOpt,~,exitflag,~] = fminsearch(@(x) sbcObj(x,varargin{:}),x0,options);
%[xOpt,~,exitflag,~] = fmincon(@(x) sbcObj(x,varargin{:}),x0,[],[],[],[],lb,ub,@(x) sbcNonLinCon(x),options);
massGrossOpt = xOpt(1);
vCruiseOpt = xOpt(2);

else
    exitflag=0;
    massGrossOpt = nan;
    vCruiseOpt = nan;
end

if exitflag > 0
    [profitPerYearOpt,costPerFlightHourOpt,impliedValueOpt,rangeOpt,dischargeRateOpt,dischargeDepthOpt] = ...
        simpleBusinessCase(xOpt(1),xOpt(2),nPax,varargin{:},'out',...
        {'profitPerYear';'costPerFlightHour';'impliedValue';'range';'dischargeRate';'dischargeDepth'});
else
    profitPerYearOpt = nan;
    costPerFlightHourOpt = nan;
    impliedValueOpt = nan;
    rangeOpt = nan;
    dischargeRateOpt = nan;
    dischargeDepthOpt = nan;
end
    
% Objective function
    function [J] = sbcObj(x,varargin)
        
        massGross = x(1);
        vCruise = x(2);
        
        profitPerYear=simpleBusinessCase(massGross,vCruise,nPax,varargin{:});
        
        J = -profitPerYear;
    end

% Non-linear constraint function
    function [c,ceq] = sbcNonLinCon(~)
        c = [];
        ceq = [];
    end

end