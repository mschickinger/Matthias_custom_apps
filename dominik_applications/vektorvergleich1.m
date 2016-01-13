function [output] = vektorvergleich1(vektor1,vektor2,toleranz_max)
        
%{
    input: 
        - vektor1 enthaelt nur die werte 1 und 2
        - vektor2 enthaelt nur die werte 1 und 2 und hat die gleiche laenge
          wie vektor1
        - toleranz_max kann beliebig gewaehlt werden    
    
    output:
        - output ist eine cell mit folgender belegung:
            {1} = anzahl der unbinding event innerhalb der toleranz
            {2} = anzahl der binding event in. tol.
            {3} = position der unbinding events in. tol.
            {4} = position der binding events in. tol.
            {5} = anzahl der unbinding events ausserhalb der toleranz von
                  vektor 1
            {6} = anzahl der binding events auss. tol. von vektor 1
            {7} = position der unbinding events auss. tol. von vektor 1
            {8} = position der binding events auss. tol. von vektor 1
            {9} = anzahl der unbinding events auss. tol. von vektor 2
            {10} = anzahl der binding events auss. tol. von vektor 2
            {11} = positionen der unbinding events auss. tol. von vektor 2
            {12} = positionen der binding events auss. tol. von vektor 2
            {13} = prozentuale deckung von vektor 1 und vektor 2

%}
    
    %prozentuale deckung der beiden vektoren:
    ueberein = vektor1==vektor2;
    proz_ueberein = (sum(ueberein)*100)/length(ueberein);
    output{13} = proz_ueberein;

    dv1 = vektor1(2:end) - vektor1(1:end-1);
    dv1 = [0,dv1];
    dv2 = vektor2(2:end) - vektor2(1:end-1);
    dv2 = [0,dv2];

    %UNBINDING {1} UND BINDING {2} EVENTS:
    pos1{1} = find(dv1==1);
    pos1{2} = find(dv1==-1);
    pos2{1} = find(dv2==1);
    pos2{2} = find(dv2==-1);
    
    %matrix gibt differenz zwischen den events aus 1 und 2
    matrix{1} = zeros(length(pos1{1}),length(pos2{1}));
    matrix{2} = zeros(length(pos1{2}),length(pos2{2}));
    matrix_in_tol{1} = zeros(length(matrix{1}));
    matrix_in_tol{2} = zeros(length(matrix{2}));
    
    for k = (1:2)
        for j = (1:length(pos1{k}))
            for i = (1:length(pos2{k}))
                matrix{k}(j,i) = pos1{k}(j) - pos2{k}(i);
            end
        end
        %matrix_in_tol gibt positionen der matrix, wo unbinding events 
        %innerhalb der toleranz
        matrix_in_tol{k} = ismember(matrix{k},-toleranz_max:toleranz_max);
    end
    
    %event aus 1 soll nur dem naechsten event aus 2 zugeordnet werden
    n{1} = 0;
    n{2} = 0;
    for k = (1:2)
        for j = (1:length(pos1{k}))
            if sum(matrix_in_tol{k}(j,:))>1
                [~,a] = min(abs(matrix{k}(j,:)));          
                matrix_in_tol{k}(j,:) = 0;
                matrix_in_tol{k}(j,a) = 1;          
            end
        end
        %vektor_plot gibt die abweichungen der unbinding events von 2 zu 1
        %fuer den plot
        vektor_plot{k} = matrix{k}(find(matrix_in_tol{k}==1));
        %anzahl der events innerhalb der toleranz
        n{k} = length(vektor_plot{k});
        output{k} = n{k};
    end
    
    %OUTPUT:
    %ausgabe der positionen, an denen ein event innerhalb der toleranz in
    %beiden vektoren vorkommt; mithilfe der zeilensummme
    for k = (1:2)
        output{k+2} = pos1{k}(find(sum(matrix_in_tol{k},2)==1));
    end
    
    %EVENTS AUSSERHALB TOLERANZ:
    ausser_tol1{1} = 0;
    ausser_tol1{2} = 0;
    ausser_tol2{1} = 0;
    ausser_tol2{2} = 0;
    %events von 1 auf 2 und events von 2 auf 1 ergeben 4 werte
    %mithilfe von zeilen- und spaltensumme
    for k = (1:2)
        ausser_tol1{k} = sum(find(sum(matrix_in_tol{k},2)==0));
        output{k+4} = ausser_tol1{k};
        output{k+6} = pos1{k}(find(sum(matrix_in_tol{k},2)==0));
        ausser_tol2{k} = sum(find(sum(matrix_in_tol{k},1)==0));
        output{k+8} = ausser_tol2{k};
        output{k+10} = pos2{k}(find(sum(matrix_in_tol{k},1)==0));
    end
    
    %hilfsvariablen fuer plots:
    toleranz_max_neg = -toleranz_max-1;
    
    for k = (1:2)
        y_max{k} = length(find(vektor_plot{k}==mode(vektor_plot{k}))) + 1;
    end
        
    x = [ausser_tol1{2},ausser_tol1{1},ausser_tol2{2},ausser_tol2{1}];
    y_max_x = max(x) + 1;
        
    %PLOTS:
    close all
    
    figure
    subplot(2,2,1)
    h1 = histogram(vektor_plot{2});
    title('binding events');
    xlim([toleranz_max_neg toleranz_max+1]);
    ylim([0 y_max{2}]);
    set(h1,'FaceColor','b');
    str_b = num2str(sum(n{2})); 
    text(toleranz_max,y_max{2},str_b,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);

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
    h3 = histogram(vektor_plot{1});
    title('unbinding events');
    xlim([toleranz_max_neg toleranz_max+1]);
    ylim([0 y_max{1}]);
    set(h3,'FaceColor','b');
    str_unb = num2str(sum(n{1})); 
    text(toleranz_max,y_max{1},str_unb,'horizontalalignment','center','verticalalignment','bottom','FontSize',20);

    subplot(2,2,4)
    h4 = bar(proz_ueberein);
    title('Uebereinstimmung in %');
    %xlim([]);
    ylim([0 100]);
    set(h4,'FaceColor',[0.9,0.9,0.9]);
    str = num2str(proz_ueberein); 
    text(1,1,str,'horizontalalignment','center','verticalalignment','bottom','FontSize',30); 

end