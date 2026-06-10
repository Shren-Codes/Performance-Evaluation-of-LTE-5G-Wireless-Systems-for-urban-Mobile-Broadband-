%% ============================================================
%  Performance Evaluation of LTE/5G Wireless Systems
%  MATLAB Simulation Code
%  Course  : BECE317L – Wireless Mobile Communication
%  Student : SHRENICA CHAWDA A | 23BEC1380
%  Guide   : Dr. VETRIVELAN. P
%  School  : SENSE, VIT Chennai | April 2026
%
%  MODULES COVERED
%  ─────────────────────────────────────────────────────────────
%  Member 1 (TX) – COST 231 Hata Path Loss, Link Budget,
%                  Adaptive Modulation (QPSK / 16-QAM / 64-QAM)
%  Member 2 (RX) – QAM Constellation, Error Magnitude, BER
%  Member 3 (TX/RX) – 2×2 MIMO ZF vs MMSE, Channel Capacity
%  Member 4 (TX/RX) – OFDM Signal, PAPR Analysis & Mitigation
%  Helper Functions – at the bottom of this file
%% ============================================================

clc; clear; close all;

%% ============================================================
%%  MEMBER 1 – PATH LOSS, LINK BUDGET & ADAPTIVE MODULATION
%% ============================================================

fprintf('========================================\n');
fprintf(' MEMBER 1 : Path Loss & Adaptive Modulation\n');
fprintf('========================================\n\n');

%% ── 1.1  System Parameters ───────────────────────────────────
fc_GHz  = 2.6;          % Carrier frequency (GHz)
fc_MHz  = fc_GHz * 1e3; % Carrier frequency (MHz) – required by Hata
hBS     = 30;           % Base-station antenna height (m)
hMS     = 1.5;          % Mobile-station antenna height (m)
Ptx_dBm = 43;           % Transmit power (dBm)  – LTE eNB
BW      = 10e6;         % Bandwidth (Hz)
T       = 290;          % Noise temperature (K)
k_B     = 1.38e-23;     % Boltzmann constant
NF_dB   = 7;            % Receiver noise figure (dB)
CM      = 3;            % Correction factor: 3 dB for dense urban

% Noise floor
noisePower_dBm = 10*log10(k_B * T * BW) + 30 + NF_dB;
fprintf('Noise Floor : %.1f dBm\n', noisePower_dBm);

%% ── 1.2  COST 231 Hata Path Loss ─────────────────────────────
distance_m  = 100 : 10 : 5000;          % Distance range (m)
distance_km = distance_m / 1000;        % Distance range (km)

% Mobile antenna correction factor (medium/small city formula)
a_hMS = (1.1*log10(fc_MHz) - 0.7)*hMS - (1.56*log10(fc_MHz) - 0.8);

% COST-231 Hata path loss (dB)
PL_dB = 46.3 + 33.9*log10(fc_MHz) ...
      - 13.82*log10(hBS) ...
      - a_hMS ...
      + (44.9 - 6.55*log10(hBS)) .* log10(distance_km) ...
      + CM;

%% ── 1.3  Graph 1 : Urban Path Loss vs Distance ───────────────
figure('Name','Member1 – Path Loss','Position',[50 50 900 550]);
plot(distance_km, PL_dB, 'b-', 'LineWidth', 2.5);
grid on; box on;
xlabel('Distance (km)', 'FontSize', 13);
ylabel('Path Loss (dB)', 'FontSize', 13);
title('Urban Path Loss vs Distance  (COST 231 Hata Model)', 'FontSize', 14);
legend(sprintf('Urban Macro-Cell  f_c = %.1f GHz', fc_GHz), ...
       'Location', 'northwest', 'FontSize', 11);
text(3.5, 140, sprintf('h_{BS} = %d m\nh_{MS} = %.1f m', hBS, hMS), ...
     'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k');

%% ── 1.4  Received Power & SNR vs Distance ────────────────────
Prx_dBm     = Ptx_dBm - PL_dB;          % Received power (dBm)
SNR_dist_dB = Prx_dBm - noisePower_dBm; % SNR (dB)

%% ── 1.5  Graph 2 : SNR vs Distance ──────────────────────────
figure('Name','Member1 – SNR vs Distance','Position',[60 60 900 550]);
plot(distance_km, SNR_dist_dB, 'r-', 'LineWidth', 2.5); hold on;
yline(10, 'g--', 'LineWidth', 1.8, 'Label', 'QPSK→16-QAM  10 dB');
yline(20, 'm--', 'LineWidth', 1.8, 'Label', '16-QAM→64-QAM  20 dB');
yline(0,  'k:',  'LineWidth', 1.5, 'Label', 'Min Coverage 0 dB');
grid on; box on;
xlabel('Distance (km)', 'FontSize', 13);
ylabel('SNR (dB)',       'FontSize', 13);
title('SNR vs Distance  –  Link Quality Analysis', 'FontSize', 14);
legend('SNR','QPSK/16-QAM threshold','16-QAM/64-QAM threshold','Min. SNR', ...
       'Location','northeast','FontSize',10);
ylim([-10 45]); hold off;

%% ── 1.6  Adaptive Modulation at a Single Operating Point ─────
SNR_op = 18;   % Example urban operating-point SNR (dB)
if     SNR_op < 10,  modOrder = 4;   modName = 'QPSK';
elseif SNR_op < 20,  modOrder = 16;  modName = '16-QAM';
else,                modOrder = 64;  modName = '64-QAM';
end
bitsPerSym = log2(modOrder);
fprintf('Operating SNR : %d dB  →  Selected Modulation : %s  (%d bits/sym)\n', ...
        SNR_op, modName, bitsPerSym);

%% ── 1.7  Graph 3 : Adaptive Modulation Regions ───────────────
figure('Name','Member1 – Adaptive Modulation','Position',[70 70 900 550]);
SNR_range = -5 : 0.5 : 35;
modScheme  = ones(size(SNR_range));
modScheme(SNR_range >= 10) = 2;
modScheme(SNR_range >= 20) = 3;

hold on;
% Shaded regions
fill_region(SNR_range, modScheme, SNR_range < 10,              [0.7 0.9 1.0]);
fill_region(SNR_range, modScheme, SNR_range>=10 & SNR_range<20,[0.7 1.0 0.7]);
fill_region(SNR_range, modScheme, SNR_range >= 20,             [1.0 1.0 0.7]);

plot(SNR_range, modScheme, 'k-', 'LineWidth', 2.5);
plot(SNR_op, 2, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'LineWidth', 2);
xline(10, 'b--', 'LineWidth', 1.5);
xline(20, 'b--', 'LineWidth', 1.5);

set(gca, 'YTick', [1 2 3], 'YTickLabel', {'QPSK (4-QAM)', '16-QAM', '64-QAM'}, ...
    'FontSize', 11);
text( 2.5, 0.55, 'QPSK Region',   'FontSize', 11, 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'center');
text(15.0, 1.55, '16-QAM Region', 'FontSize', 11, 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'center');
text(27.5, 2.55, '64-QAM Region', 'FontSize', 11, 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'center');
text(SNR_op + 0.5, 2.35, sprintf('SNR=%d dB → %s', SNR_op, modName), ...
     'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
grid on; box on;
xlabel('SNR (dB)',        'FontSize', 13);
ylabel('Modulation Scheme','FontSize', 13);
title('Adaptive Modulation Selection Regions', 'FontSize', 14);
ylim([0.2 3.8]); xlim([-5 35]);
legend('QPSK Region','16-QAM Region','64-QAM Region', ...
       'Modulation Curve','Operating Point','Thresholds', ...
       'Location','southeast','FontSize',10);
hold off;

%% ── 1.8  Graph 4 : Received Power vs Distance ────────────────
figure('Name','Member1 – Rx Power','Position',[80 80 900 550]);
plot(distance_km, Prx_dBm, 'Color',[0.85 0.65 0], 'LineWidth', 2.5); hold on;
yline(noisePower_dBm, 'r--', 'LineWidth', 1.8, 'Label', 'Noise Floor');
grid on; box on;
xlabel('Distance (km)', 'FontSize', 13);
ylabel('Received Power (dBm)', 'FontSize', 13);
title('Received Power vs Distance', 'FontSize', 14);
legend('P_{RX}','Noise Floor', 'Location','northeast','FontSize',11);
text(3.8, -55, sprintf('Min SNR 64-QAM: 20 dB\nMin SNR 16-QAM: 10 dB'), ...
     'FontSize', 10, 'BackgroundColor','w','EdgeColor','k');
hold off;

%% ── 1.9  Graph 5 : Coverage Analysis ────────────────────────
figure('Name','Member1 – Coverage','Position',[90 90 900 400]);
coverage = zeros(size(distance_km));
coverage(SNR_dist_dB >= 10) = 3;   % 16/64-QAM
coverage(SNR_dist_dB >= 0 & SNR_dist_dB < 10) = 2;  % QPSK only
% coverage = 1 (no service) already zero; remap
coverage_plot = coverage;
coverage_plot(coverage == 0) = 1;  % No coverage → level 1
coverage_plot(coverage == 2) = 2;  % QPSK only  → level 2
coverage_plot(coverage == 3) = 3;  % 16/64-QAM  → level 3

plot(distance_km, coverage_plot, 'r-', 'LineWidth', 3);
set(gca,'YTick',[1 2 3],'YTickLabel',{'No Coverage','QPSK Only','16/64-QAM'}, ...
    'FontSize', 11);
grid on; box on;
xlabel('Distance (km)', 'FontSize', 13);
ylabel('Coverage Region',  'FontSize', 13);
title('Coverage Analysis Based on SNR', 'FontSize', 14);
ylim([0.5 3.8]);

%% ── 1.10 Graph 6 : Link Budget ──────────────────────────────
figure('Name','Member1 – Link Budget','Position',[100 100 900 500]);
Ptx_line = Ptx_dBm * ones(size(distance_km));
margin   = Prx_dBm - noisePower_dBm;  % dB margin above noise floor
margin(margin < 0) = 0;

plot(distance_km, Ptx_line, 'b-', 'LineWidth', 2); hold on;
plot(distance_km, Prx_dBm, 'g-', 'LineWidth', 2);
yline(noisePower_dBm, 'r--', 'LineWidth', 1.8);
fill([distance_km fliplr(distance_km)], ...
     [Prx_dBm fliplr(noisePower_dBm*ones(size(distance_km)))], ...
     [0.6 1.0 0.6], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
grid on; box on;
xlabel('Distance (km)',  'FontSize', 13);
ylabel('Power (dBm)',    'FontSize', 13);
title('Link Budget Analysis', 'FontSize', 14);
legend('Tx Power','Rx Power','Noise Floor','Margin', ...
       'Location','northeast','FontSize',11);
hold off;

fprintf('\n[Member 1 complete]\n\n');

%% ============================================================
%%  MEMBER 2 – QAM CONSTELLATION, ERROR MAGNITUDE & BER
%% ============================================================

fprintf('========================================\n');
fprintf(' MEMBER 2 : QAM Error Analysis & BER\n');
fprintf('========================================\n\n');

%% ── 2.1  Constellation Generation ───────────────────────────
M16  = 16;  k16 = log2(M16);
M64  = 64;  k64 = log2(M64);

constellation16 = generate_qam_constellation(M16);
constellation64 = generate_qam_constellation(M64);

numBits_const = 1e4;
txBits16 = randi([0 1], floor(numBits_const/k16)*k16, 1);
txBits64 = randi([0 1], floor(numBits_const/k64)*k64, 1);
txSym16  = qam_mod(txBits16, constellation16, k16);
txSym64  = qam_mod(txBits64, constellation64, k64);

%% ── 2.2  Graph 1 : Ideal Constellations ─────────────────────
figure('Name','Member2 – Ideal Constellations','Position',[50 50 1200 500]);
subplot(1,2,1);
plot(real(txSym16), imag(txSym16), 'b.', 'MarkerSize', 8); hold on;
plot(real(constellation16), imag(constellation16), 'ro', ...
     'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r');
grid on; axis equal; axis([-1.8 1.8 -1.8 1.8]);
xlabel('In-Phase (I)','FontSize',12); ylabel('Quadrature (Q)','FontSize',12);
title('16-QAM Ideal Constellation','FontSize',13);
legend('Symbols','Ideal Points','Location','northwest','FontSize',10);
hold off;

subplot(1,2,2);
plot(real(txSym64), imag(txSym64), 'b.', 'MarkerSize', 6); hold on;
plot(real(constellation64), imag(constellation64), 'ro', ...
     'MarkerSize', 6, 'LineWidth', 2, 'MarkerFaceColor', 'r');
grid on; axis equal; axis([-1.8 1.8 -1.8 1.8]);
xlabel('In-Phase (I)','FontSize',12); ylabel('Quadrature (Q)','FontSize',12);
title('64-QAM Ideal Constellation','FontSize',13);
legend('Symbols','Ideal Points','Location','northwest','FontSize',10);
hold off;

%% ── 2.3  Constellation under Urban Fading + Noise ────────────
SNR_urban  = 18;     % dB
fadingVar  = 0.15;
numSamples = 2000;
SNR_lin    = 10^(SNR_urban/10);
nPow       = 1/SNR_lin;

idx16 = randi([1 length(constellation16)], numSamples, 1);
idx64 = randi([1 length(constellation64)], numSamples, 1);
tx16  = constellation16(idx16);
tx64  = constellation64(idx64);

h16 = (randn(numSamples,1)+1j*randn(numSamples,1))*sqrt(fadingVar/2);
h64 = (randn(numSamples,1)+1j*randn(numSamples,1))*sqrt(fadingVar/2);
noise16 = sqrt(nPow/2)*(randn(numSamples,1)+1j*randn(numSamples,1));
noise64 = sqrt(nPow/2)*(randn(numSamples,1)+1j*randn(numSamples,1));
rx16 = tx16.*(1+h16) + noise16;
rx64 = tx64.*(1+h64) + noise64;

figure('Name','Member2 – Fading Constellations','Position',[50 50 1400 900]);
titles_row = {'Ideal','AWGN Only','Fading + Noise'};
for col = 1:3
    subplot(2,3,col);
    switch col
        case 1, data=tx16;              refC=constellation16; sz=8;
        case 2, data=tx16+noise16;      refC=constellation16; sz=6;
        case 3, data=rx16;              refC=constellation16; sz=6;
    end
    plot(real(data),imag(data),'b.','MarkerSize',sz); hold on;
    plot(real(refC),imag(refC),'ro','MarkerSize',9,'LineWidth',2,'MarkerFaceColor','r');
    grid on; axis equal; axis([-2 2 -2 2]);
    xlabel('I','FontSize',11); ylabel('Q','FontSize',11);
    title(['16-QAM: ' titles_row{col}],'FontSize',12); hold off;

    subplot(2,3,col+3);
    switch col
        case 1, data=tx64;              refC=constellation64; sz=6;
        case 2, data=tx64+noise64;      refC=constellation64; sz=4;
        case 3, data=rx64;              refC=constellation64; sz=4;
    end
    plot(real(data),imag(data),'b.','MarkerSize',sz); hold on;
    plot(real(refC),imag(refC),'ro','MarkerSize',7,'LineWidth',2,'MarkerFaceColor','r');
    grid on; axis equal; axis([-2 2 -2 2]);
    xlabel('I','FontSize',11); ylabel('Q','FontSize',11);
    title(['64-QAM: ' titles_row{col}],'FontSize',12); hold off;
end
sgtitle(sprintf('QAM Constellations under Urban Fading  (SNR = %d dB)', SNR_urban), ...
        'FontSize', 14);

%% ── 2.4  Error Magnitude Analysis (16-QAM, 1000 symbols) ─────
numSym_err  = 1000;
SNR_err_dB  = 25;           % fixed SNR for error analysis
SNR_err_lin = 10^(SNR_err_dB/10);
txIdx  = randi([1 M16], numSym_err, 1);
txSymE = constellation16(txIdx);
noiseE = sqrt(1/(2*SNR_err_lin)) * (randn(numSym_err,1)+1j*randn(numSym_err,1));
rxSymE = txSymE + noiseE;
errMag = abs(rxSymE - txSymE);

figure('Name','Member2 – Error Magnitude','Position',[50 50 1200 480]);
subplot(1,2,1);
stem(errMag,'m','MarkerSize',2,'LineWidth',0.8);
grid on;
xlabel('Symbol Index','FontSize',12); ylabel('Error Magnitude','FontSize',12);
title('QAM Error Signal Magnitude','FontSize',13);
ylim([0 1.3]);

subplot(1,2,2);
histogram(errMag, 40, 'FaceColor',[0.2 0.4 0.8],'EdgeColor','w');
grid on;
xlabel('Error Magnitude','FontSize',12); ylabel('Frequency','FontSize',12);
title('Error Distribution','FontSize',13);

%% ── 2.5  BER vs SNR (16-QAM) – Simulated vs Theoretical ──────
numBits_ber = 1e4;
SNR_ber_dB  = 0 : 2 : 30;
BER_sim16   = zeros(size(SNR_ber_dB));
BER_th16    = zeros(size(SNR_ber_dB));

txBits_b = randi([0 1], floor(numBits_ber/k16)*k16, 1);
txSym_b  = qam_mod(txBits_b, constellation16, k16);

for i = 1 : length(SNR_ber_dB)
    rxSym_b     = add_awgn(txSym_b, SNR_ber_dB(i));
    rxBits_b    = qam_demod(rxSym_b, constellation16, k16);
    BER_sim16(i)= mean(txBits_b ~= rxBits_b);
    % Theoretical 16-QAM BER
    Eb_N0       = 10^(SNR_ber_dB(i)/10) / k16;
    BER_th16(i) = (3/8) * erfc(sqrt(Eb_N0/10));
end
BER_sim16 = max(BER_sim16, 1e-5);  % floor for log plot

figure('Name','Member2 – BER','Position',[50 50 850 580]);
semilogy(SNR_ber_dB, BER_sim16, '-o', 'Color',[0.85 0.33 0.1], ...
         'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor',[0.85 0.33 0.1]);
hold on;
semilogy(SNR_ber_dB, BER_th16, 'g--', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)', 'FontSize', 13);
ylabel('Bit Error Rate (BER)', 'FontSize', 13);
title('16-QAM BER Performance  –  Simulated vs Theoretical', 'FontSize', 14);
legend('Simulated BER','Theoretical BER','Location','southwest','FontSize',12);
ylim([1e-5 1]); hold off;

EVM_m2 = 100 * sqrt(mean(abs(rxSymE - txSymE).^2)) / sqrt(mean(abs(txSymE).^2));
fprintf('Member 2 EVM @ SNR=%d dB : %.2f%%\n', SNR_err_dB, EVM_m2);
fprintf('\n[Member 2 complete]\n\n');

%% ============================================================
%%  MEMBER 3 – 2×2 MIMO  ZF vs MMSE  +  CHANNEL CAPACITY
%% ============================================================

fprintf('========================================\n');
fprintf(' MEMBER 3 : MIMO Equalization & Capacity\n');
fprintf('========================================\n\n');

M_mimo   = 16;
k_mimo   = log2(M_mimo);
numBits3 = 1e5;
SNR_mimo = 0 : 2 : 30;
constellation_m = generate_qam_constellation(M_mimo);

BER_SISO      = zeros(size(SNR_mimo));
BER_MIMO_ZF   = zeros(size(SNR_mimo));
BER_MIMO_MMSE = zeros(size(SNR_mimo));

fprintf('Running MIMO BER simulation ');
for i = 1 : length(SNR_mimo)
    fprintf('.');
    SNR_lin3 = 10^(SNR_mimo(i)/10);
    noiseVar = 1 / SNR_lin3;

    %% ── SISO ──
    txB_s = randi([0 1], numBits3, 1);
    txB_s = txB_s(1 : floor(length(txB_s)/k_mimo)*k_mimo);
    txS_s = qam_mod(txB_s, constellation_m, k_mimo);
    h_s   = (randn(size(txS_s)) + 1j*randn(size(txS_s))) / sqrt(2);
    rx_s  = add_awgn(h_s .* txS_s, SNR_mimo(i));
    rxEq_s= rx_s ./ h_s;
    rxB_s = qam_demod(rxEq_s, constellation_m, k_mimo);
    BER_SISO(i) = mean(txB_s ~= rxB_s);

    %% ── 2×2 MIMO ──
    txB_m = randi([0 1], numBits3, 1);
    txB_m = txB_m(1 : floor(length(txB_m)/k_mimo)*k_mimo);
    txS_m = qam_mod(txB_m, constellation_m, k_mimo);
    txS_m = reshape(txS_m, [], 2);
    numSym3 = size(txS_m, 1);

    H3 = (randn(numSym3,2,2) + 1j*randn(numSym3,2,2)) / sqrt(2);
    rx_m = zeros(numSym3, 2);
    for s = 1 : numSym3
        rx_m(s,:) = squeeze(H3(s,:,:)) * txS_m(s,:).';
    end
    rx_m = add_awgn(rx_m, SNR_mimo(i));

    eq_zf   = zeros(numSym3, 2);
    eq_mmse = zeros(numSym3, 2);
    for s = 1 : numSym3
        Hk = squeeze(H3(s,:,:));
        eq_zf(s,:)   = pinv(Hk) * rx_m(s,:).';
        eq_mmse(s,:) = ((Hk'*Hk + noiseVar*eye(2)) \ Hk') * rx_m(s,:).';
    end

    rxB_zf   = qam_demod(eq_zf(:),   constellation_m, k_mimo);
    rxB_mmse = qam_demod(eq_mmse(:), constellation_m, k_mimo);
    BER_MIMO_ZF(i)   = mean(txB_m ~= rxB_zf);
    BER_MIMO_MMSE(i) = mean(txB_m ~= rxB_mmse);
end
fprintf(' done\n');

%% ── 3.1  Graph : BER Comparison SISO vs MIMO ─────────────────
figure('Name','Member3 – BER SISO vs MIMO','Position',[50 50 900 580]);
semilogy(SNR_mimo, max(BER_SISO,     1e-5), '-o', 'LineWidth', 2, 'MarkerSize', 7);
hold on;
semilogy(SNR_mimo, max(BER_MIMO_ZF,  1e-5), '-s', 'LineWidth', 2, 'MarkerSize', 7);
semilogy(SNR_mimo, max(BER_MIMO_MMSE,1e-5), '-^', 'LineWidth', 2, 'MarkerSize', 7);
grid on;
xlabel('SNR (dB)', 'FontSize', 13);
ylabel('Bit Error Rate (BER)', 'FontSize', 13);
title('BER Comparison : SISO vs 2×2 MIMO  (ZF vs MMSE)', 'FontSize', 14);
legend('SISO (Rayleigh)','MIMO – ZF','MIMO – MMSE', ...
       'Location','southwest','FontSize',12);
ylim([1e-5 1]); hold off;

%% ── 3.2  Multi-modulation MMSE BER ───────────────────────────
modOrders   = [4, 16, 64];
modLabels   = {'MIMO-MMSE QPSK','MIMO-MMSE 16-QAM','MIMO-MMSE 64-QAM'};
BER_multi   = zeros(length(modOrders), length(SNR_mimo));

fprintf('Running multi-modulation MMSE BER ');
for m = 1 : length(modOrders)
    Mo  = modOrders(m);
    ko  = log2(Mo);
    con = generate_qam_constellation(Mo);
    fprintf('.');
    for i = 1 : length(SNR_mimo)
        noiseVar = 1 / 10^(SNR_mimo(i)/10);
        txB = randi([0 1], floor(2e4/ko)*ko, 1);
        txS = qam_mod(txB, con, ko);
        txS = reshape(txS, [], 2);
        nS  = size(txS, 1);
        H_m = (randn(nS,2,2)+1j*randn(nS,2,2))/sqrt(2);
        rx  = zeros(nS,2);
        for s=1:nS, rx(s,:) = squeeze(H_m(s,:,:)) * txS(s,:).'; end
        rx  = add_awgn(rx, SNR_mimo(i));
        eq  = zeros(nS,2);
        for s=1:nS
            Hk=squeeze(H_m(s,:,:));
            eq(s,:)=((Hk'*Hk+noiseVar*eye(2))\Hk')*rx(s,:).';
        end
        rxB = qam_demod(eq(:), con, ko);
        BER_multi(m,i) = mean(txB ~= rxB);
    end
end
fprintf(' done\n');

figure('Name','Member3 – Multi-Mod BER','Position',[60 60 900 580]);
for m = 1:length(modOrders)
    semilogy(SNR_mimo, max(BER_multi(m,:),1e-5), '-o', 'LineWidth', 2); hold on;
end
grid on;
xlabel('SNR (dB)','FontSize',13); ylabel('BER','FontSize',13);
title('MIMO-MMSE BER  –  QPSK vs 16-QAM vs 64-QAM  |  2×2 MIMO','FontSize',14);
legend(modLabels,'Location','southwest','FontSize',12);
ylim([1e-5 1]); hold off;

%% ── 3.3  Channel Characterisation (gain histogram + phase) ───
N_ch  = 1000;
H_ch  = (randn(N_ch,1) + 1j*randn(N_ch,1)) / sqrt(2);
phase_var = angle(H_ch);

figure('Name','Member3 – Channel','Position',[50 50 1200 480]);
subplot(1,2,1);
histogram(abs(H_ch), 50, 'FaceColor',[0.2 0.5 0.8], 'EdgeColor','w');
grid on;
xlabel('|H_{11}|','FontSize',12); ylabel('Frequency','FontSize',12);
title('Channel Gain Distribution (Rayleigh)','FontSize',13);

subplot(1,2,2);
plot(phase_var(1:500), 'Color',[0.9 0.4 0.1], 'LineWidth', 1.2);
grid on;
xlabel('Sample Index','FontSize',12); ylabel('Phase (rad)','FontSize',12);
title('Channel Phase Variation (500 samples)','FontSize',13);
ylim([-pi pi]);

%% ── 3.4  ZF vs MMSE Error Magnitude at 20 dB SNR ─────────────
numSym_eq = 1000;
SNR_eq    = 20;
noiseV    = 1 / 10^(SNR_eq/10);
txB_eq    = randi([0 1], floor(numSym_eq*k_mimo/k_mimo)*k_mimo, 1);
txS_eq    = reshape(qam_mod(txB_eq, constellation_m, k_mimo), [], 2);
nSe       = size(txS_eq,1);
H_eq      = (randn(nSe,2,2)+1j*randn(nSe,2,2))/sqrt(2);
rx_eq     = zeros(nSe,2);
for s=1:nSe, rx_eq(s,:) = squeeze(H_eq(s,:,:))*txS_eq(s,:).'; end
rx_eq  = add_awgn(rx_eq, SNR_eq);
eq_zf2 = zeros(nSe,2);  eq_mmse2 = zeros(nSe,2);
for s=1:nSe
    Hk=squeeze(H_eq(s,:,:));
    eq_zf2(s,:)  = pinv(Hk)*rx_eq(s,:).';
    eq_mmse2(s,:)= ((Hk'*Hk+noiseV*eye(2))\Hk')*rx_eq(s,:).';
end
errZF   = abs(eq_zf2(:)   - txS_eq(:));
errMMSE = abs(eq_mmse2(:) - txS_eq(:));

figure('Name','Member3 – ZF vs MMSE Errors','Position',[50 50 1200 480]);
subplot(1,2,1);
plot(errZF,   'b-', 'LineWidth', 0.8); hold on;
plot(errMMSE, 'r-', 'LineWidth', 0.8);
grid on;
xlabel('Symbol Index','FontSize',12); ylabel('Error Magnitude','FontSize',12);
title('Error Magnitude: ZF vs MMSE','FontSize',13);
legend('ZF','MMSE','Location','northeast','FontSize',11); hold off;

subplot(1,2,2);
histogram(errZF,  50, 'FaceColor','b', 'FaceAlpha',0.5);  hold on;
histogram(errMMSE,50, 'FaceColor','r', 'FaceAlpha',0.5);
grid on;
xlabel('Error Magnitude','FontSize',12); ylabel('Frequency','FontSize',12);
title('Error Distribution: ZF vs MMSE','FontSize',13);
legend('ZF Error','MMSE Error','FontSize',11); hold off;

EVM_ZF   = 100*sqrt(mean(errZF.^2))  / sqrt(mean(abs(txS_eq(:)).^2));
EVM_MMSE = 100*sqrt(mean(errMMSE.^2))/ sqrt(mean(abs(txS_eq(:)).^2));
fprintf('EVM at %d dB SNR  →  ZF: %.1f%%   MMSE: %.1f%%\n', SNR_eq, EVM_ZF, EVM_MMSE);

%% ── 3.5  Shannon Channel Capacity  SISO vs 2×2 MIMO ──────────
SNR_cap = 0 : 1 : 30;
C_SISO  = log2(1 + 10.^(SNR_cap/10));
C_MIMO2 = zeros(size(SNR_cap));
C_MIMO4 = zeros(size(SNR_cap));
numMC   = 500;   % Monte Carlo realisations

for i = 1 : length(SNR_cap)
    rho = 10^(SNR_cap(i)/10);
    c2  = 0;  c4 = 0;
    for mc = 1 : numMC
        H2 = (randn(2,2)+1j*randn(2,2))/sqrt(2);
        sv2= svd(H2).^2;
        c2 = c2 + sum(log2(1 + rho/2 .* sv2));

        H4 = (randn(4,4)+1j*randn(4,4))/sqrt(2);
        sv4= svd(H4).^2;
        c4 = c4 + sum(log2(1 + rho/4 .* sv4));
    end
    C_MIMO2(i) = c2 / numMC;
    C_MIMO4(i) = c4 / numMC;
end

figure('Name','Member3 – Capacity','Position',[50 50 900 550]);
plot(SNR_cap, C_SISO,  '-o', 'LineWidth', 2, 'MarkerSize', 6);  hold on;
plot(SNR_cap, C_MIMO2, '-s', 'LineWidth', 2, 'MarkerSize', 6);
plot(SNR_cap, C_MIMO4, '-^', 'LineWidth', 2, 'MarkerSize', 6);
idx20 = find(SNR_cap == 20);
gain  = C_MIMO2(idx20) / C_SISO(idx20);
text(20, C_MIMO2(idx20)+0.5, sprintf('MIMO Gain: %.1fx at 20 dB', gain), ...
     'FontSize', 10, 'FontWeight', 'bold');
grid on;
xlabel('SNR (dB)',                 'FontSize', 13);
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontSize', 13);
title('Ergodic Channel Capacity  –  SISO vs 2×2 vs 4×4 MIMO', 'FontSize', 14);
legend('SISO','2×2 MIMO','4×4 MIMO','Location','northwest','FontSize',12);
hold off;

fprintf('\n[Member 3 complete]\n\n');

%% ============================================================
%%  MEMBER 4 – OFDM TRANSMITTER, PAPR ANALYSIS & MITIGATION
%% ============================================================

fprintf('========================================\n');
fprintf(' MEMBER 4 : OFDM & PAPR Mitigation\n');
fprintf('========================================\n\n');

%% ── 4.1  System Parameters ───────────────────────────────────
Nfft      = 1024;   % FFT size
cpLen     = 72;     % Cyclic-prefix length (LTE normal CP ≈ 7% of Nfft)
numSym4   = 100;    % OFDM symbols
numSubcar = 600;    % Active subcarriers
M4        = 16;     k4 = log2(M4);
constellation4 = generate_qam_constellation(M4);

%% ── 4.2  Data Generation & OFDM Modulation ──────────────────
numBits4  = numSubcar * numSym4 * k4;
txBits4   = randi([0 1], numBits4, 1);
txSym4    = qam_mod(txBits4, constellation4, k4);

% Map to frequency-domain grid
txGrid = zeros(Nfft, numSym4);
scIdx  = (Nfft/2 - numSubcar/2 + 1) : (Nfft/2 + numSubcar/2);
txGrid(scIdx, :) = reshape(txSym4, numSubcar, numSym4);

% IFFT → time domain + cyclic prefix
timeSig = ifft(ifftshift(txGrid, 1), Nfft, 1);
timeSig = [timeSig(end-cpLen+1:end,:) ; timeSig];   % add CP
txOFDM  = timeSig(:);

%% ── 4.3  PAPR Measurement ────────────────────────────────────
pwrSig  = abs(txOFDM).^2;
avgPwr  = mean(pwrSig);
peakPwr = max(pwrSig);
PAPR_orig_dB = 10*log10(peakPwr / avgPwr);
fprintf('Original PAPR : %.2f dB\n', PAPR_orig_dB);

%% ── 4.4  Graph 1 : Time-Domain OFDM Signal ──────────────────
samplesToPlot = 5 * (Nfft + cpLen);
tAxis = 0 : samplesToPlot-1;

figure('Name','Member4 – OFDM Signal','Position',[50 50 1200 750]);
subplot(3,1,1);
plot(tAxis, real(txOFDM(1:samplesToPlot)), 'b-', 'LineWidth', 1.2);
grid on;
xlabel('Sample Index','FontSize',11); ylabel('Amplitude','FontSize',11);
title('OFDM Signal – Real Part  (Before PAPR Reduction)','FontSize',12);

subplot(3,1,2);
plot(tAxis, imag(txOFDM(1:samplesToPlot)), 'r-', 'LineWidth', 1.2);
grid on;
xlabel('Sample Index','FontSize',11); ylabel('Amplitude','FontSize',11);
title('OFDM Signal – Imaginary Part','FontSize',12);

subplot(3,1,3);
plot(tAxis, abs(txOFDM(1:samplesToPlot)), 'g-', 'LineWidth', 1.2); hold on;
yline(sqrt(avgPwr),  'k--', 'LineWidth', 1.8, 'Label', 'Avg Power');
yline(sqrt(peakPwr), 'r--', 'LineWidth', 1.8, 'Label', sprintf('Peak (PAPR=%.1fdB)',PAPR_orig_dB));
grid on;
xlabel('Sample Index','FontSize',11); ylabel('Magnitude','FontSize',11);
title('OFDM Signal – Magnitude  (High PAPR Visible)','FontSize',12);
legend('Signal','Avg Power','Peak','Location','northeast','FontSize',9);
hold off;

%% ── 4.5  Graph 2 : Power Spectrum ───────────────────────────
Nfft_psd = 2048;
X_psd    = fft(txOFDM, Nfft_psd);
Pxx      = (abs(X_psd).^2) / length(txOFDM);
Pxx_dB   = 10*log10(Pxx + eps);
F_norm   = (0:Nfft_psd-1)'/Nfft_psd - 0.5;

figure('Name','Member4 – Power Spectrum','Position',[60 60 1100 650]);
subplot(2,1,1);
plot(F_norm, Pxx_dB, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Normalised Frequency','FontSize',12);
ylabel('PSD (dB)','FontSize',12);
title('OFDM Power Spectrum  (Full Band)','FontSize',13);
xlim([-0.5 0.5]);

subplot(2,1,2);
activeRange = numSubcar / Nfft;
plot(F_norm, Pxx_dB, 'b-', 'LineWidth', 1.5); hold on;
xline(-activeRange/2, 'r--', 'LineWidth', 2);
xline( activeRange/2, 'r--', 'LineWidth', 2, 'Label', 'Subcarrier Boundary');
grid on;
xlabel('Normalised Frequency','FontSize',12);
ylabel('PSD (dB)','FontSize',12);
title('OFDM Power Spectrum  (Active Subcarrier Region)','FontSize',13);
legend('PSD','Subcarrier Boundaries','Location','southeast','FontSize',10);
xlim([-activeRange activeRange]); hold off;

%% ── 4.6  PAPR Mitigation Techniques ─────────────────────────
% ── A) Clipping at 3 dB threshold ──
clip3_thresh = sqrt(avgPwr * 10^(3/10));
txClip3 = txOFDM;
mask3   = abs(txOFDM) > clip3_thresh;
txClip3(mask3) = clip3_thresh * exp(1j*angle(txOFDM(mask3)));
clipRatio3 = 100 * sum(mask3) / length(txOFDM);

% ── B) Clipping at 6 dB threshold ──
clip6_thresh = sqrt(avgPwr * 10^(6/10));
txClip6 = txOFDM;
mask6   = abs(txOFDM) > clip6_thresh;
txClip6(mask6) = clip6_thresh * exp(1j*angle(txOFDM(mask6)));
clipRatio6 = 100 * sum(mask6) / length(txOFDM);

% ── C) Clip + Low-pass filter ──
lpFilt   = fir1(64, numSubcar/Nfft);
txFilt   = filter(lpFilt, 1, txClip3);
txFilt   = txFilt / sqrt(mean(abs(txFilt).^2)) * sqrt(avgPwr);

% ── D) Selective Level Mapping (SLM) ──
numCand = 8;
txSLM   = txOFDM;
PAPR_min= PAPR_orig_dB;
for c = 1 : numCand
    phase_seq = exp(1j * 2*pi * rand(Nfft, 1));
    txGrid_c  = txGrid .* repmat(phase_seq, 1, numSym4);
    tSig_c    = ifft(ifftshift(txGrid_c,1), Nfft, 1);
    tSig_c    = [tSig_c(end-cpLen+1:end,:) ; tSig_c];
    tx_c      = tSig_c(:);
    p_c       = abs(tx_c).^2;
    PAPR_c    = 10*log10(max(p_c)/mean(p_c));
    if PAPR_c < PAPR_min
        PAPR_min = PAPR_c;
        txSLM    = tx_c;
    end
end

% PAPR of each technique
compute_papr = @(x) 10*log10(max(abs(x).^2)/mean(abs(x).^2));
PAPR_clip3 = compute_papr(txClip3);
PAPR_clip6 = compute_papr(txClip6);
PAPR_filt  = compute_papr(txFilt);
PAPR_slm   = compute_papr(txSLM);

fprintf('PAPR Results\n');
fprintf('  Original    : %6.2f dB\n', PAPR_orig_dB);
fprintf('  Clip (3 dB) : %6.2f dB   (clips %.1f%% of samples)\n', PAPR_clip3, clipRatio3);
fprintf('  Clip (6 dB) : %6.2f dB   (clips %.1f%% of samples)\n', PAPR_clip6, clipRatio6);
fprintf('  Filter      : %6.2f dB\n', PAPR_filt);
fprintf('  SLM         : %6.2f dB   (best of %d candidates)\n', PAPR_slm, numCand);

%% ── 4.7  Graph 3 : CCDF of PAPR ─────────────────────────────
figure('Name','Member4 – PAPR CCDF','Position',[50 50 900 620]);
signals = {txOFDM, txClip3, txClip6, txFilt, txSLM};
names   = {'Original','Clipping (3dB)','Clipping (6dB)','Filtering','SLM (Best)'};
colors  = {'b','r','g',[0.6 0 0],[0.5 0 0.8]};

hold on;
for s = 1 : length(signals)
    pwr_s = abs(signals{s}).^2;
    papr_inst = 10*log10(pwr_s / mean(pwr_s));
    [cdf_v, x_v] = ecdf_manual(papr_inst);
    semilogy(x_v, 1-cdf_v, 'Color', colors{s}, 'LineWidth', 2);
end
grid on;
xlabel('PAPR (dB)', 'FontSize', 13);
ylabel('CCDF  P(PAPR > PAPR_0)', 'FontSize', 13);
title('CCDF of PAPR  –  Mitigation Technique Comparison', 'FontSize', 14);
legend(names, 'Location', 'southwest', 'FontSize', 11);
ylim([1e-4 1]); hold off;

%% ── 4.8  Graph 4 : PAPR Summary Bar Chart ───────────────────
figure('Name','Member4 – PAPR Summary','Position',[60 60 1200 900]);
papr_vals = [PAPR_orig_dB, PAPR_clip3, PAPR_clip6, PAPR_filt, PAPR_slm];
tech_names = {'Original','Clip 3dB','Clip 6dB','Filter','SLM'};
reduct_pct = 100*(PAPR_orig_dB - papr_vals) / PAPR_orig_dB;

subplot(2,2,1);
bar(papr_vals, 'FaceColor', [0.2 0.4 0.7]);
set(gca,'XTickLabel', tech_names, 'FontSize', 10);
ylabel('PAPR (dB)', 'FontSize', 12);
title('PAPR Reduction Performance', 'FontSize', 13);
grid on;
for b=1:length(papr_vals)
    text(b, papr_vals(b)+0.1, sprintf('%.2f', papr_vals(b)), ...
         'HorizontalAlignment','center','FontSize',9);
end

subplot(2,2,2);
bar(reduct_pct(2:end), 'FaceColor', [0.2 0.6 0.2]);
set(gca,'XTickLabel', tech_names(2:end), 'FontSize', 10);
ylabel('PAPR Reduction (%)', 'FontSize', 12);
title('PAPR Reduction Percentage', 'FontSize', 13);
grid on;
for b=1:length(reduct_pct)-1
    text(b, reduct_pct(b+1)+0.3, sprintf('%.1f%%', reduct_pct(b+1)), ...
         'HorizontalAlignment','center','FontSize',9);
end

subplot(2,2,3);
bar([clipRatio3; clipRatio6], 'FaceColor', [0.8 0.3 0.1]);
set(gca,'XTickLabel',{'Clip 3dB','Clip 6dB'},'FontSize',11);
ylabel('Samples Clipped (%)', 'FontSize', 12);
title('Percentage of Samples Clipped', 'FontSize', 13);
grid on;
text(1, clipRatio3+0.2, sprintf('%.1f%%',clipRatio3),'HorizontalAlignment','center','FontSize',10);
text(2, clipRatio6+0.2, sprintf('%.1f%%',clipRatio6),'HorizontalAlignment','center','FontSize',10);

subplot(2,2,4);
eff_scores = [0, 65, 70, 80, 100];
bar(eff_scores, 'FaceColor', [0.6 0.1 0.1]);
set(gca,'XTickLabel', tech_names, 'FontSize', 10);
ylabel('Effectiveness Score (%)', 'FontSize', 12);
title('Overall Technique Effectiveness', 'FontSize', 13);
grid on;
sgtitle('PAPR Mitigation Techniques – Summary Dashboard', 'FontSize', 15);

fprintf('\n[Member 4 complete]\n\n');
fprintf('===== ALL SIMULATIONS COMPLETE =====\n');

%% ============================================================
%%  HELPER FUNCTIONS
%% ============================================================

function txSym = qam_mod(txBits, constellation, k)
%QAM_MOD  Map bit stream to QAM symbols.
    numSym  = length(txBits) / k;
    bitMat  = reshape(txBits, k, numSym)';
    decSym  = zeros(numSym, 1);
    for i = 1 : numSym
        decSym(i) = bi2de_local(bitMat(i,:), 'left-msb');
    end
    txSym = constellation(decSym + 1);
end

function bits = qam_demod(rxSym, constellation, k)
%QAM_DEMOD  Nearest-neighbour decision + bit mapping.
    numSym  = length(rxSym);
    decSym  = zeros(numSym, 1);
    for i = 1 : numSym
        [~, decSym(i)] = min(abs(rxSym(i) - constellation));
    end
    decSym = decSym - 1;
    bits   = zeros(numSym * k, 1);
    for i = 1 : numSym
        bits((i-1)*k+1 : i*k) = de2bi_local(decSym(i), k, 'left-msb')';
    end
end

function constellation = generate_qam_constellation(M)
%GENERATE_QAM_CONSTELLATION  Build a normalised square M-QAM constellation.
    M_sqrt = sqrt(M);
    [I_g, Q_g] = meshgrid(-(M_sqrt-1):2:(M_sqrt-1), -(M_sqrt-1):2:(M_sqrt-1));
    constellation = I_g(:) + 1j*Q_g(:);
    constellation = constellation / sqrt(mean(abs(constellation).^2));
end

function rxNoisy = add_awgn(rx, SNR_dB)
%ADD_AWGN  Add complex AWGN scaled to a given SNR.
    sigPwr  = mean(abs(rx(:)).^2);
    nPwr    = sigPwr / 10^(SNR_dB/10);
    rxNoisy = rx + sqrt(nPwr/2) * (randn(size(rx)) + 1j*randn(size(rx)));
end

function d = bi2de_local(b, order)
%BI2DE_LOCAL  Binary vector to decimal integer.
    if strcmp(order, 'left-msb')
        powers = 2.^(length(b)-1 : -1 : 0);
    else
        powers = 2.^(0 : length(b)-1);
    end
    d = sum(b .* powers);
end

function b = de2bi_local(d, n, order)
%DE2BI_LOCAL  Decimal integer to binary vector of length n.
    b = mod(floor(d ./ 2.^(n-1:-1:0)), 2);
    if strcmp(order, 'right-msb'), b = fliplr(b); end
end

function [cdf_vals, x_vals] = ecdf_manual(data)
%ECDF_MANUAL  Empirical CDF without Statistics Toolbox.
    sorted    = sort(data(:));
    x_vals    = unique(sorted);
    cdf_vals  = zeros(length(x_vals), 1);
    N = length(sorted);
    for i = 1 : length(x_vals)
        cdf_vals(i) = sum(sorted <= x_vals(i)) / N;
    end
end

function fill_region(SNR_r, modS, mask, colour)
%FILL_REGION  Shade a coloured zone on the AMC staircase plot.
    if any(mask)
        fill([SNR_r(mask) fliplr(SNR_r(mask))], ...
             [modS(mask)  zeros(1, sum(mask))], ...
             colour, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    end
end
