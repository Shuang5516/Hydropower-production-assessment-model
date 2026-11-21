%%main3.m for paper2, change Tsim to 180,270 and 360.
%ry--mean of wet/dry
clc;
clear;
%parpool(12);
disp('Hyropower production assessment');
display(datetime);
% Scenario 1, load qN1  %metrix 49*4500 odd years from December
% Scenario 2, load qN2  %metrix 49*4500 even years from December
% Scenario 3, load qN_con_Dec  %metrix 49*18360 all years from December

%% Input
% Odd year y=1; Even y=2;
fy=input('Choose forecasting scenarios,\nForecasts sample is from Odd years fy=1, Even years fy=2, \nControl sample fy=[].\nfy=');
ry=input('\nChoose reality scenarios, \nReality sample is from Odd years ry=1, Even years ry=2, \nControl sample ry=[]. \nry=');

% Starting month, m can be 1,2,3,4,...,12.
m=input('\nChoose scenarios,\nData selection starting month(1 to 12).\nm=');
M=datestr(m*30,"mmm");

%Randomly select a real scenarios, between 1 and 25
j=input('\nRandomly choose a real scenarios,\nbetween 1 and 25 for SelectN=25,\nbetween 1 and 50 for SelectN=50,\nmean real scenarios j=[].\nj=');
%fixed real scenario, set as a mean of all
%j=[];

%Sensitive analysis of Monte Carlo runs
%N=input('\nChoose Monte Carlo runs.\nN=');
N=100;

%Sensitive analysis of Monte Carlo runs
K=input('\nChoose Tsim, K can be 45(90days),90(180days),135(270days),180(360days).\nK=');
%K=90;

%if qN is qN1 or qN2, odd or even years there is 25 years data
SelectN=25; % data selection size is different
%if qN is qN_con, control sample, the all-year, 50 years data
%SelectN=50;
fprintf('\nSelectN=%d\n',SelectN)


%% Forcastign runoff scenarios
qN=Data_preparation2(fy,m,SelectN,K);
qN(qN<0)=0;

%% load reality scenario
SelectN1=25;  % For control scenario has same real runoff sample as wet and dry years' scenario.                                           
% if SelectN==25
    if isempty(j)==0   %use random real Scenario
            qra=Data_preparation(ry,m,SelectN1);
            qra=qra(:,(j-1)*180+1:j*180);
            qra=repmat(qra,2,1);
            qra=reshape(qra,49,360);
            %qra=qra(:,1:360);
        %end
        qra(qra<0)=0;
    else
        disp('Mean real Scenario of wet or dry');
        mean_qra=zeros(K*2+90,49);  %360use mean real Scenario
        qra=Data_preparation2(ry,m,SelectN1,K);
        for i=1:49
            qra1=reshape(qra(i,:),K*2+90,25);
            mean_qra(:,i)=mean(qra1,2);
        end
        qra=repmat(mean_qra',2,1);
        qra=reshape(qra,49,(K*2+90)*2);%720
        qra(qra<0)=0;

    end    
%end

% SelectN1=50;
%  %if SelectN==50 %For random real scenario not same as dry and wet years' scenario.
%     if isempty(j)==0   %use random real Scenario
%         qra=qN(:,(j-1)*180+1:j*180);
%         qra=repmat(qra,2,1);
%         qra=reshape(qra,49,360);
% 
%     else %use mean real Scenario
%         %load qN/qN_control_Jan.mat qN_control_Jan  % qN_control data start from March 1st, 1961.
%         %load reality sample
%         mean_qra=zeros(360,49); %use mean real Scenario
%         qra=Data_preparation1([],m,SelectN1);
%         disp('Mean real Scenario');
%         for i=1:49
%             qra1=reshape(qra(i,:),360,50);
%             mean_qra(:,i)=mean(qra1,2);
%         end
%         qra=repmat(mean_qra',2,1);
%         qra=reshape(qra,49,720);
%         qra(qra<0)=0;
%     end
%end

%% Initials
E_Rfinal=zeros(100,4);
jjj=zeros(50,1);
if SelectN==50
    filejjj=['jjj/jjj' M '_control_' num2str(j) '_' num2str(N) '.mat'];
else
    filejjj=['jjj/jjj' M num2str(fy) '_' num2str(ry) '.mat'];
end
save(filejjj,'jjj')

%% main.m simulation function
% core_number=12;
% parpool('Processes',core_number);
% parpool('local');
clear qra1 jjj
parfor ii=1:N
    [E_R,V_t,E_p]=Hydrop_Assess1(qN,qra,SelectN,filejjj,K);
    E_Rfinal(ii,:)=E_R;
    V_tfinal(:,ii)=V_t;
    E_pfinal(:,ii)=E_p;
end

%% Saving results
if SelectN==25
    if isempty(j)==0
        filenm=['Results_paper2/E_R_Tsim/E_R_' M num2str(fy) '_' num2str(ry) '_' num2str(j) '.mat'];
    else
        filenm=['Results_paper2/E_R_Tsim/E_R_' M num2str(fy) '_' num2str(ry) '_mean_' num2str(K*2) '.mat'];
        filenm1=['Results_paper2/E_R_Tsim/V_t_' M num2str(fy) '_' num2str(ry) '_mean_' num2str(K*2) '.mat'];
        filenm2=['Results_paper2/E_R_Tsim/E_p_' M num2str(fy) '_' num2str(ry) '_mean_' num2str(K*2) '.mat'];
 
    end
end
if SelectN==50
    if isempty(j)==0
        filenm=['Results_paper2/E_R_Tsim/E_R_' M '_Control_' num2str(j) '.mat'];
    else
    filenm=['Results_paper2/E_R_Tsim/E_R_' M '_Control_meanofall.mat'];%num2str(ry) '_' num2str(N)
    end
end
%sprintf('Results_withoutPP_PW/E_R_', M)
save(filenm,'E_Rfinal')
save(filenm1,'V_tfinal')
save(filenm2,'E_pfinal')
display(datetime);
fprintf('\nm=%s\n',M)
fprintf('fy=%d\n',fy)
fprintf('ry=%d\n',ry)
fprintf('j=%d\n',j)
fprintf('N=%d\n',N)
fprintf('SelectN=%d\n',SelectN)
fprintf('K=%d days\n',K*2)

%Plots
% %figure('Name','F1R1');
% figure(3);
% scatter(E_R_Dec1_1(:,1),E_R_Dec1_1(:,2))
% hold on
% scatter(E_R_F2R1test1(:,1),E_R_F2R1test1(:,2))
% hold on
% scatter(E_R_control1(:,1),E_R_control1(:,2))
% xlabel('Forecasting Error');
% ylabel('Production Efficiency Factor ηd');
% legend('F1R1','F2R1','Control');


