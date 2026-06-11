% =========================================================================
% FILE: Plot_Delay_CSMACD.m
% CHỨC NĂNG: Đọc dữ liệu từ CSMACD_Data.mat và vẽ biểu đồ Trễ Hàng Đợi
% FIX: Xử lý hiển thị khi có nhiều cặp node (nhãn đè nhau, text chồng chéo)
% =========================================================================
clear; clc; close all;

% --- 1. Load dữ liệu ---
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
file_load_path = fullfile(current_dir, 'CSMACD_Data.mat');
try
    load(file_load_path);
    fprintf('Da tai thanh cong du lieu tu: %s\n', file_load_path);
catch
    error('Khong tim thay file CSMACD_Data.mat trong thu muc nay!');
end

% --- 2. Trích xuất dữ liệu Trễ (Cột 5) ---
all_data = [DATA_LOW; DATA_MED; DATA_HIGH];
unique_pairs = unique(all_data(:, 1:2), 'rows');
num_pairs = size(unique_pairs, 1);

delay_matrix = NaN(num_pairs, 3);
node_pairs = cell(num_pairs, 1);

for i = 1:num_pairs
    src = unique_pairs(i, 1);
    dst = unique_pairs(i, 2);
    node_pairs{i} = sprintf('%d->%d', src, dst);
%tim tre cua cap node o tai thap
    idx1 = find(DATA_LOW(:,1) == src & DATA_LOW(:,2) == dst);
    if ~isempty(idx1)
        delay_matrix(i, 1) = mean(DATA_LOW(idx1, 4) - DATA_LOW(idx1, 3)); 
    end
%tim tre cua cap node o tai cao
    idx2 = find(DATA_MED(:, 1) == src & DATA_MED(:,2) == dst);
    if ~isempty(idx2)
        delay_matrix(i, 2) = mean(DATA_MED(idx2, 4) - DATA_MED(idx2, 3)); 
    end

    idx3 = find(DATA_HIGH(:,1) == src & DATA_HIGH(:,2) == dst);
    if ~isempty(idx3)
        delay_matrix(i,3) = mean(DATA_HIGH(idx3, 4) - DATA_HIGH(idx3, 3)); 
    end
end

% --- 4. Tính chiều rộng figure tự động theo số cặp node ---
% Mỗi nhóm cột cần ~60px; tối thiểu 900px, tối đa không giới hạn
px_per_group  = 60;
fig_width_px  = max(900, num_pairs * px_per_group + 200);
fig_height_px = 520;

% Chuyển sang đơn vị normalized (so với màn hình)
screen_sz  = get(0, 'ScreenSize');        % [1 1 W H]
fig_w_norm = min(fig_width_px  / screen_sz(3), 0.98);
fig_h_norm = min(fig_height_px / screen_sz(4), 0.90);
fig_x_norm = (1 - fig_w_norm) / 2;
fig_y_norm = (1 - fig_h_norm) / 2;

figure('Color', 'w', 'Name', 'Phan Tich Tre Hang Doi Giua Cac Node', ...
       'NumberTitle', 'off', ...
       'Units', 'normalized', ...
       'OuterPosition', [fig_x_norm, fig_y_norm, fig_w_norm, fig_h_norm]);

% --- 5. Vẽ biểu đồ cột grouped ---
b = bar(delay_matrix, 'grouped');
b(1).FaceColor = [0.20 0.60 0.80];   % Tải thấp   – xanh lam
b(2).FaceColor = [0.90 0.60 0.20];   % Tải trung bình – cam
b(3).FaceColor = [0.80 0.20 0.20];   % Tải cao    – đỏ

ax = gca;

% --- 6. Nhãn trục X thông minh ---
set(ax, 'XTick', 1:num_pairs, 'XTickLabel', node_pairs);

% Tự động chọn góc xoay & cỡ chữ theo số lượng cặp node
if num_pairs <= 8
    xtickangle(30);
    ax.XAxis.FontSize = 10;
elseif num_pairs <= 16
    xtickangle(45);
    ax.XAxis.FontSize = 9;
else
    xtickangle(60);
    ax.XAxis.FontSize = 8;
end

% --- 7. Margin dưới đủ rộng để nhãn xoay không bị cắt ---
% Ước tính chiều cao nhãn dài nhất (pixel) sau khi xoay
max_label_len = max(cellfun(@length, node_pairs));
label_height_est = max_label_len * 6 + 20;   % ~6px/ký tự + padding
ax.Units = 'pixels';
ax_pos   = ax.Position;                       % [x y w h] in pixels
bottom_margin = max(80, label_height_est);
ax.Position  = [ax_pos(1), bottom_margin, ax_pos(3), ...
                ax_pos(4) - (bottom_margin - ax_pos(2))];
ax.Units = 'normalized';

% --- 8. Trục & tiêu đề ---
xlabel('Tuyến giao tiếp (Nguồn→Đích)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Trễ hàng đợi trung bình (µs)',  'FontSize', 10, 'FontWeight', 'bold');
title({'MÔ PHỎNG BIẾN ĐỘNG TRỄ TRUY NHẬP THEO CÁC MỨC TẢI NGHẼN MẠNG'}, ...
      'FontSize', 13, 'FontWeight', 'bold');

legend('\lambda = 0.1  (Tải Thấp)', ...
       '\lambda = 0.5  (Tải Trung Bình)', ...
       '\lambda = 1.0  (Tải Cao)', ...
       'Location', 'best', 'FontSize', 10);

grid on;
set(ax, 'GridLineStyle', '--', 'GridAlpha', 0.4, 'FontWeight', 'bold');

% --- 9. Nhãn cảnh báo nghẽn mạng (trễ > 500 µs) ---
% FIX: Dùng offset dọc ngẫu nhiên nhỏ để tránh text đè nhau khi các cột gần nhau
THRESHOLD = 500;
y_lim_top = max(delay_matrix(:), [], 'omitnan') * 1.18;
ylim([0, y_lim_top]);   % Mở rộng trục Y để text không bị cắt trên cùng

% Tự động chọn cỡ chữ nhãn theo số cặp node
if num_pairs <= 10
    lbl_fontsize = 8;
elseif num_pairs <= 20
    lbl_fontsize = 7;
else
    lbl_fontsize = 6;
end

hold on;
for j = 1:3
    for i = 1:num_pairs
        val = delay_matrix(i, j);
        if ~isnan(val) && val > THRESHOLD
            x_pos = b(j).XEndPoints(i);
            % Định dạng ngắn gọn: dùng 'k' cho giá trị >= 1000
            if val >= 1000
                lbl_str = sprintf('%.1fk', val/1000);
            else
                lbl_str = sprintf('%d', round(val));
            end
            text(x_pos, val, lbl_str, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment',   'bottom', ...
                'FontWeight', 'bold', ...
                'Color',      [0.75 0.10 0.10], ...
                'FontSize',   lbl_fontsize);
        end
    end
end
hold off;

fprintf('Ve bieu do thanh cong! (%d cap node)\n', num_pairs);