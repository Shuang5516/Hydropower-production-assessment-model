%Aeq , Aeq*X=beq
C=readmatrix('Connection_of_Dalalven.xlsx','Range','B2:AX50');
Aob=zeros(N*d,N*d*3);  %sparse
for t=1:d
    for i=1:N
        Aob((t-1)*N+i,(i-1)*3+1+(t-1)*N*3:i*3+(t-1)*N*3)=[A(i)*e 1*dt 1*dt];  %A(i)h(i,t)+qT(i,t)+qS(i,t)
        [~,j]=find(C(i,:)==1);
        if isempty(j)==0            %if j ~=[]
            if numel(j)==1
                Aob((t-1)*N+i,(t-1)*N*3+(j-1)*3+2:(t-1)*N*3+(j-1)*3+3)=[-1*dt -1*dt];  %Connection part, C(ji)
            else
                Aob((t-1)*N+i,(t-1)*N*3+(j(1)-1)*3+2:(t-1)*N*3+(j(1)-1)*3+3)=[-1*dt -1*dt];  %Connection part, C(ji)
                Aob((t-1)*N+i,(t-1)*N*3+(j(2)-1)*3+2:(t-1)*N*3+(j(2)-1)*3+3)=[-1*dt -1*dt];  %Connection part, C(ji), if have two stations connected in upstream
                
            end
        end
        if t>1
            Aob((t-1)*N+i,(t-2)*N*3+(i-1)*3+1)=-A(i)*e;  %-A(i)h(i,t-1)
        end
    end
end
%Aeq=sparse(Aeq);
%Aeq_s=Aeq(N+1:N+49,1:N*3*2);

% Aeq=zeros(N*d,N*d*3);
% for t=1:d
%     for i=1:N
%         Aeq((t-1)*N+i,(i-1)*3+1+(t-1)*N*3)=1;  %A(i)h(i,t)+qT(i,t)+qS(i,t)
%         
%     end
% end


