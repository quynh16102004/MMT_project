% =========================================================================
% CHƯƠNG TRÌNH MÔ PHỎNG CSMA/CD VÀ ĐỊNH TUYẾN QUA ROUTER (CÓ VẼ BIỂU ĐỒ)
% =========================================================================
clear all; clc; close all;

% --- 1. KHỞI TẠO THÔNG SỐ ---
TOTALSIM = 50000;       % Tăng thời gian mô phỏng lên chút để có nhiều data vẽ biểu đồ
lambda = 0.5;           % Tốc độ sinh gói tin
frameslot = 500;        % Thời gian truyền 1 frame cơ bản
td = 80;                % Trễ lan truyền trên BUS (Propagation Delay)
pd = 10;                % Trễ xử lý gói tin
tdelay = td + pd;       % Tổng trễ nội bộ
tbackoff = frameslot;   % Slot time dùng cho Backoff
maxbackoff = 3;         % Ngưỡng va chạm

% Khởi tạo hàng đợi
elist1 = []; % Bus 1 (Node 1, 2)
elist2 = []; % Bus 2 (Node 3, 4)
GENTIMECURSOR = [0 0 0 0]; 
CLOCK = 0;   

% MẢNG THU THẬP KẾT QUẢ ĐỂ VẼ BIỂU ĐỒ
SIMRESULT = []; 

% --- 2. SINH GÓI TIN ---
for i = 1:100 % Sinh 100 gói tin để đồ thị nhìn đẹp và rõ ràng hơn
    src_node = randi(2); 
    dest_node = randi(2);
    while src_node == dest_node 
        dest_node = randi(2);
    end
    
    interarvtime = round(frameslot * (-log(rand()) / lambda));
    GENTIMECURSOR(src_node) = GENTIMECURSOR(src_node) + interarvtime;
    
    pkt = [src_node, dest_node, GENTIMECURSOR(src_node), 0, 0, GENTIMECURSOR(src_node), 0];
    
    if (src_node == 1 || src_node == 2)
        elist1 = [elist1; pkt];
    else
        elist2 = [elist2; pkt];
    end
end

% --- 3. VÒNG LẶP MÔ PHỎNG ---
disp('Bắt đầu chạy mô phỏng và thu thập dữ liệu...');
while CLOCK < TOTALSIM
    if ~isempty(elist1), elist1 = sortrows(elist1, 6); end
    
    if size(elist1, 1) >= 2
        timediff1 = elist1(2, 6) - elist1(1, 6);
        
        if timediff1 <= pd % XẢY RA XUNG ĐỘT
            elist1(1, 7) = elist1(1, 7) + 1; 
            elist1(2, 7) = elist1(2, 7) + 1;
            
            gioihan1 = 2^min(elist1(1,7), maxbackoff);
            gioihan2 = 2^min(elist1(2,7), maxbackoff);
            
            bk1 = (randi([1, gioihan1]) - 1) * tbackoff;
            bk2 = (randi([1, gioihan2]) - 1) * tbackoff;
            
            elist1(1, 6) = elist1(1, 6) + bk1;
            elist1(2, 6) = elist1(2, 6) + bk2;
            
        else % TRUYỀN THÀNH CÔNG
            src = elist1(1, 1);
            dst = elist1(1, 2);
            
            if (dst == 3 || dst == 4) 
                [path_cost, delay_them] = routing_dijkstra();
                tdelay_total = tdelay + delay_them; 
            else
                tdelay_total = tdelay; 
            end
            
            if elist1(1, 4) == 0, elist1(1, 4) = elist1(1, 6); end 
            elist1(1, 5) = elist1(1, 6) + tdelay_total; 
            
            % THU THẬP DATA: Gói tin truyền xong thì ném vào mảng SIMRESULT
            SIMRESULT = [SIMRESULT; elist1(1,:)]; 
            elist1(1,:) = []; % Xóa khỏi hàng đợi
        end
    end
    CLOCK = CLOCK + frameslot; 
end
disp('Mô phỏng hoàn tất! Đang xuất đồ thị...');

% --- 4. HÀM ĐỊNH TUYẾN ---
function [cost, delay_router] = routing_dijkstra()
    c1 = randi(10); 
    c2 = randi(10); 
    cost = min([c1, c2]); 
    delay_router = cost * 20; 
end

% =========================================================================
% --- 5. VE BIEU DO (PLOT KET QUA) ---
% =========================================================================
if exist('SIMRESULT', 'var') && ~isempty(SIMRESULT)
    % Rut trich du lieu
    thoi_gian_sinh = SIMRESULT(:, 3);
    thoi_gian_nhan = SIMRESULT(:, 5);
    do_tre = thoi_gian_nhan - thoi_gian_sinh; 
    so_va_cham = SIMRESULT(:, 7);             
    
    % Tao cua so Figure
    figure('Name', 'Danh gia Hieu nang Mang CSMA/CD', 'NumberTitle', 'off');
    
    % --- Do thi 1: Do tre ---
    subplot(2, 1, 1);
    plot(1:length(do_tre), do_tre, '-o', 'Color', 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
    title('Do tre (Delay) cua cac goi tin', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Thu tu goi tin'); 
    ylabel('Do tre (usec)');
    grid on;
    
    % --- Do thi 2: Va cham ---
    subplot(2, 1, 2);
    bar(1:length(so_va_cham), so_va_cham, 'FaceColor', [0.8500 0.3250 0.0980]);
    title('So lan va cham (Collisions) cua tung goi', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Thu tu goi tin'); 
    ylabel('So lan va cham');
    grid on;
    
    % --- In thong ke ---
    disp('======================================');
    disp('KET QUA THONG KE MANG:');
    fprintf('- So goi tin truyen thanh cong: %d goi\n', length(do_tre));
    fprintf('- Do tre trung binh: %.2f (usec)\n', mean(do_tre));
    fprintf('- Tong so lan dung xe: %d lan\n', sum(so_va_cham));
    disp('======================================');
else
    disp('Khong co du lieu! Kiem tra lai Buoc 1 va Buoc 2');
end