function [data, lbls] = partition(pred, all_data, all_lbls)
    indx = find(arrayfun(pred, all_lbls));
    data = all_data(indx, :);
    lbls = all_lbls(indx);
end