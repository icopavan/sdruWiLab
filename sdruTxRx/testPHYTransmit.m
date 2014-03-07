function testPHYTransmit(offset)

[...
    ObjAGC,...           %Objects
    ObjSDRuReceiver,...
    ObjSDRuTransmitter,...
    ObjDetect,...
    ObjPreambleDemod,...
    ObjDataDemod,...
    estimate,...         %Structs
    tx,...
    timeoutDuration,...  %Values/Vectors
    messageBits...
    ] = CreateTXRX;

inputPayloadMessage = ['ACK'];

destNodeID = 1;

originNodeID = 2;

% Adjust offset for node
ObjSDRuTransmitter.CenterFrequency = tx.CenterFrequency + offset;

while 1
PHYTransmit(...
    ObjSDRuTransmitter,...
    ObjSDRuReceiver,...
    inputPayloadMessage,...
    tx.samplingFreq,...
    originNodeID,...
    destNodeID...
    );

end

end