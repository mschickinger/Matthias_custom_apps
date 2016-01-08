function [] = vektorvergleich1(vektor1,vektor2,toleranz_max)
%UNTITLED Summary of this function goes here

    %prozentuale deckung der beiden vektoren:
    ueberein = vektor1==vektor2;
    proz_ueberein = (sum(ueberein)*100)/length(ueberein);

    dv1 = vektor1(2:end) - vektor1(1:end-1);
    dv1 = [0,dv1];
    dv2 = vektor2(2:end) - vektor2(1:end-1);
    dv2 = [0,dv2];

    %unbinding events:
    unb_pos1 = find(dv1==1);
    unb_pos2 = find(dv2==1);
    
    unb_matrix = zeros(length(unb_pos1),length(unb_pos2));
    unb_matrix_in_tol = unb_matrix;
    for j = (1:length(unb_pos1))
       for i = (1:length(unb_pos2))
          unb_matrix(j,i) = unb_pos1(j)-unb_pos2(i);
       end
    end

    unb_matrix_in_tol = find(ismember(unb_matrix,-toleranz_max:toleranz_max)==1);
    %unb_matrix_in_tol gibt positionen der matrix, wo unbinding events 
    %innerhalb der toleranz
    
    unb_vektor_plot = [];
    for j = (1:length(unb_matrix_in_tol))
         unb_vektor_plot(j) = unb_matrix(unb_matrix_in_tol(j));       
    end
    %unb_vektor_plot gibt die abweichungen der unbinding events von 2 zu 1
    %fuer den plot
    n_unb = length(unb_vektor_plot);

    %binding events:
    b_pos1 = find(dv1==-1);
    b_pos2 = find(dv2==-1);
    
    b_matrix = zeros(length(b_pos1),length(b_pos2));
    b_matrix_in_tol = b_matrix;
    for j = (1:length(b_pos1))
       for i = (1:length(b_pos2))
          b_matrix(j,i) = b_pos1(j)-b_pos2(i);
       end
    end
    
    b_matrix_in_tol = find(ismember(b_matrix,-toleranz_max:toleranz_max)==1);
    %b_matrix_in_tol gibt positionen der matrix, wo binding events 
    %innerhalb der toleranz
    
    b_vektor_plot = [];
    for j = (1:length(b_matrix_in_tol))
         b_vektor_plot(j) = b_matrix(b_matrix_in_tol(j));       
    end
    %b_vektor_plot gibt die abweichungen der binding events von 2 zu 1 fuer
    %den plot
    n_b = length(b_vektor_plot);
    
    %events ausserhalb der toleranz:
    %unbinding events von 1 auf 2:
    unb_ausser_tol1 = 0;    
    for j = (1:length(unb_pos1))
        if any(ismember(unb_matrix(j,1:end),-toleranz_max:toleranz_max)==1)
            unb_ausser_tol1 = unb_ausser_tol1;
        else
            unb_ausser_tol1 = unb_ausser_tol1 +1;
        end
    end
    
    %unbinding events von 2 auf 1:
    unb_ausser_tol2 = 0;
    for j = (1:length(unb_pos2))
        if any(ismember(unb_matrix(1:end,j),-toleranz_max:toleranz_max)==1)
            unb_ausser_tol2 = unb_ausser_tol2;
        else
            unb_ausser_tol2 = unb_ausser_tol2 +1;
        end
    end
    
    %binding events von 1 auf 2:
    b_ausser_tol1 = 0;    
    for j = (1:length(b_pos1))
        if any(ismember(b_matrix(j,1:end),-toleranz_max:toleranz_max)==1)
            b_ausser_tol1 = b_ausser_tol1;
        else
            b_ausser_tol1 = b_ausser_tol1 +1;
        end
    end
    
    %binding events von 2 auf 1:
    b_ausser_tol2 = 0;
    for j = (1:length(b_pos2))
        if any(ismember(b_matrix(1:end,j),-toleranz_max:toleranz_max)==1)
            b_ausser_tol2 = b_ausser_tol2;
        else
            b_ausser_tol2 = b_ausser_tol2 +1;
        end
    end
    
    %unb_ausser_tol1
    %unb_ausser_tol2
    %b_ausser_tol1
    %b_ausser_tol2
    
    %b_matrix_in_tol = find(ismember(b_matrix,-toleranz_max:toleranz_max)==1);
    
    %hilfsvariablen fuer plots:
    toleranz_max_neg = -toleranz_max-1;
    
    y_max_b = length(find(b_vektor_plot==mode(b_vektor_plot)))+1;
    y_max_unb = length(find(unb_vektor_plot==mode(unb_vektor_plot)))+1;
        
    %plots:
    close all
    
    figure
    subplot(2,2,1)
    h1 = histogram(b_vektor_plot);
    title('binding events');
    xlim([toleranz_max_neg toleranz_max+1]);
    ylim([0 y_max_b]);
    set(h1,'FaceColor','b');
    str_b = num2str(sum(n_b)); 
    text(toleranz_max,y_max_b,str_b,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);

    %{
    subplot(2,2,2)
    h2 = bar(n_ausser_tol_x,n_ausser_tol);
    title('events ausser Toleranz');
    %xlim([]);
    %ylim([]);
    set(h2,'FaceColor','b');
    ax = gca;
    ax.XTick = [1 2];
    ax.XTickLabels = {'unbinding','binding'};
    %}
    
    subplot(2,2,3)
    h3 = histogram(unb_vektor_plot);
    title('unbinding events');
    xlim([toleranz_max_neg toleranz_max+1]);
    ylim([0 y_max_unb]);
    set(h3,'FaceColor','b');
    str_unb = num2str(sum(n_unb)); 
    text(toleranz_max,y_max_unb,str_unb,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);

    subplot(2,2,4)
    h4 = bar(proz_ueberein);
    title('Uebereinstimmung in %');
    %xlim([]);
    ylim([0 100]);
    set(h4,'FaceColor','b');
    str = num2str(proz_ueberein); 
    text(1,1,str,'horizontalalignment','center','verticalalignment','bottom','FontSize',20); 

end

