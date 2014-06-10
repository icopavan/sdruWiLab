%% QPSK Transmitter with USRP(R) Hardware
% This example shows how to use the Universal Software Radio Peripheral(R)
% (USRP(R)) device using SDRu (Software Defined Radio USRP(R)) System
% objects to implement a QPSK transmitter. The USRP(R) device in this
% system will keep transmitting indexed "Hello world" messages at its
% specified center frequency. You can demodulate the transmitted message
% using the <matlab:edit('sdruQPSKReceiver.m') QPSK Receiver with USRP(R)
% Hardware> example with an additional USRP(R) device.
%
% Please refer to <../../help/index.html Getting Started> for details on
% configuring your host computer to work with the SDRu Transmitter System
% object.
%
% Copyright 2012 The MathWorks, Inc.

%% Implementations
% This example describes the MATLAB(R) implementation of a QPSK transmitter
% with USRP(R) hardware. There is another implementation of this example
% that uses Simulink(R).
%
% MATLAB script using System objects:
% <matlab:edit('sdruQPSKTransmitter.m') sdruQPSKTransmitter.m>.
%
% Simulink implementation using blocks: <matlab:sdruqpsktx sdruqpsktx.mdl>.
%
% You can also explore a no-USRP QPSK Transmitter and Receiver example that
% models a general wireless communication system using an AWGN channel and
% simulated channel impairments at
% <matlab:edit('commQPSKTransmitterReceiver.m') commQPSKTransmitterReceiver.m>.

%% Introduction
% This example has the following motivation:
%
% * To implement a real QPSK-based transmission-reception environment in
% MATLAB using SDRu System objects.
%
% * To illustrate the use of key Communications System Toolbox(TM) System
% objects for QPSK system design.
%
% In this example, the transmitter generates a message using ASCII  
% characters, converts the characters to bits, and prepends a Barker code
% for receiver frame synchronization. This data is then modulated using
% QPSK and filtered with a square root raised cosine filter. The filtered
% QPSK symbols can be transmitted over the air using the SDRu transmitter
% System object and the USRP(R) hardware. 

%% Initialization
% The <matlab:edit('sdruqpsktransmitter_init.m')
% sdruqpsktransmitter_init.m> script initializes the simulation parameters
% and generates the structure prmQPSKTransmitter.

prmQPSKTransmitter = sdruqpsktransmitter_init % Transmitter parameter structure
compileIt  = false; % true if code is to be compiled for accelerated execution 
useCodegen = false; % true to run the latest generated mex file
%%
% To achieve a successful transmission, ensure that the specified center
% frequency of the SDRu Transmitter is within the acceptable range of your
% USRP(R) daughterboard.
%
% Also, by using the compileIt and useCodegen flags, you can interact with
% the code to explore different execution options.  Set the MATLAB variable
% compileIt to true in order to generate C code; this can be
% accomplished by using the *codegen* command provided by the MATLAB
% Coder(TM) product. The *codegen* command compiles MATLAB(R) functions to
% a C-based static or dynamic library, executable, or MEX file, producing
% code for accelerated execution. The generated executable runs several times
% faster than the original MATLAB code. Set useCodegen to true to run the
% executable generated by *codegen* instead of the MATLAB code.

%% Code Architecture
% The function runSDRuQPSKTransmitter implements the QPSK transmitter using
% two System objects, QPSKTransmitter and comm.SDRuTransmitter. 
%
% *QPSK Transmitter*
%
% The transmitter includes the *Bit Generation*, *QPSK Modulator* and
% *Raised Cosine Transmit Filter*  objects. The *Bit Generation*
% object generates the data frames. Each frame contains 200 bits. The
% first 26 bits are header bits, a 13-bit Barker code that has been
% oversampled by two.  The Barker code is sent on both in-phase and
% quadrature components of the QPSK modulated symbols. This is achieved by
% repeating the Barker code bits twice before modulating them with the QPSK
% modulator.
%
% The remaining bits are the payload. The first 105 bits of the payload
% correspond to the ASCII representation of 'Hello world ###', where '###'
% is an incrementing sequence of '001', '002', '003',..., '100'. The
% remaining payload bits are random bits. The payload is scrambled to
% guarantee a balanced distribution of zeros and ones for the timing
% recovery operation in the receiver object. The scrambled bits are
% modulated by the *QPSK Modulator* (with Gray mapping). The *Raised Cosine
% Transmit Filter* upsamples the modulated symbols by four, and has a
% roll-off factor of 0.5.  The output rate of the *Raised Cosine Filter* is
% set to be 200e3 samples per second.
%
% *SDRu Transmitter*
%
% The host computer communicates with the USRP(R) radio using the SDRu
% transmitter System object.  You can supply the IP address of the USRP(R)
% radio as an argument when you construct the object.  The IP address can be
% any address within the same subnetwork as the host computer.  The IP
% address should match the IP address of the USRP radio connected to the
% host. The CenterFrequency, Gain, and InterpolationFactor arguments are
% set by the parameter variable prmQPSKTransmitter.

%% Execution
% Before running the script, first turn on the USRP(R) radio and connect it
% to the computer. As already mentioned, you can check the correct data
% transmission by running the
% <matlab:edit('sdruQPSKReceiver.m') QPSK Receiver with USRP(R) Hardware> 
% example while running the transmitter script.

if compileIt
    compilesdru('runSDRuQPSKTransmitter','mex', '-args', {coder.Constant(prmQPSKTransmitter)}); %#ok<UNRCH>
end
if useCodegen
   clear runSDRuQPSKTransmitter_mex %#ok<UNRCH>
   runSDRuQPSKTransmitter_mex(prmQPSKTransmitter);
else
   runSDRuQPSKTransmitter(prmQPSKTransmitter);
end
%%
% The gain behavior of different USRP(R) daughter boards varies
% considerably. Thus, the gain setting in the transmitter and receiver
% defined in this example may not be well suited for your daughter boards.
% If the message is not properly decoded by the receiver object, you can
% vary the gain of the source signals in the *SDRu Transmitter* and *SDRu
% Receiver* System objects by changing the SimParams.USRPGain value in the
% <matlab:edit('sdruqpsktransmitter_init.m') transmitter initialization
% file> and in the <matlab:edit('sdruqpskreceiver_init.m') receiver
% initialization file>.
%
% Also, a large relative frequency offset between the transmit and receive
% USRP(R) radios can prevent the receiver functions from properly decoding
% the message.  If that happens, you can determine the offset by sending a
% tone at a known frequency from the transmitter to the receiver, then
% measuring the offset between the transmitted and received frequency, then
% applying that offset to the center frequency of the SDRu Receiver System
% object.

%% Appendix
% This example uses the following script and helper functions:
%
% * <matlab:edit('runSDRuQPSKTransmitter.m') runSDRuQPSKTransmitter.m>
% * <matlab:edit('sdruqpsktransmitter_init.m') sdruqpsktransmitter_init.m>
% * <matlab:edit('QPSKTransmitter.m') QPSKTransmitter.m>
% * <matlab:edit('QPSKBitsGenerator.m') QPSKBitsGenerator.m>

%% Copyright Notice
% Universal Software Radio Peripheral(R) and USRP(R) are trademarks of
% National Instruments Corp.
