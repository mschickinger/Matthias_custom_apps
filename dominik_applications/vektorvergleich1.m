toleranz_max = 5;
vektor1 = ones(1,36000);
vektor1([6 7 8 9 10 500:550 600:20000 35000:end]) = 2;
vektor2 = ones(1,36000);
vektor2([2 3 4 5 6 555 6666:7777 35500]) = 2;

ueberein = vektor1==vektor2;
proz_ueberein = (sum(ueberein)*100)/length(ueberein);

dv1 = vektor1(2:end) - vektor1(1:end-1);
dv1 = [0,dv1];
dv2 = vektor2(2:end) - vektor2(1:end-1);
dv2 = [0,dv2];

unb_pos_vektor1 = find(dv1==1);
unb_pos_vektor2 = find(dv2==1);
unb_unique = unique([unb_pos_vektor1 unb_pos_vektor2]);

for j = (1:length(unb_pos_vektor1))
   for i = (1:length(unb_pos_vektor2))
       unb_matrix(j,i) = unb_pos_vektor1(j)-unb_pos_vektor2(i);
      if (abs(unb_matrix(j,i))<=toleranz_max) || ((unb_matrix(j,i)<0) && (unb_matrix(j,i)>=-toleranz_max))
         unb_matrix_in_tol(j,i) = 1;
      else
         unb_matrix_in_tol(j,i) = 0;
      end
   end
end

unb_vektor_plot=[];
for j = (1:length(unb_pos_vektor1))
    for i = (1:length(unb_pos_vektor2))
        if unb_matrix_in_tol(j,i)==1
            unb_vektor_plot = [unb_matrix(j,i),unb_vektor_plot];
        else
            unb_vektor_plot = unb_vektor_plot;
        end
    end
end

for i = (-toleranz_max:toleranz_max)
    if i<0
        k = -i;
        n_unb_neg_i(k) = length(find(unb_vektor_plot==i));
    elseif i==0
        n_unb_null = length(find(unb_vektor_plot==0));
    else
        n_unb_pos_i(i) = length(find(unb_vektor_plot==i));
    end
end
n_unb = [fliplr(n_unb_neg_i) n_unb_null n_unb_pos_i];
n_unb_ausser_tol = abs(length(unb_pos_vektor1)-length(unb_pos_vektor2));

b_pos1 = find(dv1==-1);
b_pos2 = find(dv2==-1);
b_unique = unique([b_pos1 b_pos2]);

for j = (1:length(b_pos1))
   for i = (1:length(b_pos2))
       b_matrix(j,i) = b_pos1(j)-b_pos2(i);
      if (abs(b_matrix(j,i))<=toleranz_max) || ((b_matrix(j,i)<0) && (b_matrix(j,i)>=-toleranz_max))
         b_matrix_in_tol(j,i) = 1;
      else
         b_matrix_in_tol(j,i) = 0;
      end
   end
end

b_vektor_plot=[];
for j = (1:length(b_pos1))
    for i = (1:length(b_pos2))
        if b_matrix_in_tol(j,i)==1
            b_vektor_plot = [b_matrix(j,i),b_vektor_plot];
        else
            b_vektor_plot = b_vektor_plot;
        end
    end
end

for i = (-toleranz_max:toleranz_max)
    if i<0
        k = -i;
        n_b_neg_i(k) = length(find(b_vektor_plot==i));
    elseif i==0
        n_b_null = length(find(b_vektor_plot==0));
    else
        n_b_pos_i(i) = length(find(b_vektor_plot==i));
    end
end
n_b = [fliplr(n_b_neg_i) n_b_null n_b_pos_i];
n_b_ausser_tol = [abs(length(b_pos1)-length(b_pos2))];

n_ausser_tol = [n_unb_ausser_tol n_b_ausser_tol];
n_ausser_tol_x = [1 2];

toleranz_max_neg = -toleranz_max-1;

if max(n_unb)==0
    y_max_unb = 1;
else
    y_max_unb = max(n_unb);
end

if max(n_b)==0
    y_max_b = 1;
else
    y_max_b = max(n_b);
end

figure
subplot(2,2,1)
h1 = histogram(b_vektor_plot);
title('binding events');
axis([toleranz_max_neg,toleranz_max+1,0,y_max_b]);
set(h1,'FaceColor','b');
str_b = num2str(sum(n_b)); 
text(5,1,str_b,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);

subplot(2,2,2)
h2 = bar(n_ausser_tol_x,n_ausser_tol);
title('events außer Toleranz');
set(h2,'FaceColor','b');
ax = gca;
ax.XTick = [1 2];
ax.XTickLabels = {'unbinding','binding'};

subplot(2,2,3)
h3 = histogram(unb_vektor_plot);
title('unbinding events');
str_unb = num2str(sum(n_unb)); 
text(5,1,str_unb,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);
axis([toleranz_max_neg,toleranz_max+1,0,y_max_unb]);
set(h3,'FaceColor','b');


subplot(2,2,4)
h4 = bar(proz_ueberein);
title('Übereinstimmung in %');
set(h4,'FaceColor','b');
str = num2str(proz_ueberein); 
text(1,1,str,'horizontalalignment','center','verticalalignment','bottom','FontSize',20); 
