function output = TestOFDMATune()

% The goal of this function is to test the tunablility of the number of
% users for the following:
%   Support up to 48 User (Max # of data subcarriers)
%   Change the number of carriers per user

%% Transmitter
%persistent TxMAC %TxPHY SDRuTransmitter

% SETUP MAC
TxMAC = TxOFDMA;
TxMAC.desiredUser = 1;
TxMAC.dataType = 'c';
TxMAC.symbolsPerFrame = 20;

% RxMAC = RxOFDMA;
% RxMAC.dataType = 'c';
% RxMAC.desiredUser = 1;
% RxMAC.symbolsPerFrame = 20;

% Setup PHY
TxPHY = PHYTransmitter;
TxPHY.HWAttached = false;
TxPHY.NumDataSymbolsPerFrame = TxMAC.symbolsPerFrame;


% Messages to transmit
messageUE1 = 'HelloWorld';
messageUE2 = 'PinkFloyd';
bitsToTx1 = step(TxMAC, messageUE1(1,:),messageUE2(1,:));
frame = step(TxPHY,bitsToTx1);

% Receiver
Buffer = [frame; frame];
[rFrame,statusFlag] = FindtheFrame(Buffer);

if statusFlag<1
    [ RHard ] = SignalCorrect(rFrame);
    % Decode
    Decoder( RHard );
end


end