function testPHYTransmit


persistent  ObjAGC...           %Objects
    ObjSDRuTransmitter...
    ObjDetect...
    ObjPreambleDemod...
    ObjDataDemod...
    estimate...         %Structs
    tx...
    timeoutDuration...  %Values/Vectors
    messageBits;


if isempty(ObjSDRuTransmitter)
[...
    ObjAGC,...           %Objects
    ObjSDRuTransmitter,...
    ObjDetect,...
    ObjPreambleDemod,...
    ObjDataDemod,...
    estimate,...         %Structs
    tx,...
    timeoutDuration,...  %Values/Vectors
    messageBits...
    ] = CreateTXRX_TX;

end

inputPayloadMessage = ['Hello World'];

destNodeID = 1;

originNodeID = 2;

% Adjust offset for node
%ObjSDRuTransmitter.CenterFrequency = tx.CenterFrequency + offset;

for k=1:1e5
%fprintf('Transmitting\n');
PHYTransmit(...
    ObjSDRuTransmitter,...
    inputPayloadMessage,...
    tx.samplingFreq,...
    originNodeID,...
    destNodeID...
    );

end

end
