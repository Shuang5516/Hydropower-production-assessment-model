% % Prepare data for 'y' year and start from 'm'month
% for Tsim=90,180,270,360
function qN=Data_preparation2(y,m,SelectN,K)
load qN/qN_control_Jan.mat qN_control_Jan  % qN_control_Jan data start from Jan 1st, 1961.

if SelectN==25  % odd or even year scenarios
    qN=zeros(49,(K*2+90)*SelectN);
    c=zeros(1,(K*2+90)*SelectN);
    for i=1:49
        a=qN_control_Jan(i,:);   % 360*51
        if y==1
            for j=1:SelectN
                b=a(((j-1)*720)+(m-1)*30+1:((j-1)*720)+(m-1)*30+K*2+90);
                c((j-1)*(K*2+90)+1:j*(K*2+90))=b;
            end
        else
            a(18361:18720)=a(1:360);
            a(1:360)=[];
            
            for j=1:SelectN
                b=a(((j-1)*720)+(m-1)*30+1:((j-1)*720)+(m-1)*30+K*2+90);
                c((j-1)*(K*2+90)+1:j*(K*2+90))=b;
            end
        end
        qN(i,:)=c;
    end
end

if SelectN==50
    qN=zeros(49,(K*2+90)*SelectN);  %control scenarios
    for i=1:49
        a=[qN_control_Jan(i,:),qN_control_Jan(i,18001:18060)];
        for j=1:SelectN
            b=a(((j-1)*360)+(m-1)*30+1:((j-1)*360)+(m-1)*30+K*2+90);
            c((j-1)*(K*2+90)+1:j*(K*2+90))=b;
        end
        qN(i,:)=c;
    end
end


