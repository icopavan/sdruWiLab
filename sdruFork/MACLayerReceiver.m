function [Response, previousMessage] = MACLayerReceiver(...
    ObjAGC,...           %Objects
    ObjSDRuReceiver,...
    ObjSDRuTransmitter,...
    ObjDetect,...
    ObjPreambleDemod,...
    ObjDataDemod,...
    estimate,...         %Structs
    tx,...
    timeoutDuration,...  %Values/Vectors
    messageBits,...
    lookingForACK,...
    previousMessage...
    )

% This function is called when the node is just listening to the spectrum
% waiting for a message to be transmitted to them

DebugFlag = 0;

%% Listen to the spectrum
% previousMessage will be updated for next run
[Response, previousMessage, originNodeID, destNodeID] = DLLayer(...
    ObjAGC,...           %Objects
    ObjSDRuReceiver,...
    ObjDetect,...
    ObjPreambleDemod,...
    ObjDataDemod,...
    estimate,...         %Structs
    tx,...
    timeoutDuration,...  %Values/Vectors
    messageBits,...
    previousMessage...
    );



%% Possible response messages
% 1.) Timeout
% 2.) Some message
if ~strcmp(Response,'Timeout') &&  ~strcmp(Response,'Duplicate')
    %fprintf('###########################################\n');
    %fprintf('MAC| Got message: %s\n',Response);
    %fprintf('MAC| From Node: %d\n',int16(originNodeID));
    
    if ~lookingForACK
        if DebugFlag;fprintf('MAC| Transmitting ACK\n');end
        % Send ACK
        %fprintf('Transmitting to node: %d, with offset: %f\n',int16(originNodeID),tx.offsetTable(originNodeID));
        ObjSDRuTransmitter.CenterFrequency = tx.CenterFrequency + tx.offsetTable(originNodeID);% Adjust offset for node       
        PHYTransmit(...
            ObjSDRuTransmitter,...
            ObjSDRuReceiver,...
            'ACK',...
            tx.samplingFreq,...
            originNodeID,...
            destNodeID...
            );
        
    end
elseif strcmp(Response,'Duplicate')
    
    if DebugFlag;fprintf('MAC| Transmitting ACK for dupe\n');end
    %% Send ACK
    %fprintf('Transmitting to node: %d, with offset: %f\n',int16(originNodeID),tx.offsetTable(originNodeID));
    ObjSDRuTransmitter.CenterFrequency = tx.CenterFrequency + tx.offsetTable(originNodeID); % Adjust offset for node
    PHYTransmit(...
        ObjSDRuTransmitter,...
        ObjSDRuReceiver,...
        'ACK',...
        tx.samplingFreq,...
        originNodeID,...
        destNodeID...
        );
end


end

