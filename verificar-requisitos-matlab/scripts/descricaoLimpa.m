function textoLimpo = descricaoLimpa(html)
    if ~contains(html, '<html>')
        textoLimpo = strtrim(html);
        return;
    end
    
    % Remove blocos <style>...</style> e <head>...</head> primeiro
    textoLimpo = regexprep(html, '<style[^>]*>.*?</style>', '', 'ignorecase');
    textoLimpo = regexprep(textoLimpo, '<head[^>]*>.*?</head>', '', 'ignorecase');
    
    % Remove as demais tags HTML
    textoLimpo = regexprep(textoLimpo, '<[^>]*>', '');
    
    % Decodifica entidades HTML
    textoLimpo = strrep(textoLimpo, '&amp;',  '&');
    textoLimpo = strrep(textoLimpo, '&lt;',   '<');
    textoLimpo = strrep(textoLimpo, '&gt;',   '>');
    textoLimpo = strrep(textoLimpo, '&nbsp;', ' ');
    textoLimpo = strrep(textoLimpo, '&quot;', '"');
    
    textoLimpo = strtrim(textoLimpo);
end