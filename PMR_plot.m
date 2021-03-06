x = [2.91, 3.42, 3.93, 4.46, 4.99];
opt1 = 1 - [0.50, 0.44, 0.34, 0.28, 0.20]; % c = 0.5
%loc1 = 1 - [0.56, 0.42, 0.38];
opt2 = 1 - [0.60, 0.58, 0.48, 0.44, 0.42]; % c = 1
%loc2 = 1 - [0.56, 0.42, 0.38];
opt3 = 1 - [0.78, 0.76, 0.72, 0.70, 0.66]; % c = 2
%loc3 = 1 - [0.73, 0.66, 0.58];
opt4 = 1 - [0.80, 0.78, 0.72]; % c = 4
%loc4 = 1 - [0.76, 0.72, 0.66];

figure;
%plot(x,opt3,'ks-',x,loc3,'bo-',x,opt2,'ks--',x,loc2,'bo--',x,opt1,'ks:',x,loc1,'bo:')
plot(x,opt1,'ks-',x,opt2,'ks--',x,opt3,'ks-.')
xlabel('Peak-to-Mean ratio');
ylabel('Optimal solar ratio');
ylim([0,1.15]);
xlim([min(x),max(x)]);
legend('c=0.5','c=1','c=2','Location','Northwest');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/PMR2.eps');


x = [1.53, 1.68, 1.83, 2.00, 2.16];
opt1 = 1 - [0.74, 0.73, 0.72, 0.68, 0.66]; % c = 0.5
%loc1 = 1 - [0.80, 0.74, 0.68];
opt2 = 1 - [0.82, 0.81, 0.78, 0.75, 0.70]; % c = 1
%loc2 = 1 - [0.64, 0.60, 0.58];
opt3 = 1 - [0.84, 0.83, 0.82, 0.81, 0.80]; % c = 2
%opt3 = 1 - [0.60, 0.46, 0.42];
%loc3 = 1 - [0.56, 0.42, 0.38];

figure;
plot(x,opt1,'ks-',x,opt2,'ks--',x,opt3,'ks-.')
xlabel('Peak-to-Mean ratio');
ylabel('Optimal solar ratio');
ylim([0,0.5]);
xlim([min(x),max(x)]);
legend('c=0.5','c=1','c=2','Location','Northwest');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/PMR1.eps');

trace1 = [    1.0000
    0.9781
    0.9565
    0.9350
    0.9138
    0.8931
    0.8731
    0.8537
    0.8349
    0.8167
    0.7996
    0.7839
    0.7699
    0.7577
    0.7481
    0.7414
    0.7380
    0.7385
    0.7428
    0.7502
    0.7605];
trace2 = [    1.0000
    0.9795
    0.9603
    0.9420
    0.9262
    0.9104
    0.8970
    0.8852
    0.8754
    0.8676
    0.8622
    0.8589
    0.8578
    0.8589
    0.8619
    0.8680
    0.8741
    0.8829
    0.8940
    0.9069
    0.9214];

figure;
plot(0:0.05:1,trace1,'k-',0:0.05:1,trace2,'k--')
xlabel('wind ratio');
ylabel('relative cost');
%ylim([0,1]);
set(gca,'XTick',[0:0.2:1]);
legend('Trace 1','Trace 2');
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 2.8 2.1]);
print ('-depsc', 'figs/portfolio2.eps');