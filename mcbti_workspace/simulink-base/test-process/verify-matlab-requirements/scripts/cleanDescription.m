function cleanText = cleanDescription(html)
    if ~contains(html, '<html>')
        cleanText = strtrim(html);
        return;
    end
    % Remove <style>...</style> and <head>...</head> blocks first
    cleanText = regexprep(html, '<style[^>]*>.*?</style>', '', 'ignorecase');
    cleanText = regexprep(cleanText, '<head[^>]*>.*?</head>', '', 'ignorecase');
    % Remove remaining HTML tags
    cleanText = regexprep(cleanText, '<[^>]*>', '');
    % Decode HTML entities
    cleanText = strrep(cleanText, '&amp;',  '&');
    cleanText = strrep(cleanText, '&lt;',   '<');
    cleanText = strrep(cleanText, '&gt;',   '>');
    cleanText = strrep(cleanText, '&nbsp;', ' ');
    cleanText = strrep(cleanText, '&quot;', '"');
    cleanText = strtrim(cleanText);
end