function [data, lbls] = partition(pred, all_data, all_lbls)

    if iscell(all_lbls)
        indx = find(cellfun(pred, all_lbls));
    else
        indx = find(arrayfun(pred, all_lbls));
    end

    data = all_data(indx, :);
    lbls = all_lbls(indx);
end