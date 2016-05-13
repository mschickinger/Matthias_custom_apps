function [output] = StateVectorComparison(states1,states2,toleranz_max)
        
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
            {14} = Settings des oberen Plots

%}
    
    %prozentuale deckung der beiden vektoren:
    ueberein = states1==states2;
    proz_ueberein = (sum(ueberein)*100)/length(ueberein);
    output{13} = proz_ueberein;

    dv1 = states1(2:end) - states1(1:end-1);
    dv1 = [0;dv1];
    dv2 = states2(2:end) - states2(1:end-1);
    dv2 = [0;dv2];

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
        vektor_plot{k} = matrix{k}((matrix_in_tol{k}==1));
        %anzahl der events innerhalb der toleranz
        n{k} = length(vektor_plot{k});
        output{k} = n{k};
    end
    
    %OUTPUT:
    %ausgabe der positionen, an denen ein event innerhalb der toleranz in
    %beiden vektoren vorkommt; mithilfe der zeilensummme
    for k = (1:2)
        output{k+2} = pos1{k}((sum(matrix_in_tol{k},2)==1));
    end
    
    %EVENTS AUSSERHALB TOLERANZ:
    ausser_tol1{1} = 0;
    ausser_tol1{2} = 0;
    ausser_tol2{1} = 0;
    ausser_tol2{2} = 0;
    %events von 1 auf 2 und events von 2 auf 1 ergeben 4 werte
    %mithilfe von zeilen- und spaltensumme
    for k = (1:2)
        ausser_tol1{k} = sum(sum(matrix_in_tol{k},2)==0);
        output{k+4} = ausser_tol1{k};
        output{k+6} = pos1{k}(sum(matrix_in_tol{k},2)==0);
        ausser_tol2{k} = sum(sum(matrix_in_tol{k},1)==0);
        output{k+8} = ausser_tol2{k};
        output{k+10} = pos2{k}(sum(matrix_in_tol{k},1)==0);
    end
    %und Markierung in den Plots der Vektoren
    
    for k = (1:2)
        P1{k} = pos1{k}(sum(matrix_in_tol{k},2)==0);
        P2{k} = pos2{k}(sum(matrix_in_tol{k},1)==0);
    end
        
    %PLOTS:
    close all
   
    figure('Units', 'normalized','OuterPosition', [0 0 1 1], 'PaperPositionMode', 'auto')
    
    subplot('Position',[0.05,0.60,0.90,0.35]);
    hold on
    for k = (1:2)
        for i = (1:length(P1{k}))
            plot(P1{k}(i)*[1 1], [0 5],'-','Color',[0.8500    0.3250    0.0980]);        
        end
        for i = (1:length(P2{k}))
            plot(P2{k}(i)*[1 1], [0 5],'-','Color',[0.8500    0.3250    0.0980]);        
        end
    end
    
    p = plot([states1 states2+2]);
    p(1).Color = [0 0 1];
    p(2).Color = [ 0.4660    0.6740    0.1880];
    ylim([0.5 4.5]);
    ay = gca;
    ay.YTick = [1 2 3 4];
    ay.YTickLabels = {'1','2','1','2'};
    legend(p,'states1: test trace','states2: reference trace','Location','west','Orientation','horizontal');
    output{14} = ay;
      
    subplot('Position',[0.05,0.10,0.40,0.35]);
    b1 = bar([-5:5],[histcounts(vektor_plot{1},-5:6)' histcounts(vektor_plot{2},[-5:6])']);
    b1(1).FaceColor = [0.0 0.0 0.9];
    b1(2).FaceColor = [0.0 0.8 0.8];
    ylim([0 (max([histcounts(vektor_plot{1}) histcounts(vektor_plot{2})])+2) ]);
    title('deviation from reference trace');
    legend('unbinding events','binding events','Orientation','horizontal');
    xlabel({'negative: events of blue (down) graph happen earlier','positive: events of green (up) graph happen earlier'})
    
    subplot('Position',[0.50,0.10,0.25,0.35]);
    b2 = bar([ausser_tol1{1} ausser_tol1{2}; ausser_tol2{1} ausser_tol2{2}]);
    b2(1).FaceColor = [0.0 0.0 0.9];
    b2(2).FaceColor = [0.0 0.8 0.8];
    title('events out of tolerance');
    ylim([0 (max([1 ausser_tol1{1} ausser_tol2{1} ausser_tol1{2} ausser_tol2{2}])*1.2) ]);
    ax = gca;
    ax.XTick = [1 2];
    ax.XTickLabels = {'from 1 to 2 (1 is reference)','from 2 to 1 (2 is reference)'};
    legend('unbinding events','binding events','Orientation','horizontal');
   
    subplot('Position',[0.80,0.10,0.15,0.35]);
    axis off;
    text(0,1,['match:  ' num2str(proz_ueberein) '  %'],'horizontalalignment','left','verticalalignment','bottom','FontSize',15);
    text(0,0.8,['unbinding events in tolerance: ' num2str(n{1})],'horizontalalignment','left','verticalalignment','bottom','FontSize',12);
    text(0,0.6,['binding events in tolerance: ' num2str(n{2})],'horizontalalignment','left','verticalalignment','bottom','FontSize',12);
    
end