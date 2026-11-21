% % Prepare data for 'y' year and start from 'm'month
% for Tsim=180
function qN=Data_preparation1(y,m,SelectN,K)
load qN/qN_control_Jan.mat qN_control_Jan  % qN_control_Jan data start from Jan 1st, 1961.

if SelectN==25  % odd or even year scenarios
    qN=zeros(49,K*100);
    for i=1:49
        a=qN_control_Jan(i,:);
        a=reshape(a,360,51);
        b=a(:,y:2:50);%360*26 % "y" years'data
        a(:,y:2:51)=[]; % the opposite of "y" years'data
        if y==1
            c=[b;a];
        else
            a(:,1)=[];
            c=[b;a];
        end
        c=c((m-1)*30+1:(m-1)*30+K*4,:);
        qN(i,:)=c(1:K*100);
    end
end

if SelectN==50
    qN=zeros(49,18000);  %control scenarios
    for i=1:49
        c=qN_control_Jan(i,:);
        c=reshape(c,30,612);
        if m>1
            c(:,1:m-1)=[];
        end
        c=c(:,1:600);
        c=reshape(c,360,50);
        %c=c(1:180,:);
        qN(i,:)=c(:);
    end
end

end


