function [  ] = threeinarow( positions, binds, unbinds, frames )

%wie gro? soll counter?   counter(i)->3 in a row counter(2)->4 in a row...
counter(size(positions,1))=0;
%characterise last states
if binds(end)<unbinds(end)
    lastunbinds=[binds-1,frames];
    lastbinds=[unbinds-1];
else
    lastbinds=[unbinds-1,frames];
    lastunbinds=[binds-1];
end

%characterise first states
if binds(1)<unbinds(1)
    unbinds=[1,unbinds];
else
    binds=[1,binds];
end

%build matrix bound/unbound start, end states
binds=[binds; lastbinds];
unbinds=[unbinds; lastunbinds];

distance=0.1;
number=3;
value=1;
maxvector(size(positions,1),2)=0;
minvector(size(positions,1),2)=0;
X(size(positions),number,2)=0;
smallXY(size(positions,1),2)=0;

% x-limit for bar graph
xlim=4;


%X
for i=1:number
X(i:end,i,1)=positions(1:end+1-i,1);
end
%Y
for i=1:number
X(i:end,i,2)=positions(1:end+1-i,2);
end

%max, min
%X-vector
maxvector(1:end-number+1,1)=max(X(number:end,:,1),[],2);
minvector(1:end-number+1,1)=min(X(number:end,:,1),[],2);

%Y-vector
maxvector(1:end-number+1,2)=max(X(number:end,:,2),[],2);
minvector(1:end-number+1,2)=min(X(number:end,:,2),[],2);


%the "number-1" frames following the frame of index are close to i NOT
%RADIALLY!!
smallXY=find(maxvector(:,1)-minvector(:,1)<distance & maxvector(:,2)-minvector(:,2)<distance);
vector_smallXY=maxvector(:,1)-minvector(:,1)<distance & maxvector(:,2)-minvector(:,2)<distance;



%%%%%% prepare output
i=1;
while i<=size(vector_smallXY,1)
   
        j=1;
   if vector_smallXY(i)
       
       while i+j<=size(vector_smallXY,1) && vector_smallXY(i+j)

           j=j+1;
       end
       
       counter(j)=counter(j)+1;

   end

           i=i+j;
end


bar (1:xlim,counter(1:xlim));
xlim([0 7]);

% plot
% hold on
% for i=1:length(smallXY)
%     if anything==1(unbinds(:,1)<smallXY(i) & smallXY(i)unbinds(:,2))
%         plot
%     end
% end
% %lines=find(toplot==2 & vector_smallXY);
% 
% disp(lines);
% %total number of
% nr=length(smallXY);
% 
% %check in which state smallxy is
% %third row for number of close points in that state
% binds=[binds; zeros(size(binds,2),1)']';
% unbinds=[unbinds; zeros(size(unbinds,2),1)']';
% 
% 
% 
% for i=1:size(binds,1)
%     binds(i,3)=sum(binds(i,1)<smallXY & smallXY<binds(i,2));
% end
% 
% 
% for i=1:size(unbinds,1)
%     unbinds(i,3)=sum(unbinds(i,1)<smallXY & smallXY<unbinds(i,2));
% end
% 
% %anteil an bind, unbind interval,, 
% 
% % position striche
% plot(toplot);
% ylim([0 3]);
% hold on
% 
% % for i=1:size(unbinds,1)
% %     if
% %     plot([unbinds(i,3) unbinds(i,3)], [0 2.5], 'k-');
% % end
% %save data


end