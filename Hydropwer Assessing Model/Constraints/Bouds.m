%%Bounds
% lb0=[hmin';zeros(1,49);qSmin'];
% lb=repmat(lb0(:),d,1);
% ub0=[hmax'; qTmax'; qSmax'];
% ub=repmat(ub0(:),d,1);
%%Bounds
% lb0=[zeros(1,49);zeros(1,49);qSmin'];    %The limitation of 'h' change to 'h-h_fallheight'.
% lb=repmat(lb0(:),d,1);
% ub0=[hmax'; qTmax'; qSmax'];
% ub=repmat(ub0(:),d,1);

lb0=[zeros(1,49);zeros(1,49);zeros(1,49)];    %The limitation of 'h' change to 'h-h_fallheight'.
lb=repmat(lb0(:),d,1);
ub0=[hmax'; qTmax'; qSmax'];
ub=repmat(ub0(:),d,1);



