-- =====================================================================
-- DỰ ÁN VIZO - HỆ THỐNG KHẢO THÍ TRỰC TUYẾN (B2B SaaS)
-- Task: TSK-12 | Engine: InnoDB | Charset: utf8mb4
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `vizo_saas`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `vizo_saas`;

-- Xóa các bảng cũ nếu tồn tại (xóa bảng con trước, bảng cha sau)
DROP TABLE IF EXISTS `student_answers`;
DROP TABLE IF EXISTS `exam_attempts`;
DROP TABLE IF EXISTS `question_options`;
DROP TABLE IF EXISTS `questions`;
DROP TABLE IF EXISTS `exams`;
DROP TABLE IF EXISTS `users`;

-- ---------------------------------------------------------------------
-- 1. BẢNG USERS (Tài khoản, gói B2B, Credit & Chống đăng nhập trùng)
-- ---------------------------------------------------------------------
CREATE TABLE `users` (
    `user_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('admin', 'teacher', 'student') NOT NULL DEFAULT 'student',
    `plan_type` ENUM('free', 'basic', 'pro') NOT NULL DEFAULT 'free',
    `credits` INT UNSIGNED NOT NULL DEFAULT 20,
    `active_session_id` VARCHAR(128) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. BẢNG EXAMS (Đề thi & cấu hình phòng thi)
-- Gợi ý: user_id (INT UNSIGNED NOT NULL) tham chiếu tới users(user_id) ON DELETE CASCADE
-- ---------------------------------------------------------------------
CREATE TABLE `exams` (
    `exam_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `exam_code` VARCHAR(20) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `duration_minutes` SMALLINT UNSIGNED NOT NULL,
    `max_violations` TINYINT UNSIGNED NOT NULL DEFAULT 3,
    `is_published` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. BẢNG QUESTIONS (Ngân hàng câu hỏi của đề thi)
-- Gợi ý: exam_id tham chiếu tới exams(exam_id) ON DELETE CASCADE
-- ---------------------------------------------------------------------
CREATE TABLE `questions` (
    `question_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `content` TEXT NOT NULL,
    `exam_id` INT UNSIGNED NOT NULL,
    `points` DECIMAL(5,2) DEFAULT 1.00,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`exam_id`) REFERENCES `exams`(`exam_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. BẢNG QUESTION_OPTIONS (Các phương án lựa chọn A, B, C, D)
-- Gợi ý: option_label CHAR(1), is_correct TINYINT(1) DEFAULT 0
-- ---------------------------------------------------------------------
CREATE TABLE `question_options` (
    `option_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `question_id` INT UNSIGNED NOT NULL,
    `option_label` CHAR(1) NOT NULL,
    `option_content` TEXT NOT NULL,
    `is_correct` TINYINT(1) DEFAULT 0,
    FOREIGN KEY (`question_id`) REFERENCES `questions`(`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. BẢNG EXAM_ATTEMPTS (Lượt thi thực tế của thí sinh)
-- Gợi ý: start_time (DATETIME NOT NULL), end_time (DATETIME NOT NULL),
-- submitted_at (DATETIME DEFAULT NULL), status ENUM('in_progress', 'submitted', 'locked')
-- ---------------------------------------------------------------------
CREATE TABLE `exam_attempts` (
    `attempt_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `exam_id` INT UNSIGNED NOT NULL,
    `user_id` INT UNSIGNED NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NOT NULL,
    `submitted_at` DATETIME DEFAULT NULL,
    `violation_count` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `status` ENUM('in_progress', 'submitted', 'locked') NOT NULL,
    `score` DECIMAL(5,2) DEFAULT NULL,
    FOREIGN KEY (`exam_id`) REFERENCES `exams`(`exam_id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. BẢNG STUDENT_ANSWERS (Lưu đáp án ngầm theo thời gian thực - TSK-09)
-- LƯU Ý KIẾN TRÚC SƯ:
-- 1) option_id phải cho phép NULL và dùng ON DELETE SET NULL
-- 2) Bắt buộc có UNIQUE KEY `uk_attempt_question` (`attempt_id`, `question_id`)
--    để dùng lệnh INSERT ... ON DUPLICATE KEY UPDATE khi Auto-save!
-- ---------------------------------------------------------------------
CREATE TABLE `student_answers` (
    `student_answer_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `attempt_id` INT UNSIGNED NOT NULL,
    `question_id` INT UNSIGNED NOT NULL,
    `option_id` INT UNSIGNED DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_attempt_question` (`attempt_id`, `question_id`),
    FOREIGN KEY (`attempt_id`) REFERENCES `exam_attempts`(`attempt_id`) ON DELETE CASCADE,
    FOREIGN KEY (`question_id`) REFERENCES `questions`(`question_id`) ON DELETE CASCADE,
    FOREIGN KEY (`option_id`) REFERENCES `question_options`(`option_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
