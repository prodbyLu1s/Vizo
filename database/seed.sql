-- =====================================================================
-- DỰ ÁN VIZO - DỮ LIỆU MẪU KIỂM THỬ (SEED DATA)
-- Task: TSK-03
-- Mật khẩu mặc định của toàn bộ tài khoản mẫu: password
-- (Chuỗi hash Bcrypt bên dưới là hash chuẩn của chuỗi 'password')
-- =====================================================================

USE `vizo_saas`;
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 0. DỌN DỮ LIỆU CŨ (Xóa bảng con trước, bảng cha sau - không cần tắt FK)
-- Dùng DELETE thay vì TRUNCATE để không bị InnoDB chặn lỗi khóa ngoại #1701
-- ---------------------------------------------------------------------
DELETE FROM `student_answers`;
DELETE FROM `exam_attempts`;
DELETE FROM `question_options`;
DELETE FROM `questions`;
DELETE FROM `exams`;
DELETE FROM `users`;

ALTER TABLE `student_answers` AUTO_INCREMENT = 1;
ALTER TABLE `exam_attempts` AUTO_INCREMENT = 1;
ALTER TABLE `question_options` AUTO_INCREMENT = 1;
ALTER TABLE `questions` AUTO_INCREMENT = 1;
ALTER TABLE `exams` AUTO_INCREMENT = 1;
ALTER TABLE `users` AUTO_INCREMENT = 1;

-- ---------------------------------------------------------------------
-- 1. BẢNG USERS (5 tài khoản bao phủ đủ role & edge-case Credit)
-- Mật khẩu gốc: password
-- ---------------------------------------------------------------------
INSERT INTO `users` (`user_id`, `full_name`, `email`, `password`, `role`, `plan_type`, `credits`) VALUES
(1, 'Quản trị viên Vizo',   'admin@vizo.vn',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',   'pro',  999),
(2, 'Thầy Nguyễn Văn An',   'gv.an@vizo.vn',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'teacher', 'pro',  50),
(3, 'Cô Trần Thị Bình',     'gv.binh@vizo.vn',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'teacher', 'free', 0),
(4, 'Lê Minh Cường',        'sv.cuong@vizo.vn', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'free', 0),
(5, 'Phạm Hoàng Dũng',      'sv.dung@vizo.vn',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'free', 0);

-- ---------------------------------------------------------------------
-- 2. BẢNG EXAMS (3 đề thi: Công bố / Nháp / Chủ đề hết Credit)
-- ---------------------------------------------------------------------
INSERT INTO `exams` (`exam_id`, `user_id`, `exam_code`, `title`, `duration_minutes`, `max_violations`, `is_published`) VALUES
(1, 2, 'VIZO-PHP01',    'Kiểm tra Kiến thức PHP 8 OOP & MySQL InnoDB', 15, 3, 1),
(2, 2, 'VIZO-DRAFT01',  'Đề thi Nháp - Chưa mở cho thí sinh',          30, 3, 0),
(3, 3, 'VIZO-NOCREDIT', 'Đề thi Test chặn vào phòng khi hết Credit',   15, 3, 1);

-- ---------------------------------------------------------------------
-- 3. BẢNG QUESTIONS (5 câu hỏi cho exam_id = 1, mỗi câu 2.00đ -> tổng 10.00đ)
-- ---------------------------------------------------------------------
INSERT INTO `questions` (`question_id`, `exam_id`, `content`, `points`) VALUES
(1, 1, 'Cấu hình PDO nào bắt buộc tắt để ngăn chặn triệt để SQL Injection ở tầng Driver MySQL?', 2.00),
(2, 1, 'Storage Engine nào trong MySQL hỗ trợ Transaction (ACID) và ràng buộc Khóa ngoại (Foreign Key)?', 2.00),
(3, 1, 'Khi trả danh sách câu hỏi về trình duyệt bằng JSON API, cột nào tuyệt đối phải ẩn để chống lộ đáp án?', 2.00),
(4, 1, 'Ràng buộc nào trên bảng student_answers giúp cơ chế Auto-save ghi đè đáp án cũ thay vì tạo dòng trùng?', 2.00),
(5, 1, 'Hàm chuẩn nào trong PHP 8 dùng để kiểm tra mật khẩu người dùng nhập vào khớp với chuỗi Bcrypt trong CSDL?', 2.00);

-- ---------------------------------------------------------------------
-- 4. BẢNG QUESTION_OPTIONS (20 phương án - đúng 1 đáp án is_correct = 1/câu)
-- Đáp án đúng: Q1->B (2), Q2->A (5), Q3->C (11), Q4->D (16), Q5->B (18)
-- ---------------------------------------------------------------------
INSERT INTO `question_options` (`option_id`, `question_id`, `option_label`, `option_content`, `is_correct`) VALUES
-- Câu 1
(1,  1, 'A', 'PDO::ATTR_ERRMODE', 0),
(2,  1, 'B', 'PDO::ATTR_EMULATE_PREPARES', 1),
(3,  1, 'C', 'PDO::ATTR_DEFAULT_FETCH_MODE', 0),
(4,  1, 'D', 'PDO::ATTR_PERSISTENT', 0),
-- Câu 2
(5,  2, 'A', 'InnoDB', 1),
(6,  2, 'B', 'MyISAM', 0),
(7,  2, 'C', 'MEMORY', 0),
(8,  2, 'D', 'CSV', 0),
-- Câu 3
(9,  3, 'A', 'option_label', 0),
(10, 3, 'B', 'option_id', 0),
(11, 3, 'C', 'is_correct', 1),
(12, 3, 'D', 'points', 0),
-- Câu 4
(13, 4, 'A', 'DEFAULT NULL', 0),
(14, 4, 'B', 'ON DELETE CASCADE', 0),
(15, 4, 'C', 'AUTO_INCREMENT', 0),
(16, 4, 'D', 'UNIQUE KEY (attempt_id, question_id)', 1),
-- Câu 5
(17, 5, 'A', 'md5_verify()', 0),
(18, 5, 'B', 'password_verify()', 1),
(19, 5, 'C', 'password_hash()', 0),
(20, 5, 'D', 'hash_equals()', 0);

-- ---------------------------------------------------------------------
-- 5. BẢNG EXAM_ATTEMPTS
-- Attempt 1: SV Cường (user_id=4) đã nộp, đúng 4/5 câu -> score = 8.00
-- Attempt 2: SV Dũng (user_id=5) đang thi dở, 1 lần vi phạm chuyển tab
-- ---------------------------------------------------------------------
INSERT INTO `exam_attempts` (`attempt_id`, `exam_id`, `user_id`, `start_time`, `end_time`, `submitted_at`, `violation_count`, `status`, `score`) VALUES
(1, 1, 4, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_SUB(NOW(), INTERVAL 45 MINUTE), DATE_SUB(NOW(), INTERVAL 48 MINUTE), 0, 'submitted',   8.00),
(2, 1, 5, NOW(),                            DATE_ADD(NOW(), INTERVAL 15 MINUTE), NULL,                                1, 'in_progress', NULL);

-- ---------------------------------------------------------------------
-- 6. BẢNG STUDENT_ANSWERS
-- ---------------------------------------------------------------------
INSERT INTO `student_answers` (`attempt_id`, `question_id`, `option_id`) VALUES
-- Bài làm của SV Cường (attempt_id = 1): Đúng câu 1, 2, 3, 4; Sai câu 5 (chọn A=17 thay vì B=18) -> 8.00 điểm
(1, 1, 2),
(1, 2, 5),
(1, 3, 11),
(1, 4, 16),
(1, 5, 17),
-- Bài làm dở của SV Dũng (attempt_id = 2): Mới Auto-save 2 câu đầu
(2, 1, 2),
(2, 2, 6);