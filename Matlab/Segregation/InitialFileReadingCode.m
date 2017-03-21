global ROOT; 

ROOT  = '.';

v = ReadValues();

function [values] = ReadValues(); global ROOT;

    ME = [];
    fid = fopen([ROOT '\sample.csv']);

    try
        values = textscan(fid, '%f %f %f %f %f', 'HeaderLines', 1, 'Delimiter', ',');
    catch ME
    end
    
    if ~isempty(ME)
        rethrow(ME);
    end

    if(~all(0 <= values{2}) || ~all(values{2} <= 20) )
        throw(MException('badConversationLength', 'invalid indication of length of conversation'));
    end
    
    if(~all(ismember(values{3}, [0 1])))
        throw(MException('badSimilarityBinary', 'invalid indication of similarity with conversant'));
    end
    
    if(~all(ismember(values{4}, [0 1])))
        throw(MException('badNeighborsBinary', 'invalid indication of neighbors to talk with'));
    end
    
    if(~all(ismember(values{5}, [1 2 3 4])))
        throw(MException('badActions', 'invalid action read from file'));
    end
end