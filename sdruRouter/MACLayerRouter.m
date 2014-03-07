function [Response, previousMessage] = MACLayerRouter(...
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
    fprintf('MAC| Got message: %s\n',Response);
    fprintf('MAC| From Node: %d\n',int16(originNodeID));
    
    if ~lookingForACK
        fprintf('MAC| Transmitting ACK\n');
        % Send ACK
        fprintf('Transmitting to node: %d, with offset: %f\n',int16(originNodeID),tx.offsetTable(originNodeID));
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
    
    fprintf('MAC| Transmitting ACK for dupe\n');
    %% Send ACK
    fprintf('Transmitting to node: %d, with offset: %f\n',int16(originNodeID),tx.offsetTable(originNodeID));
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

% % Send message to next user if required
% if destNodeID ~= tx.nodeNum
% 
%     recipient = destNodeID;
%     %message = Response;
%     
%     % Send message to next node
%     [previousMessage, msgStatus] = MACLayerTransmitter(...
%         ObjAGC,...           %Objects
%         ObjSDRuReceiver,...
%         ObjSDRuTransmitter,...
%         ObjDetect,...
%         ObjPreambleDemod,...
%         ObjDataDemod,...
%         estimate,...         %Structs
%         tx,...
%         timeoutDuration,...  %Values/Vectors
%         messageBits,...
%         Response,...
%         previousMessage,...
%         recipient...
%         );
%     
%     % What happend?
%     if msgStatus
%         fprintf('MAC| Message redirect successful\n');
%     else
%         fprintf('MAC| Message redirect failed\n');
%     end
% else
%     fprintf('MAC| That one was for me:)\n');
% end


end

