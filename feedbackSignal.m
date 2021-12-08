clc
clear

% load data
d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);

close all
for subj = 1:numel(d)-1 % -1 because last subject didn't load properly
    % load subject data
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);
    
    % subtract imagery signal from motor signal to get feedback
    Feedback_Rec_signal = data.Motor_Rec_signal - data.Imagery_Rec_signal;
    Feedback_Freq_response = fft(Feedback_Rec_signal');
    
    % plot if needed
%     figure
%     subplot(321)
%     plot(data.Motor_Rec_signal')
%     subplot(322)
%     plot(abs(data.Motor_Freq_response(:, 1:256)'))
%     subplot(323)
%     plot(data.Imagery_Rec_signal')
%     subplot(324)
%     plot(abs(data.Imagery_Freq_response(:, 1:256)'))
%     subplot(325)
%     plot(Feedback_Rec_signal')
%     subplot(326)
%     plot(abs(Feedback_Freq_response(1:256, :)))
%     
    save(file, 'Feedback_Rec_signal', 'Feedback_Freq_response', '-append')
end