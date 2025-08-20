-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 18, 2025 at 07:24 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `maternal_health`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` bigint(20) NOT NULL,
  `additional_problems` text DEFAULT NULL,
  `appointment_date` datetime(6) NOT NULL,
  `appointment_type` enum('DOCTOR','MIDWIFE') NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `mother_email` varchar(255) NOT NULL,
  `mother_name` varchar(255) NOT NULL,
  `mother_nic` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `provider_id` varchar(255) DEFAULT NULL,
  `provider_name` varchar(255) NOT NULL,
  `status` enum('CANCELLED','COMPLETED','CONFIRMED','PENDING') NOT NULL,
  `time_slot` varchar(255) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `additional_problems`, `appointment_date`, `appointment_type`, `created_at`, `mother_email`, `mother_name`, `mother_nic`, `notes`, `provider_id`, `provider_name`, `status`, `time_slot`, `updated_at`) VALUES
(11, 'thujee', '2025-08-15 00:00:00.000000', 'DOCTOR', '2025-08-14 23:06:45.000000', 'thujee44@gmail.com', 'Mohanathas Thujeeban', '200201901851', NULL, 'DOC001', 'Dr. Prasad Wickramasinghe - General Practitioner', 'COMPLETED', '08:30 AM', '2025-08-15 00:03:38.000000'),
(12, 'thujee', '2025-08-16 00:00:00.000000', 'MIDWIFE', '2025-08-15 10:07:47.000000', 'thujee44@gmail.com', 'Mohanathas Thujeeban', '200201901851', NULL, 'MID001', 'Mrs. Kamali Jayasinghe - Senior Midwife', 'CANCELLED', '08:00 AM', '2025-08-15 10:41:42.000000'),
(13, 'thujee', '2025-08-17 00:00:00.000000', 'MIDWIFE', '2025-08-15 10:41:28.000000', 'thujee44@gmail.com', 'Mohanathas Thujeeban', '200201901851', NULL, 'MID001', 'Mrs. Kamali Jayasinghe - Senior Midwife', 'PENDING', '08:00 AM', '2025-08-15 10:41:28.000000');

-- --------------------------------------------------------

--
-- Table structure for table `email_verification_tokens`
--

CREATE TABLE `email_verification_tokens` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `email` varchar(255) NOT NULL,
  `expiry_date` datetime(6) NOT NULL,
  `token` varchar(255) NOT NULL,
  `verified` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `email_verification_tokens`
--

INSERT INTO `email_verification_tokens` (`id`, `created_at`, `email`, `expiry_date`, `token`, `verified`) VALUES
(5, '2025-08-12 11:00:57.000000', 'nadeeshathashmi16@gmail.com', '2025-08-13 11:00:57.000000', '101b0aef-7099-4dc8-88d2-6721bde2e554', b'1'),
(8, '2025-08-13 09:52:43.000000', 'subangi2702@gmail.com', '2025-08-14 09:52:43.000000', '63dfd4d6-9918-4f73-b933-5faa29475857', b'1'),
(11, '2025-08-13 14:11:46.000000', 'sutheshikasuthe@gmail.com', '2025-08-14 14:11:46.000000', 'a1dc518f-d3d9-49d1-88ae-21fae640de5f', b'1'),
(13, '2025-08-13 14:34:22.000000', 'thujee44@gmail.com', '2025-08-14 14:34:22.000000', '37dcbd56-7754-470f-a084-019b1332bbe4', b'1'),
(15, '2025-08-18 21:07:26.000000', 'thujeeforearn@gmail.com', '2025-08-19 21:07:26.000000', 'c8d39f92-19bf-4ce8-b566-25ef8a7b9253', b'1'),
(17, '2025-08-18 22:14:54.000000', 'mohanrajsrilanka@gmail.com', '2025-08-19 22:14:54.000000', '989200', b'1'),
(18, '2025-08-18 22:51:37.000000', 'ethusblue@gmail.com', '2025-08-19 22:51:37.000000', '459100', b'1');

-- --------------------------------------------------------

--
-- Table structure for table `flyway_schema_history`
--

CREATE TABLE `flyway_schema_history` (
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flyway_schema_history`
--

INSERT INTO `flyway_schema_history` (`installed_rank`, `version`, `description`, `type`, `script`, `checksum`, `installed_by`, `installed_on`, `execution_time`, `success`) VALUES
(1, '1', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'root', '2025-08-12 04:15:22', 0, 1),
(2, '7', 'Create Thiriposa Table', 'SQL', 'V7__Create_Thiriposa_Table.sql', 636243808, 'root', '2025-08-12 04:15:22', 10, 1),
(3, '8', 'Fix Thiriposa Table Schema', 'SQL', 'V8__Fix_Thiriposa_Table_Schema.sql', -85835886, 'root', '2025-08-12 08:00:37', 58, 1),
(4, '9', 'Create Vaccination Table', 'SQL', 'V9__Create_Vaccination_Table.sql', 0, 'root', '2025-08-18 09:54:41', 11, 1);

-- --------------------------------------------------------

--
-- Table structure for table `healthcare_providers`
--

CREATE TABLE `healthcare_providers` (
  `id` bigint(20) NOT NULL,
  `approved_at` datetime(6) DEFAULT NULL,
  `approved_by` bigint(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `institution` varchar(100) NOT NULL,
  `is_active` bit(1) NOT NULL,
  `is_approved` bit(1) NOT NULL,
  `is_email_verified` bit(1) NOT NULL,
  `license_expiry_date` datetime(6) DEFAULT NULL,
  `medical_license_number` varchar(50) NOT NULL,
  `nic_number` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `provider_type` enum('DOCTOR','MIDWIFE','NURSE','SPECIALIST') NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `years_of_experience` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `healthcare_providers`
--

INSERT INTO `healthcare_providers` (`id`, `approved_at`, `approved_by`, `created_at`, `email`, `full_name`, `institution`, `is_active`, `is_approved`, `is_email_verified`, `license_expiry_date`, `medical_license_number`, `nic_number`, `password`, `phone_number`, `provider_type`, `specialization`, `updated_at`, `years_of_experience`) VALUES
(1, '2025-08-18 22:43:53.000000', NULL, '2025-08-18 16:45:58', 'mohanrajsrilanka@gmail.com', 'thujee', 'MBBS', b'1', b'1', b'0', NULL, '12345', '200201901853', '$2a$10$Pmi2Vm5pvRbnImLcFBh5DORl3NPlZw2xAfGtpSpmFA.j8UKmFn12W', '0755420809', 'DOCTOR', 'MBBS', '2025-08-18 17:13:53', 4),
(2, '2025-08-18 22:53:48.000000', NULL, '2025-08-18 17:23:48', 'ethusblue@gmail.com', 'Sutheshika', 'MBBS', b'1', b'1', b'0', NULL, '67890', '200291001876', '$2a$10$8y1QeWUpQuGvWrpoGzFyTurjvcGz5ntDww3yYgvHkzfSLdoMJSJ9e', '0755420809', 'MIDWIFE', 'MBBS', '2025-08-18 17:23:48', 2);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_token`
--

CREATE TABLE `password_reset_token` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `expiry_date` datetime(6) NOT NULL,
  `token` varchar(255) NOT NULL,
  `used` bit(1) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `password_reset_token`
--

INSERT INTO `password_reset_token` (`id`, `created_at`, `expiry_date`, `token`, `used`, `user_id`) VALUES
(3, '2025-08-13 14:35:33.000000', '2025-08-13 15:35:33.000000', '7b602d1d-e95b-4ac7-9cf0-6e08909a1ce7', b'1', 9);

-- --------------------------------------------------------

--
-- Table structure for table `problem_records`
--

CREATE TABLE `problem_records` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `date_of_diagnosis` date NOT NULL,
  `ear_problem` varchar(255) DEFAULT NULL,
  `eye_problem` varchar(255) DEFAULT NULL,
  `patient_name` varchar(255) NOT NULL,
  `remarks` text DEFAULT NULL,
  `symptoms_duration` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `problem_records`
--

INSERT INTO `problem_records` (`id`, `created_at`, `date_of_diagnosis`, `ear_problem`, `eye_problem`, `patient_name`, `remarks`, `symptoms_duration`, `updated_at`) VALUES
(1, '2025-08-15 09:13:10.000000', '2025-08-09', 'None', 'Blocked Tear Duct', 'Baby Perera', 'Excessive tearing in left eye. Gentle massage recommended.', '1-2 weeks', '2025-08-15 09:13:10.000000'),
(2, '2025-08-15 09:13:10.000000', '2025-08-11', 'Ear Infection', 'None', 'Baby Silva', 'Fussy, pulling at ear. Prescribed antibiotic drops.', '3-7 days', '2025-08-15 09:13:10.000000'),
(3, '2025-08-15 09:13:10.000000', '2025-08-14', 'Ear Pain/Fussiness', 'Conjunctivitis (Pink Eye)', 'Baby Fernando', 'Both eye and ear issues observed during checkup.', 'Less than 1 day', '2025-08-15 09:13:10.000000');

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `is_active` bit(1) NOT NULL,
  `nic_number` varchar(12) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number3` varchar(15) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `user_role` enum('ADMIN','DOCTOR','MIDWIFE','MOTHER') NOT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `medical_license_number` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registration`
--

INSERT INTO `registration` (`id`, `created_at`, `email`, `full_name`, `is_active`, `nic_number`, `password`, `phone_number3`, `updated_at`, `user_role`, `institution`, `medical_license_number`) VALUES
(2, '2025-08-12 11:03:27.000000', 'nadeeshathashmi16@gmail.com', 'Thasmi', b'1', '200184210125', '$2a$10$MbMvdqVz80b431TcARA3eekwz5Uo.oi6P7jJxJiIjw6WXN/P4YaOu', '0771234567', '2025-08-12 11:03:27.000000', 'ADMIN', NULL, NULL),
(6, '2025-08-13 09:53:42.000000', 'subangi2702@gmail.com', 'Subangi', b'1', '200155801170', '$2a$10$K/kH84R5R3d/OFLOhZUqf.KE7OIlSAzj/QMhysd8cFPVnq5sqQdP.', '0770726949', '2025-08-13 09:55:02.000000', 'ADMIN', NULL, NULL),
(7, '2025-08-13 14:13:11.000000', 'sutheshikasuthe@gmail.com', 'Sutheshika', b'1', '200274101334', '$2a$10$Za2i3kDmr2VuclOOheQNO.m3Q5nNw8Cdu1jCTv/NzAjJCOhh1hEQG', '0772770454', '2025-08-13 14:13:11.000000', 'ADMIN', NULL, NULL),
(9, '2025-08-13 14:35:00.000000', 'thujee44@gmail.com', 'Thujeeban', b'1', '200201901851', '$2a$10$7C9Vi3SaBYWn352egdtGdOGPxPkK19jvTgTrKvrYTqo.bbZfqCMfO', '0755420709', '2025-08-13 14:36:05.000000', 'ADMIN', NULL, NULL),
(10, '2025-08-18 21:03:38.000000', 'samanthi@example.com', 'Samanthi Perera', b'1', '199876543210', '$2a$10$EK6AOWXeyz7EddUy./0S1OMfl5rmxkK5iRS794RtTDxOmiuqrwMdq', '0771234568', '2025-08-18 21:03:38.000000', 'MOTHER', NULL, NULL),
(11, '2025-08-18 21:03:38.000000', 'nimalka@example.com', 'Nimalka Silva', b'1', '199234567890', '$2a$10$SiqQy9iRi/QPRccPhGhIH.8dwXBzY.jKU1G/pv3YFEFzLfBob.JNO', '0771234569', '2025-08-18 21:03:38.000000', 'MOTHER', NULL, NULL),
(12, '2025-08-18 21:03:38.000000', 'midwife@maternalhealth.com', 'Dr. Priya Jayasinghe', b'1', '198512345678', '$2a$10$Ml/14MFtxMp8PiqET7XPve1VbSkdsSXF0ILhsWoMjyl04tCZ7I.26', '0712345678', '2025-08-18 21:03:38.000000', 'MIDWIFE', NULL, NULL),
(13, '2025-08-18 21:03:38.000000', 'doctor@maternalhealth.com', 'Dr. Kumara Fernando', b'1', '198012345679', '$2a$10$PPqqyU8qrrNMbbjQY.wj8.83cVoyQtUAkFnUd0RelfhHIbaxsufpi', '0713456789', '2025-08-18 21:03:38.000000', 'DOCTOR', NULL, NULL),
(14, '2025-08-18 21:09:59.000000', 'thujeeforearn@gmail.com', 'Mohanathas Thujeeban', b'1', '200201901852', '$2a$10$gVau/LKBxFhyIXfUADWCweqqiSlk0Wkp9Y0nL4e2LhghbHsKfPFFy', '0755420809', '2025-08-18 21:09:59.000000', 'MOTHER', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `thiriposa_records`
--

CREATE TABLE `thiriposa_records` (
  `id` bigint(20) NOT NULL,
  `mother_nic` varchar(20) NOT NULL,
  `supply_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `quantity` int(11) NOT NULL,
  `midwife_id` bigint(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `thiriposa_records`
--

INSERT INTO `thiriposa_records` (`id`, `mother_nic`, `supply_date`, `quantity`, `midwife_id`, `notes`, `created_at`) VALUES
(8, '200274101334', '2025-08-13 08:48:10', 1000, NULL, NULL, '2025-08-13 08:48:25'),
(9, '200201901851', '2025-08-13 09:10:05', 12, NULL, NULL, '2025-08-13 09:10:15');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `email_verification_tokens`
--
ALTER TABLE `email_verification_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKewmvysc7e9y6uy7og2c21axa9` (`token`);

--
-- Indexes for table `flyway_schema_history`
--
ALTER TABLE `flyway_schema_history`
  ADD PRIMARY KEY (`installed_rank`),
  ADD KEY `flyway_schema_history_s_idx` (`success`);

--
-- Indexes for table `healthcare_providers`
--
ALTER TABLE `healthcare_providers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK6klad50fnb14u65p54h63ga2` (`email`),
  ADD UNIQUE KEY `UK1bqrg1w4wqqwp82oviahgglq2` (`medical_license_number`),
  ADD UNIQUE KEY `UKtdv5i50bj1yq95g6iy6cbq3tr` (`nic_number`);

--
-- Indexes for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKg0guo4k8krgpwuagos61oc06j` (`token`),
  ADD KEY `FK9t9x00l89078rcve1xqoy9epb` (`user_id`);

--
-- Indexes for table `problem_records`
--
ALTER TABLE `problem_records`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKpqp6404l2ndskpsr1xx8eaa68` (`email`),
  ADD UNIQUE KEY `UK468i3st9urgic33fwltjogsyt` (`nic_number`);

--
-- Indexes for table `thiriposa_records`
--
ALTER TABLE `thiriposa_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_thiriposa_mother_nic` (`mother_nic`),
  ADD KEY `idx_thiriposa_supply_date` (`supply_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `email_verification_tokens`
--
ALTER TABLE `email_verification_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `healthcare_providers`
--
ALTER TABLE `healthcare_providers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `problem_records`
--
ALTER TABLE `problem_records`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `thiriposa_records`
--
ALTER TABLE `thiriposa_records`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  ADD CONSTRAINT `FK9t9x00l89078rcve1xqoy9epb` FOREIGN KEY (`user_id`) REFERENCES `registration` (`id`);

--
-- Constraints for table `thiriposa_records`
--
ALTER TABLE `thiriposa_records`
  ADD CONSTRAINT `fk_thiriposa_mother_nic` FOREIGN KEY (`mother_nic`) REFERENCES `registration` (`nic_number`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
