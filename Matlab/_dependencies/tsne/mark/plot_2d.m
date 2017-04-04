function plot_2d(data, lbls, figureName)

    red   = [1 .5 .5];
    green = [.5 1 .5];

    figure('Name', figureName);
    hold on;

    for lbl = unique(lbls)
        if isempty(lbls)
            lbl_data = data;
            lbl      = '';            
        else
            [lbl_data, ~] = partition(@(l) l == lbl, data, lbls);
            legend(lbl, 'Location', 'northeast');
        end
        
        plot(lbl_data(:,1), lbl_data(:,2), '.'...
             ,'MarkerSize'     , 10        ...
             ,'MarkerEdgeColor', green    ...
             ,'MarkerFaceColor', green    ...
             ,'DisplayName'    , lbl      ...
        );
        
    end       

    hold off;
end