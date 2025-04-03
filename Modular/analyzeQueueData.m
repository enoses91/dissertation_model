function queue_pred = analyzeQueueData(simOut)
% analyzeQueueData Analyzes queue length data.
%   queue_pred = analyzeQueueData(simOut)
%
% Retrieves the queue length time series for each engineer's queue, converts them
% to timetables, synchronizes the timetables, computes the average queue length,
% and returns the final average value.

    E1QueueTS = simOut.E1QueueLength;
    if isempty(E1QueueTS.Time)
        E1QueueTS = timeseries(0,0);
    end
    E1QueueTT = timeseries2timetable(E1QueueTS);

    SE1QueueTS = simOut.SE1QueueLength;
    if isempty(SE1QueueTS.Time)
        SE1QueueTS = timeseries(0,0);
    end
    SE1QueueTT = timeseries2timetable(SE1QueueTS);

    SE2QueueTS = simOut.SE2QueueLength;
    if isempty(SE2QueueTS.Time)
        SE2QueueTS = timeseries(0,0);
    end
    SE2QueueTT = timeseries2timetable(SE2QueueTS);

    SE3QueueTS = simOut.SE3QueueLength;
    if isempty(SE3QueueTS.Time)
        SE3QueueTS = timeseries(0,0);
    end
    SE3QueueTT = timeseries2timetable(SE3QueueTS);

    TTQueuesync = synchronize(E1QueueTT, SE1QueueTT, SE2QueueTT, SE3QueueTT, 'union', 'previous');
    TTQueuesync.AvgQueue = mean(TTQueuesync{:,{'Data_E1QueueTT','Data_SE1QueueTT','Data_SE2QueueTT','Data_SE3QueueTT'}}, 2);
    queue_pred = TTQueuesync.AvgQueue(end);
end
