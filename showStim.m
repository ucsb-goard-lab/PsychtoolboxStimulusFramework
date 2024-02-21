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

if opt_list(answer) == 'Natural Movie'
    showMovie()
elseif opt_list(answer) == 'Multi Gratings'
    showMultiGratings()
elseif opt_list(answer) == 'Random Dot'
    showRandomDot()
elseif opt_list(answer) == 'Natural Images'
    showNatImgs()
elseif opt_list(answer) == 'Retinotopic Mapping'
    showRetinotopicMapping()
elseif opt_list(answer) == 'Simple Gratings'
    showSimpleGratings()
end



end

