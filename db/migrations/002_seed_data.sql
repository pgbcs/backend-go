-- =============================================================================
-- Charity Chain — Seed Data
-- Migration: 002_seed_data.sql
-- =============================================================================

-- ─── USERS ───────────────────────────────────────────────────────────────────
-- Passwords đều là: Password123! (bcrypt hash)

INSERT INTO users (email, password, full_name, role, wallet_address) VALUES
-- Admin
('admin@charitychain.io',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'System Admin', 0, NULL),

-- Charity Organizations
('greenearth@org.vn',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Green Earth Foundation', 2, '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2'),

('mualhethanhthuong@org.vn',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Mùa Hè Thanh Thương', 2, '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db'),

('hopevietnam@org.vn',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Hope Vietnam NGO', 2, '0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB'),

-- Voters
('voter01@gmail.com',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Nguyen Van An', 3, '0x617F2E2fD72FD9D5503197092AC168c91465E7f2'),

('voter02@gmail.com',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Tran Thi Bich', 3, '0x17F6AD8Ef982297579C203069C1DbfFE4348c372'),

('voter03@gmail.com',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Le Minh Duc', 3, '0x5c6B0f7Bf3E7Ce5B6cB6b6e7fD9b9b2C3a4d5e6F'),

('voter04@gmail.com',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Pham Thi Lan', 3, '0x9D7f8e5A4B3C2d1e0F9a8b7c6d5e4f3a2b1c0d9E'),

('voter05@gmail.com',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'Hoang Van Khanh', 3, '0x1a2B3c4D5e6F7a8B9c0D1e2F3a4B5c6D7e8F9a0B');

-- ─── CAMPAIGNS ───────────────────────────────────────────────────────────────

INSERT INTO campaigns (title, description, image_url, goal_amount, current_amount, token_address, contract_address, charity_id, status, deadline) VALUES
(
  'Mùa Hè Xanh 2025',
  'Chiến dịch trồng cây gây rừng tại các tỉnh miền Trung bị lũ lụt tàn phá. Mục tiêu phục hồi 500 ha rừng đầu nguồn.',
  'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
  50000.000000000000000000,
  42000.000000000000000000,
  '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
  2, 'active',
  NOW() + INTERVAL '60 days'
),
(
  'Học Bổng Vùng Cao 2025',
  'Hỗ trợ 200 em học sinh dân tộc thiểu số tại Hà Giang, Lai Châu có điều kiện đến trường. Cấp học bổng, sách vở và đồng phục.',
  'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
  30000.000000000000000000,
  30000.000000000000000000,
  '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
  3, 'completed',
  NOW() - INTERVAL '10 days'
),
(
  'Nhà Chống Lũ Miền Tây',
  'Xây dựng 50 căn nhà phao chống lũ cho các hộ gia đình nghèo tại vùng đồng bằng sông Cửu Long thường xuyên chịu lũ lụt.',
  'https://images.unsplash.com/photo-1584483766114-2cea6facdf57?w=800',
  80000.000000000000000000,
  15000.000000000000000000,
  '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  NULL,
  4, 'active',
  NOW() + INTERVAL '90 days'
);

-- ─── WITHDRAWAL REQUESTS ─────────────────────────────────────────────────────

INSERT INTO withdrawal_requests (campaign_id, charity_id, amount, reason, proof_url, status, voting_deadline, yes_votes, no_votes, tx_hash) VALUES
-- Campaign 1: Mùa Hè Xanh — đã approved, đã giải ngân
(
  1, 2,
  10000.000000000000000000,
  'Mua 10,000 cây giống keo lai và dụng cụ trồng cây đợt 1 cho tỉnh Quảng Bình',
  'https://drive.google.com/file/d/proof_muacaygiong_q1_2025.pdf',
  'approved',
  NOW() - INTERVAL '20 days',
  45, 5,
  '0xabc123def456abc123def456abc123def456abc123def456abc123def456abc1'
),
-- Campaign 1: Mùa Hè Xanh — đang voting
(
  1, 2,
  15000.000000000000000000,
  'Chi phí vận chuyển cây giống và thuê nhân công trồng rừng đợt 2 tại Quảng Trị',
  'https://drive.google.com/file/d/proof_vanchuyencay_q2_2025.pdf',
  'voting',
  NOW() + INTERVAL '2 days',
  28, 12,
  NULL
),
-- Campaign 2: Học Bổng — đã approved, đã giải ngân
(
  2, 3,
  30000.000000000000000000,
  'Giải ngân toàn bộ học bổng cho 200 học sinh: mỗi em 150 USDT bao gồm học phí, sách vở và đồng phục',
  'https://drive.google.com/file/d/proof_hocbong_final_2025.pdf',
  'approved',
  NOW() - INTERVAL '15 days',
  89, 3,
  '0xdef789ghi012def789ghi012def789ghi012def789ghi012def789ghi012def7'
),
-- Campaign 1: Mùa Hè Xanh — bị rejected
(
  1, 2,
  20000.000000000000000000,
  'Mua xe tải chuyên dụng để vận chuyển cây giống',
  'https://drive.google.com/file/d/proof_muaxetai_rejected.pdf',
  'rejected',
  NOW() - INTERVAL '5 days',
  10, 40,
  NULL
);

-- ─── VOTES ───────────────────────────────────────────────────────────────────
-- Request 1 (approved): 45 yes, 5 no — chỉ seed một số mẫu
INSERT INTO votes (request_id, voter_id, is_approved) VALUES
(1, 5, true),
(1, 6, true),
(1, 7, true),
(1, 8, false),
(1, 9, true),
-- Request 2 (voting): 28 yes, 12 no hiện tại
(2, 5, true),
(2, 6, false),
(2, 7, true),
(2, 8, true),
(2, 9, false),
-- Request 3 (approved): học bổng
(3, 5, true),
(3, 6, true),
(3, 7, true),
(3, 8, true),
(3, 9, false),
-- Request 4 (rejected): mua xe tải
(4, 5, false),
(4, 6, false),
(4, 7, true),
(4, 8, false),
(4, 9, false);

-- ─── TRANSACTIONS ────────────────────────────────────────────────────────────

INSERT INTO transactions (campaign_id, request_id, tx_hash, amount, from_address, to_address, type) VALUES
-- Giải ngân request 1 (Mùa Hè Xanh đợt 1)
(
  1, 1,
  '0xabc123def456abc123def456abc123def456abc123def456abc123def456abc1',
  10000.000000000000000000,
  '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
  '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
  'disbursement'
),
-- Giải ngân request 3 (Học Bổng toàn bộ)
(
  2, 3,
  '0xdef789ghi012def789ghi012def789ghi012def789ghi012def789ghi012def7',
  30000.000000000000000000,
  '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
  '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
  'disbursement'
);
