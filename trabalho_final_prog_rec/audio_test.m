% Two-tone audio generator

clear; clc;

% Sampling parameters
Fs = 44100;        % Sample rate (Hz)
duration = 5;      % seconds
t = 0:1/Fs:duration;

% Frequencies (Hz)
f1 = 440;          % A4 note
f2 = 10000;          % A5 note

% Generate signals
signal1 = sin(2*pi*f1*t);
signal2 = sin(2*pi*f2*t);

% Combine signals (sum)
audio = signal1 + signal2;

% Normalize to avoid clipping
audio = audio / max(abs(audio));

% Write to WAV file
filename = 'two_tone_audio.wav';
audiowrite(filename, audio, Fs);

disp(['Audio file created: ', filename]);