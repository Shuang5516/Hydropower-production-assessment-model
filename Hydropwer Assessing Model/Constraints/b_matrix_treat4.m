%% beq
%i=randi(18596,d,1);     %for control group, (group1+2+3+4)
%i=randi(52,1);    %randomly picking up from "wet year wet month" cassification
%i=randi(30*50*3,d,1);    %randomly picking up from "dry year dry month" cassification
% for i=1:NR
%     j=randi(50,1);
%     q(:,i)=reservoirs(:,i).TotalNaturalQ(:,j);
% end
% for i=1:NP
%     %j=randi(50,1);
%     q(:,i+13)=plants(:,i).TotalNaturalQ(:,j);
% end
 
% % b0=q(:,i);
%  b0=b0(:);
% %Beq(:,n)=b0(:);
% %% beq
% b=b0*dt;      %remove the water used for municipal withdrawal

%% Receding horizon, dynamic move on from b (matrix)
b=b0((k-1)*4*N+1:(k-1)*4*N+8820,n)*dt;

%% dynamic update 
if k==1
    b(1:49)=beq_init+qa1(:,k)*dt;
elseif size(H,2)==1
        b(1:49)=qa1(:,(k-1)*4+1)*dt+A*e.*h_init;%Hf((k-2),N*3+1:N*4)';
%     CQT=zeros(1,49);
%     CQS=zeros(1,49);
%     [i,j]=find(C==1);
%     CQT(i)=QTf((k-1),j);
%     CQS(i)=QSf((k-1),j);
    else
    b(1:49)=qa1(:,(k-1)*4+1)*dt+A*e.*h_init;%Hf((k-1),N*3+1:N*4)';%+CQT'*dt+CQS'*dt; ha(:,(k-1)*4)             % update the initial condition, the -A(i)*h(i,t-1).
    
end
%b(50:196)=[qa1(:,(k-1)*4+2);qa1(:,(k-1)*4+3);qa1(:,(k-1)*4+4)]*dt; %update system
% beq(:,k)=beq;
% save beq.mat beq
