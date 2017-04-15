function values = ReadSampleTrajectories_2(fileName)

    ME = [];
    fid = fopen(fileName);

    try
        values = textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1, 'Delimiter', ',');
    catch ME
    end
    
    if ~isempty(ME)
        rethrow(ME);
    end

    if(~all(0 <= values{3}) || ~all(values{3} <= 10) )
        throw(MException('badConversationLength', 'invalid indication of length of conversation'));
    end
    
    if(~all(ismember(values{4}, [0 1])))
        throw(MException('badSimilarityBinary', 'invalid indication of similarity with conversant'));
    end
    
    if(~all(ismember(values{5}, [0 1])))
        throw(MException('badPartnerBinary', 'invalid indication of partners to talk with'));
    end
    
    if(~all(ismember(values{6}, [0 1])))
        throw(MException('badFamiliarityBinary', 'invalid indication of familiarity to talk with'));
    end
    
    if(~all(ismember(values{7}, [1 2 3 4])))
        throw(MException('badActions', 'invalid action read from file'));
    end
    
    fclose(fid);
end