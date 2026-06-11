% =========================================================================
% CHUONG TRINH MO PHONG CSMA/CD - 4 NODES
% TU DONG XUAT BANG THONG KE (CHONG LOI NGOAC VUONG)
% =========================================================================
clear all; clc; close all;

% Khoi tao 3 muc tai (Tai thap, Tai trung binh, Tai cao)
lambdas = horzcat(0.1, 0.5, 1.0); 

TOTALSIM = 50000;       
frameslot = 500;        
td = 80;                
pd = 10;                
tdelay = td + pd;       
tbackoff = frameslot;   
maxbackoff = 3;         

disp('DANG CHAY MO PHONG... VUI LONG DOI...');

for scenario = 1:3
    lambda = lambdas(scenario);
    elist1 = zeros(0, 7); 
    GENTIMECURSOR = zeros(1, 4); % Chuyen thanh 4 Node
    CLOCK = 0;   
    SIMRESULT = zeros(0, 7); 
    
    % Sinh khoi tao 500 goi tin ngau nhien cho 4 Node
    for i = 1:500 
        src_node = randi(4); 
        dest_node = randi(4);       
        while src_node == dest_node
            dest_node = randi(4);
        end
        
        interarvtime = round(frameslot * (-log(rand()) / lambda));
        GENTIMECURSOR(src_node) = GENTIMECURSOR(src_node) + interarvtime;
        
        pkt = horzcat(src_node, dest_node, GENTIMECURSOR(src_node), 0, 0, GENTIMECURSOR(src_node), 0);
        elist1 = vertcat(elist1, pkt);
    end
    
    % Vong lap mo phong loi
    while CLOCK < TOTALSIM
        if size(elist1, 1) > 0
            elist1 = sortrows(elist1, 6); 
        end
        
        if size(elist1, 1) >= 2
            timediff1 = elist1(2, 6) - elist1(1, 6);
            
            if timediff1 <= pd 
                elist1(1, 7) = elist1(1, 7) + 1; 
                elist1(2, 7) = elist1(2, 7) + 1;
                
                gioihan1 = 2^min(elist1(1,7), maxbackoff);
                gioihan2 = 2^min(elist1(2,7), maxbackoff);
                
                bk1 = (randi(gioihan1) - 1) * tbackoff;
                bk2 = (randi(gioihan2) - 1) * tbackoff;
                
                elist1(1, 6) = elist1(1, 6) + bk1;
                elist1(2, 6) = elist1(2, 6) + bk2;
            else 
                % Neu goi tin di khac LAN (VD: 1,2 sang 3,4) thi cong them tre Router
                src = elist1(1, 1);
                dst = elist1(1, 2);
                delay_them = 0;
                if (src <= 2 && dst >= 3) || (src >= 3 && dst <= 2)
                    delay_them = randi(5) * 20; 
                end
                
                tdelay_total = tdelay + delay_them; 
                
                if elist1(1, 4) == 0
                    elist1(1, 4) = elist1(1, 6); 
                end 
                elist1(1, 5) = elist1(1, 6) + tdelay_total; 
                
                SIMRESULT = vertcat(SIMRESULT, elist1(1,:)); 
                elist1(1,:) = []; 
            end
        elseif size(elist1, 1) == 1 
            src = elist1(1, 1);
            dst = elist1(1, 2);
            delay_them = 0;
            if (src <= 2 && dst >= 3) || (src >= 3 && dst <= 2)
                delay_them = randi(5) * 20; 
            end
            
            tdelay_total = tdelay + delay_them;
            if elist1(1, 4) == 0
                elist1(1, 4) = elist1(1, 6); 
            end 
            elist1(1, 5) = elist1(1, 6) + tdelay_total; 
            SIMRESULT = vertcat(SIMRESULT, elist1(1,:)); 
            elist1(1,:) = []; 
        end
        CLOCK = CLOCK + frameslot; 
    end
    
    if scenario == 1
        DATA_LOW = SIMRESULT;
    elseif scenario == 2
        DATA_MED = SIMRESULT;
    elseif scenario == 3
        DATA_HIGH = SIMRESULT;
    end
    
    % =====================================================================
    % IN BANG KET QUA CHO TUNG MUC TAI
    % =====================================================================
    fprintf('\n=========================================================================\n');
    fprintf('KICH BAN %d: TAI LAMBDA = %.1f\n', scenario, lambda);
    fprintf('=========================================================================\n');
    fprintf('Nguon\tDich\tSo Goi\tVa Cham\t\tTre TB (us)\tThong Luong(bps)\n');
    fprintf('-------------------------------------------------------------------------\n');
    
    total_pkts = 0;
    total_cols = 0;
    
    % Quet qua 16 truong hop (4x4)
    for s = 1:4
        for d = 1:4
            if s == d
                continue; 
            end
            
            % Loc cac goi tin tu s den d
            idx = (SIMRESULT(:,1) == s) & (SIMRESULT(:,2) == d);
            subset = SIMRESULT(idx, :);
            
            so_goi = size(subset, 1);
            if so_goi > 0
                va_cham = sum(subset(:,7));
                tre_tb = mean(subset(:,5) - subset(:,3));
                
                % Tinh thong luong (Gia su 1 packet = 1000 bits)
                % Thong luong = (So bit) / (Tong thoi gian tinh bang giay)
                thong_luong = (so_goi * 1000) / (TOTALSIM / 1000000); 
                
                fprintf('%d\t\t%d\t\t%d\t\t%d\t\t\t%.2f\t\t%.2f\n', s, d, so_goi, va_cham, tre_tb, thong_luong);
                
                total_pkts = total_pkts + so_goi;
                total_cols = total_cols + va_cham;
            end
        end
    end
    fprintf('-------------------------------------------------------------------------\n');
    fprintf('TONG CONG:\t\t%d\t\t%d\n', total_pkts, total_cols);
end

% --- ĐOẠN ĐỔI MỚI Ở CUỐI CHƯƠNG TRÌNH GỐC ĐỂ ÉP ĐƯỜNG DẪN LƯU ---

% Tự động lấy đường dẫn của chính file .m đang chạy
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));

% Ghép đường dẫn với tên file dữ liệu muốn lưu
file_save_path = fullfile(current_dir, 'CSMACD_Data.mat');

% Lưu dữ liệu vào đúng vị trí của file code
save(file_save_path, 'DATA_LOW', 'DATA_MED', 'DATA_HIGH', 'TOTALSIM');

fprintf('DA LUU DU LIEU THANH CONG VAO FILE: %s\n', file_save_path);