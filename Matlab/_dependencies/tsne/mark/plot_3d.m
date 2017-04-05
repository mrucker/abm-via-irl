function plot_3d(data, lbls, figureName)

    red   = [1 .5 .5];
    black = [0  0  0];
    green = [.5 1 .5];

    colors = [red;black;green];
    
    figure('Name', figureName);
    hold on;

    u_lbls = unique(lbls);
    u_lbls = {u_lbls{~strcmp(u_lbls,'')}};
    
    for i = 1:length(u_lbls)
        lbl = u_lbls{i};

        if isempty(lbls)
            lbl_data = data;
        else
            [lbl_data, ~] = partition(@(l) strcmp(l,lbl), data, lbls);
        end

        plot3(lbl_data(:,1), lbl_data(:,2), lbl_data(:,3), '.'...
             ,'MarkerSize'     , 10                           ...
             ,'MarkerEdgeColor', colors(i,:)                  ...
             ,'MarkerFaceColor', colors(i,:)                  ...
             ,'DisplayName'    , lbl                          ...
        );
    end
    legend('Show');
    hold off;
end