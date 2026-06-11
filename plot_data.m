% =========================================================================
% CHUONG TRINH 2: DOC DU LIEU VA VE BIEU DO (DATA PLOTTER)
% Khong dung ngoac vuong
% =========================================================================
clear all; clc; close all;

% Kiem tra xem co file data chua
if ~isfile('CSMACD_Data.mat')
    disp('LOI: Khong tim thay file CSMACD_Data.mat. Hay chay chuong trinh 1 truoc!');
    return;
end

% Load du lieu nguyen ban
load('CSMACD_Data.mat');
disp('DA TAI DU LIEU... DANG VE BIEU DO...');

% --- TINH TOAN THONG KE CHO 3 MUC TAI ---
% TAI THAP
tre_low = DATA_LOW(:,5) - DATA_LOW(:,3);
tb_tre_low = mean(tre_low);
tong_col_low = sum(DATA_LOW(:,7));
thongluong_low = (size(DATA_LOW, 1) * 1000) / (TOTALSIM / 1000000);

% TAI TRUNG BINH
tre_med = DATA_MED(:,5) - DATA_MED(:,3);
tb_tre_med = mean(tre_med);
tong_col_med = sum(DATA_MED(:,7));
thongluong_med = (size(DATA_MED, 1) * 1000) / (TOTALSIM / 1000000);

% TAI CAO
tre_high = DATA_HIGH(:,5) - DATA_HIGH(:,3);
tb_tre_high = mean(tre_high);
tong_col_high = sum(DATA_HIGH(:,7));
thongluong_high = (size(DATA_HIGH, 1) * 1000) / (TOTALSIM / 1000000);

% Gom data ve chung de ve cot
cot_tre = horzcat(tb_tre_low, tb_tre_med, tb_tre_high);
cot_col = horzcat(tong_col_low, tong_col_med, tong_col_high);
cot_tl  = horzcat(thongluong_low, thongluong_med, thongluong_high);

% ==========================================================
% HINH 1: BIEU DO PHAN TAN (SCATTER) MO PHONG CAC GOI TIN
% ==========================================================
figure('Name', 'Hinh 1: Bieu do phan tan (Scatter)', 'Color', 'w');
subplot(3,1,1);
scatter(1:length(tre_low), tre_low, 'b', 'filled');
title('Do tre tung goi tin - Tai Thap (Lambda = 0.1)', 'FontWeight', 'bold');
ylabel('Tre (us)'); grid on;

subplot(3,1,2);
scatter(1:length(tre_med), tre_med, 'g', 'filled');
title('Do tre tung goi tin - Tai Trung Binh (Lambda = 0.5)', 'FontWeight', 'bold');
ylabel('Tre (us)'); grid on;

subplot(3,1,3);
scatter(1:length(tre_high), tre_high, 'r', 'filled');
title('Do tre tung goi tin - Tai Cao (Lambda = 1.0)', 'FontWeight', 'bold');
xlabel('Goi tin'); ylabel('Tre (us)'); grid on;

% ==========================================================
% HINH 2: SO SANH DO TRE VA SO VA CHAM (BAR CHART)
% ==========================================================
figure('Name', 'Hinh 2: Tre & Va Cham', 'Color', 'w');
subplot(1,2,1);
bar(cot_tre, 'FaceColor', 'c');
set(gca, 'XTickLabel', char('Thap', 'Trung Binh', 'Cao'));
title('TRE TRUNG BINH THEO TAI', 'FontWeight', 'bold');
ylabel('Tre (us)'); grid on;

subplot(1,2,2);
bar(cot_col, 'FaceColor', 'm');
set(gca, 'XTickLabel', char('Thap', 'Trung Binh', 'Cao'));
title('TONG SO VA CHAM THEO TAI', 'FontWeight', 'bold');
ylabel('So lan va cham'); grid on;

% ==========================================================
% HINH 3: BIEU DO THONG LUONG (THROUGHPUT)
% ==========================================================
figure('Name', 'Hinh 3: Thong Luong', 'Color', 'w');
plot(horzcat(0.1, 0.5, 1.0), cot_tl, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'Color', 'b');
title('THONG LUONG HE THONG (THROUGHPUT) THEO TAI MANG', 'FontWeight', 'bold');
xlabel('Muc tai (Lambda)');
ylabel('Thong luong (bps)');
grid on;

disp('DA VE XONG 3 HINH! HAY KIEM TRA CAC CUA SO FIGURE.');