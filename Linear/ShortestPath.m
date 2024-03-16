function [sink, pred, u, v]=ShortestPath(curUnassCol,u,v,C,col4row,row4col)
numRow=size(C,1);
numCol=size(C,2);
pred=zeros(numCol,1);

%Initially, none of the rows and columns have been scanned.
%This will store a 1 in every column that has been scanned.
ScannedCols=zeros(numCol,1);

%This will store a 1 in every row that has been scanned.
ScannedRow=zeros(numRow,1);
Row2Scan=1:numRow;
numRow2Scan=numRow;

sink=0;
delta=0;
curCol=curUnassCol;
shortestPathCost=Inf(numRow,1);

while(sink==0)
    %Mark the current column as having been visited.
    ScannedCols(curCol)=1;
    
    %Scan all of the rows that have not already been scanned.
    minVal=Inf;
    for curRowScan=1:numRow2Scan
        curRow=Row2Scan(curRowScan);
        
        reducedCost=delta+C(curRow,curCol)-u(curCol)-v(curRow);
        if(reducedCost<shortestPathCost(curRow))
            pred(curRow)=curCol;
            shortestPathCost(curRow)=reducedCost;
        end
        
        %Find the minimum unassigned row that was scanned.
        if(shortestPathCost(curRow)<minVal)
            minVal=shortestPathCost(curRow);
            closestRowScan=curRowScan;
        end
    end
    
    if(~isfinite(minVal))
        %If the minimum cost row is not finite, then the problem is
        %not feasible.
        sink=0;
        return;
    end
    
    closestRow=Row2Scan(closestRowScan);
    
    %Add the row to the list of scanned rows and delete it from
    %the list of rows to scan.
    ScannedRow(closestRow)=1;
    numRow2Scan=numRow2Scan-1;
    Row2Scan(closestRowScan)=[];
    
    delta=shortestPathCost(closestRow);
    
    %If we have reached an unassigned column.
    if(col4row(closestRow)==0)
        sink=closestRow;
    else
        curCol=col4row(closestRow);
    end
    
end

%Dual Update Step

%Update the first column in the augmenting path.
u(curUnassCol)=u(curUnassCol)+delta;
%Update the rest of the columns in the augmenting path.
sel=(ScannedCols~=0);
sel(curUnassCol)=0;
u(sel)=u(sel)+delta-shortestPathCost(row4col(sel));

%Update the scanned rows in the augmenting path.
sel=ScannedRow~=0;
v(sel)=v(sel)-delta+shortestPathCost(sel);
end