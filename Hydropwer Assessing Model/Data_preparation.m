% % Prepare data for 'y' year and start from 'm'month
%
function qN=Data_preparation(y,m,SelectN)
load qN/qN_control_Jan.mat qN_control_Jan  % qN_control data start from March 1st, 1961.

if SelectN==25  % odd or even year scenarios
    qN=zeros(49,4500);
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
        c=c((m-1)*30+1:(m-1)*30+180,:);
        qN(i,:)=c(1:4500);
    end
end

if SelectN==50
    qN=zeros(49,9000);  %control scenarios
    for i=1:49
        c=qN_control_Jan(i,:);
        c=reshape(c,30,612);
        if m>1
            c(:,1:m-1)=[];
        end
        c=c(:,1:600);
        c=reshape(c,360,50);
        c=c(1:180,:);
        qN(i,:)=c(:);
    end
end

end


