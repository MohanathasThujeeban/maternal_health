-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 05, 2025 at 06:23 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `maternaldb`
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
  `provider_name` varchar(255) NOT NULL,
  `status` enum('CANCELLED','COMPLETED','CONFIRMED','PENDING') NOT NULL,
  `time_slot` varchar(255) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `provider_id` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `additional_problems`, `appointment_date`, `appointment_type`, `created_at`, `mother_email`, `mother_name`, `mother_nic`, `notes`, `provider_name`, `status`, `time_slot`, `updated_at`, `provider_id`) VALUES
(3, 'puwan is pragnant', '2025-08-04 00:00:00.000000', 'DOCTOR', '2025-08-03 02:04:13.000000', 'thujee44@gmail.com', 'Mohanathas Thujeeban', '200201901851', NULL, 'Dr. Prasad Wickramasinghe - General Practitioner', 'CANCELLED', '08:00 AM', '2025-08-03 02:05:20.000000', 'DOC001'),
(4, 'ranuja is good', '2025-08-07 00:00:00.000000', 'DOCTOR', '2025-08-05 09:33:50.000000', 'thujee44@gmail.com', 'Mohanathas Thujeeban', '200201901851', NULL, 'Dr. Prasad Wickramasinghe - General Practitioner', 'PENDING', '08:00 AM', '2025-08-05 09:33:51.000000', 'DOC001');

-- --------------------------------------------------------

--
-- Table structure for table `email_verification_token`
--

CREATE TABLE `email_verification_token` (
  `id` bigint(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `expiry_date` datetime(6) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `verified` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(14, '2025-08-05 09:27:34.000000', 'thujee44@gmail.com', '2025-08-06 09:27:34.000000', 'd548ccdd-2bc4-4927-afa9-f01da7d08f47', b'1'),
(15, '2025-08-05 09:41:05.000000', 'ethusblue@gmail.com', '2025-08-06 09:41:05.000000', '15d69038-5c9a-4a09-83fd-43466088fba2', b'1');

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
(7, '2025-08-05 09:34:52.000000', '2025-08-05 10:34:52.000000', 'f9d6eb63-d1f8-49bc-808e-f2d8b2569412', b'1', 19);

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `is_active` bit(1) NOT NULL,
  `nic_number` varchar(12) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number3` varchar(15) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registration`
--

INSERT INTO `registration` (`id`, `created_at`, `email`, `is_active`, `nic_number`, `password`, `phone_number3`, `updated_at`, `full_name`) VALUES
(19, '2025-08-05 09:32:45.000000', 'thujee44@gmail.com', b'1', '200201901851', '$2a$10$DiLTmIUDt98DcgcpjK5R7Ozi9Zzv0DrCQBiUuWXYkH9ijdA7Ty49e', '0755420809', '2025-08-05 09:35:16.000000', 'Thujeeban'),
(20, '2025-08-05 09:43:52.000000', 'ethusblue@gmail.com', b'1', '200274101334', '$2a$10$TcZ5zeynUU1qUTEOHyU4MefEcIguz42NoXfu9ITt40M4p9DvJsK5e', '0772770454', '2025-08-05 09:43:52.000000', 'Rathnavel sutheshika');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `email_verification_token`
--
ALTER TABLE `email_verification_token`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `email_verification_tokens`
--
ALTER TABLE `email_verification_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKewmvysc7e9y6uy7og2c21axa9` (`token`);

--
-- Indexes for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKg0guo4k8krgpwuagos61oc06j` (`token`),
  ADD KEY `FK9t9x00l89078rcve1xqoy9epb` (`user_id`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKpqp6404l2ndskpsr1xx8eaa68` (`email`),
  ADD UNIQUE KEY `UK468i3st9urgic33fwltjogsyt` (`nic_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `email_verification_token`
--
ALTER TABLE `email_verification_token`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_verification_tokens`
--
ALTER TABLE `email_verification_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `password_reset_token`
--
ALTER TABLE `password_reset_token`
  ADD CONSTRAINT `FK9t9x00l89078rcve1xqoy9epb` FOREIGN KEY (`user_id`) REFERENCES `registration` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
