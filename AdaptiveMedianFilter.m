function filteredSignal = AdaptiveMedianFilter(signal, leftWindowSize, rightWindowSize, leftTransitionIndex, ...
        rightTransitionIndex)
    % AdaptiveMedianFilter      Filters the input signal using median filters with two different kernels and blends
    %                           the output of the two filters in the range between the two specified transition 
    %                           indices.
    %
    % Copyright (C) 2025      Michigan State University
    % Author:  Matt Latourette

    leftWindowFilteredSignal = smoothdata(signal, 'movmedian', leftWindowSize);
    rightWindowFilteredSignal = smoothdata(signal, 'movmedian', rightWindowSize);

    signalLength = size(signal, 2);
    filteredSignal = zeros(1, signalLength);
    leftTransitionIndex = ConstrainValueToRange(leftTransitionIndex, 1, signalLength);
    rightTransitionIndex = ConstrainValueToRange(rightTransitionIndex, 1, signalLength);
    oneBeforeTransitionIndex = ConstrainValueToRange(leftTransitionIndex-1, 1, signalLength);
    oneAfterTransitionIndex = ConstrainValueToRange(rightTransitionIndex+1, 1, signalLength);
    filteredSignal(1:oneBeforeTransitionIndex) = ...
        leftWindowFilteredSignal(1:oneBeforeTransitionIndex);
    filteredSignal(oneAfterTransitionIndex:signalLength) = ...
        rightWindowFilteredSignal(oneAfterTransitionIndex:signalLength);
    idx = leftTransitionIndex:rightTransitionIndex;
    filteredSignal(idx) = ((idx-leftTransitionIndex).*rightWindowFilteredSignal(idx) + ...
        (rightTransitionIndex-idx).*leftWindowFilteredSignal(idx)) ./ ...
        (rightTransitionIndex-leftTransitionIndex);

    % % debugging code to show plots depicting the transition zone
    % figure
    % plot(1:length(signal), signal, 'c');
    % hold on
    % plot(1:length(leftWindowFilteredSignal), leftWindowFilteredSignal, 'r.');
    % plot(1:length(rightWindowFilteredSignal), rightWindowFilteredSignal, 'b.');
    % 
    % plot(1:oneBeforeTransitionIndex, filteredSignal(1:oneBeforeTransitionIndex), 'g');
    % hold on
    % plot(oneAfterTransitionIndex:signalLength, filteredSignal(oneAfterTransitionIndex:signalLength), 'm');
    % plot(oneBeforeTransitionIndex:oneAfterTransitionIndex, ...
    %     filteredSignal(oneBeforeTransitionIndex:oneAfterTransitionIndex), 'k')
end