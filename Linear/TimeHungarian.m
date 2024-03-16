function [pktidx,RUidx,gain]=TimeHungarian(C,maximum_timelimit)
maximum_timelimit;
maximize=true;
if(isempty(maximize))
    maximize=false;
end
numRow=size(C,1);
numCol=size(C,2);

didFlip=false;
if(numCol>numRow)
    C=C';
    temp=numRow;
    numRow=numCol;
    numCol=temp;
    didFlip=true;
end

%The cost matrix must have all non-negative elements for the assignment
%algorithm to work. This forces all of the elements to be positive. The
%delta is added back in when computing the gain in the end.
if(maximize==true)
    CDelta=max(C(:));

    %If C is all negative, do not shift.
    if(CDelta<0)
        CDelta=0;
    end

    C=-C+CDelta;
else
    CDelta=min(C(:));

    %If C is all positive, do not shift.
    if(CDelta>0)
        CDelta=0;
    end

    C=C-CDelta;
end

%These store the assignment as it is made.
col4row=zeros(numRow,1);
row4col=zeros(numCol,1);
u=zeros(numCol,1);%The dual variable for the columns
v=zeros(numRow,1);%The dual variable for the rows.

% if maximum_time<numCol
%     stop_point=maximum_time;
%     col4row2=zeros(numRow,1);
%     row4col2=zeros(numCol,1);
% else
%     stop_point=numCol;
%     col4row2=zeros(numRow,1);
%     row4col2=zeros(numCol,1);
% end

tic
%Initially, none of the columns are assigned.
for curUnassCol=1:numCol
    %This finds the shortest augmenting path starting at k and returns
    %the last node in the path.
    [sink,pred,u,v]=ShortestPath(curUnassCol,u,v,C,col4row,row4col);

    %If the problem is infeasible, mark it as such and return.
    if(sink==0)
        col4row=[];
        row4col=[];
        gain=-1;
        return;
    end

    %We have to remove node k from those that must be assigned.
    j=sink;
    temp_time=toc;
    while(temp_time<maximum_timelimit)
        i=pred(j);
        col4row(j)=i;
        h=row4col(i);
        row4col(i)=j;
        j=h;

        if(i==curUnassCol)
            break;
        end
    end
    if temp_time>=maximum_timelimit
        stop_point=curUnassCol;
        pktidx=col4row;
        row4col_temp=row4col;
        break;
    else
        stop_point=curUnassCol;
        pktidx=col4row;
        row4col_temp=row4col;
    end
end

row4col_temp_new=row4col_temp;

if stop_point<=numCol
    Zeroidx=find(row4col_temp==0);
    NoZeroidx=find(row4col_temp~=0);
    unassignedset=setdiff(1:numCol,row4col_temp(NoZeroidx));
    unassignNewidx=randperm(length(unassignedset));
    unassignedsetNew=unassignedset(unassignNewidx);
    row4col_temp_new(Zeroidx)=unassignedsetNew;
end
RUidx=row4col_temp_new;




%Calculate the gain that should be returned.
gain=0;

for curCol=1:numCol
    gain=gain+C(RUidx(curCol),curCol);
    %gain=gain+C(curCol,curCol);
end

%Adjust the gain for the initial offset of the cost matrix.
if(maximize)
    gain=-gain+CDelta*numCol;
    u=-u;
    v=-v;
else
    gain=gain+CDelta*numCol;
end


if(didFlip==true)
    temp=row4col;
    row4col=col4row;
    col4row=temp;

    temp=u;
    u=v;
    v=temp;
end

end