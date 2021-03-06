% load data input
has_quadprog = exist( 'quadprog' );
has_quadprog = has_quadprog == 2 | has_quadprog == 3;
has_linprog  = exist( 'linprog' );
has_linprog  = has_linprog == 2 | has_linprog == 3;
rnstate = randn( 'state' ); randn( 'state', 1 );
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_solver sdpt3;
cvx_clear;
clc;
clear;

% There are 10 datacenters and 48 population centers.
a = 10;
b = 48;
I = ones(a,1);
J = ones(b,1);

% Sample every 5 minites an hour for a day.
length = 288;
scale = 1000;
L = load('traces/load-hp6.txt');
L = (L - min(L))/scale;

for i = 1:1:6*24*8
    x1(i) = i/6;
    load1(i) = (L(2*i-1) + L(2*i)) / 2;
end

% The population
geography = [930 1536 585 8614 1354 931 213 4921 2261 330 3137 1498 767 700 960 875 352 1443 1710 2334 1407 523 1344 241 455 654 399 2252 441 4596 2015 162 2702 762 1031 3038 278 976 197 1333 5040 623 181 2049 1091 369 1556 132];
% The time difference
time_zone = [2 1 2 0 1 3 3 3 3 1 2 3 2 2 3 2 3 3 3 3 2 2 2 1 2 0 3 3 1 3 3 2 3 2 0 3 3 3 2 2 2 1 3 3 0 3 2 1];

% Initialize the load for each state, scale it according to the population
% and time zone. (Assume the requests have the same pattern.)
% The array is 48 by 1008 (144*7)
for i=1:1:48  
    load2(i,:) = geography(i)*load1(time_zone(i)*6+1:time_zone(i)*6+144*7);
end

datacenter_location = [37 120; 47 120; 44 120; 40 90; 31 83; 38 78; 31 99; 28 81; 35 79; 33 81];
state_location = [32 87; 34 119; 35 92; 37 120; 39 105; 41 73; 39 76; 28 81; 31 83; 44 114; 40 89; 40 86; 41 93; 38 98; 38 85; 31 92; 45 69; 39 77; 42 72; 43 84; 45 93; 33 90; 38 92; 47 110; 41 99; 39 116; 43 71; 40 74; 34 106; 43 76; 35 79; 47 100; 40 83; 35 97; 44 120; 41 78; 42 71; 32 80; 44 100; 35 86; 31 99; 40 112; 44 73; 38 79; 47 121; 39 81; 44 89; 43 107];

% Initialize the routing delay array. 10 by 48
for i = 1:1:10
    for j = 1:1:48
        delay(i,j)=sqrt((datacenter_location(i,1)-state_location(j,1))^2+(datacenter_location(i,2)-state_location(j,2))^2);
    end
end

% Initialize the wind and solar data.
W = csvread('traces/wind_supply_week.csv');
S1 = csvread('traces/solar_supply_week.csv');
% Sample the green energy every 10 minutes for a week = 144 * 7 = 1008  
% 1008 by 10
for i = 1:1:144*7
    S(i,:) = max(0,S1(2*i-1,:));
end
s_mean = mean(S(1:length,:));
w_mean = mean(W(1:length,:));
for i = 1:1:a
    S(:,i) = S(:,i)/s_mean(i);
    W(:,i) = W(:,i)/w_mean(i);
end



%[Y DCM] = min(delay);


%DCL = zeros(a,144*7);


%for j = 1:1:48
%    DCL(DCM(j),:) = DCL(DCM(j),:) + load2(j,:);
%end





S = S';
W = W';

step = 0.01;

% Y is the minimum delay from a population center to datacenter
% DCM is the index of the min delay.
% 1 by b = 48
[Y DCM] = min(delay);
% 10 by 1008
DCL = zeros(a,144*7);
delay_DC = zeros(a,144*7);
% Assume that the population center sends all its requests
% to the nearest data center.
for jo = 1:1:b
    DCL(DCM(jo),:) = DCL(DCM(jo),:) + load2(jo,:);
    delay_DC(DCM(jo),:) = delay_DC(DCM(jo),:) +  load2(jo,:)*delay(DCM(jo),jo);
end
prop_delay_loc = sum(delay_DC')./sum(DCL');


for i = 1:1:1
    i
    
    %{
    for so = 1:1:11
        done = 0;
        for wi = 1:1:20/step            
            T = S.*(0.1*(so-1)*capacity'*ones(1,144*7)) + W.*(step*(wi-1)*capacity'*ones(1,144*7));
            T_total = ones(1,10)*T;
            if done == 0
                defi_total = max(0,DCL_total - T_total);
                if sum(defi_total)/sum(DCL_total) <= 0.1
                    lo9(so) = wi;
                    done = 1;
                end
            end
            if done == 1
                defi = max(0,DCL - T);
                if sum(sum(defi))/sum(sum(DCL)) <= 0.1
                    done = 2;
                    up9(so) = wi;
                    break;
                end
            end
            if done == 2
                break;
            end
        end
    end
    for so = 1:1:11
        done = 0;
        for wi = 1:1:20/step            
            T = S.*(0.1*(so-1)*capacity'*ones(1,144*7)) + W.*(step*(wi-1)*capacity'*ones(1,144*7));
            T_total = ones(1,10)*T;
            if done == 0
                defi_total = max(0,DCL_total - T_total);
                if sum(defi_total)/sum(DCL_total) <= 0.2
                    lo8(so) = wi;
                    done = 1;
                end
            end
            if done == 1
                defi = max(0,DCL - T);
                if sum(sum(defi))/sum(sum(DCL)) <= 0.2
                    done = 2;
                    up8(so) = wi;
                    break;
                end
            end
            if done == 2
                break;
            end
        end
    end
    for so = 1:1:11
        done = 0;
        for wi = 1:1:20/step            
            T = S.*(0.1*(so-1)*capacity'*ones(1,144*7)) + W.*(step*(wi-1)*capacity'*ones(1,144*7));
            T_total = ones(1,10)*T;
            if done == 0
                defi_total = max(0,DCL_total - T_total);
                if sum(defi_total)/sum(DCL_total) <= 0.3
                    lo7(so) = wi;
                    done = 1;
                end
            end
            if done == 1
                defi = max(0,DCL - T);
                if sum(sum(defi))/sum(sum(DCL)) <= 0.3
                    done = 2;
                    up7(so) = wi;
                    break;
                end
            end
            if done == 2
                break;
            end
        end
    end
    %}
    
    ss = 6;
    p = 0;    
    for j = 1:1:1
        beta0 = 6;
        %factor = 1+1/sqrt(beta0);
        %??DCL = DCL;
        M = 2 * (1+1./sqrt([10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]')).*floor(max(DCL'))';
        capacity = i * mean(DCL');    
        DCL_total = ones(1,10)*DCL;
        j
        %wi = (0.75+0.01*(j-1))*i;
        wi = 0.8*i;
        so = i - wi;
        %re(j) = 0.5*(j-1);
        Re = 2*(S.*(so*capacity'*ones(1,144*7)) + W.*(wi*capacity'*ones(1,144*7)));
        for k = 1:6:144*7
            T2(:,k:k+5) = Re(:,k)*ones(1,6);
        end
        x0 = 0;
        lambda_t = load2';
        mu = ones(a,1);
        energy_cost = [10.41 3.73 5.87 7.48 5.86 6.67 6.44 8.6 6.03 5.49]';
        delay_cost = ones(a,1);
        beta = beta0*ones(a,1);
        prop_delay = delay;
        caps = M;
        w = 3;
        [x_opt(:,:,j,i) cost_opt(j,i) delay_opt(j,i) ld_TSJ] = hetero_opt(x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_opt(j,i) = sum(sum(max(0,x_opt(:,:,j,i)-Re(:,1:length)')))
        ld_TSJ
        dim = size(ld_TSJ);
        nccreate('routing.nc', 'routingPlan', 'Dimensions', {'T' dim(1) 'S' dim(2) 'J' dim(3)});
        
        ncwrite('routing.nc', 'routingPlan', ld_TSJ); 
        ncdisp('routing.nc');
        vardata = ncread('routing.nc', 'routingPlan');
        vardata
        
        %ncwrite('routing.nc', 'routing', ld_TSJ);
        %csvwrite('results/beta-opt-x.csv',[x_opt],0,0);
        %{
        x_rhc(:,:,j,i) = rhc(lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)',w);
        [cost_rhc(j,i) delay_rhc(j,i)] = cost (x_rhc(:,:,j,i), x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_rhc(j,i) = sum(sum(max(0,x_rhc(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/betarhc-x.csv',[x_rhc],0,0);
        
        x_afhc(:,:,j,i) = afhc(lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)',w);
        [cost_afhc(j,i) delay_afhc(j,i)] = cost (x_afhc(:,:,j,i), x0, lambda_t(1:length,:), mu, energy_cost, delay_cost, beta, prop_delay, caps, Re(:,1:length)');
        brown_afhc(j,i) = sum(sum(max(0,x_afhc(:,:,j,i)-Re(:,1:length)')))
        %csvwrite('results/beta-afhc-x.csv',[x_afhc],0,0);        

        for k = 1:1:a
            [x_loc(:,k,j,i) cost_local(k) delay_local(k)] = hetero_opt(x0, DCL(k,1:length)', mu(k), energy_cost(k), delay_cost(k), beta(k), prop_delay_loc(1,k), caps(k), Re(k,1:length)');
        end
        brown_loc(j,i) = sum(sum(max(0,x_loc(:,:,j,i)-Re(:,1:length)')))
        delay_loc(j,i) = sum(DCL(:,1:length)')*delay_local(:)/sum(sum(DCL(:,1:length)));
        cost_loc(j,i) = sum(cost_local(:));
        %csvwrite('results/beta-loc-x.csv',[x_loc],0,0);
        
        csvwrite('results/beta-compare.csv',[cost_opt, brown_opt, delay_opt, cost_loc, brown_loc, delay_loc],0,0); 
        %csvwrite('results/portfolio-compare.csv',[cost_opt, brown_opt, delay_opt, cost_rhc, brown_rhc, delay_rhc, cost_afhc, brown_afhc, delay_afhc, cost_loc, brown_loc, delay_loc],0,0); 
        %}    
            %{
            cvx_begin
               variables m(a) lambda(a,b);%lambda1(b) lambda2(b) lambda3(b) lambba4(b) lambba5(b) lambba6(b) lambba7(b) lambba8(b) lambba9(b) lambba10(b);
               minimize( beta*ones(1,10)*((1-p)*max(0,m-T(:,t)) + p*m) + sum(sum(delay.*lambda)) - sum(m) + sum(quad_over_lin([m';zeros(1,a)],m'-J'*lambda')) );
               subject to
                    m >= 0;
                    lambda >= 0;    
                    lambda'*I == load2(:,t);
                    m <= M;       
            cvx_end
            m_opt_record(t,:) = m;
            lambda_opt_record(t,:,:) = lambda;
            optimal_record(t) = cvx_optval;
            %}
        %end
        %{
        for k = 1:ss:length
            m_opt_record(k+1:k+ss-1,:) = ones(ss-1,1)*m_opt_record(k,:);
        end
        defi_glb_s = max(0,m_opt_record(1:1008,:)'-T2);
        defi_glb = max(0,m_opt_record(1:1008,:)'-T);
        brown_s_ratio(j,i) = sum(sum(defi_glb_s))/sum(sum(m_opt_record(1:1008,:)))
        brown_s(j,i) = sum(sum(defi_glb_s))
        brown_ratio(j,i) = sum(sum(defi_glb))/sum(sum(m_opt_record(1:1008,:)))
        brown(j,i) = sum(sum(defi_glb))
        cost_s(j,i) = ss*sum(optimal_record)
        cost(j,i) = cost_s(j,i) + beta*(brown(j,i) - brown_s(j,i))
        aver_delay(j,i) = cost(j,i) - beta*sum(sum(defi_glb_s))
        %}
    end
    %{
    ss = 6;
    p = 0;
    glb8_10 = [1.0825,0,0.8738,0,0.7731,0,0.7388,0,0.7250,0,0.7131];
    glb8_1 = [1.2325,0,1.0012,0,0.8394,0,0.7962,0,0.7250,0,0.7131];
    for so = 1:2:11
        so
        %upper = up8(so)*step;
        upper = glb8_1(so);
        lower = lo8(so)*step;
        while upper - lower > 0.04
        %done = 0;
        %wi = glb8_10(so);
        %while done == 0
        	wi = (upper+lower)/2;
            
            T = S.*(0.1*(so-1)*capacity'*ones(1,length)) + W.*(wi*capacity'*ones(1,length));
            
            for k = 1:6:length
                T2(:,k:k+5) = T(:,k)*ones(1,6);
            end
            %T = T2;
            
            %T_total = ones(1,10)*T;
            for t = 1:ss:length
                cvx_begin
                   variables m(a) lambda(a,b);%lambda1(b) lambda2(b) lambda3(b) lambba4(b) lambba5(b) lambba6(b) lambba7(b) lambba8(b) lambba9(b) lambba10(b);
                   minimize( beta*ones(1,10)*((1-p)*max(0,m-T(:,t)) + p*m) + sum(sum(delay.*lambda)) - sum(m) + sum(quad_over_lin([m';zeros(1,a)],m'-J'*lambda')) );
                   subject to
                        m >= 0;
                        lambda >= 0;    
                        lambda'*I == load2(:,t);
                        m <= M;       
                cvx_end
                m_opt_record(t,:) = m;
                lambda_opt_record(t,:,:) = lambda;
                optimal_record(t) = cvx_optval;
            end
            for k = 1:ss:length
                m_opt_record(k+1:k+ss-1,:) = ones(ss-1,1)*m_opt_record(k,:);
            end
            defi_glb = max(0,m_opt_record(1:1008,:)'-T2);            
            brown = sum(sum(defi_glb))/sum(sum(m_opt_record(1:1008,:)))         
            if brown <= 0.2
                 upper = wi;
                 lower = lower;
            else
                upper = upper;
                lower = wi;
            end
            [lower,upper]
            
        end
        glb8(so) = wi;
    end
    %}
end

%{
figure;
plot(1:1:10,brown_opt(1:1:10),'k',1:1:10,brown_rhc(1:1:10),'r',1:1:10,brown_afhc(1:1:10),'g',1:1:10,brown_loc(1:1:10),'b')
xlabel('beta');
ylabel('brown energy consumption');
xlim([1,10]);
%ylim([0,1]);
legend('GLB','RHC','AFHC','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/brownBeta.eps');

figure;
plot(1:1:10,cost_opt(1:1:10),'k',1:1:10,cost_rhc(1:1:10),'r',1:1:10,cost_afhc(1:1:10),'g',1:1:10,cost_loc(1:1:10),'b')
xlabel('beta');
ylabel('total cost');
xlim([1,10]);
%ylim([0,1]);
legend('GLB','RHC','AFHC','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/costBeta.eps');

figure;
plot(1:1:10,delay_opt(1:1:10),'k',1:1:10,delay_rhc(1:1:10),'r',1:1:10,delay_afhc(1:1:10),'g',1:1:10,delay_loc(1:1:10),'b')
xlabel('beta');
ylabel('average delay');
xlim([1,10]);
%ylim([0,1]);
legend('GLB','RHC','AFHC','LOCAL');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'figs/delayBeta.eps');
%}


%{
figure;
plot(75:1:85,brown(:,1),75:1:85,brown(:,2),75:1:85,brown(:,3))
xlabel('% of wind');
ylabel('brown energy consumption');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windBrownNo1.eps');
saveas(gcf,'windBrownNo1.fig')

figure;
plot(75:1:85,brown_s(:,1),75:1:85,brown_s(:,2),75:1:85,brown_s(:,3))
xlabel('% of wind');
ylabel('brown energy consumption');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windBrown1.eps');
saveas(gcf,'windBrown1.fig')

figure;
plot(75:1:85,cost(:,1),75:1:85,cost(:,2),75:1:85,cost(:,3))
xlabel('% of wind');
ylabel('cost');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windCostNo1.eps');
saveas(gcf,'windCostNo1.fig')

figure;
plot(75:1:85,cost_s(:,1),75:1:85,cost_s(:,2),75:1:85,cost_s(:,3))
xlabel('% of wind');
ylabel('cost');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windCost1.eps');
saveas(gcf,'windCost1.fig')

figure;
plot(75:1:85,aver_delay(:,1),75:1:85,aver_delay(:,2),75:1:85,aver_delay(:,3))
xlabel('% of wind');
ylabel('average delay');
legend('capacity = 1','capacity = 2','capacity = 3');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
print ('-depsc', 'windDelay1.eps');
saveas(gcf,'windDelay1.fig')


figure;
    %plot(0:0.1:1,lo9*step,':',0:0.1:1,up9*step,'-',0:0.1:1,lo8*step,':',0:0.1:1,up8*step,'-',0:0.1:1,lo7*step,':',0:0.1:1,up7*step,'-',0:0.1:1,lo6*step,':',0:0.1:1,up6*step,'-',0:0.1:1,lo5*step,':',0:0.1:1,up5*step,'-')
    plot(re,brown,re,brown_s)
    xlabel('capacity');
    ylabel('brown energy consumption');
    ylim([0,1]);
    %set(gca,'YTick',[0:0.5:4]);
    %set(gca,'XTick',[0:1:10]);
    legend('without storage','perfect storage');
    set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.8]);
    print ('-depsc', 'brownCapacity.eps');
%}