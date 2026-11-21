%%% Tsim=90,180,270,360
%%% add the calculation of power production

function [E_R,V_t,E_p]=Hydrop_Assess1(qN,qra,SelectN,filejjj,K)
%flag1=1;
%for ii=1:100
load(filejjj, 'jjj')

%save jjj_F1test2.mat jjj_F1test2
%global filejjj
addpath1;

%%
NR               =13; % numel(reservoirs);     % Number of reservoirs
NP              = 36; %numel(plants);       % Number of power stations
N                = NP+NR;
e=1000000;     %km2 to m2
e1=2.77778e-10;                   %1J=2.77778e-10MWh
dt=43200;       %1 day=86400s, 1 hour=3600s2econds, 0.5 day=43200 s
d=180; %optimization Time horizon=90 days,90/0.5(time-step)=180
%K=90; %K times tu-step move on forecasting.

%% Load Area, MinHeight, MaxHeight, Max turbine discharge, Max spillage discharge, and MeanEfficiency
Data=readmatrix('Data_programming.xlsx','Range','E2:K50');
Ti=readmatrix('Tributaries_Dalalven1.xlsx','Range','A1:A106');     %Index of tributaries in Dalalven
%Tj=readmatrix('Tributaries_Dalalven2.xlsx','Range','A1:A49');

Data(14:49,5)=Inf;
A=Data(:,2);
hmax=Data(:,1);
hmax1=repmat(hmax,4,1);
qSmin=Data(:,4);
qSmax=Data(:,5);
qSmax(14:49)=10.1*ones(36,1);
qTmax=Data(:,3);
hd=Data(:,6);
Effic=Data(14:49,7); %[plants.MeanEfficiency]';
Effic1=[zeros(13,1);Effic];%
%Effic2=repmat([zeros(13,1);Effic],4,1);
clear Data


%% PP electricity price
% PPraw =readtable('ele_prices_2017_daily.xlsx','Range','C3:F368');          %the format in xlsx is text,need conversion!
% PPraw=table2array(PPraw);
% PP0=str2double(PPraw(:,3))/100;%       %100 is format conversion, important, daily price of electricity, SEK/MWh
% 
% p=PP0(331:360,1);
% PP=[p;PP0(1:150)];  %Start from December

%PP0(366,1)=PP0(365,1);       %100 is factor for balance optimization weight between power production and store water
%p=PP0(1:59,1);                        %format conversion, daily price of electricity, SEK/MWh


% PP1=mean(reshape(PP0(1:3*30),[3,30]));
% PP2=mean(reshape(PP0(3*30+1:3*30*2),[3,30]));
% PP3=mean(reshape(PP0(3*30*2+1:3*30*3),[3,30]));
% PP4=mean(reshape(PP0(3*30*3+1:3*30*4),[3,30]));
%
% PP=mean([PP1;PP3]);
% PP=repmat(PP,1,3);

%% PR  water price SEK per m3
% PPraw=str2double(PPraw(:,3))/100;
% PPraw=mean(PPraw,'all');
% PR=PPraw*9800*e1*hmax;     %repmat(,3,1);             %PR=PP*E/V=PP*Rho*g*hmax                PR size 49*1

%% bounds
Bouds

%% Monte Carlo run ii=100?
%for ii=1:100
%     if flag1~=101
%     else
%         break
%     end


%% Initial states0
H=zeros(10,N*4);
QT=zeros(10,N*4);
QS=zeros(10,N*4);
Hf=zeros(K*10,N*4);    %stop and continue
QTf=zeros(K*10,N*4);
QSf=zeros(K*10,N*4);
h=zeros(1,N*4);
qT=zeros(1,N*4);
qS=zeros(1,N*4);
%load z.mat z       %initial points for programming Optimization_treat1_dyn.m
%qf=zeros(49,45);
%V=zeros(45,5);
%Er=zeros(49,1);
Aeq=zeros(d*N,d*N*3);
beq=zeros(d*N,1);
NSE=zeros(K,1);
et1=zeros(K,30);
et3=zeros(K,30);
Ti2=zeros(106,49);
hdd=zeros(N,K*4);  %changed!!20210901
qrf=zeros(8820,K*10);
E=zeros(K,1);
b0=zeros((K*2+90)*N*2,50);


%% objective
% for i=1:N
%     f1(i)=9810*hd(i)*A(i)*e*PR(i);    %
% end
% f1=[-f1,zeros(1,(d-2)*N),f1];%f1=repmat(f1,1,d);

%% Aeq
Aob_matrix_nodelay

Aeq(1:N*4,1:N*12)=Aob(1:N*4,1:N*12);

for n=1:17
    Ti2(:,n)=[zeros(n-1,1);Ti(n:17);zeros(89,1)];
end
for n=18:21
    Ti2(:,n)=[zeros(n-1,1);Ti(n:33);zeros(73,1)];
end
for n=22:23
    Ti2(:,n)=[zeros(n+11,1);Ti(n+12:46);zeros(60,1)];
end
for n=24:32
    Ti2(:,n)=[zeros(n+22,1);Ti(n+23:64);zeros(42,1)];
end
for n=33:40
    Ti2(:,n)=[zeros(n+31,1);Ti(n+32:83);zeros(23,1)];
end
for n=41:48
    Ti2(:,n)=[zeros(n+42,1);Ti(n+43:96);zeros(10,1)];
end
n=49;
Ti2(:,n)=[zeros(n+47,1);Ti(n+48:106)];

n=zeros(49,1);
for i=1:49
    kk=find(Ti2==i);
    n(i,1)=length(kk);   %The number of connected stations
end

% load ha.mat
load ha1 ha1
%ha(1,1:N*4)=ha1(1,N+1:N*5);

j=randi(SelectN,50,1);   %4500/180=25
%load jjj
% if ismember(j',jjj','row')==1
%     pause
% end
if ismember(j',jjj','row')==0 %make sure the random selection is not repeat
    %jjj_F1test2(:,ii)=j;
    jjj=[jjj, j];
    save(filejjj,'jjj')
    %save jjj_F1test.mat jjj_F1test
    for i=1:50
        q=qN(:,(j(i)-1)*(K*2+90)+1:j(i)*(K*2+90));   %for Group 1,selecting 180days' continuous time series data
        q=repmat(q,2,1);
        b0(:,i)=q(:);
    end

    %% beq_init
    h0=8/10*hmax; h_init=h0;    %ha';   % h_init';   %h_init1'; %h0(1:13)=zeros(13,1);
    beq_init=A.*h0*e ;% h_init1', zeros(49,1) dt*qSmin,  =A.*hmax*1/2*e;

    zz=[]; beq1=[];
    options = optimoptions('linprog','Algorithm','dual-simplex','ConstraintTolerance',1e-3,'Display','off');%
    %kk=1;
    for k=1:300
        fprintf('\nIteration K=%d\n',k);

        jj=0;     %make sure the n=10 times repeat
        f1=9810*n.*A*e.*h0;%.*PR/e; adding water prise, e is optimization balance factor.
        f1=[-f1',zeros(1,(d-2)*N),f1'];%f1=repmat(f1,1,d);

        for n=1:50
            %fprintf('\t repetition n=%d\n',n);

            %% beq
            qa1=qra;
            b_matrix_treat4
            beq(1:N*4,1)=b(1:N*4);

            %% objective min fx
            for i=1:d
                f2((i-1)*N+1:i*N,1)=9810*dt*h0.*Effic1*e1;%*PP(i); % coefficient of qT,    *PP0(i)
            end

            f=[f1;f2';zeros(1,d*N)];%         f1=f1.*PP0;
            f=-f(:)';

            %Function
            z= linprog(f,Aob,b,Aeq,beq,lb,ub,options);%

            flag=1;
            if isempty(z)==1
                %fprintf('No feasible solution\n');%
                flag=0;
                %break
                %z= linprog(f,Aob,b,[],[],lb,ub,options);
            end
            jj=jj+flag;  %make sure the n=10 times repeat

            if flag==1
                %                     h=zeros(1,49*4);
                %                     qT=zeros(1,49*4);
                %                     qS=zeros(1,49*4);%(1,1:N*4)
                %                     qrf(:,(k-1)*30+n)=zeros(8820,1);%
                %                 else
                x0=z;
                z=reshape(z,3,N*d);

                h(1,1:N*4)=z(1,1:49*4);
                qT(1,1:N*4)=z(2,1:49*4);
                qS(1,1:N*4)=z(3,1:49*4);
                qrf(:,(k-1)*30+n)=[qra(:,(k-1)*4+1);b0((k-1)*4*N+50:(k-1)*4*N+8820,n)];% See b_matrix_trea4.m - 'b'
                et1(k,n)=mean(abs(reshape(qra(:,(k-1)*4+1:(k-1)*4+180),8820,1)-qrf(:,(k-1)*10+n)),'all');
                et3(k,n)=mean((reshape(qra(:,(k-1)*4+1:(k-1)*4+180),8820,1)-qrf(:,(k-1)*10+n)).^2,'all');

                %save outcome
                H(jj,:)=h;
                QT(jj,:)=qT;
                QS(jj,:)=qS;
            end

            if jj==10
                fprintf('\n jj=%d\n',jj);
                break
            end
        end

        %% Calculate the total profit of power production and stored water
        % if jj==10    %flag==1
        if jj~=10

            H((size(H,1)+1):10,:)=zeros(10-size(H,1),196);
            QT((size(QT,1)+1):10,:)=zeros(10-size(QT,1),196);
            QS((size(QS,1)+1):10,:)=zeros(10-size(QS,1),196);
            %fprintf('tu Time Step = %d\n',kk);
            %kk=kk+1;
        end

        %save
        Hf((k-1)*10+1:k*10,:)=H;%h;
        QTf((k-1)*10+1:k*10,:)=QT;%QT;
        QSf((k-1)*10+1:k*10,:)=QS;%QS;
        h0=H(N*3+1:N*4)';%ha1(k*N*4-48:k*N*4)';  %undate h0 in objective functionend
        %display(datetime);
        if k==K
            break
        end
    end
 
    %% Calculate total energy production
    Hf1=reshape(Hf,10,[]);
    Hf1=mean(Hf1);
    QTf1=reshape(QTf,10,[]);
    QTf1=mean(QTf1);
    Effic1=repmat(Effic1,K*4,1);

    E_p=9810*dt*Effic1.*Hf1(:).*QTf1(:)*e1;
    E_p1=sum(E_p);
    

    %% Calculate the water storage change with time
    V_t=repmat(A,4*K,1).*Hf1'-repmat(A,4*K,1).*[h0;Hf1(1:length(Hf1)-49)'];

    %% Calculate the Error and Production efficiency,NSE

    a1=mean(abs(qra(:,2:2*d)-qra(:,1:(2*d-1))),'all');
    a2=mean((qra(:)-mean(qra(:))).^2,'all');
    for i=1:K
        et2=et1(i,:);
        et2(et2==0)=[];%et2(:,all(et2==0,1))=[];
        if isempty(et2)==1
            et2=0;
        end
        E(i,1)=mean(et2/a1,2);
    end
    E(E==0)=[];
    E=mean(E);

    %Calculate the Nash-Sutchiffe model dfficiency coefficient(NSE)，for each i station and tu time period, results not good.
    for i=1:K
        et4=et3(i,:);
        et4(et4==0)=[];%et4(:,all(et4==0,1))=[];
        if isempty(et4)==1
            et4=0;
        end
        NSE(i,1)=1-mean(et4/a2,2);
    end
    NSE(NSE==0)=[];
    NSE=mean(NSE);
    NNSE=1/(2-NSE);

    %Calculate Production efficiency
    Hff=zeros(K,196);
    QTff=zeros(K,196);
    QSff=zeros(K,196);
    for i=1:K
        Hf1=Hf((i-1)*10+1:i*10,:);
        Hf1(all(Hf1==0,2),:)=[];
        QTf1=QTf((i-1)*10+1:i*10,:);
        QTf1(all(QTf1==0,2),:)=[];
        QSf1=QSf((i-1)*10+1:i*10,:);
        QSf1(all(QSf1==0,2),:)=[];
        Hff(i,:)=mean(Hf1);
        QTff(i,:)=mean(QTf1);
        QSff(i,:)=mean(QSf1);
    end
    Hff=reshape(Hff',49,K*4)';
    QTff=reshape(QTff',49,K*4)';
    QSff=reshape(QSff',49,K*4)';

    for i=1:49
        j=Ti2(:,i);   %Ti2 is the serial number of downstream stations
        j(j==0)=[];

        hdd(i,:)=sum(Hff(:,j),2);   %size 49*180
    end
    R5=(sum(hdd'.*QTff,'all'))/(sum((hd'.*sum((QTff+QSff))),2)); 
    E_R=[E,R5,NNSE,E_p1];%NSE,


    %flag1=flag1+1;
end
end
%end



