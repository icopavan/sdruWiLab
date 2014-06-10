function result = testPHYReceive_per(decimation)

result = 100;

persistent ObjAGC...           %Objects
    ObjSDRuReceiver...
    ObjDetect...
    ObjPreambleDemod...
    ObjDataDemod...
    estimate...         %Structs
    rx...
    timeoutDuration...  %Values/Vectors
    messageBits;

if isempty(ObjSDRuReceiver)
[...
    ObjAGC,...           %Objects
    ObjSDRuReceiver,...
    ObjDetect,...
    ObjPreambleDemod,...
    ObjDataDemod,...
    estimate,...         %Structs
    rx,...
    timeoutDuration,...  %Values/Vectors
    messageBits...
    ] = CreateTXRX;
end

ObjSDRuReceiver.DecimationFactor = double(decimation);
% Adjust offset for node
%ObjSDRuReceiver.CenterFrequency = rx.CenterFrequency - offset;

%fprintf('Starting Receiver Loop\n');

for k=1:1e5
[recoveredMessage] = PHYReceive(...
                ObjAGC,...           %Objects
                ObjSDRuReceiver,...
                ObjDetect,...
                ObjPreambleDemod,...
                ObjDataDemod,...
                estimate,...         %Structs
                rx,...
                timeoutDuration,...  %Values/Vectors
                messageBits...
                );

            
            if ~strcmp(recoveredMessage,'CRC Error') && ~strcmp(recoveredMessage,'Timeout') 
                fprintf('Got Message: %s\n',recoveredMessage);
                break;
            end
end

%fprintf('Finished Receiver Loop\n');


end
