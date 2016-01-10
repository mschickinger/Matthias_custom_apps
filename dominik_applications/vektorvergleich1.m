function [pos_unique] = vektorvergleich1(vektor1,vektor2,toleranz_max)
        
%{
    input: 
    zwei ersten beiden variablen (vektor1, vektor2) sind vektoren mit 
    36.000 komponenten, die entweder 1 oder 2 sein druerfen. 1 steht dabei
    für den gebundenen zustand und 2 für den ungebundenen zustand. die 
    funktion vergleicht nun diese beiden vektoren. zum einen auf ihre 
    globale deckung und zum anderen auf die uebergänge zwischen den beiden 
    zustaenden. 
    die dritte variable (toleranz_max) gibt die toleranz an, bei der zwei 
    uebergaenge mit abweichung noch als dasselbe event erkannt wird.
    
    output:
    die variable (pos_unique) vereint die positionen von events, die
    innerhalb der toleranz in beiden vektoren vorhanden sind. zuerst kommen
    die positionen der binding events anschließend die der unbinding
    events.
    
%}
    
    %prozentuale deckung der beiden vektoren:
    ueberein = vektor1==vektor2;
    proz_ueberein = (sum(ueberein)*100)/length(ueberein);

    dv1 = vektor1(2:end) - vektor1(1:end-1);
    dv1 = [0,dv1];
    dv2 = vektor2(2:end) - vektor2(1:end-1);
    dv2 = [0,dv2];

    
    %UNBINDING EVENTS:
    unb_pos1 = find(dv1==1);
    unb_pos2 = find(dv2==1);
    
    %unb_matrix gibt differenz zwischen den events aus 1 und 2
    unb_matrix = zeros(length(unb_pos1),length(unb_pos2));
    unb_matrix_in_tol = unb_matrix;
    for j = (1:length(unb_pos1))
       for i = (1:length(unb_pos2))
          unb_matrix(j,i) = unb_pos1(j)-unb_pos2(i);
       end
    end
    
    %unb_matrix_in_tol gibt positionen der matrix, wo unbinding events 
    %innerhalb der toleranz
    unb_matrix_in_tol = ismember(unb_matrix,-toleranz_max:toleranz_max);
    
    %event aus 1 soll nur einem event aus 2 zugeordnet werden, dem nächsten
    for j = (1:length(unb_pos1))
        if sum(ismember(unb_matrix(j,1:end),-toleranz_max:toleranz_max)==1)>1
            a = find(abs(unb_matrix)==min(abs(unb_matrix(j,1:end))));          
            unb_matrix_in_tol(j,1:end) = 0;
            unb_matrix_in_tol(a) = 1;          
        end
    end
    
    %unb_matrix_in_tol wird in vektor umgewandelt
    unb_vektor_in_tol = find(unb_matrix_in_tol==1);
        
    %unb_vektor_plot gibt die abweichungen der unbinding events von 2 zu 1
    %fuer den plot
    unb_vektor_plot = [];
    for j = (1:length(unb_vektor_in_tol))
         unb_vektor_plot(j) = unb_matrix(unb_vektor_in_tol(j));       
    end
    
    %anzahl der unbinding events innerhalb der toleranz
    n_unb = length(unb_vektor_plot);

    
    %BINDING EVENTS:
    b_pos1 = find(dv1==-1);
    b_pos2 = find(dv2==-1);
    
    %b_matrix gibt differenz zwischen den events aus 1 und 2
    b_matrix = zeros(length(b_pos1),length(b_pos2));
    b_matrix_in_tol = b_matrix;
    for j = (1:length(b_pos1))
       for i = (1:length(b_pos2))
          b_matrix(j,i) = b_pos1(j)-b_pos2(i);
       end
    end
    
    %b_matrix_in_tol gibt positionen der matrix, wo binding events 
    %innerhalb der toleranz
    b_matrix_in_tol = ismember(b_matrix,-toleranz_max:toleranz_max);
        
    %event aus 1 soll nur einem event aus 2 zugeordnet werden, dem nächsten
    for j = (1:length(b_pos1))
        if sum(ismember(b_matrix(j,1:end),-toleranz_max:toleranz_max)==1)>1
            a = find(abs(b_matrix)==min(abs(b_matrix(j,1:end))));     
            b_matrix_in_tol(j,1:end) = 0;
            b_matrix_in_tol(a) = 1;
        end
    end
    
    %b_matrix_in_tol wird in vektor umgewandelt
    b_vektor_in_tol = find(b_matrix_in_tol==1);
        
    %b_vektor_plot gibt die abweichungen der binding events von 2 zu 1 fuer
    %den plot
    b_vektor_plot = [];
    for j = (1:length(b_vektor_in_tol))
         b_vektor_plot(j) = b_matrix(b_vektor_in_tol(j));       
    end
    
    %anzahl der binding events innerhalb der toleranz
    n_b = length(b_vektor_plot);
    
    
    %OUTPUT:
    pos_unique = [];
    for i = (1:length(b_pos1))
        if any(b_matrix_in_tol(i,:)==1)
            pos_unique = [pos_unique b_pos1(i)];
        end
    end
    for j = (1:length(unb_pos1))
        if any(unb_matrix_in_tol(j,:)==1)
            pos_unique = [pos_unique unb_pos1(j)];
        end
    end
    
   
    %EVENTS AUSSERHALB TOLERANZ:
    %unbinding events von 1 auf 2:
    unb_ausser_tol1 = 0;    
    for j = (1:length(unb_pos1))
        if any(ismember(unb_matrix(j,1:end),-toleranz_max:toleranz_max)==1)
        else
            unb_ausser_tol1 = unb_ausser_tol1 + 1;
        end
    end
    
    %unbinding events von 2 auf 1:
    unb_ausser_tol2 = 0;
    for j = (1:length(unb_pos2))
        if any(ismember(unb_matrix(1:end,j),-toleranz_max:toleranz_max)==1)
        else
            unb_ausser_tol2 = unb_ausser_tol2 + 1;
        end
    end
    
    %binding events von 1 auf 2:
    b_ausser_tol1 = 0;    
    for j = (1:length(b_pos1))
        if any(ismember(b_matrix(j,1:end),-toleranz_max:toleranz_max)==1)
        else
            b_ausser_tol1 = b_ausser_tol1 + 1;
        end
    end
    
    %binding events von 2 auf 1:
    b_ausser_tol2 = 0;
    for j = (1:length(b_pos2))
        if any(ismember(b_matrix(1:end,j),-toleranz_max:toleranz_max)==1)
        else
            b_ausser_tol2 = b_ausser_tol2 + 1;
        end
    end
    
    %hilfsvariablen fuer plots:
    toleranz_max_neg = -toleranz_max-1;
    
    y_max_b = length(find(b_vektor_plot==mode(b_vektor_plot))) + 1;
    y_max_unb = length(find(unb_vektor_plot==mode(unb_vektor_plot))) + 1;
    
    x = [b_ausser_tol1,unb_ausser_tol1,b_ausser_tol2,unb_ausser_tol2];
    y_max_x = max(x) + 1;
        
    %alle plots:
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

    subplot(2,2,2)
    h2 = bar(x);
    title('events ausser Toleranz');
    %xlim([]);
    ylim([0 y_max_x]);
    set(h2,'FaceColor','b');
    ax = gca;
    ax.XTick = [1 2 3 4];
    ax.XTickLabels = {'b: 1->2','unb: 1->2','b: 2->1','unb: 2->1'};
        
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
    set(h4,'FaceColor',[0.9,0.9,0.9]);
    str = num2str(proz_ueberein); 
    text(1,1,str,'horizontalalignment','center','verticalalignment','bottom','FontSize',30); 

end

