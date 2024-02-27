function [] = showStim()

opt_list = {
    'Natural Movie',
    'Multi Gratings',
    'Random Dot',
    'Natural Images',
    'Retinotopic Mapping',
    'Simple Gratings'
};

answer = listdlg('PromptString', 'Select the stimulus to present.', ...
    'SelectionMode', 'single', 'ListString', opt_list);

chk = string(opt_list(answer));

if chk == 'Natural Movie'
    showMovie
elseif chk == 'Multi Gratings'
    showMultiGratings
elseif chk == 'Random Dot'
    showRandomDot
elseif chk == 'Natural Images'
    showNatImgs
elseif chk == 'Retinotopic Mapping'
    showRetinotopicMapping
elseif chk == 'Simple Gratings'
    showSimpleGratings
end



end

