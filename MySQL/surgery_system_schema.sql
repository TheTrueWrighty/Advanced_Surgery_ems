
-- Surgery log table
CREATE TABLE IF NOT EXISTS `surgery_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `doctor_cid` VARCHAR(64) NOT NULL,
  `doctor_name` VARCHAR(100) NOT NULL,
  `patient_cid` VARCHAR(64) NOT NULL,
  `patient_name` VARCHAR(100) NOT NULL,
  `surgery_result` VARCHAR(255),
  `notes` TEXT,
  `illness` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

-- Example metadata field for surgery XP
-- (If using qb-core's metadata system, this doesn't require SQL — it's stored in JSON in the database)
-- But here’s a backup in case you use standalone logic:
-- ALTER TABLE `players` ADD COLUMN `surgeryxp` INT DEFAULT 0;
