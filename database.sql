-- MySQL dump 10.13  Distrib 5.7.32, for osx10.16 (x86_64)
--
-- Host: localhost    Database: finly_development
-- ------------------------------------------------------
-- Server version	5.7.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_reconciliation_balances`
--

DROP TABLE IF EXISTS `account_reconciliation_balances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_reconciliation_balances` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reconciliation_balance_id` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `account_type` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_account_reconciliation_balances_on_account_id` (`account_id`),
  KEY `index_account_reconciliation_balances_on_account_type` (`account_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accounting_system_configurations`
--

DROP TABLE IF EXISTS `accounting_system_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounting_system_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `accounting_system` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `options` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accounting_system_configurations_on_company_id` (`company_id`),
  KEY `index_accounting_system_configurations_on_accounting_system` (`accounting_system`),
  CONSTRAINT `fk_rails_ca89ab74e8` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `active_admin_comments`
--

DROP TABLE IF EXISTS `active_admin_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_admin_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `namespace` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `resource_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `resource_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `author_id` int(11) DEFAULT NULL,
  `author_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_active_admin_comments_on_namespace` (`namespace`),
  KEY `index_active_admin_comments_on_author_type_and_author_id` (`author_type`,`author_id`),
  KEY `index_active_admin_comments_on_resource_type_and_resource_id` (`resource_type`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `active_storage_attachments`
--

DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint(20) NOT NULL,
  `blob_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `active_storage_blobs`
--

DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text,
  `byte_size` bigint(20) NOT NULL,
  `checksum` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `line_1` text COLLATE utf8_unicode_ci,
  `line_2` text COLLATE utf8_unicode_ci,
  `line_3` text COLLATE utf8_unicode_ci,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `pin_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `address_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `landmark` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_2d87b6c11e` (`state_id`),
  CONSTRAINT `fk_rails_2d87b6c11e` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_implementation_requests`
--

DROP TABLE IF EXISTS `admin_implementation_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_implementation_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `admin_user_id` int(11) NOT NULL,
  `request_key` varchar(255) NOT NULL,
  `request_params` longtext,
  `master` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL,
  `message` text,
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `runtime` decimal(10,0) DEFAULT NULL,
  `requested_items` int(11) DEFAULT NULL,
  `completed_items` int(11) DEFAULT NULL,
  `request_file_file_name` varchar(255) DEFAULT NULL,
  `request_file_content_type` varchar(255) DEFAULT NULL,
  `request_file_file_size` bigint(20) DEFAULT NULL,
  `request_file_updated_at` datetime DEFAULT NULL,
  `result_file_file_name` varchar(255) DEFAULT NULL,
  `result_file_content_type` varchar(255) DEFAULT NULL,
  `result_file_file_size` bigint(20) DEFAULT NULL,
  `result_file_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `success_items` int(11) DEFAULT '0',
  `failed_items` int(11) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_implementation_requests_on_company_id` (`company_id`),
  KEY `index_admin_implementation_requests_on_admin_user_id` (`admin_user_id`),
  KEY `index_admin_implementation_requests_on_request_key` (`request_key`),
  KEY `index_admin_implementation_requests_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_review_workflow_levels`
--

DROP TABLE IF EXISTS `admin_review_workflow_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_review_workflow_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_review_workflow_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `trigger_email` tinyint(1) NOT NULL DEFAULT '0',
  `reviewer` tinyint(1) NOT NULL DEFAULT '0',
  `admin_user_id` int(11) NOT NULL,
  `email_triggered_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_review_workflow_levels_on_admin_review_workflow_id` (`admin_review_workflow_id`),
  KEY `index_admin_review_workflow_levels_on_position` (`position`),
  CONSTRAINT `fk_rails_122236d54b` FOREIGN KEY (`admin_review_workflow_id`) REFERENCES `admin_review_workflows` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_review_workflows`
--

DROP TABLE IF EXISTS `admin_review_workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_review_workflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_review_workflows_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_summary_mail_configs`
--

DROP TABLE IF EXISTS `admin_summary_mail_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_summary_mail_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `starting_day_of_month` int(11) DEFAULT NULL,
  `scheduled_day_of_month` int(11) DEFAULT NULL,
  `starting_day_of_week` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `scheduled_day_of_week` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `scheduled_time` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_summary_mail_configs_on_user_id` (`user_id`),
  KEY `index_admin_summary_mail_configs_on_period_id` (`period_id`),
  KEY `index_admin_summary_mail_configs_on_starting_day_of_month` (`starting_day_of_month`),
  KEY `index_admin_summary_mail_configs_on_scheduled_day_of_month` (`scheduled_day_of_month`),
  KEY `index_admin_summary_mail_configs_on_starting_day_of_week` (`starting_day_of_week`),
  KEY `index_admin_summary_mail_configs_on_scheduled_day_of_week` (`scheduled_day_of_week`),
  KEY `index_admin_summary_mail_configs_on_scheduled_time` (`scheduled_time`),
  CONSTRAINT `fk_rails_692fb3d647` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`),
  CONSTRAINT `fk_rails_b3dccc1463` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_user_role_mappings`
--

DROP TABLE IF EXISTS `admin_user_role_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_user_role_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_user_id` int(11) DEFAULT NULL,
  `admin_user_role_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_user_role_mappings_on_admin_user_id` (`admin_user_id`),
  KEY `index_admin_user_role_mappings_on_admin_user_role_id` (`admin_user_role_id`),
  CONSTRAINT `fk_rails_9e60d56a83` FOREIGN KEY (`admin_user_role_id`) REFERENCES `admin_user_roles` (`id`),
  CONSTRAINT `fk_rails_bb3756cf13` FOREIGN KEY (`admin_user_id`) REFERENCES `admin_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_user_roles`
--

DROP TABLE IF EXISTS `admin_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `encrypted_master_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authorized_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `admin_panel_access` tinyint(1) DEFAULT '1',
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admin_users_on_email` (`email`),
  UNIQUE KEY `index_admin_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `advance_amount_statuses`
--

DROP TABLE IF EXISTS `advance_amount_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advance_amount_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `agreement_types`
--

DROP TABLE IF EXISTS `agreement_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agreement_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `agreements`
--

DROP TABLE IF EXISTS `agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agreements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agreement_type_id` int(11) NOT NULL,
  `file_file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `file_content_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `file_file_size` int(11) NOT NULL,
  `file_updated_at` datetime NOT NULL,
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_agreements_on_agreement_type_id` (`agreement_type_id`),
  CONSTRAINT `fk_rails_68f388d15e` FOREIGN KEY (`agreement_type_id`) REFERENCES `agreement_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amounts`
--

DROP TABLE IF EXISTS `amounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` decimal(64,12) DEFAULT NULL,
  `currency_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `INR` decimal(20,5) DEFAULT NULL,
  `USD` decimal(20,5) DEFAULT NULL,
  `GBP` decimal(20,5) DEFAULT NULL,
  `CAD` decimal(20,5) DEFAULT NULL,
  `EUR` decimal(20,5) DEFAULT NULL,
  `HRK` decimal(20,5) DEFAULT NULL,
  `RUB` decimal(20,5) DEFAULT NULL,
  `BGN` decimal(20,5) DEFAULT NULL,
  `BRL` decimal(20,5) DEFAULT NULL,
  `CHF` decimal(20,5) DEFAULT NULL,
  `CNY` decimal(20,5) DEFAULT NULL,
  `CZK` decimal(20,5) DEFAULT NULL,
  `DKK` decimal(20,5) DEFAULT NULL,
  `HKD` decimal(20,5) DEFAULT NULL,
  `HUF` decimal(20,5) DEFAULT NULL,
  `IDR` decimal(20,5) DEFAULT NULL,
  `ILS` decimal(20,5) DEFAULT NULL,
  `JPY` decimal(20,5) DEFAULT NULL,
  `KRW` decimal(20,5) DEFAULT NULL,
  `MXN` decimal(20,5) DEFAULT NULL,
  `NOK` decimal(20,5) DEFAULT NULL,
  `NZD` decimal(20,5) DEFAULT NULL,
  `PHP` decimal(20,5) DEFAULT NULL,
  `PLN` decimal(20,5) DEFAULT NULL,
  `RON` decimal(20,5) DEFAULT NULL,
  `SEK` decimal(20,5) DEFAULT NULL,
  `SGD` decimal(20,5) DEFAULT NULL,
  `THB` decimal(20,5) DEFAULT NULL,
  `TRY` decimal(20,5) DEFAULT NULL,
  `ZAR` decimal(20,5) DEFAULT NULL,
  `AUD` decimal(20,5) DEFAULT NULL,
  `AED` decimal(20,5) DEFAULT NULL,
  `AFN` decimal(20,5) DEFAULT NULL,
  `ALL` decimal(20,5) DEFAULT NULL,
  `AMD` decimal(20,5) DEFAULT NULL,
  `ANG` decimal(20,5) DEFAULT NULL,
  `AOA` decimal(20,5) DEFAULT NULL,
  `ARS` decimal(20,5) DEFAULT NULL,
  `AWG` decimal(20,5) DEFAULT NULL,
  `AZN` decimal(20,5) DEFAULT NULL,
  `BAM` decimal(20,5) DEFAULT NULL,
  `BBD` decimal(20,5) DEFAULT NULL,
  `BDT` decimal(20,5) DEFAULT NULL,
  `BHD` decimal(20,5) DEFAULT NULL,
  `BIF` decimal(20,5) DEFAULT NULL,
  `BMD` decimal(20,5) DEFAULT NULL,
  `BND` decimal(20,5) DEFAULT NULL,
  `BOB` decimal(20,5) DEFAULT NULL,
  `BSD` decimal(20,5) DEFAULT NULL,
  `BTC` decimal(20,5) DEFAULT NULL,
  `BTN` decimal(20,5) DEFAULT NULL,
  `BWP` decimal(20,5) DEFAULT NULL,
  `BYN` decimal(20,5) DEFAULT NULL,
  `BYR` decimal(20,5) DEFAULT NULL,
  `BZD` decimal(20,5) DEFAULT NULL,
  `CDF` decimal(20,5) DEFAULT NULL,
  `CLF` decimal(20,5) DEFAULT NULL,
  `CLP` decimal(20,5) DEFAULT NULL,
  `COP` decimal(20,5) DEFAULT NULL,
  `CRC` decimal(20,5) DEFAULT NULL,
  `CUC` decimal(20,5) DEFAULT NULL,
  `CUP` decimal(20,5) DEFAULT NULL,
  `CVE` decimal(20,5) DEFAULT NULL,
  `DJF` decimal(20,5) DEFAULT NULL,
  `DOP` decimal(20,5) DEFAULT NULL,
  `DZD` decimal(20,5) DEFAULT NULL,
  `EEK` decimal(20,5) DEFAULT NULL,
  `EGP` decimal(20,5) DEFAULT NULL,
  `ERN` decimal(20,5) DEFAULT NULL,
  `ETB` decimal(20,5) DEFAULT NULL,
  `FJD` decimal(20,5) DEFAULT NULL,
  `FKP` decimal(20,5) DEFAULT NULL,
  `GEL` decimal(20,5) DEFAULT NULL,
  `GGP` decimal(20,5) DEFAULT NULL,
  `GHS` decimal(20,5) DEFAULT NULL,
  `GIP` decimal(20,5) DEFAULT NULL,
  `GMD` decimal(20,5) DEFAULT NULL,
  `GNF` decimal(20,5) DEFAULT NULL,
  `GTQ` decimal(20,5) DEFAULT NULL,
  `GYD` decimal(20,5) DEFAULT NULL,
  `HNL` decimal(20,5) DEFAULT NULL,
  `HTG` decimal(20,5) DEFAULT NULL,
  `IMP` decimal(20,5) DEFAULT NULL,
  `IQD` decimal(20,5) DEFAULT NULL,
  `IRR` decimal(20,5) DEFAULT NULL,
  `ISK` decimal(20,5) DEFAULT NULL,
  `JEP` decimal(20,5) DEFAULT NULL,
  `JMD` decimal(20,5) DEFAULT NULL,
  `JOD` decimal(20,5) DEFAULT NULL,
  `KES` decimal(20,5) DEFAULT NULL,
  `KGS` decimal(20,5) DEFAULT NULL,
  `KHR` decimal(20,5) DEFAULT NULL,
  `KMF` decimal(20,5) DEFAULT NULL,
  `KPW` decimal(20,5) DEFAULT NULL,
  `KWD` decimal(20,5) DEFAULT NULL,
  `KYD` decimal(20,5) DEFAULT NULL,
  `KZT` decimal(20,5) DEFAULT NULL,
  `LAK` decimal(20,5) DEFAULT NULL,
  `LBP` decimal(20,5) DEFAULT NULL,
  `LKR` decimal(20,5) DEFAULT NULL,
  `LRD` decimal(20,5) DEFAULT NULL,
  `LSL` decimal(20,5) DEFAULT NULL,
  `LTL` decimal(20,5) DEFAULT NULL,
  `LVL` decimal(20,5) DEFAULT NULL,
  `LYD` decimal(20,5) DEFAULT NULL,
  `MAD` decimal(20,5) DEFAULT NULL,
  `MDL` decimal(20,5) DEFAULT NULL,
  `MGA` decimal(20,5) DEFAULT NULL,
  `MKD` decimal(20,5) DEFAULT NULL,
  `MMK` decimal(20,5) DEFAULT NULL,
  `MNT` decimal(20,5) DEFAULT NULL,
  `MOP` decimal(20,5) DEFAULT NULL,
  `MRO` decimal(20,5) DEFAULT NULL,
  `MUR` decimal(20,5) DEFAULT NULL,
  `MVR` decimal(20,5) DEFAULT NULL,
  `MWK` decimal(20,5) DEFAULT NULL,
  `MZN` decimal(20,5) DEFAULT NULL,
  `NAD` decimal(20,5) DEFAULT NULL,
  `NGN` decimal(20,5) DEFAULT NULL,
  `NIO` decimal(20,5) DEFAULT NULL,
  `NPR` decimal(20,5) DEFAULT NULL,
  `OMR` decimal(20,5) DEFAULT NULL,
  `PAB` decimal(20,5) DEFAULT NULL,
  `PEN` decimal(20,5) DEFAULT NULL,
  `PGK` decimal(20,5) DEFAULT NULL,
  `PKR` decimal(20,5) DEFAULT NULL,
  `PYG` decimal(20,5) DEFAULT NULL,
  `QAR` decimal(20,5) DEFAULT NULL,
  `RSD` decimal(20,5) DEFAULT NULL,
  `RWF` decimal(20,5) DEFAULT NULL,
  `SAR` decimal(20,5) DEFAULT NULL,
  `SBD` decimal(20,5) DEFAULT NULL,
  `SCR` decimal(20,5) DEFAULT NULL,
  `SDG` decimal(20,5) DEFAULT NULL,
  `SHP` decimal(20,5) DEFAULT NULL,
  `SLL` decimal(20,5) DEFAULT NULL,
  `SOS` decimal(20,5) DEFAULT NULL,
  `SRD` decimal(20,5) DEFAULT NULL,
  `STD` decimal(20,5) DEFAULT NULL,
  `SVC` decimal(20,5) DEFAULT NULL,
  `SYP` decimal(20,5) DEFAULT NULL,
  `SZL` decimal(20,5) DEFAULT NULL,
  `TJS` decimal(20,5) DEFAULT NULL,
  `TMT` decimal(20,5) DEFAULT NULL,
  `TND` decimal(20,5) DEFAULT NULL,
  `TOP` decimal(20,5) DEFAULT NULL,
  `TTD` decimal(20,5) DEFAULT NULL,
  `TWD` decimal(20,5) DEFAULT NULL,
  `TZS` decimal(20,5) DEFAULT NULL,
  `UAH` decimal(20,5) DEFAULT NULL,
  `UGX` decimal(20,5) DEFAULT NULL,
  `UYU` decimal(20,5) DEFAULT NULL,
  `UZS` decimal(20,5) DEFAULT NULL,
  `VEF` decimal(20,5) DEFAULT NULL,
  `VND` decimal(20,5) DEFAULT NULL,
  `VUV` decimal(20,5) DEFAULT NULL,
  `WST` decimal(20,5) DEFAULT NULL,
  `XAF` decimal(20,5) DEFAULT NULL,
  `XAG` decimal(20,5) DEFAULT NULL,
  `XAU` decimal(20,5) DEFAULT NULL,
  `XCD` decimal(20,5) DEFAULT NULL,
  `XDR` decimal(20,5) DEFAULT NULL,
  `XOF` decimal(20,5) DEFAULT NULL,
  `XPF` decimal(20,5) DEFAULT NULL,
  `YER` decimal(20,5) DEFAULT NULL,
  `ZMK` decimal(20,5) DEFAULT NULL,
  `ZMW` decimal(20,5) DEFAULT NULL,
  `ZWL` decimal(20,5) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_amounts_on_currency_id` (`currency_id`),
  KEY `index_amounts_on_created_at` (`created_at`),
  CONSTRAINT `fk_rails_3442d826db` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=279139 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analytics_dashboard_schedule_user_mappings`
--

DROP TABLE IF EXISTS `analytics_dashboard_schedule_user_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analytics_dashboard_schedule_user_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `analytics_dashboard_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_company_id` (`company_id`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_dashboard_id` (`analytics_dashboard_id`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_user_id` (`user_id`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_deleted_at` (`deleted_at`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_created_at` (`created_at`),
  KEY `index_analytics_dashboard_schedule_user_mappings_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analytics_dashboard_schedules`
--

DROP TABLE IF EXISTS `analytics_dashboard_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analytics_dashboard_schedules` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `analytics_dashboard_id` int(11) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `hour` int(11) DEFAULT NULL,
  `minute` int(11) DEFAULT NULL,
  `day_of_the_week` int(11) DEFAULT NULL,
  `day_of_the_month` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_analytics_dashboard_schedules_on_company_id` (`company_id`),
  KEY `index_analytics_dashboard_schedules_on_analytics_dashboard_id` (`analytics_dashboard_id`),
  KEY `index_analytics_dashboard_schedules_on_start_date` (`start_date`),
  KEY `index_analytics_dashboard_schedules_on_end_date` (`end_date`),
  KEY `index_analytics_dashboard_schedules_on_frequency` (`frequency`),
  KEY `index_analytics_dashboard_schedules_on_hour` (`hour`),
  KEY `index_analytics_dashboard_schedules_on_minute` (`minute`),
  KEY `index_analytics_dashboard_schedules_on_day_of_the_week` (`day_of_the_week`),
  KEY `index_analytics_dashboard_schedules_on_day_of_the_month` (`day_of_the_month`),
  KEY `index_analytics_dashboard_schedules_on_deleted_at` (`deleted_at`),
  KEY `index_analytics_dashboard_schedules_on_created_at` (`created_at`),
  KEY `index_analytics_dashboard_schedules_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analytics_dashboards`
--

DROP TABLE IF EXISTS `analytics_dashboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analytics_dashboards` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `default` tinyint(1) DEFAULT '0',
  `reports` text,
  `is_system_dashboard` tinyint(1) DEFAULT NULL,
  `system_dashboard_id` varchar(255) DEFAULT NULL,
  `feature_subscriptions` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `feature_toggle` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_analytics_dashboards_on_app` (`app`),
  KEY `index_analytics_dashboards_on_company_id` (`company_id`),
  KEY `index_analytics_dashboards_on_created_by_id` (`created_by_id`),
  KEY `index_analytics_dashboards_on_name` (`name`),
  KEY `index_analytics_dashboards_on_default` (`default`),
  KEY `index_analytics_dashboards_on_is_system_dashboard` (`is_system_dashboard`),
  KEY `index_analytics_dashboards_on_system_dashboard_id` (`system_dashboard_id`),
  KEY `index_analytics_dashboards_on_deleted_at` (`deleted_at`),
  KEY `index_analytics_dashboards_on_created_at` (`created_at`),
  KEY `index_analytics_dashboards_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_tokens`
--

DROP TABLE IF EXISTS `api_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_tokens` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `base_url` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `client_secret` varchar(255) DEFAULT NULL,
  `grant_type` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `approval_routes`
--

DROP TABLE IF EXISTS `approval_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `approval_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purpose_id` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `reviewer_id` int(11) NOT NULL,
  `threshold` int(11) NOT NULL DEFAULT '0',
  `created_by_user_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `policy_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_approval_routes_on_purpose_id` (`purpose_id`),
  KEY `index_approval_routes_on_level` (`level`),
  KEY `index_approval_routes_on_reviewer_id` (`reviewer_id`),
  KEY `index_approval_routes_on_threshold` (`threshold`),
  KEY `index_approval_routes_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_approval_routes_on_user_id` (`user_id`),
  KEY `index_approval_routes_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_79330f794d` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`),
  CONSTRAINT `fk_rails_a339dd4ed2` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_a343adc6be` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artifacts`
--

DROP TABLE IF EXISTS `artifacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artifacts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) DEFAULT NULL,
  `resource_type` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `description` text,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artifacts_on_company_id` (`company_id`),
  KEY `index_artifacts_on_creator_id` (`creator_id`),
  KEY `index_artifacts_on_resource_id_and_resource_type` (`resource_id`,`resource_type`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) DEFAULT NULL,
  `resource_type` varchar(255) DEFAULT NULL,
  `file_file_name` varchar(255) DEFAULT NULL,
  `file_file_size` decimal(64,12) DEFAULT NULL,
  `file_content_type` varchar(255) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_company_id` (`company_id`),
  KEY `index_attachments_on_creator_id` (`creator_id`),
  KEY `index_attachments_on_resource_id_and_resource_type` (`resource_id`,`resource_type`)
) ENGINE=InnoDB AUTO_INCREMENT=174 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authentications`
--

DROP TABLE IF EXISTS `authentications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `provider` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `uid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nickname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `urls` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `secret` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires` tinyint(1) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `refresh_token_at` datetime DEFAULT NULL,
  `extra` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_authentications_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_08833fecbe` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_reload_configs`
--

DROP TABLE IF EXISTS `auto_reload_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_reload_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `minimum_balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `reloadable_id` int(11) DEFAULT NULL,
  `reloadable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `threshold_balance_id` int(11) DEFAULT NULL,
  `target_balance_id` int(11) DEFAULT NULL,
  `source_account_id` int(11) DEFAULT NULL,
  `source_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_auto_reload_configs_on_reloadable_type_and_reloadable_id` (`reloadable_type`,`reloadable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_submit_configs`
--

DROP TABLE IF EXISTS `auto_submit_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_submit_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `limit_to_card_expenses` tinyint(1) NOT NULL DEFAULT '0',
  `period_id` int(11) NOT NULL,
  `default_memo` text COLLATE utf8_unicode_ci,
  `default_policy_id` int(11) DEFAULT NULL,
  `submitable_id` int(11) NOT NULL,
  `submitable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_auto_submit_configs_on_period_id` (`period_id`),
  KEY `index_auto_submit_configs_on_default_policy_id` (`default_policy_id`),
  KEY `index_auto_submit_configs_on_submitable_type_and_submitable_id` (`submitable_type`,`submitable_id`),
  CONSTRAINT `fk_rails_e6c6dc745f` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_sync_config_types`
--

DROP TABLE IF EXISTS `auto_sync_config_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_sync_config_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_sync_configs`
--

DROP TABLE IF EXISTS `auto_sync_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_sync_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `auto_sync_config_type_id` int(11) DEFAULT NULL,
  `categories_sync` tinyint(1) DEFAULT '0',
  `company_tags_sync` tinyint(1) DEFAULT '0',
  `external_users_sync` tinyint(1) DEFAULT '0',
  `reports_sync` tinyint(1) DEFAULT '0',
  `period_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_auto_sync_configs_on_company_id` (`company_id`),
  KEY `index_auto_sync_configs_on_auto_sync_config_type_id` (`auto_sync_config_type_id`),
  KEY `index_auto_sync_configs_on_period_id` (`period_id`),
  CONSTRAINT `fk_rails_268c006b23` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_4059f43806` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`),
  CONSTRAINT `fk_rails_8231a3e3ba` FOREIGN KEY (`auto_sync_config_type_id`) REFERENCES `auto_sync_config_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `balance_sheets`
--

DROP TABLE IF EXISTS `balance_sheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `balance_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `cash_in_hand_id` int(11) DEFAULT NULL,
  `approved_reports_total_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `pending_advance_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_balance_sheets_on_user_id` (`user_id`),
  KEY `index_balance_sheets_on_cash_in_hand_id` (`cash_in_hand_id`),
  KEY `index_balance_sheets_on_approved_reports_total_id` (`approved_reports_total_id`),
  CONSTRAINT `fk_rails_5195ec7d1e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `balance_tally_ledgers`
--

DROP TABLE IF EXISTS `balance_tally_ledgers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `balance_tally_ledgers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `api_balance_id` int(11) DEFAULT NULL,
  `finly_database_balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `calculated_balance_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_balance_tally_ledgers_on_api_balance_id` (`api_balance_id`),
  KEY `index_balance_tally_ledgers_on_finly_database_balance_id` (`finly_database_balance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=338 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_account_masters`
--

DROP TABLE IF EXISTS `bank_account_masters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_account_masters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_number` varchar(255) DEFAULT NULL,
  `ifsc` varchar(255) DEFAULT NULL,
  `account_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_account_providers`
--

DROP TABLE IF EXISTS `bank_account_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_account_providers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_accounts`
--

DROP TABLE IF EXISTS `bank_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `yes_bank_vendor_id` int(11) DEFAULT NULL,
  `account_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ifsc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pin_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `account_owner_id` int(11) DEFAULT NULL,
  `account_owner_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `reimbursable` tinyint(1) DEFAULT NULL,
  `default_account` tinyint(1) DEFAULT '0',
  `is_deleted` tinyint(1) DEFAULT '0',
  `disabled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `on_hold` tinyint(1) DEFAULT '0',
  `bank_account_master_id` int(11) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT NULL,
  `swift_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bank_accounts_on_yes_bank_vendor_id` (`yes_bank_vendor_id`),
  KEY `index_bank_accounts_on_account_number` (`account_number`),
  KEY `index_bank_accounts_on_name` (`name`),
  KEY `index_bank_accounts_on_ifsc` (`ifsc`),
  KEY `index_bank_accounts_on_company_id` (`company_id`),
  KEY `index_bank_accounts_on_created_at` (`created_at`),
  CONSTRAINT `fk_rails_c72925e352` FOREIGN KEY (`yes_bank_vendor_id`) REFERENCES `yes_bank_vendors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=373 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_details_masters`
--

DROP TABLE IF EXISTS `bank_details_masters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_details_masters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `ifsc_prefix` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_request_comment_actions`
--

DROP TABLE IF EXISTS `bank_payment_request_comment_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_request_comment_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_request_comments`
--

DROP TABLE IF EXISTS `bank_payment_request_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_request_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8_unicode_ci,
  `action_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bank_payment_request_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `forwarded_to_user_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `previous_value` text COLLATE utf8_unicode_ci,
  `new_value` text COLLATE utf8_unicode_ci,
  `edited_field` text COLLATE utf8_unicode_ci,
  `beneficiary_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bank_payment_request_comments_on_action_id` (`action_id`),
  KEY `index_bank_payment_request_comments_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_b73e5809b9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=346 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_request_statuses`
--

DROP TABLE IF EXISTS `bank_payment_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_request_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_request_trail_actions`
--

DROP TABLE IF EXISTS `bank_payment_request_trail_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_request_trail_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_request_trails`
--

DROP TABLE IF EXISTS `bank_payment_request_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_request_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bank_payment_request_id` int(11) DEFAULT NULL,
  `request_status_id` int(11) DEFAULT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `action_user_role_id` int(11) DEFAULT NULL,
  `modified_user_id` int(11) DEFAULT NULL,
  `modified_user_role_id` int(11) DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `action_for_user_id` int(11) DEFAULT NULL,
  `action_for_user_role_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bank_payment_request_trails_on_bank_payment_request_id` (`bank_payment_request_id`),
  KEY `index_bank_payment_request_trails_on_request_status_id` (`request_status_id`),
  KEY `index_bank_payment_request_trails_on_action_user_id` (`action_user_id`),
  KEY `index_bank_payment_request_trails_on_action_user_role_id` (`action_user_role_id`),
  KEY `index_bank_payment_request_trails_on_modified_user_id` (`modified_user_id`),
  KEY `index_bank_payment_request_trails_on_modified_user_role_id` (`modified_user_role_id`),
  KEY `index_bank_payment_request_trails_on_action_id` (`action_id`),
  CONSTRAINT `fk_rails_779442ea59` FOREIGN KEY (`bank_payment_request_id`) REFERENCES `bank_payment_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_payment_requests`
--

DROP TABLE IF EXISTS `bank_payment_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_payment_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `controlling_user_id` int(11) DEFAULT NULL,
  `payment_order_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `requested_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `require_approval` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `beneficiary_type_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `payment_file_downloaded` tinyint(1) DEFAULT '0',
  `auto_approved` tinyint(1) DEFAULT NULL,
  `api_initiated` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `max_payment_amount` decimal(20,5) DEFAULT NULL,
  `rejection_note` text COLLATE utf8_unicode_ci,
  `bank_account_provider_id` int(11) DEFAULT NULL,
  `otp` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `otp_sent_at` datetime DEFAULT NULL,
  `otp_attempts` int(11) DEFAULT NULL,
  `otp_count` int(11) DEFAULT NULL,
  `expected_payments` int(11) DEFAULT '0',
  `ticket_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_mode_id` int(11) DEFAULT NULL,
  `is_domestic` tinyint(1) DEFAULT '1',
  `base_currency_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bank_payment_requests_on_owner_id` (`owner_id`),
  KEY `index_bank_payment_requests_on_status_id` (`status_id`),
  KEY `index_bank_payment_requests_on_controlling_user_id` (`controlling_user_id`),
  KEY `index_bank_payment_requests_on_requested_amount_id` (`requested_amount_id`),
  KEY `index_bank_payment_requests_on_created_at` (`created_at`),
  KEY `index_bank_payment_requests_on_company_id` (`company_id`),
  KEY `index_bank_payment_requests_on_controlling_level_id` (`controlling_level_id`),
  KEY `index_bank_payment_requests_on_ticket_type` (`ticket_type`),
  KEY `index_bank_payment_requests_on_transfer_mode_id` (`transfer_mode_id`),
  KEY `index_bpr_ct_lvl_cmpny_id` (`company_id`,`controlling_level_id`,`deleted_at`),
  KEY `index_bpr_fields` (`deleted_at`,`policy_id`,`payment_order_id`,`status_id`),
  KEY `index_bpr_fields_2` (`deleted_at`,`policy_id`,`payment_order_id`,`status_id`,`owner_id`),
  KEY `index_bpr_fields_3` (`deleted_at`,`policy_id`,`payment_order_id`),
  KEY `index_bpr_fields_4` (`deleted_at`,`policy_id`,`status_id`),
  KEY `index_bpr_fields_5` (`deleted_at`,`owner_id`),
  KEY `index_bpr_awaiting_approval_fields` (`deleted_at`,`payment_order_id`,`policy_id`,`controlling_level_id`,`company_id`,`owner_id`),
  KEY `index_bpr_awaiting_approval_fields_2` (`deleted_at`,`payment_order_id`,`policy_id`,`controlling_level_id`,`company_id`),
  KEY `index_bpr_awaiting_approval_fields_3` (`deleted_at`,`policy_id`,`controlling_level_id`,`company_id`),
  KEY `index_bpr_awaiting_approval_fields_4` (`deleted_at`,`payment_order_id`,`policy_id`,`controlling_level_id`,`company_id`,`owner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_transaction_types`
--

DROP TABLE IF EXISTS `bank_transaction_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_transaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_transfer_statuses`
--

DROP TABLE IF EXISTS `bank_transfer_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bank_transfer_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_bill_statuses`
--

DROP TABLE IF EXISTS `bbps_bill_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_bill_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_biller_subscription_statuses`
--

DROP TABLE IF EXISTS `bbps_biller_subscription_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_biller_subscription_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_biller_subscription_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_biller_subscriptions`
--

DROP TABLE IF EXISTS `bbps_biller_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_biller_subscriptions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bbps_biller_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sequence_id` varchar(255) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `note` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `agreement_id` int(11) DEFAULT NULL,
  `expected_bill_day` varchar(255) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `reminder_before_days` varchar(255) DEFAULT NULL,
  `biller_category_name` varchar(255) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `mobile_number` varchar(255) DEFAULT NULL,
  `customer_param_key_1` varchar(255) DEFAULT NULL,
  `customer_param_value_1` varchar(255) DEFAULT NULL,
  `customer_param_key_2` varchar(255) DEFAULT NULL,
  `customer_param_value_2` varchar(255) DEFAULT NULL,
  `customer_param_key_3` varchar(255) DEFAULT NULL,
  `customer_param_value_3` varchar(255) DEFAULT NULL,
  `customer_param_key_4` varchar(255) DEFAULT NULL,
  `customer_param_value_4` varchar(255) DEFAULT NULL,
  `customer_param_key_5` varchar(255) DEFAULT NULL,
  `customer_param_value_5` varchar(255) DEFAULT NULL,
  `fetch_requirement` varchar(255) DEFAULT NULL,
  `auto_generate_bill` tinyint(1) DEFAULT '1',
  `support_bill_validation` varchar(255) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `customer_aadhar_number` varchar(255) DEFAULT NULL,
  `customer_pan` varchar(255) DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `hsn_sac` varchar(255) DEFAULT NULL,
  `quick_pay` varchar(255) DEFAULT 'N',
  `last_paid_at` datetime DEFAULT NULL,
  `review_note` text,
  `refreshed_at` datetime DEFAULT NULL,
  `auto_fetch_enabled` tinyint(1) DEFAULT '1',
  `biller_response` text,
  `last_bill_generated_at` datetime DEFAULT NULL,
  `last_bill_due_date` date DEFAULT NULL,
  `last_bill_bill_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_biller_subscriptions_on_bbps_biller_id` (`bbps_biller_id`),
  KEY `index_bbps_biller_subscriptions_on_name` (`name`),
  KEY `index_bbps_biller_subscriptions_on_sequence_id` (`sequence_id`),
  KEY `index_bbps_biller_subscriptions_on_department_id` (`department_id`),
  KEY `index_bbps_biller_subscriptions_on_cost_center_id` (`cost_center_id`),
  KEY `index_bbps_biller_subscriptions_on_location_id` (`location_id`),
  KEY `index_bbps_biller_subscriptions_on_policy_id` (`policy_id`),
  KEY `index_bbps_biller_subscriptions_on_deleted_at` (`deleted_at`),
  KEY `index_bbps_biller_subscriptions_on_active` (`active`),
  CONSTRAINT `fk_rails_4722f30ff4` FOREIGN KEY (`bbps_biller_id`) REFERENCES `bbps_billers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_billers`
--

DROP TABLE IF EXISTS `bbps_billers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_billers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `biller_id` varchar(255) DEFAULT NULL,
  `biller_name` varchar(255) DEFAULT NULL,
  `biller_alias_name` varchar(255) DEFAULT NULL,
  `biller_category_name` varchar(255) DEFAULT NULL,
  `biller_mode` varchar(255) DEFAULT NULL,
  `biller_accepts_adhoc` tinyint(1) DEFAULT NULL,
  `parent_biller` tinyint(1) DEFAULT NULL,
  `parent_biller_id` varchar(255) DEFAULT NULL,
  `biller_owner_shp` varchar(255) DEFAULT NULL,
  `biller_coverage` varchar(255) DEFAULT NULL,
  `fetch_requirement` varchar(255) DEFAULT NULL,
  `payment_amount_exactness` varchar(255) DEFAULT NULL,
  `support_bill_validation` varchar(255) DEFAULT NULL,
  `biller_effctv_from` date DEFAULT NULL,
  `biller_effctv_to` date DEFAULT NULL,
  `biller_temp_deactivation_start` date DEFAULT NULL,
  `biller_temp_deactivation_end` date DEFAULT NULL,
  `biller_payment_modes` longtext,
  `biller_payment_channels` longtext,
  `biller_customer_params` longtext,
  `biller_response_params` longtext,
  `biller_additional_info` longtext,
  `interchange_fee_conf` longtext,
  `interchange_fee` longtext,
  `status` varchar(255) DEFAULT NULL,
  `biller_description` text,
  `support_deemed` varchar(255) DEFAULT NULL,
  `support_pending_status` varchar(255) DEFAULT NULL,
  `biller_time_out` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_bbps_billers_on_biller_id` (`biller_id`),
  KEY `index_bbps_billers_on_parent_biller_id` (`parent_biller_id`),
  KEY `index_bbps_billers_on_status` (`status`),
  KEY `index_bbps_billers_on_created_at` (`created_at`),
  KEY `index_bbps_billers_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=898 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_bills`
--

DROP TABLE IF EXISTS `bbps_bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_bills` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sequence_id` varchar(255) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `autofetched` tinyint(1) DEFAULT '0',
  `expected_due_date` date DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `note` text,
  `company_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `bill_date` date DEFAULT NULL,
  `bill_number` varchar(255) DEFAULT NULL,
  `paid_on_date` date DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `bbps_id` varchar(255) DEFAULT NULL,
  `bill_period` varchar(255) DEFAULT NULL,
  `late_payment_fee_id` int(11) DEFAULT NULL,
  `early_payment_fee_id` int(11) DEFAULT NULL,
  `convenience_fee_id` int(11) DEFAULT NULL,
  `quick_pay` varchar(255) DEFAULT 'N',
  `total_amount_id` int(11) DEFAULT NULL,
  `early_payment_fee_selected` tinyint(1) DEFAULT '0',
  `late_payment_fee_selected` tinyint(1) DEFAULT '0',
  `convenience_fee_selected` tinyint(1) DEFAULT '0',
  `bbps_biller_id` int(11) DEFAULT NULL,
  `bill_validation_required` tinyint(1) DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
  `order_number_type` varchar(255) DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `hsn_sac` varchar(255) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `review_note` text,
  `selected_amount_type` varchar(255) DEFAULT 'base_amount',
  `disconn_tag` varchar(255) DEFAULT NULL,
  `bill_month` varchar(255) DEFAULT NULL,
  `pc` varchar(255) DEFAULT NULL,
  `early_payment_date` date DEFAULT NULL,
  `api_response` mediumtext,
  `generated_at` datetime DEFAULT NULL,
  `biller_response` text,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text,
  `erp_sync_reference_id` varchar(255) DEFAULT NULL,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_bills_on_subscription_id` (`subscription_id`),
  KEY `index_bbps_bills_on_user_id` (`user_id`),
  KEY `index_bbps_bills_on_sequence_id` (`sequence_id`),
  KEY `index_bbps_bills_on_department_id` (`department_id`),
  KEY `index_bbps_bills_on_cost_center_id` (`cost_center_id`),
  KEY `index_bbps_bills_on_location_id` (`location_id`),
  KEY `index_bbps_bills_on_policy_id` (`policy_id`),
  KEY `index_bbps_bills_on_controlling_level_id` (`controlling_level_id`),
  KEY `index_bbps_bills_on_status_id` (`status_id`),
  KEY `index_bbps_bills_on_amount_id` (`amount_id`),
  KEY `index_bbps_bills_on_autofetched` (`autofetched`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_subscription_fields`
--

DROP TABLE IF EXISTS `bbps_subscription_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_subscription_fields` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `biller_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_subscription_fields_on_label` (`label`),
  KEY `index_bbps_subscription_fields_on_value` (`value`),
  KEY `index_bbps_subscription_fields_on_subscription_id` (`subscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_subscription_pocs`
--

DROP TABLE IF EXISTS `bbps_subscription_pocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_subscription_pocs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_subscription_pocs_on_user_id` (`user_id`),
  KEY `index_bbps_subscription_pocs_on_subscription_id` (`subscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bbps_yes_bank_transactions`
--

DROP TABLE IF EXISTS `bbps_yes_bank_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bbps_yes_bank_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_code` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `error_code` varchar(255) DEFAULT NULL,
  `error_desc` varchar(255) DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
  `agent_institution_id` varchar(255) DEFAULT NULL,
  `channel_id` varchar(255) DEFAULT NULL,
  `bbps_ref_id` varchar(255) DEFAULT NULL,
  `agent_id` varchar(255) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_mobile` varchar(255) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `customer_aadhar_no` varchar(255) DEFAULT NULL,
  `customer_pan_id` varchar(255) DEFAULT NULL,
  `biller_id` varchar(255) DEFAULT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `bill_date` varchar(255) DEFAULT NULL,
  `due_date` varchar(255) DEFAULT NULL,
  `bill_number` varchar(255) DEFAULT NULL,
  `bill_period` varchar(255) DEFAULT NULL,
  `convenience_fee` varchar(255) DEFAULT NULL,
  `convenience_fee_desc` varchar(255) DEFAULT NULL,
  `late_payment_fee` varchar(255) DEFAULT NULL,
  `early_payment_fee` varchar(255) DEFAULT NULL,
  `additional_field` varchar(255) DEFAULT NULL,
  `bill_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `transfer_status_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `quick_pay` varchar(255) DEFAULT 'N',
  `deleted_at` datetime DEFAULT NULL,
  `reference_payment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bbps_yes_bank_transactions_on_bill_id` (`bill_id`),
  KEY `index_bbps_yes_bank_transactions_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beneficiary_payment_statuses`
--

DROP TABLE IF EXISTS `beneficiary_payment_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beneficiary_payment_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beneficiary_payments`
--

DROP TABLE IF EXISTS `beneficiary_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beneficiary_payments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `bank_account_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `original_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `payable_amount_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `tax` decimal(10,3) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `balance_due_id` int(11) DEFAULT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `gross_amount_id` int(11) DEFAULT NULL,
  `roundoff_amount` decimal(20,10) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `invoice_number` text,
  `invoice_date` date DEFAULT NULL,
  `invoice_due_date` date DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `payment_agreement_id` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `vendor_location_id` int(11) DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `payment_notification_users` text,
  `freight_amount_id` int(11) DEFAULT NULL,
  `resource_template_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `payment_agreement_upcoming_date` date DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_beneficiary_payments_on_vendor_id` (`vendor_id`),
  KEY `index_beneficiary_payments_on_bank_account_id` (`bank_account_id`),
  KEY `index_beneficiary_payments_on_category_id` (`category_id`),
  KEY `index_beneficiary_payments_on_department_id` (`department_id`),
  KEY `index_beneficiary_payments_on_original_amount_id` (`original_amount_id`),
  KEY `index_beneficiary_payments_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_beneficiary_payments_on_payable_amount_id` (`payable_amount_id`),
  KEY `index_beneficiary_payments_on_gst_type_id` (`gst_type_id`),
  KEY `index_beneficiary_payments_on_tds_slab_id` (`tds_slab_id`),
  KEY `index_beneficiary_payments_on_company_id` (`company_id`),
  KEY `index_beneficiary_payments_on_sub_department_id` (`sub_department_id`),
  KEY `index_beneficiary_payments_on_status_id` (`status_id`),
  KEY `index_beneficiary_payments_on_cost_center_id` (`cost_center_id`),
  KEY `index_beneficiary_payments_on_invoice_number` (`invoice_number`(20)),
  KEY `index_beneficiary_payments_on_invoice_date` (`invoice_date`),
  KEY `index_beneficiary_payments_on_invoice_due_date` (`invoice_due_date`),
  KEY `index_beneficiary_payments_on_balance_due_id` (`balance_due_id`),
  KEY `index_beneficiary_payments_on_gross_amount_id` (`gross_amount_id`),
  KEY `index_beneficiary_payments_on_net_amount_id` (`net_amount_id`),
  KEY `index_beneficiary_payments_on_tds_amount_id` (`tds_amount_id`),
  KEY `index_beneficiary_payments_on_advance_amount_id` (`advance_amount_id`),
  KEY `index_beneficiary_payments_on_freight_amount_id` (`freight_amount_id`),
  KEY `index_beneficiary_payments_on_resource_template_id` (`resource_template_id`),
  KEY `index_beneficiary_payments_on_creator_id` (`creator_id`),
  CONSTRAINT `fk_rails_50fb9f971f` FOREIGN KEY (`bank_account_id`) REFERENCES `bank_accounts` (`id`),
  CONSTRAINT `fk_rails_652d480a1d` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_85da5f8ee7` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `fk_rails_da2d90265c` FOREIGN KEY (`vendor_id`) REFERENCES `yes_bank_vendors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10018 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bill_of_supplies`
--

DROP TABLE IF EXISTS `bill_of_supplies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bill_of_supplies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `procurement_term_id` int(11) DEFAULT NULL,
  `document_status_id` int(11) DEFAULT NULL,
  `doc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `override_doc_number` tinyint(1) DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `bill_date` date DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `roundoff_total_enabled` tinyint(1) DEFAULT NULL,
  `roundoff_amount` decimal(10,5) DEFAULT NULL,
  `transaction_amount_id` int(11) DEFAULT NULL,
  `total_before_tax_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `total_after_tax_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `balance_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bill_of_supplies_on_company_id` (`company_id`),
  KEY `index_bill_of_supplies_on_user_id` (`user_id`),
  KEY `index_bill_of_supplies_on_procurement_id` (`procurement_id`),
  KEY `index_bill_of_supplies_on_location_id` (`location_id`),
  KEY `index_bill_of_supplies_on_delivery_location_id` (`delivery_location_id`),
  KEY `index_bill_of_supplies_on_vendor_id` (`vendor_id`),
  KEY `index_bill_of_supplies_on_payment_term_id` (`payment_term_id`),
  KEY `index_bill_of_supplies_on_procurement_term_id` (`procurement_term_id`),
  KEY `index_bill_of_supplies_on_document_status_id` (`document_status_id`),
  KEY `index_bill_of_supplies_on_transaction_amount_id` (`transaction_amount_id`),
  KEY `index_bill_of_supplies_on_total_before_tax_id` (`total_before_tax_id`),
  KEY `index_bill_of_supplies_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_bill_of_supplies_on_total_after_tax_id` (`total_after_tax_id`),
  KEY `index_bill_of_supplies_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_bill_of_supplies_on_balance_amount_id` (`balance_amount_id`),
  CONSTRAINT `fk_rails_1aaaa923f0` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`),
  CONSTRAINT `fk_rails_956d2a7df0` FOREIGN KEY (`document_status_id`) REFERENCES `document_statuses` (`id`),
  CONSTRAINT `fk_rails_c3e551d7de` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c6e772e939` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_d4296f6193` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_df3d3f56fa` FOREIGN KEY (`procurement_term_id`) REFERENCES `procurement_terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `billing_types`
--

DROP TABLE IF EXISTS `billing_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `billing_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_attachments`
--

DROP TABLE IF EXISTS `booking_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attachment_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attachment_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_attachments_on_booking_id` (`booking_id`),
  KEY `index_booking_attachments_on_user_id` (`user_id`),
  KEY `index_booking_attachments_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_51c3735ca4` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `fk_rails_d55f368baa` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f2d803a27e` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_buses`
--

DROP TABLE IF EXISTS `booking_buses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_buses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `booking_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_id` int(11) NOT NULL,
  `to_id` int(11) NOT NULL,
  `cost_id` int(11) DEFAULT NULL,
  `boarding_point` text COLLATE utf8_unicode_ci,
  `drop_point` text COLLATE utf8_unicode_ci,
  `description` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_buses_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_car_rentals`
--

DROP TABLE IF EXISTS `booking_car_rentals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_car_rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pickup_address` text COLLATE utf8_unicode_ci,
  `car_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `car_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pickup_city_id` int(11) NOT NULL,
  `drop_city_id` int(11) NOT NULL,
  `drop_address` text COLLATE utf8_unicode_ci,
  `pickup_datetime` datetime DEFAULT NULL,
  `drop_datetime` datetime DEFAULT NULL,
  `rental_company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `cost_id` int(11) DEFAULT NULL,
  `pickup_date` date DEFAULT NULL,
  `pickup_time` time DEFAULT NULL,
  `drop_date` date DEFAULT NULL,
  `drop_time` time DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_car_rentals_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_customs`
--

DROP TABLE IF EXISTS `booking_customs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_customs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `journey_date` date DEFAULT NULL,
  `journey_destination` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `journey_source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `start_time` text COLLATE utf8_unicode_ci,
  `end_time` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_booking_customs_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_flight_classes`
--

DROP TABLE IF EXISTS `booking_flight_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_flight_classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_flight_classes_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_flights`
--

DROP TABLE IF EXISTS `booking_flights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_flights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pnr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `airline` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stops` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ticket_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_id` int(11) NOT NULL,
  `to_id` int(11) NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `terminal` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cost_id` int(11) DEFAULT NULL,
  `booking_class_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_flights_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=156 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_hotels`
--

DROP TABLE IF EXISTS `booking_hotels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_hotels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hotel_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_id` int(11) NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `hotel_address` text COLLATE utf8_unicode_ci,
  `number_of_guests` int(11) DEFAULT NULL,
  `cost_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `checkin_date` date DEFAULT NULL,
  `checkin_time` time DEFAULT NULL,
  `checkout_date` date DEFAULT NULL,
  `checkout_time` time DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_hotels_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_others`
--

DROP TABLE IF EXISTS `booking_others`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_others` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `booking_details` text COLLATE utf8_unicode_ci,
  `description` text COLLATE utf8_unicode_ci,
  `cost_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_others_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_requests`
--

DROP TABLE IF EXISTS `booking_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_status_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `travel_request_destination_id` int(11) DEFAULT NULL,
  `booking_type_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `travel_request_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_requests_on_booking_status_id` (`booking_status_id`),
  KEY `index_booking_requests_on_booking_type_id` (`booking_type_id`),
  CONSTRAINT `fk_rails_208f62c031` FOREIGN KEY (`booking_type_id`) REFERENCES `booking_types` (`id`),
  CONSTRAINT `fk_rails_9bca24c7f5` FOREIGN KEY (`booking_status_id`) REFERENCES `booking_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_restaurants`
--

DROP TABLE IF EXISTS `booking_restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_restaurants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_id` int(11) NOT NULL,
  `restaurant_address` text COLLATE utf8_unicode_ci,
  `number_of_guests` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `reservation_date` date DEFAULT NULL,
  `reservation_time` time DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_restaurants_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_statuses`
--

DROP TABLE IF EXISTS `booking_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_trains`
--

DROP TABLE IF EXISTS `booking_trains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_trains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `train_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pnr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `booking_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_id` int(11) NOT NULL,
  `boarding_station` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_id` int(11) NOT NULL,
  `destination_station` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `seat_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cost_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_booking_trains_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_types`
--

DROP TABLE IF EXISTS `booking_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_request_id` int(11) DEFAULT NULL,
  `booking_status_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `booking_type_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_by_user_id` int(11) DEFAULT NULL,
  `travel_request_id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `parent_booking_id` int(11) DEFAULT NULL,
  `reject_reason` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bookings_on_booking_request_id` (`booking_request_id`),
  KEY `index_bookings_on_booking_status_id` (`booking_status_id`),
  KEY `index_bookings_on_booking_type_id` (`booking_type_id`),
  CONSTRAINT `fk_rails_39ccaa75d9` FOREIGN KEY (`booking_request_id`) REFERENCES `booking_requests` (`id`),
  CONSTRAINT `fk_rails_b33736b20c` FOREIGN KEY (`booking_status_id`) REFERENCES `booking_statuses` (`id`),
  CONSTRAINT `fk_rails_ce860754b5` FOREIGN KEY (`booking_type_id`) REFERENCES `booking_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branch_locations`
--

DROP TABLE IF EXISTS `branch_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `gstin` varchar(255) DEFAULT NULL,
  `pan` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `address_1` text,
  `address_2` text,
  `city` varchar(255) DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `pin` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `contact_mobile_number` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `location_code` varchar(255) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `nature_of_office` varchar(255) DEFAULT NULL,
  `billable_location` tinyint(1) DEFAULT '1',
  `shippable_location` tinyint(1) DEFAULT '1',
  `gl_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branch_locations_on_company_id` (`company_id`),
  KEY `index_branch_locations_on_state_id` (`state_id`),
  KEY `index_branch_locations_on_ancestry` (`ancestry`),
  CONSTRAINT `fk_rails_55c7060767` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`),
  CONSTRAINT `fk_rails_59ac0819b2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_consumptions`
--

DROP TABLE IF EXISTS `budget_consumptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_consumptions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pending_amount_id` int(11) DEFAULT NULL,
  `committed_amount_id` int(11) DEFAULT NULL,
  `pending_payment_amount_id` int(11) DEFAULT NULL,
  `payment_processing_amount_id` int(11) DEFAULT NULL,
  `paid_amount_id` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `budget_amount_id` int(11) DEFAULT NULL,
  `remaining_amount_id` int(11) DEFAULT NULL,
  `total_consumed_amount_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_consumptions_on_pending_amount_id` (`pending_amount_id`),
  KEY `index_budget_consumptions_on_committed_amount_id` (`committed_amount_id`),
  KEY `index_budget_consumptions_on_pending_payment_amount_id` (`pending_payment_amount_id`),
  KEY `index_budget_consumptions_on_payment_processing_amount_id` (`payment_processing_amount_id`),
  KEY `index_budget_consumptions_on_paid_amount_id` (`paid_amount_id`),
  KEY `index_budget_consumptions_on_budget_id` (`budget_id`),
  KEY `index_budget_consumptions_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_criteria_mappings`
--

DROP TABLE IF EXISTS `budget_criteria_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_criteria_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_id` int(11) DEFAULT NULL,
  `budgetable_id` int(11) DEFAULT NULL,
  `budgetable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_criteria_mappings_on_budget_id` (`budget_id`),
  CONSTRAINT `fk_rails_e2929274e7` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=140 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_date_types`
--

DROP TABLE IF EXISTS `budget_date_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_date_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_group_criteria`
--

DROP TABLE IF EXISTS `budget_group_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_group_criteria` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `budget_group_id` int(11) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `budget_creation_in_progress` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_budget_group_criteria_on_budget_group_id` (`budget_group_id`),
  KEY `index_budget_group_criteria_on_deleted` (`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_group_criteria_mappings`
--

DROP TABLE IF EXISTS `budget_group_criteria_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_group_criteria_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `budget_group_criterium_id` int(11) DEFAULT NULL,
  `budgetable_id` int(11) DEFAULT NULL,
  `budgetable_type` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_group_criteria_mappings_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=206 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_groups`
--

DROP TABLE IF EXISTS `budget_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `period_id` int(11) DEFAULT NULL,
  `purchase_order` tinyint(1) DEFAULT NULL,
  `payment` tinyint(1) DEFAULT NULL,
  `expense` tinyint(1) DEFAULT NULL,
  `purchase_request` tinyint(1) DEFAULT NULL,
  `invoice` tinyint(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `budget_date_type_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `calculated_before_tax_amount` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_budget_groups_on_company_id` (`company_id`),
  KEY `index_budget_groups_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_budget_groups_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_modification_actions`
--

DROP TABLE IF EXISTS `budget_modification_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_modification_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_modification_trails`
--

DROP TABLE IF EXISTS `budget_modification_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_modification_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_id` int(11) DEFAULT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `previous_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `changed_column_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_modification_trails_on_budget_id` (`budget_id`),
  KEY `index_budget_modification_trails_on_action_user_id` (`action_user_id`),
  KEY `index_budget_modification_trails_on_action_id` (`action_id`),
  CONSTRAINT `fk_rails_c7172ecf87` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rule_branch_location_mappings`
--

DROP TABLE IF EXISTS `budget_rule_branch_location_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rule_branch_location_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `budget_rule_id` int(11) NOT NULL,
  `branch_location_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rule_branch_location_mappings_on_budget_rule_id` (`budget_rule_id`),
  KEY `index_budget_rule_branch_location_mappings_on_branch_location_id` (`branch_location_id`),
  CONSTRAINT `fk_rails_4ed4c6fbcf` FOREIGN KEY (`branch_location_id`) REFERENCES `branch_locations` (`id`),
  CONSTRAINT `fk_rails_86592fde31` FOREIGN KEY (`budget_rule_id`) REFERENCES `budget_rules` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rule_category_mappings`
--

DROP TABLE IF EXISTS `budget_rule_category_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rule_category_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_rule_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rule_category_mappings_on_budget_rule_id` (`budget_rule_id`),
  KEY `index_budget_rule_category_mappings_on_category_id` (`category_id`),
  CONSTRAINT `fk_rails_4cf591186a` FOREIGN KEY (`budget_rule_id`) REFERENCES `budget_rules` (`id`),
  CONSTRAINT `fk_rails_fbbe2e697c` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rule_department_mappings`
--

DROP TABLE IF EXISTS `budget_rule_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rule_department_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `budget_rule_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rule_department_mappings_on_budget_rule_id` (`budget_rule_id`),
  KEY `index_budget_rule_department_mappings_on_department_id` (`department_id`),
  CONSTRAINT `fk_rails_1699c65381` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `fk_rails_5125f515e0` FOREIGN KEY (`budget_rule_id`) REFERENCES `budget_rules` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rule_expense_type_mappings`
--

DROP TABLE IF EXISTS `budget_rule_expense_type_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rule_expense_type_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `budget_rule_id` int(11) NOT NULL,
  `expense_type_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rule_expense_type_mappings_on_budget_rule_id` (`budget_rule_id`),
  KEY `index_budget_rule_expense_type_mappings_on_expense_type_id` (`expense_type_id`),
  CONSTRAINT `fk_rails_717d662c58` FOREIGN KEY (`expense_type_id`) REFERENCES `expense_types` (`id`),
  CONSTRAINT `fk_rails_e6ba006118` FOREIGN KEY (`budget_rule_id`) REFERENCES `budget_rules` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rule_field_mappings`
--

DROP TABLE IF EXISTS `budget_rule_field_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rule_field_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_rule_id` int(11) NOT NULL,
  `field_configuration_id` int(11) NOT NULL,
  `field_drop_down_item_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rule_field_mappings_on_budget_rule_id` (`budget_rule_id`),
  KEY `index_budget_rule_field_mappings_on_field_configuration_id` (`field_configuration_id`),
  KEY `index_budget_rule_field_mappings_on_field_drop_down_item_id` (`field_drop_down_item_id`),
  CONSTRAINT `fk_rails_60c2a02b7a` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`),
  CONSTRAINT `fk_rails_62e7afb358` FOREIGN KEY (`budget_rule_id`) REFERENCES `budget_rules` (`id`),
  CONSTRAINT `fk_rails_d50ca91e7a` FOREIGN KEY (`field_drop_down_item_id`) REFERENCES `field_drop_down_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_rules`
--

DROP TABLE IF EXISTS `budget_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rule_type_id` int(11) DEFAULT NULL,
  `include_reimbursable` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `expense_type_id` int(11) DEFAULT NULL,
  `with_receipt_amount_id` int(11) DEFAULT NULL,
  `without_receipt_amount_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_rules_on_category_id` (`category_id`),
  KEY `index_budget_rules_on_amount_id` (`amount_id`),
  KEY `index_budget_rules_on_period_id` (`period_id`),
  KEY `index_budget_rules_on_policy_id` (`policy_id`),
  KEY `index_budget_rules_on_rule_type_id` (`rule_type_id`),
  CONSTRAINT `fk_rails_08557d26f5` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_0d68b59e66` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`),
  CONSTRAINT `fk_rails_0db9a7dd09` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_414b521a3d` FOREIGN KEY (`rule_type_id`) REFERENCES `rule_types` (`id`),
  CONSTRAINT `fk_rails_6f4d4efe4c` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budget_trails`
--

DROP TABLE IF EXISTS `budget_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) DEFAULT NULL,
  `entity_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `entity_date` date DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `spent_amount_id` int(11) DEFAULT NULL,
  `committed_amount_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `payment_processing_amount_before_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `payment_processing_amount_after_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `tds_value` decimal(20,10) DEFAULT '0.0000000000',
  `billed` tinyint(1) DEFAULT '0',
  `entity_status_id` int(11) DEFAULT NULL,
  `reimbursable` tinyint(1) DEFAULT '0',
  `amount_before_tax_id` int(11) DEFAULT NULL,
  `amount_after_tax_id` int(11) DEFAULT NULL,
  `entity_created_at` datetime DEFAULT NULL,
  `entity_submitted_at` datetime DEFAULT NULL,
  `purchase_order_id` int(11) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `payment_purpose_id` int(11) DEFAULT NULL,
  `po_trail_item_id` int(11) DEFAULT NULL,
  `billed_amount_before_tax_value` decimal(20,10) DEFAULT NULL,
  `billed_amount_after_tax_value` decimal(20,10) DEFAULT NULL,
  `remaining_amount_before_tax_value` decimal(20,10) DEFAULT NULL,
  `remaining_amount_after_tax_value` decimal(20,10) DEFAULT NULL,
  `effective_paid_amount_before_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `paid_amount_after_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `billed_quantity` int(11) DEFAULT NULL,
  `billed_rate` decimal(20,10) DEFAULT NULL,
  `remaining_quantity` int(11) DEFAULT NULL,
  `revised` tinyint(1) DEFAULT '0',
  `payment_confirmed` tinyint(1) DEFAULT '0',
  `tax_amount_value` decimal(20,10) DEFAULT '0.0000000000',
  `net_paid_amount_before_tax_value` decimal(20,10) DEFAULT NULL,
  `rcm_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `paid_tds_value` decimal(20,10) DEFAULT '0.0000000000',
  `processing_tds_value` decimal(20,0) DEFAULT '0',
  `cn_adjusted_amount_before_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `cn_adjusted_amount_after_tax_value` decimal(20,10) DEFAULT '0.0000000000',
  `credit_note_tax_amount_value` decimal(20,10) DEFAULT '0.0000000000',
  `date` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budget_trails_on_entity_type_and_entity_id` (`entity_type`,`entity_id`),
  KEY `index_budget_trails_on_category_id` (`category_id`),
  KEY `index_budget_trails_on_cost_center_id` (`cost_center_id`),
  KEY `index_budget_trails_on_location_id` (`location_id`),
  KEY `index_budget_trails_on_vendor_id` (`vendor_id`),
  KEY `index_budget_trails_on_amount_id` (`amount_id`),
  KEY `index_budget_trails_on_user_id` (`user_id`),
  KEY `index_budget_trails_on_department_id` (`department_id`),
  KEY `index_budget_trails_on_entity_date` (`entity_date`),
  KEY `index_budget_trails_on_sub_department_id` (`sub_department_id`),
  KEY `index_budget_trails_on_procurement_id` (`procurement_id`),
  KEY `index_budget_trails_on_deleted_at` (`deleted_at`),
  KEY `idx_budget_trails_on_pmt_processing_amt_b4_tax_value` (`payment_processing_amount_before_tax_value`),
  KEY `idx_budget_trails_on_pmt_processing_amt_aftr_tax_value` (`payment_processing_amount_after_tax_value`),
  KEY `index_budget_trails_on_tds_value` (`tds_value`),
  KEY `index_budget_trails_on_billed` (`billed`),
  KEY `index_budget_trails_on_entity_status_id` (`entity_status_id`),
  KEY `index_budget_trails_on_reimbursable` (`reimbursable`),
  KEY `index_budget_trails_on_amount_before_tax_id` (`amount_before_tax_id`),
  KEY `index_budget_trails_on_amount_after_tax_id` (`amount_after_tax_id`),
  KEY `index_budget_trails_on_entity_created_at` (`entity_created_at`),
  KEY `index_budget_trails_on_entity_submitted_at` (`entity_submitted_at`),
  KEY `index_budget_trails_on_purchase_order_id` (`purchase_order_id`),
  KEY `index_budget_trails_on_invoice_id` (`invoice_id`),
  KEY `index_budget_trails_on_payment_purpose_id` (`payment_purpose_id`),
  KEY `index_budget_trails_on_po_trail_item_id` (`po_trail_item_id`),
  KEY `index_budget_trails_on_billed_amount_before_tax_value` (`billed_amount_before_tax_value`),
  KEY `index_budget_trails_on_billed_amount_after_tax_value` (`billed_amount_after_tax_value`),
  KEY `index_budget_trails_on_remaining_amount_before_tax_value` (`remaining_amount_before_tax_value`),
  KEY `index_budget_trails_on_remaining_amount_after_tax_value` (`remaining_amount_after_tax_value`),
  KEY `index_budget_trails_on_effective_paid_amount_before_tax_value` (`effective_paid_amount_before_tax_value`),
  KEY `index_budget_trails_on_paid_amount_after_tax_value` (`paid_amount_after_tax_value`),
  KEY `index_budget_trails_on_billed_quantity` (`billed_quantity`),
  KEY `index_budget_trails_on_billed_rate` (`billed_rate`),
  KEY `index_budget_trails_on_remaining_quantity` (`remaining_quantity`),
  KEY `index_budget_trails_on_revised` (`revised`),
  KEY `index_budget_trails_on_payment_confirmed` (`payment_confirmed`),
  KEY `index_budget_trails_on_tax_amount_value` (`tax_amount_value`),
  KEY `index_budget_trails_on_net_paid_amount_before_tax_value` (`net_paid_amount_before_tax_value`),
  KEY `index_budget_trails_on_rcm_tax_value` (`rcm_tax_value`),
  KEY `index_budget_trails_on_paid_tds_value` (`paid_tds_value`),
  KEY `index_budget_trails_on_processing_tds_value` (`processing_tds_value`),
  KEY `index_budget_trails_on_cn_adjusted_amount_before_tax_value` (`cn_adjusted_amount_before_tax_value`),
  KEY `index_budget_trails_on_cn_adjusted_amount_after_tax_value` (`cn_adjusted_amount_after_tax_value`),
  KEY `index_budget_trails_on_credit_note_tax_amount_value` (`credit_note_tax_amount_value`),
  KEY `index_budget_trails_on_date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=4278 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `budgets`
--

DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `budget_amount_id` int(11) DEFAULT NULL,
  `spent_amount_id` int(11) DEFAULT NULL,
  `budgetable_id` int(11) DEFAULT NULL,
  `budgetable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `purchase_order` tinyint(1) DEFAULT NULL,
  `payment` tinyint(1) DEFAULT NULL,
  `expense` tinyint(1) DEFAULT NULL,
  `ancestry` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `budget_group_id` int(11) DEFAULT NULL,
  `calculated_before_tax_amount` tinyint(1) DEFAULT '0',
  `purchase_request` tinyint(1) DEFAULT NULL,
  `invoice` tinyint(1) DEFAULT NULL,
  `budget_group_criterium_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `budget_date_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_budgets_on_period_id` (`period_id`),
  KEY `index_budgets_on_budget_amount_id` (`budget_amount_id`),
  KEY `index_budgets_on_spent_amount_id` (`spent_amount_id`),
  KEY `index_budgets_on_budgetable_type_and_budgetable_id` (`budgetable_type`,`budgetable_id`),
  KEY `index_budgets_on_user_id` (`user_id`),
  KEY `index_budgets_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_c3899b65d4` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`),
  CONSTRAINT `fk_rails_e502a129d7` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_e708f32fd8` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=197 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `callback_tracks`
--

DROP TABLE IF EXISTS `callback_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `callback_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `request` text COLLATE utf8_unicode_ci,
  `response` mediumtext COLLATE utf8_unicode_ci,
  `entity_id` int(11) DEFAULT NULL,
  `entity_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `success` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_callback_tracks_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_a14abc583b` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_assign_request_statuses`
--

DROP TABLE IF EXISTS `card_assign_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_assign_request_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_assign_request_track_actions`
--

DROP TABLE IF EXISTS `card_assign_request_track_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_assign_request_track_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_assign_request_tracks`
--

DROP TABLE IF EXISTS `card_assign_request_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_assign_request_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_assign_request_id` int(11) NOT NULL,
  `action_resource_id` int(11) DEFAULT NULL,
  `action_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_id` int(11) NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_assign_request_tracks_on_card_assign_request_id` (`card_assign_request_id`),
  KEY `index_card_assign_request_tracks_on_action_resource_id` (`action_resource_id`),
  KEY `index_card_assign_request_tracks_on_action_resource_type` (`action_resource_type`),
  KEY `index_card_assign_request_tracks_on_action_id` (`action_id`),
  CONSTRAINT `fk_rails_1ba4224b66` FOREIGN KEY (`card_assign_request_id`) REFERENCES `card_assign_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_assign_requests`
--

DROP TABLE IF EXISTS `card_assign_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_assign_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) DEFAULT NULL,
  `card_owner_id` int(11) NOT NULL,
  `initiating_resource_id` int(11) NOT NULL,
  `initiating_resource_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `status_id` int(11) NOT NULL,
  `assigned_by_resource_id` int(11) DEFAULT NULL,
  `assigned_by_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `assigned_on` datetime DEFAULT NULL,
  `card_program_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `admin_review_workflow_id` int(11) DEFAULT NULL,
  `review_position` int(11) DEFAULT '0',
  `admin_note` text COLLATE utf8_unicode_ci,
  `company_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_assign_requests_on_card_id` (`card_id`),
  KEY `index_card_assign_requests_on_card_owner_id` (`card_owner_id`),
  KEY `index_card_assign_requests_on_initiating_resource_id` (`initiating_resource_id`),
  KEY `index_card_assign_requests_on_initiating_resource_type` (`initiating_resource_type`),
  KEY `index_card_assign_requests_on_status_id` (`status_id`),
  KEY `index_card_assign_requests_on_assigned_by_resource_id` (`assigned_by_resource_id`),
  KEY `index_card_assign_requests_on_assigned_by_resource_type` (`assigned_by_resource_type`),
  KEY `index_card_assign_requests_on_card_program_id` (`card_program_id`),
  KEY `index_card_assign_requests_on_admin_review_workflow_id` (`admin_review_workflow_id`),
  KEY `index_card_assign_requests_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_2793066f0c` FOREIGN KEY (`card_program_id`) REFERENCES `card_programs` (`id`),
  CONSTRAINT `fk_rails_2d50d4d2c4` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`),
  CONSTRAINT `fk_rails_546057f5cc` FOREIGN KEY (`admin_review_workflow_id`) REFERENCES `admin_review_workflows` (`id`),
  CONSTRAINT `fk_rails_d36a0bef78` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_balance_histories`
--

DROP TABLE IF EXISTS `card_balance_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_balance_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_balance_histories_on_card_id` (`card_id`),
  KEY `index_card_balance_histories_on_amount_id` (`amount_id`),
  CONSTRAINT `fk_rails_25d79e670e` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`),
  CONSTRAINT `fk_rails_9e6196e54f` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_configurations`
--

DROP TABLE IF EXISTS `card_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prepaid_card_id` int(11) DEFAULT NULL,
  `configured_by_user_id` int(11) DEFAULT NULL,
  `card_status_id` int(11) DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_configurations_on_prepaid_card_id` (`prepaid_card_id`),
  KEY `index_card_configurations_on_configured_by_user_id` (`configured_by_user_id`),
  KEY `index_card_configurations_on_card_status_id` (`card_status_id`),
  CONSTRAINT `fk_rails_581c387a5b` FOREIGN KEY (`card_status_id`) REFERENCES `card_statuses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_expense_configs`
--

DROP TABLE IF EXISTS `card_expense_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_expense_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) DEFAULT '1',
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_expense_configs_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_3e5a419cf0` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_expenses`
--

DROP TABLE IF EXISTS `card_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `editable_merchant` text COLLATE utf8_unicode_ci,
  `card_transaction_id` int(11) DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `surcharge_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `cancelled` tinyint(1) DEFAULT '0',
  `atm_surcharge` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_expenses_on_card_transaction_id` (`card_transaction_id`),
  KEY `index_card_expenses_on_expense_id` (`expense_id`),
  CONSTRAINT `fk_rails_12c72528cd` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`),
  CONSTRAINT `fk_rails_44ce8edcf5` FOREIGN KEY (`card_transaction_id`) REFERENCES `card_transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_fund_transactions`
--

DROP TABLE IF EXISTS `card_fund_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_fund_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `response` text COLLATE utf8_unicode_ci NOT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `requesting_user` int(11) NOT NULL,
  `for_user` int(11) NOT NULL,
  `post_params` text COLLATE utf8_unicode_ci NOT NULL,
  `post_url` text COLLATE utf8_unicode_ci NOT NULL,
  `amount_value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_fund_transactions_on_requesting_user` (`requesting_user`),
  KEY `index_card_fund_transactions_on_for_user` (`for_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_limits`
--

DROP TABLE IF EXISTS `card_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_restriction_id` int(11) DEFAULT NULL,
  `transactions` int(11) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `budget` decimal(10,0) DEFAULT NULL,
  `limit_type_id` int(11) DEFAULT NULL,
  `allowed` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_limits_on_card_restriction_id` (`card_restriction_id`),
  KEY `index_card_limits_on_period_id` (`period_id`),
  CONSTRAINT `fk_rails_a62e97096e` FOREIGN KEY (`card_restriction_id`) REFERENCES `card_restrictions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_programs`
--

DROP TABLE IF EXISTS `card_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `create_expense` tinyint(1) DEFAULT NULL,
  `receive_reimbursement` tinyint(1) DEFAULT NULL,
  `personal_wallet_fund_transfer` tinyint(1) DEFAULT NULL,
  `spend_restrictions` tinyint(1) DEFAULT NULL,
  `end_date_restrictions` tinyint(1) DEFAULT NULL,
  `manager_credit` tinyint(1) DEFAULT NULL,
  `manager_debit` tinyint(1) DEFAULT NULL,
  `manager_blockable` tinyint(1) DEFAULT NULL,
  `manager_view_balance` tinyint(1) DEFAULT NULL,
  `manager_view_eligibility` tinyint(1) DEFAULT NULL,
  `manager_view_transactions` tinyint(1) DEFAULT NULL,
  `non_personal_fund_transfer` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_request_statuses`
--

DROP TABLE IF EXISTS `card_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_request_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_restrictions`
--

DROP TABLE IF EXISTS `card_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_restrictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) DEFAULT NULL,
  `channel_atm` tinyint(1) DEFAULT NULL,
  `channel_pos` tinyint(1) DEFAULT NULL,
  `channel_online` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `channel_ecom_pos` tinyint(1) DEFAULT NULL,
  `mcc_group_id` int(11) DEFAULT NULL,
  `mcc_restriction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_restrictions_on_card_id` (`card_id`),
  CONSTRAINT `fk_rails_558e442e98` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_statuses`
--

DROP TABLE IF EXISTS `card_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_transactions`
--

DROP TABLE IF EXISTS `card_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `card_id` int(11) DEFAULT NULL,
  `merchant_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `post_data` text COLLATE utf8_unicode_ci,
  `transaction_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `auth_transaction_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `itzcash_merchant_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `merchant_city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `response_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `serial_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_timestamp` datetime DEFAULT NULL,
  `expensed` tinyint(1) DEFAULT '0',
  `error_message` text COLLATE utf8_unicode_ci,
  `billing_amount_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `mcc_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `api_reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cancelled` tinyint(1) DEFAULT '0',
  `cancelled_against_expense_id` int(11) DEFAULT NULL,
  `type_of_details` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `success` tinyint(1) DEFAULT NULL,
  `acquirer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_message` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_transactions_on_user_id` (`user_id`),
  KEY `index_card_transactions_on_card_id` (`card_id`),
  KEY `index_card_transactions_on_transaction_amount_id` (`transaction_amount_id`),
  CONSTRAINT `fk_rails_31c51d51a4` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`),
  CONSTRAINT `fk_rails_f1f6a75d66` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=494 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `card_types`
--

DROP TABLE IF EXISTS `card_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `ending_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `proxy` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `card_type_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) NOT NULL,
  `disabled_by_role_id` int(11) DEFAULT NULL,
  `disabled_by_user_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `disable_note` text COLLATE utf8_unicode_ci,
  `card_balance_id` int(11) DEFAULT NULL,
  `card_program_id` int(11) DEFAULT NULL,
  `card_eligibility_id` int(11) DEFAULT NULL,
  `admin_unblockable` tinyint(1) DEFAULT '1',
  `itz_cash_card_program_id` int(11) DEFAULT NULL,
  `card_status_id` int(11) NOT NULL,
  `hotlisted` tinyint(1) DEFAULT '0',
  `card_processor_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `replaced_card_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cards_on_user_id` (`user_id`),
  KEY `index_cards_on_card_type_id` (`card_type_id`),
  KEY `index_cards_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_31e9cb1159` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_8ef7749967` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f6a0ddd0ab` FOREIGN KEY (`card_type_id`) REFERENCES `card_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cash_expense_configs`
--

DROP TABLE IF EXISTS `cash_expense_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_expense_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) DEFAULT '1',
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cash_expense_configs_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_f89b0366c6` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cash_on_hands`
--

DROP TABLE IF EXISTS `cash_on_hands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_on_hands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cash_on_hands_on_user_id` (`user_id`),
  KEY `index_cash_on_hands_on_balance_id` (`balance_id`),
  CONSTRAINT `fk_rails_61a1d82277` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `gl_code` varchar(255) DEFAULT NULL,
  `payroll_code` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `expense_management` tinyint(1) DEFAULT NULL,
  `vendor_payments` tinyint(1) DEFAULT NULL,
  `outward_invoices` tinyint(1) DEFAULT NULL,
  `inward_invoice_line_items` tinyint(1) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `outward_invoice_line_items` tinyint(1) DEFAULT NULL,
  `category_code` varchar(255) DEFAULT NULL,
  `gst_applicable` tinyint(1) DEFAULT '0',
  `tds_applicable` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_categories_on_company_id` (`company_id`),
  KEY `index_categories_on_ancestry` (`ancestry`),
  KEY `index_categories_on_name` (`name`),
  KEY `index_categories_on_active` (`active`),
  CONSTRAINT `fk_rails_5740af41d8` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_department_mappings`
--

DROP TABLE IF EXISTS `category_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_department_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_department_mappings_on_category_id` (`category_id`),
  KEY `index_category_department_mappings_on_location_id` (`location_id`),
  KEY `index_category_department_mappings_on_department_id` (`department_id`),
  CONSTRAINT `fk_rails_62cec35ddb` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_designation_mappings`
--

DROP TABLE IF EXISTS `category_designation_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_designation_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `designation_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_designation_mappings_on_category_id` (`category_id`),
  KEY `index_category_designation_mappings_on_designation_id` (`designation_id`),
  CONSTRAINT `fk_rails_5ae9a603aa` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_location_mappings`
--

DROP TABLE IF EXISTS `category_location_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_location_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_location_mappings_on_category_id` (`category_id`),
  KEY `index_category_location_mappings_on_location_id` (`location_id`),
  CONSTRAINT `fk_rails_ad7b6880d5` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_rails_db86dbadaa` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `channel_types`
--

DROP TABLE IF EXISTS `channel_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channel_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `city_id_city_code_mappings`
--

DROP TABLE IF EXISTS `city_id_city_code_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `city_id_city_code_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8349 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collect_company_details`
--

DROP TABLE IF EXISTS `collect_company_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collect_company_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gst` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `company_logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_logo_file_size` int(11) DEFAULT NULL,
  `company_logo_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `address` text COLLATE utf8_unicode_ci,
  `pin` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_collect_company_details_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_8c87e86b70` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collect_transaction_purposes`
--

DROP TABLE IF EXISTS `collect_transaction_purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collect_transaction_purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collect_transaction_virtual_account_mappings`
--

DROP TABLE IF EXISTS `collect_transaction_virtual_account_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collect_transaction_virtual_account_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `virtual_account_id` int(11) DEFAULT NULL,
  `transaction_purpose_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `companies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `base_currency_id` int(11) DEFAULT '1',
  `status_id` int(11) NOT NULL DEFAULT '1',
  `test_account` tinyint(1) DEFAULT '0',
  `subdomain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `reporting_currency_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'INR',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_account_types`
--

DROP TABLE IF EXISTS `company_account_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_account_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_accounts`
--

DROP TABLE IF EXISTS `company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `wallet_balance_id` int(11) DEFAULT NULL,
  `company` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_account_type_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_accounts_on_company_id` (`company_id`),
  KEY `index_company_accounts_on_wallet_balance_id` (`wallet_balance_id`),
  KEY `index_company_accounts_on_company` (`company`),
  KEY `index_company_accounts_on_company_account_type_id` (`company_account_type_id`),
  CONSTRAINT `fk_rails_10bbe6f530` FOREIGN KEY (`company_account_type_id`) REFERENCES `company_account_types` (`id`),
  CONSTRAINT `fk_rails_f9fca01a1d` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_agreement_tracks`
--

DROP TABLE IF EXISTS `company_agreement_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_agreement_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `agreement_id` int(11) NOT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referrer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_agreement_tracks_on_user_id` (`user_id`),
  KEY `index_company_agreement_tracks_on_agreement_id` (`agreement_id`),
  CONSTRAINT `fk_rails_2c5a6677d0` FOREIGN KEY (`agreement_id`) REFERENCES `agreements` (`id`),
  CONSTRAINT `fk_rails_42be28985c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_balance_histories`
--

DROP TABLE IF EXISTS `company_balance_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_balance_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `neft_transfer_id` int(11) DEFAULT NULL,
  `company_balance_id` int(11) DEFAULT NULL,
  `company_withdrawal_to_card_id` int(11) DEFAULT NULL,
  `company_load_from_card_id` int(11) DEFAULT NULL,
  `card_load_from_wallet_id` int(11) DEFAULT NULL,
  `card_withdrawal_to_wallet_id` int(11) DEFAULT NULL,
  `card_balance_id` int(11) DEFAULT NULL,
  `card_expenses_id` int(11) DEFAULT NULL,
  `wallet_load_from_wallet_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `card_atm_withdrawal_id` int(11) DEFAULT NULL,
  `company_withdrawal_to_wallet_id` int(11) DEFAULT NULL,
  `company_load_from_wallet_id` int(11) DEFAULT NULL,
  `card_withdrawal_to_card_id` int(11) DEFAULT NULL,
  `card_withdrawal_to_virtual_account_id` int(11) DEFAULT NULL,
  `card_load_from_card_id` int(11) DEFAULT NULL,
  `card_load_from_virtual_account_id` int(11) DEFAULT NULL,
  `wallet_withdrawal_to_wallet_id` int(11) DEFAULT NULL,
  `wallet_withdrawal_to_card_id` int(11) DEFAULT NULL,
  `wallet_withdrawal_to_virtual_account_id` int(11) DEFAULT NULL,
  `wallet_load_from_card_id` int(11) DEFAULT NULL,
  `wallet_load_from_virtual_account_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `wallet_balance_id` int(11) DEFAULT NULL,
  `cash_on_hand_load_id` int(11) DEFAULT NULL,
  `cash_on_hand_withdrawal_id` int(11) DEFAULT NULL,
  `cash_on_hand_balance_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_balance_histories_on_company_id` (`company_id`),
  KEY `index_company_balance_histories_on_neft_transfer_id` (`neft_transfer_id`),
  KEY `index_company_balance_histories_on_company_balance_id` (`company_balance_id`),
  KEY `index_company_balance_histories_on_company_withdrawal_to_card_id` (`company_withdrawal_to_card_id`),
  KEY `index_company_balance_histories_on_company_load_from_card_id` (`company_load_from_card_id`),
  KEY `index_company_balance_histories_on_card_load_from_wallet_id` (`card_load_from_wallet_id`),
  KEY `index_company_balance_histories_on_card_withdrawal_to_wallet_id` (`card_withdrawal_to_wallet_id`),
  KEY `index_company_balance_histories_on_card_balance_id` (`card_balance_id`),
  KEY `index_company_balance_histories_on_card_expenses_id` (`card_expenses_id`),
  KEY `index_company_balance_histories_on_wallet_load_from_wallet_id` (`wallet_load_from_wallet_id`),
  KEY `index_wal_2_wal_on_company_history` (`wallet_withdrawal_to_wallet_id`),
  KEY `index_wal_2_card_on_company_history` (`wallet_withdrawal_to_card_id`),
  KEY `index_wal_2_va_on_company_history` (`wallet_withdrawal_to_virtual_account_id`),
  KEY `index_wal_load_on_company_history` (`wallet_load_from_virtual_account_id`),
  CONSTRAINT `fk_rails_9fbb204cdf` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_branches`
--

DROP TABLE IF EXISTS `company_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_branches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collect_company_detail_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gst` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `address_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pin` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_branches_on_collect_company_detail_id` (`collect_company_detail_id`),
  KEY `index_company_branches_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_3bf96108ed` FOREIGN KEY (`collect_company_detail_id`) REFERENCES `collect_company_details` (`id`),
  CONSTRAINT `fk_rails_9e51ae5a43` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_configurations`
--

DROP TABLE IF EXISTS `company_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `contact_id` int(11) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT '0',
  `logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `other_expense_types` tinyint(1) DEFAULT '0',
  `encrypted_easy_login_params` text COLLATE utf8_unicode_ci,
  `registered_mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_card_expense_category_id` int(11) DEFAULT NULL,
  `sso_enabled` tinyint(1) DEFAULT '0',
  `address` text COLLATE utf8_unicode_ci,
  `cash_money_requests_enabled` tinyint(1) DEFAULT '1',
  `auto_retry_payment` tinyint(1) DEFAULT '0',
  `legal_entity_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `show_custom_fields_in_pdf` tinyint(1) DEFAULT '1',
  `show_po_approved_trail` tinyint(1) DEFAULT '0',
  `email_purchase_order_initiator` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_configurations_on_company_id` (`company_id`),
  KEY `index_company_configurations_on_contact_id` (`contact_id`),
  CONSTRAINT `fk_rails_20e42dca84` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_c48acfca16` FOREIGN KEY (`contact_id`) REFERENCES `contacts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_departments`
--

DROP TABLE IF EXISTS `company_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company_id` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_by_user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_departments_on_name` (`name`),
  KEY `index_company_departments_on_company_id` (`company_id`),
  KEY `index_company_departments_on_active` (`active`),
  KEY `index_company_departments_on_is_deleted` (`is_deleted`),
  KEY `index_company_departments_on_created_by_user_id` (`created_by_user_id`),
  CONSTRAINT `fk_rails_19923fb85f` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_funds_auto_transfer_configs`
--

DROP TABLE IF EXISTS `company_funds_auto_transfer_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_funds_auto_transfer_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `threshold_amount_id` int(11) DEFAULT NULL,
  `frequency_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `frequency_day` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_transfer_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `transfer_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_funds_auto_transfer_configs_on_company_id` (`company_id`),
  KEY `index_company_funds_auto_transfer_configs_on_threshold_amount_id` (`threshold_amount_id`),
  CONSTRAINT `fk_rails_8dde994306` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_funds_load_request_types`
--

DROP TABLE IF EXISTS `company_funds_load_request_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_funds_load_request_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_funds_load_requests`
--

DROP TABLE IF EXISTS `company_funds_load_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_funds_load_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `requested_by_user_id` int(11) NOT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `remark` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bank_type_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_funds_load_requests_on_company_id` (`company_id`),
  KEY `index_company_funds_load_requests_on_requested_by_user_id` (`requested_by_user_id`),
  KEY `index_company_funds_load_requests_on_amount_id` (`amount_id`),
  KEY `index_company_funds_load_requests_on_bank_type_id` (`bank_type_id`),
  CONSTRAINT `fk_rails_13fb9447e6` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_b65700de0c` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_groups`
--

DROP TABLE IF EXISTS `company_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `default_company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `subdomain` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_kyc_document_types`
--

DROP TABLE IF EXISTS `company_kyc_document_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_kyc_document_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `identifier` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_kyc_trail_actions`
--

DROP TABLE IF EXISTS `company_kyc_trail_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_kyc_trail_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_kyc_trails`
--

DROP TABLE IF EXISTS `company_kyc_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_kyc_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_kyc_id` int(11) DEFAULT NULL,
  `action_resource_id` int(11) DEFAULT NULL,
  `action_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_kyc_trails_on_company_kyc_id` (`company_kyc_id`),
  CONSTRAINT `fk_rails_95047c7840` FOREIGN KEY (`company_kyc_id`) REFERENCES `company_kycs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_kycs`
--

DROP TABLE IF EXISTS `company_kycs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_kycs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pan_card_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan_card_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan_card_file_size` int(11) DEFAULT NULL,
  `pan_card_updated_at` datetime DEFAULT NULL,
  `coi_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `coi_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `coi_file_size` int(11) DEFAULT NULL,
  `coi_updated_at` datetime DEFAULT NULL,
  `board_resolution_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `board_resolution_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `board_resolution_file_size` int(11) DEFAULT NULL,
  `board_resolution_updated_at` datetime DEFAULT NULL,
  `kyc_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `date_of_establishment` date DEFAULT NULL,
  `street_2` text COLLATE utf8_unicode_ci,
  `street_3` text COLLATE utf8_unicode_ci,
  `registered_mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan_card_no` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pin_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_card_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_card_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_card_file_size` int(11) DEFAULT NULL,
  `aadhar_card_updated_at` datetime DEFAULT NULL,
  `vat_registration_certificate_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vat_registration_certificate_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vat_registration_certificate_file_size` int(11) DEFAULT NULL,
  `vat_registration_certificate_updated_at` datetime DEFAULT NULL,
  `registration_of_trust_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_of_trust_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_of_trust_file_size` int(11) DEFAULT NULL,
  `registration_of_trust_updated_at` datetime DEFAULT NULL,
  `driving_licence_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `driving_licence_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `driving_licence_file_size` int(11) DEFAULT NULL,
  `driving_licence_updated_at` datetime DEFAULT NULL,
  `passport_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `passport_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `passport_file_size` int(11) DEFAULT NULL,
  `passport_updated_at` datetime DEFAULT NULL,
  `company_type_id` int(11) DEFAULT NULL,
  `certificate_of_registration_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `certificate_of_registration_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `certificate_of_registration_file_size` int(11) DEFAULT NULL,
  `certificate_of_registration_updated_at` datetime DEFAULT NULL,
  `customer_type_id` int(11) DEFAULT NULL,
  `user_confirmed` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_kycs_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_3fe9dbae11` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_location_departments`
--

DROP TABLE IF EXISTS `company_location_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_location_departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_location_id` int(11) NOT NULL,
  `company_department_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_location_departments_on_branch_location_id` (`branch_location_id`),
  KEY `index_company_location_departments_on_company_department_id` (`company_department_id`),
  CONSTRAINT `fk_rails_0c7c17f160` FOREIGN KEY (`branch_location_id`) REFERENCES `branch_locations` (`id`),
  CONSTRAINT `fk_rails_7a3fe644a4` FOREIGN KEY (`company_department_id`) REFERENCES `company_departments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_pocket_templates`
--

DROP TABLE IF EXISTS `company_pocket_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_pocket_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `user_pocket_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_pocket_templates_on_company_id` (`company_id`),
  KEY `index_company_pocket_templates_on_user_pocket_type_id` (`user_pocket_type_id`),
  CONSTRAINT `fk_rails_5adc3b6576` FOREIGN KEY (`user_pocket_type_id`) REFERENCES `user_pocket_types` (`id`),
  CONSTRAINT `fk_rails_db7beb608b` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_statuses`
--

DROP TABLE IF EXISTS `company_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_tags`
--

DROP TABLE IF EXISTS `company_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `gl_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_tags_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_889ae7e543` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_transactions`
--

DROP TABLE IF EXISTS `company_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `request_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `merchant_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_date` datetime NOT NULL,
  `transaction_amount_id` int(11) NOT NULL,
  `transaction_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `balance_amount_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `transaction_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `merchant_type_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_transactions_on_company_id` (`company_id`),
  KEY `index_company_transactions_on_transaction_amount_id` (`transaction_amount_id`),
  KEY `index_company_transactions_on_balance_amount_id` (`balance_amount_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2523 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_types`
--

DROP TABLE IF EXISTS `company_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contactable_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `designation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_allocation_items`
--

DROP TABLE IF EXISTS `cost_allocation_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_allocation_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cost_allocation_id` int(11) DEFAULT NULL,
  `percentage` decimal(10,5) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cost_allocation_items_on_cost_allocation_id` (`cost_allocation_id`),
  KEY `index_cost_allocation_items_on_department_id` (`department_id`),
  KEY `index_cost_allocation_items_on_cost_center_id` (`cost_center_id`),
  KEY `index_cost_allocation_items_on_sub_department_id` (`sub_department_id`),
  CONSTRAINT `fk_rails_7189d3d4a6` FOREIGN KEY (`cost_allocation_id`) REFERENCES `cost_allocations` (`id`),
  CONSTRAINT `fk_rails_8b89ab40ab` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `fk_rails_d57e0f85fe` FOREIGN KEY (`cost_center_id`) REFERENCES `cost_centers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_allocation_types`
--

DROP TABLE IF EXISTS `cost_allocation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_allocation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_allocations`
--

DROP TABLE IF EXISTS `cost_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_allocations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `procurement_id` int(11) DEFAULT NULL,
  `cost_allocation_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cost_allocations_on_procurement_id` (`procurement_id`),
  KEY `index_cost_allocations_on_cost_allocation_type_id` (`cost_allocation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_centers`
--

DROP TABLE IF EXISTS `cost_centers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `cost_center_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ancestry` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `gl_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cost_centers_on_company_id` (`company_id`),
  KEY `index_cost_centers_on_ancestry` (`ancestry`),
  CONSTRAINT `fk_rails_e882abfc91` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_note_adjustments`
--

DROP TABLE IF EXISTS `credit_note_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_note_adjustments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) DEFAULT NULL,
  `credit_note_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_credit_note_adjustments_on_invoice_id` (`invoice_id`),
  KEY `index_credit_note_adjustments_on_credit_note_id` (`credit_note_id`),
  KEY `index_credit_note_adjustments_on_amount_id` (`amount_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_note_item_types`
--

DROP TABLE IF EXISTS `credit_note_item_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_note_item_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_note_items`
--

DROP TABLE IF EXISTS `credit_note_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_note_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_note_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `invoice_item_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `credit_note_item_type_id` int(11) DEFAULT NULL,
  `comment` text,
  `gl_code` varchar(255) DEFAULT NULL,
  `hsn_sac` varchar(255) DEFAULT NULL,
  `original_quantity` decimal(20,5) DEFAULT NULL,
  `revised_quantity` decimal(20,5) DEFAULT NULL,
  `quantity` decimal(20,5) DEFAULT NULL,
  `original_rate` decimal(20,5) DEFAULT NULL,
  `revised_rate` decimal(20,5) DEFAULT NULL,
  `rate` decimal(20,5) DEFAULT NULL,
  `original_taxable_amount_id` int(11) DEFAULT NULL,
  `revised_taxable_amount_id` int(11) DEFAULT NULL,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `original_tax_rate_id` int(11) DEFAULT NULL,
  `revised_tax_rate_id` int(11) DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `tds_applicable` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_credit_note_items_on_credit_note_id` (`credit_note_id`),
  KEY `index_credit_note_items_on_item_id` (`item_id`),
  KEY `index_credit_note_items_on_invoice_item_id` (`invoice_item_id`),
  KEY `index_credit_note_items_on_category_id` (`category_id`),
  KEY `index_credit_note_items_on_credit_note_item_type_id` (`credit_note_item_type_id`),
  KEY `index_credit_note_items_on_original_taxable_amount_id` (`original_taxable_amount_id`),
  KEY `index_credit_note_items_on_revised_taxable_amount_id` (`revised_taxable_amount_id`),
  KEY `index_credit_note_items_on_taxable_amount_id` (`taxable_amount_id`),
  KEY `index_credit_note_items_on_original_tax_rate_id` (`original_tax_rate_id`),
  KEY `index_credit_note_items_on_revised_tax_rate_id` (`revised_tax_rate_id`),
  KEY `index_credit_note_items_on_tax_rate_id` (`tax_rate_id`),
  KEY `index_credit_note_items_on_total_amount_id` (`total_amount_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_note_statuses`
--

DROP TABLE IF EXISTS `credit_note_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_note_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_notes`
--

DROP TABLE IF EXISTS `credit_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_notes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `shipping_location_id` int(11) DEFAULT NULL,
  `billing_location_id` int(11) DEFAULT NULL,
  `sequence_id` varchar(255) DEFAULT NULL,
  `credit_note_date` date DEFAULT NULL,
  `narration` text,
  `billing_address` text,
  `shipping_address` text,
  `gross_receivable_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `net_receivable_amount_id` int(11) DEFAULT NULL,
  `tds_rate_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `freight_amount_id` int(11) DEFAULT NULL,
  `previously_adjusted_amount_id` int(11) DEFAULT NULL,
  `net_adjustable_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `roundoff_amount_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `credit_note_number` varchar(255) DEFAULT NULL,
  `last_adjusted_at` datetime DEFAULT NULL,
  `review_note` text,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text,
  `erp_sync_reference_id` varchar(255) DEFAULT NULL,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_credit_notes_on_company_id` (`company_id`),
  KEY `index_credit_notes_on_user_id` (`user_id`),
  KEY `index_credit_notes_on_invoice_id` (`invoice_id`),
  KEY `index_credit_notes_on_procurement_id` (`procurement_id`),
  KEY `index_credit_notes_on_status_id` (`status_id`),
  KEY `index_credit_notes_on_controlling_level_id` (`controlling_level_id`),
  KEY `index_credit_notes_on_policy_id` (`policy_id`),
  KEY `index_credit_notes_on_vendor_id` (`vendor_id`),
  KEY `index_credit_notes_on_shipping_location_id` (`shipping_location_id`),
  KEY `index_credit_notes_on_billing_location_id` (`billing_location_id`),
  KEY `index_credit_notes_on_sequence_id` (`sequence_id`),
  KEY `index_credit_notes_on_credit_note_date` (`credit_note_date`),
  KEY `index_credit_notes_on_gross_receivable_amount_id` (`gross_receivable_amount_id`),
  KEY `index_credit_notes_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_credit_notes_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_credit_notes_on_net_receivable_amount_id` (`net_receivable_amount_id`),
  KEY `index_credit_notes_on_tds_rate_id` (`tds_rate_id`),
  KEY `index_credit_notes_on_tds_amount_id` (`tds_amount_id`),
  KEY `index_credit_notes_on_freight_amount_id` (`freight_amount_id`),
  KEY `index_credit_notes_on_previously_adjusted_amount_id` (`previously_adjusted_amount_id`),
  KEY `index_credit_notes_on_net_adjustable_amount_id` (`net_adjustable_amount_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crono_jobs`
--

DROP TABLE IF EXISTS `crono_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crono_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `log` mediumtext COLLATE utf8_unicode_ci,
  `last_performed_at` datetime DEFAULT NULL,
  `healthy` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_crono_jobs_on_job_id` (`job_id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `symbol` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currency_conversion_rates`
--

DROP TABLE IF EXISTS `currency_conversion_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency_conversion_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `INR` decimal(20,5) DEFAULT NULL,
  `USD` decimal(20,5) DEFAULT NULL,
  `GBP` decimal(20,5) DEFAULT NULL,
  `EUR` decimal(20,5) DEFAULT NULL,
  `CAD` decimal(20,5) DEFAULT NULL,
  `HRK` decimal(20,5) DEFAULT NULL,
  `RUB` decimal(20,5) DEFAULT NULL,
  `BGN` decimal(20,5) DEFAULT NULL,
  `BRL` decimal(20,5) DEFAULT NULL,
  `CHF` decimal(20,5) DEFAULT NULL,
  `CNY` decimal(20,5) DEFAULT NULL,
  `CZK` decimal(20,5) DEFAULT NULL,
  `DKK` decimal(20,5) DEFAULT NULL,
  `HKD` decimal(20,5) DEFAULT NULL,
  `HUF` decimal(20,5) DEFAULT NULL,
  `IDR` decimal(20,5) DEFAULT NULL,
  `ILS` decimal(20,5) DEFAULT NULL,
  `JPY` decimal(20,5) DEFAULT NULL,
  `KRW` decimal(20,5) DEFAULT NULL,
  `MXN` decimal(20,5) DEFAULT NULL,
  `MYR` decimal(20,5) DEFAULT NULL,
  `NOK` decimal(20,5) DEFAULT NULL,
  `NZD` decimal(20,5) DEFAULT NULL,
  `PHP` decimal(20,5) DEFAULT NULL,
  `PLN` decimal(20,5) DEFAULT NULL,
  `RON` decimal(20,5) DEFAULT NULL,
  `SEK` decimal(20,5) DEFAULT NULL,
  `SGD` decimal(20,5) DEFAULT NULL,
  `THB` decimal(20,5) DEFAULT NULL,
  `TRY` decimal(20,5) DEFAULT NULL,
  `ZAR` decimal(20,5) DEFAULT NULL,
  `AUD` decimal(20,5) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `AED` decimal(20,5) DEFAULT NULL,
  `AFN` decimal(20,5) DEFAULT NULL,
  `ALL` decimal(20,5) DEFAULT NULL,
  `AMD` decimal(20,5) DEFAULT NULL,
  `ANG` decimal(20,5) DEFAULT NULL,
  `AOA` decimal(20,5) DEFAULT NULL,
  `ARS` decimal(20,5) DEFAULT NULL,
  `AWG` decimal(20,5) DEFAULT NULL,
  `AZN` decimal(20,5) DEFAULT NULL,
  `BAM` decimal(20,5) DEFAULT NULL,
  `BBD` decimal(20,5) DEFAULT NULL,
  `BDT` decimal(20,5) DEFAULT NULL,
  `BHD` decimal(20,5) DEFAULT NULL,
  `BIF` decimal(20,5) DEFAULT NULL,
  `BMD` decimal(20,5) DEFAULT NULL,
  `BND` decimal(20,5) DEFAULT NULL,
  `BOB` decimal(20,5) DEFAULT NULL,
  `BSD` decimal(20,5) DEFAULT NULL,
  `BTC` decimal(20,5) DEFAULT NULL,
  `BTN` decimal(20,5) DEFAULT NULL,
  `BWP` decimal(20,5) DEFAULT NULL,
  `BYN` decimal(20,5) DEFAULT NULL,
  `BYR` decimal(20,5) DEFAULT NULL,
  `BZD` decimal(20,5) DEFAULT NULL,
  `CDF` decimal(20,5) DEFAULT NULL,
  `CLF` decimal(20,5) DEFAULT NULL,
  `CLP` decimal(20,5) DEFAULT NULL,
  `COP` decimal(20,5) DEFAULT NULL,
  `CRC` decimal(20,5) DEFAULT NULL,
  `CUC` decimal(20,5) DEFAULT NULL,
  `CUP` decimal(20,5) DEFAULT NULL,
  `CVE` decimal(20,5) DEFAULT NULL,
  `DJF` decimal(20,5) DEFAULT NULL,
  `DOP` decimal(20,5) DEFAULT NULL,
  `DZD` decimal(20,5) DEFAULT NULL,
  `EEK` decimal(10,5) DEFAULT NULL,
  `EGP` decimal(20,5) DEFAULT NULL,
  `ERN` decimal(20,5) DEFAULT NULL,
  `ETB` decimal(20,5) DEFAULT NULL,
  `FJD` decimal(20,5) DEFAULT NULL,
  `FKP` decimal(20,5) DEFAULT NULL,
  `GEL` decimal(20,5) DEFAULT NULL,
  `GGP` decimal(20,5) DEFAULT NULL,
  `GHS` decimal(20,5) DEFAULT NULL,
  `GIP` decimal(20,5) DEFAULT NULL,
  `GMD` decimal(20,5) DEFAULT NULL,
  `GNF` decimal(20,5) DEFAULT NULL,
  `GTQ` decimal(20,5) DEFAULT NULL,
  `GYD` decimal(20,5) DEFAULT NULL,
  `HNL` decimal(20,5) DEFAULT NULL,
  `HTG` decimal(20,5) DEFAULT NULL,
  `IMP` decimal(20,5) DEFAULT NULL,
  `IQD` decimal(20,5) DEFAULT NULL,
  `IRR` decimal(20,5) DEFAULT NULL,
  `ISK` decimal(20,5) DEFAULT NULL,
  `JEP` decimal(20,5) DEFAULT NULL,
  `JMD` decimal(20,5) DEFAULT NULL,
  `JOD` decimal(20,5) DEFAULT NULL,
  `KES` decimal(20,5) DEFAULT NULL,
  `KGS` decimal(20,5) DEFAULT NULL,
  `KHR` decimal(20,5) DEFAULT NULL,
  `KMF` decimal(20,5) DEFAULT NULL,
  `KPW` decimal(20,5) DEFAULT NULL,
  `KWD` decimal(20,5) DEFAULT NULL,
  `KYD` decimal(20,5) DEFAULT NULL,
  `KZT` decimal(20,5) DEFAULT NULL,
  `LAK` decimal(20,5) DEFAULT NULL,
  `LBP` decimal(20,5) DEFAULT NULL,
  `LKR` decimal(20,5) DEFAULT NULL,
  `LRD` decimal(20,5) DEFAULT NULL,
  `LSL` decimal(20,5) DEFAULT NULL,
  `LTL` decimal(20,5) DEFAULT NULL,
  `LVL` decimal(20,5) DEFAULT NULL,
  `LYD` decimal(20,5) DEFAULT NULL,
  `MAD` decimal(20,5) DEFAULT NULL,
  `MDL` decimal(20,5) DEFAULT NULL,
  `MGA` decimal(20,5) DEFAULT NULL,
  `MKD` decimal(20,5) DEFAULT NULL,
  `MMK` decimal(20,5) DEFAULT NULL,
  `MNT` decimal(20,5) DEFAULT NULL,
  `MOP` decimal(20,5) DEFAULT NULL,
  `MRO` decimal(20,5) DEFAULT NULL,
  `MUR` decimal(20,5) DEFAULT NULL,
  `MVR` decimal(20,5) DEFAULT NULL,
  `MWK` decimal(20,5) DEFAULT NULL,
  `MZN` decimal(20,5) DEFAULT NULL,
  `NAD` decimal(20,5) DEFAULT NULL,
  `NGN` decimal(20,5) DEFAULT NULL,
  `NIO` decimal(20,5) DEFAULT NULL,
  `NPR` decimal(20,5) DEFAULT NULL,
  `OMR` decimal(20,5) DEFAULT NULL,
  `PAB` decimal(20,5) DEFAULT NULL,
  `PEN` decimal(20,5) DEFAULT NULL,
  `PGK` decimal(20,5) DEFAULT NULL,
  `PKR` decimal(20,5) DEFAULT NULL,
  `PYG` decimal(20,5) DEFAULT NULL,
  `QAR` decimal(20,5) DEFAULT NULL,
  `RSD` decimal(20,5) DEFAULT NULL,
  `RWF` decimal(20,5) DEFAULT NULL,
  `SAR` decimal(20,5) DEFAULT NULL,
  `SBD` decimal(20,5) DEFAULT NULL,
  `SCR` decimal(20,5) DEFAULT NULL,
  `SDG` decimal(20,5) DEFAULT NULL,
  `SHP` decimal(20,5) DEFAULT NULL,
  `SLL` decimal(20,5) DEFAULT NULL,
  `SOS` decimal(20,5) DEFAULT NULL,
  `SRD` decimal(20,5) DEFAULT NULL,
  `STD` decimal(20,5) DEFAULT NULL,
  `SVC` decimal(20,5) DEFAULT NULL,
  `SYP` decimal(20,5) DEFAULT NULL,
  `SZL` decimal(20,5) DEFAULT NULL,
  `TJS` decimal(20,5) DEFAULT NULL,
  `TMT` decimal(20,5) DEFAULT NULL,
  `TND` decimal(20,5) DEFAULT NULL,
  `TOP` decimal(20,5) DEFAULT NULL,
  `TTD` decimal(20,5) DEFAULT NULL,
  `TWD` decimal(20,5) DEFAULT NULL,
  `TZS` decimal(20,5) DEFAULT NULL,
  `UAH` decimal(20,5) DEFAULT NULL,
  `UGX` decimal(20,5) DEFAULT NULL,
  `UYU` decimal(20,5) DEFAULT NULL,
  `UZS` decimal(20,5) DEFAULT NULL,
  `VEF` decimal(20,5) DEFAULT NULL,
  `VND` decimal(20,5) DEFAULT NULL,
  `VUV` decimal(20,5) DEFAULT NULL,
  `WST` decimal(20,5) DEFAULT NULL,
  `XAF` decimal(20,5) DEFAULT NULL,
  `XAG` decimal(20,5) DEFAULT NULL,
  `XAU` decimal(20,5) DEFAULT NULL,
  `XCD` decimal(20,5) DEFAULT NULL,
  `XDR` decimal(20,5) DEFAULT NULL,
  `XOF` decimal(20,5) DEFAULT NULL,
  `XPF` decimal(20,5) DEFAULT NULL,
  `YER` decimal(20,5) DEFAULT NULL,
  `ZMK` decimal(20,5) DEFAULT NULL,
  `ZMW` decimal(20,5) DEFAULT NULL,
  `ZWL` decimal(20,5) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currency_conversion_rates_on_date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=591 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_export_configurations`
--

DROP TABLE IF EXISTS `custom_export_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_export_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `configurable_id` int(11) DEFAULT NULL,
  `configurable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_report` tinyint(1) DEFAULT NULL,
  `custom_invoice` tinyint(1) DEFAULT NULL,
  `custom_purchase_order` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_attachments`
--

DROP TABLE IF EXISTS `custom_field_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `form_custom_field_id` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` bigint(20) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_attachments_on_uuid` (`uuid`),
  KEY `index_custom_field_attachments_on_form_custom_field_id` (`form_custom_field_id`),
  KEY `index_custom_field_attachments_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=794 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_selections`
--

DROP TABLE IF EXISTS `custom_field_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_selections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `form_entity_choice_id` varchar(255) DEFAULT NULL,
  `form_custom_field_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_selections_on_uuid` (`uuid`),
  KEY `index_custom_field_selections_on_form_entity_choice_id` (`form_entity_choice_id`),
  KEY `index_custom_field_selections_on_form_custom_field_id` (`form_custom_field_id`),
  KEY `index_custom_field_selections_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=425 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_fields`
--

DROP TABLE IF EXISTS `custom_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_configuration_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `value_id` int(11) DEFAULT NULL,
  `value_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dependent_parent_id` int(11) DEFAULT NULL,
  `dependent_parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `configured_field_value` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_fields_on_field_configuration_id` (`field_configuration_id`),
  KEY `index_custom_fields_on_parent_id` (`parent_id`),
  KEY `index_custom_fields_on_parent_type` (`parent_type`),
  CONSTRAINT `fk_rails_9ea356542c` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=201903 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_account_transactions`
--

DROP TABLE IF EXISTS `customer_account_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_account_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_account_id` int(11) DEFAULT NULL,
  `transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_amount_id` int(11) DEFAULT NULL,
  `note` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `associated_account_id` int(11) DEFAULT NULL,
  `associated_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customer_account_transactions_on_customer_account_id` (`customer_account_id`),
  KEY `index_customer_account_transactions_on_transaction_amount_id` (`transaction_amount_id`),
  KEY `indx_cstmer_acc_tranxs_on_assoc_acc_type_and_assoc_acc_id` (`associated_account_type`,`associated_account_id`),
  CONSTRAINT `fk_rails_82c5d37d49` FOREIGN KEY (`customer_account_id`) REFERENCES `customer_accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_accounts`
--

DROP TABLE IF EXISTS `customer_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customer_accounts_on_customer_id` (`customer_id`),
  KEY `index_customer_accounts_on_balance_id` (`balance_id`),
  CONSTRAINT `fk_rails_c477a916cd` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_attachments`
--

DROP TABLE IF EXISTS `customer_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attached_file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_file_size` int(11) DEFAULT NULL,
  `attached_file_updated_at` datetime DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customer_attachments_on_customer_id` (`customer_id`),
  CONSTRAINT `fk_rails_e26bc87e59` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gst` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_challans`
--

DROP TABLE IF EXISTS `delivery_challans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delivery_challans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `procurement_term_id` int(11) DEFAULT NULL,
  `document_status_id` int(11) DEFAULT NULL,
  `doc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `override_doc_number` tinyint(1) DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `challan_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `roundoff_total_enabled` tinyint(1) DEFAULT NULL,
  `roundoff_amount` decimal(10,5) DEFAULT NULL,
  `transaction_amount_id` int(11) DEFAULT NULL,
  `total_before_tax_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `total_after_tax_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `balance_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_delivery_challans_on_company_id` (`company_id`),
  KEY `index_delivery_challans_on_user_id` (`user_id`),
  KEY `index_delivery_challans_on_procurement_id` (`procurement_id`),
  KEY `index_delivery_challans_on_location_id` (`location_id`),
  KEY `index_delivery_challans_on_delivery_location_id` (`delivery_location_id`),
  KEY `index_delivery_challans_on_vendor_id` (`vendor_id`),
  KEY `index_delivery_challans_on_payment_term_id` (`payment_term_id`),
  KEY `index_delivery_challans_on_procurement_term_id` (`procurement_term_id`),
  KEY `index_delivery_challans_on_document_status_id` (`document_status_id`),
  KEY `index_delivery_challans_on_transaction_amount_id` (`transaction_amount_id`),
  KEY `index_delivery_challans_on_total_before_tax_id` (`total_before_tax_id`),
  KEY `index_delivery_challans_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_delivery_challans_on_total_after_tax_id` (`total_after_tax_id`),
  KEY `index_delivery_challans_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_delivery_challans_on_balance_amount_id` (`balance_amount_id`),
  CONSTRAINT `fk_rails_190d1a940b` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_52faecda49` FOREIGN KEY (`procurement_term_id`) REFERENCES `procurement_terms` (`id`),
  CONSTRAINT `fk_rails_67836910f3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_8562f6596c` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_a34805229f` FOREIGN KEY (`document_status_id`) REFERENCES `document_statuses` (`id`),
  CONSTRAINT `fk_rails_d054f0f795` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `ancestry` varchar(255) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `department_code` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `gl_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_departments_on_company_id` (`company_id`),
  KEY `index_departments_on_cost_center_id` (`cost_center_id`),
  CONSTRAINT `fk_rails_1703941606` FOREIGN KEY (`cost_center_id`) REFERENCES `cost_centers` (`id`),
  CONSTRAINT `fk_rails_f911441942` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `desktop_users`
--

DROP TABLE IF EXISTS `desktop_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `desktop_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distance_expense_configs`
--

DROP TABLE IF EXISTS `distance_expense_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distance_expense_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `default_category_id` int(11) DEFAULT NULL,
  `rate_id` int(11) DEFAULT NULL,
  `distance_unit_id` int(11) DEFAULT NULL,
  `policy_id` int(11) NOT NULL,
  `enforce_category` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distance_expense_types`
--

DROP TABLE IF EXISTS `distance_expense_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distance_expense_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_distance_expense_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distance_expenses`
--

DROP TABLE IF EXISTS `distance_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distance_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expense_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `distance_id` int(11) DEFAULT NULL,
  `maps_distance_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `odometer_reading_start` decimal(10,0) DEFAULT NULL,
  `odometer_reading_end` decimal(10,0) DEFAULT NULL,
  `odometer_reading_receipt_start_id` int(11) DEFAULT NULL,
  `odometer_reading_receipt_end_id` int(11) DEFAULT NULL,
  `vehicle_rate_id` int(11) DEFAULT NULL,
  `distance_rate_id` int(11) DEFAULT NULL,
  `distance_unit_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_distance_expenses_on_expense_id` (`expense_id`),
  CONSTRAINT `fk_rails_ec3627e497` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=215 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distances`
--

DROP TABLE IF EXISTS `distances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` decimal(10,4) DEFAULT NULL,
  `physical_unit_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_distances_on_physical_unit_id` (`physical_unit_id`),
  CONSTRAINT `fk_rails_408bbf8e23` FOREIGN KEY (`physical_unit_id`) REFERENCES `physical_units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=343 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_items`
--

DROP TABLE IF EXISTS `document_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_document_id` int(11) NOT NULL,
  `parent_document_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `inventory_line_item_id` int(11) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hsn_sac` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` decimal(20,5) DEFAULT NULL,
  `rate` decimal(20,5) DEFAULT NULL,
  `tax` decimal(20,5) DEFAULT '0.00000',
  `tds` decimal(20,5) DEFAULT '0.00000',
  `discount` decimal(20,5) DEFAULT '0.00000',
  `tax_amount_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purchase_order_item_id` int(11) DEFAULT NULL,
  `product_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `indx_doc_items_on_parent_doc_type_and_parent_doc_id` (`parent_document_type`,`parent_document_id`),
  KEY `index_document_items_on_inventory_line_item_id` (`inventory_line_item_id`),
  KEY `index_document_items_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_document_items_on_tds_amount_id` (`tds_amount_id`),
  KEY `index_document_items_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_document_items_on_total_amount_id` (`total_amount_id`),
  KEY `index_document_items_on_purchase_order_item_id` (`purchase_order_item_id`),
  CONSTRAINT `fk_rails_5fc7541606` FOREIGN KEY (`inventory_line_item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `fk_rails_db0bb59525` FOREIGN KEY (`purchase_order_item_id`) REFERENCES `purchase_order_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_level_reviewer_mappings`
--

DROP TABLE IF EXISTS `document_level_reviewer_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_level_reviewer_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) DEFAULT NULL,
  `level_id` int(11) DEFAULT NULL,
  `reviewer_id` int(11) DEFAULT NULL,
  `document_reviewer_mappable_id` int(11) NOT NULL,
  `document_reviewer_mappable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `level_number` int(11) DEFAULT NULL,
  `taken_control` tinyint(1) DEFAULT '0',
  `taken_control_by_id` int(11) DEFAULT NULL,
  `viewable` tinyint(1) DEFAULT '0',
  `action_taken_by_id` int(11) DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `provider_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `threshold` decimal(20,5) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `wo_exception` tinyint(1) DEFAULT '1',
  `forwarded` tinyint(1) DEFAULT '0',
  `forwarded_by_id` int(11) DEFAULT NULL,
  `forwarded_to_id` int(11) DEFAULT NULL,
  `min` decimal(20,5) DEFAULT '0.00000',
  `max` decimal(20,5) DEFAULT NULL,
  `rejected_by_id` int(11) DEFAULT NULL,
  `action_taken_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `tat` int(11) DEFAULT NULL,
  `tat_added_by_script` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_level_reviewer_mappings_on_policy_id` (`policy_id`),
  KEY `index_document_level_reviewer_mappings_on_level_id` (`level_id`),
  KEY `index_document_level_reviewer_mappings_on_reviewer_id` (`reviewer_id`),
  KEY `indx_doc_lvl_rvwr_mpng_on_doc_rvwr_mpble_tp_n_doc_rvwr_mpble_id` (`document_reviewer_mappable_type`,`document_reviewer_mappable_id`),
  KEY `index_document_level_reviewer_mappings_on_rejected_by_id` (`rejected_by_id`),
  KEY `index_dlrm_provider_policy_mappable_type` (`document_reviewer_mappable_type`,`provider_name`,`policy_id`),
  KEY `index_document_level_reviewer_mappings_on_level_number` (`level_number`),
  KEY `index_document_level_reviewer_mappings_on_taken_control` (`taken_control`),
  KEY `index_document_level_reviewer_mappings_on_forwarded` (`forwarded`),
  KEY `index_document_level_reviewer_mappings_on_viewable` (`viewable`),
  CONSTRAINT `fk_rails_c34d0a503f` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4657 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_message_receipts`
--

DROP TABLE IF EXISTS `document_message_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_message_receipts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `receiptable_document_id` int(11) NOT NULL,
  `receiptable_document_type` varchar(255) NOT NULL,
  `document_message_id` int(11) NOT NULL,
  `browser_push_sent_at` datetime DEFAULT NULL,
  `app_push_sent_at` datetime DEFAULT NULL,
  `email_sent_at` datetime DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `trashed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_message_receipts_on_user_id` (`user_id`),
  KEY `index_document_message_receipts_on_receiptable_document_id` (`receiptable_document_id`),
  KEY `index_document_message_receipts_on_receiptable_document_type` (`receiptable_document_type`),
  KEY `index_document_message_receipts_on_document_message_id` (`document_message_id`),
  KEY `index_document_message_receipts_on_browser_push_sent_at` (`browser_push_sent_at`),
  KEY `index_document_message_receipts_on_app_push_sent_at` (`app_push_sent_at`),
  KEY `index_document_message_receipts_on_email_sent_at` (`email_sent_at`),
  KEY `index_document_message_receipts_on_read_at` (`read_at`),
  KEY `index_document_message_receipts_on_trashed_at` (`trashed_at`),
  KEY `index_document_message_receipts_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_message_types`
--

DROP TABLE IF EXISTS `document_message_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_message_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_message_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_messages`
--

DROP TABLE IF EXISTS `document_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `body` text,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` bigint(20) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `trashed_at` datetime DEFAULT NULL,
  `messageable_document_id` int(11) NOT NULL,
  `messageable_document_type` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_messages_on_order` (`order`),
  KEY `index_document_messages_on_user_id` (`user_id`),
  KEY `index_document_messages_on_type_id` (`type_id`),
  KEY `index_document_messages_on_deleted_at` (`deleted_at`),
  KEY `index_document_messages_on_trashed_at` (`trashed_at`),
  KEY `index_document_messages_on_messageable_document_id` (`messageable_document_id`),
  KEY `index_document_messages_on_messageable_document_type` (`messageable_document_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_number_config_types`
--

DROP TABLE IF EXISTS `document_number_config_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_number_config_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_number_configs`
--

DROP TABLE IF EXISTS `document_number_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_number_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `document_number_config_type_id` int(11) DEFAULT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_number_configs_on_company_id` (`company_id`),
  KEY `index_document_number_configs_on_document_number_config_type_id` (`document_number_config_type_id`),
  KEY `index_document_number_configs_on_purpose_id` (`purpose_id`),
  CONSTRAINT `fk_rails_469fe59c29` FOREIGN KEY (`document_number_config_type_id`) REFERENCES `document_number_config_types` (`id`),
  CONSTRAINT `fk_rails_56381a83a3` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`),
  CONSTRAINT `fk_rails_e7372debb6` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_slices`
--

DROP TABLE IF EXISTS `document_slices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_slices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_number` int(11) DEFAULT NULL,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `receipt_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_slices_on_receipt_id` (`receipt_id`),
  CONSTRAINT `fk_rails_bf7600d892` FOREIGN KEY (`receipt_id`) REFERENCES `receipts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_statuses`
--

DROP TABLE IF EXISTS `document_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_blocks`
--

DROP TABLE IF EXISTS `document_workflow_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_blocks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `document_workflow_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `criteria` text,
  `config` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `parent_id` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `sequence` int(11) DEFAULT NULL,
  `document_workflow_version_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_blocks_on_company_id` (`company_id`),
  KEY `index_document_workflow_blocks_on_created_by_id` (`created_by_id`),
  KEY `index_document_workflow_blocks_on_type` (`type`),
  KEY `index_document_workflow_blocks_on_document_workflow_id` (`document_workflow_id`),
  KEY `index_document_workflow_blocks_on_position` (`position`),
  KEY `index_document_workflow_blocks_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_blocks_on_created_at` (`created_at`),
  KEY `index_document_workflow_blocks_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_item_reassignments`
--

DROP TABLE IF EXISTS `document_workflow_item_reassignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_item_reassignments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `document_workflow_item_id` int(11) NOT NULL,
  `reassigned_to_id` int(11) DEFAULT NULL,
  `reassigned_by_id` int(11) DEFAULT NULL,
  `reassigned_at` datetime DEFAULT NULL,
  `reassign_type` varchar(255) DEFAULT NULL,
  `reassign_message` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_item_reassignments_on_company_id` (`company_id`),
  KEY `index_document_workflow_item_reassignments_on_reassigned_to_id` (`reassigned_to_id`),
  KEY `index_document_workflow_item_reassignments_on_reassigned_by_id` (`reassigned_by_id`),
  KEY `index_document_workflow_item_reassignments_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_item_reassignments_on_created_at` (`created_at`),
  KEY `index_document_workflow_item_reassignments_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_item_statuses`
--

DROP TABLE IF EXISTS `document_workflow_item_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_item_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_item_statuses_on_name` (`name`),
  KEY `index_document_workflow_item_statuses_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_item_statuses_on_created_at` (`created_at`),
  KEY `index_document_workflow_item_statuses_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_items`
--

DROP TABLE IF EXISTS `document_workflow_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `action_resource_type` varchar(255) DEFAULT NULL,
  `action_resource_id` bigint(20) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `document_workflow_id` int(11) NOT NULL,
  `block_id` int(11) NOT NULL,
  `visible` tinyint(1) DEFAULT '1',
  `sequence` int(11) DEFAULT NULL,
  `tat` int(11) DEFAULT NULL,
  `tat_in_working_hours` int(11) DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `estimated_completion_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `status_id` int(11) NOT NULL,
  `document_workflow_record_mapping_id` int(11) DEFAULT NULL,
  `parent_id` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `reassigned_to_id` int(11) DEFAULT NULL,
  `reassigned_by_id` int(11) DEFAULT NULL,
  `reassigned_at` datetime DEFAULT NULL,
  `reassign_type` varchar(255) DEFAULT NULL,
  `reassign_message` text,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_items_on_company_id` (`company_id`),
  KEY `index_document_workflow_items_on_action_resource` (`action_resource_type`,`action_resource_id`),
  KEY `index_document_workflow_items_on_document_workflow_id` (`document_workflow_id`),
  KEY `index_document_workflow_items_on_block_id` (`block_id`),
  KEY `index_document_workflow_items_on_visible` (`visible`),
  KEY `index_document_workflow_items_on_sequence` (`sequence`),
  KEY `index_document_workflow_items_on_tat` (`tat`),
  KEY `index_document_workflow_items_on_tat_in_working_hours` (`tat_in_working_hours`),
  KEY `index_document_workflow_items_on_received_at` (`received_at`),
  KEY `index_document_workflow_items_on_processed_at` (`processed_at`),
  KEY `index_document_workflow_items_on_estimated_completion_at` (`estimated_completion_at`),
  KEY `index_document_workflow_items_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_items_on_created_at` (`created_at`),
  KEY `index_document_workflow_items_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_record_mappings`
--

DROP TABLE IF EXISTS `document_workflow_record_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_record_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint(20) NOT NULL,
  `document_workflow_id` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `document_workflow_version_id` int(11) NOT NULL,
  `message` text,
  `completion_percentage` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_record_mappings_on_company_id` (`company_id`),
  KEY `index_document_workflow_record_mappings_on_created_by_id` (`created_by_id`),
  KEY `index_document_workflow_on_record` (`record_type`,`record_id`),
  KEY `index_document_workflow_record_mappings_on_document_workflow_id` (`document_workflow_id`),
  KEY `index_document_workflow_record_mappings_on_active` (`active`),
  KEY `index_document_workflow_record_mappings_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_record_mappings_on_created_at` (`created_at`),
  KEY `index_document_workflow_record_mappings_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_user_mapping_types`
--

DROP TABLE IF EXISTS `document_workflow_user_mapping_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_user_mapping_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_user_mapping_types_on_name` (`name`),
  KEY `index_document_workflow_user_mapping_types_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_user_mapping_types_on_created_at` (`created_at`),
  KEY `index_document_workflow_user_mapping_types_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_user_mappings`
--

DROP TABLE IF EXISTS `document_workflow_user_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_user_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `mapping_type_id` int(11) NOT NULL,
  `block_id` int(11) NOT NULL,
  `criteria` text,
  `user_resource_type` varchar(255) DEFAULT NULL,
  `user_resource_id` bigint(20) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_user_mappings_on_company_id` (`company_id`),
  KEY `index_document_workflow_user_mappings_on_mapping_type_id` (`mapping_type_id`),
  KEY `index_document_workflow_user_mappings_on_block_id` (`block_id`),
  KEY `index_document_workflow_user_mappings_on_user_resource` (`user_resource_type`,`user_resource_id`),
  KEY `index_document_workflow_user_mappings_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_user_mappings_on_created_at` (`created_at`),
  KEY `index_document_workflow_user_mappings_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflow_versions`
--

DROP TABLE IF EXISTS `document_workflow_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflow_versions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `document_workflow_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `version_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflow_versions_on_company_id` (`company_id`),
  KEY `index_document_workflow_versions_on_document_workflow_id` (`document_workflow_id`),
  KEY `index_document_workflow_versions_on_status` (`status`),
  KEY `index_document_workflow_versions_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflow_versions_on_created_at` (`created_at`),
  KEY `index_document_workflow_versions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_workflows`
--

DROP TABLE IF EXISTS `document_workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_workflows` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `document` varchar(255) DEFAULT NULL,
  `trigger` varchar(255) DEFAULT NULL,
  `criteria` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `priority` int(11) DEFAULT '0',
  `workflow_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_document_workflows_on_company_id` (`company_id`),
  KEY `index_document_workflows_on_created_by_id` (`created_by_id`),
  KEY `index_document_workflows_on_document` (`document`),
  KEY `index_document_workflows_on_trigger` (`trigger`),
  KEY `index_document_workflows_on_deleted_at` (`deleted_at`),
  KEY `index_document_workflows_on_created_at` (`created_at`),
  KEY `index_document_workflows_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `duplicate_expense_mappings`
--

DROP TABLE IF EXISTS `duplicate_expense_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `duplicate_expense_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expense_id` int(11) NOT NULL,
  `duplicate_expense_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_duplicate_expense_mappings_on_expense_id` (`expense_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2257 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_way_bills`
--

DROP TABLE IF EXISTS `e_way_bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `e_way_bills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `procurement_term_id` int(11) DEFAULT NULL,
  `doc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `generated_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `ref_doc_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ref_doc_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `hsn_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reason_for_transportation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vehicle_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_e_way_bills_on_company_id` (`company_id`),
  KEY `index_e_way_bills_on_user_id` (`user_id`),
  KEY `index_e_way_bills_on_procurement_id` (`procurement_id`),
  KEY `index_e_way_bills_on_location_id` (`location_id`),
  KEY `index_e_way_bills_on_delivery_location_id` (`delivery_location_id`),
  KEY `index_e_way_bills_on_vendor_id` (`vendor_id`),
  KEY `index_e_way_bills_on_payment_term_id` (`payment_term_id`),
  KEY `index_e_way_bills_on_procurement_term_id` (`procurement_term_id`),
  KEY `index_e_way_bills_on_amount_id` (`amount_id`),
  CONSTRAINT `fk_rails_123d6e7b23` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`),
  CONSTRAINT `fk_rails_14f06f0cff` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_3a7294d268` FOREIGN KEY (`procurement_term_id`) REFERENCES `procurement_terms` (`id`),
  CONSTRAINT `fk_rails_626cd9dc4b` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_a9f7f549c0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_fd18716a2f` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_authorizations`
--

DROP TABLE IF EXISTS `email_authorizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_authorizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `authorizable_id` int(11) NOT NULL,
  `authorizable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT '1',
  `view_role_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_email_authorizations_on_user_id` (`user_id`),
  KEY `index_email_authorizations_on_authorizable_id` (`authorizable_id`),
  KEY `index_email_authorizations_on_authorizable_type` (`authorizable_type`),
  KEY `index_email_authorizations_on_token` (`token`),
  CONSTRAINT `fk_rails_faf7e663d1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_bodies`
--

DROP TABLE IF EXISTS `email_bodies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_bodies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `email_id` int(11) NOT NULL,
  `body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_email_bodies_on_company_id` (`company_id`),
  KEY `index_email_bodies_on_email_id` (`email_id`),
  KEY `index_email_bodies_on_deleted_at` (`deleted_at`),
  KEY `index_email_bodies_on_created_at` (`created_at`),
  KEY `index_email_bodies_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_events`
--

DROP TABLE IF EXISTS `email_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_events` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email_id` bigint(20) NOT NULL,
  `event` varchar(255) NOT NULL,
  `link` varchar(255) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `event_id` varchar(255) DEFAULT NULL,
  `payload` longtext,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `ip_addr` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `link_tags` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_email_events_on_email_id` (`email_id`),
  KEY `index_email_events_on_event` (`event`),
  KEY `index_email_events_on_link` (`link`),
  KEY `index_email_events_on_timestamp` (`timestamp`),
  KEY `index_email_events_on_event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_type` varchar(255) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `message_id` varchar(255) DEFAULT NULL,
  `sender` varchar(255) DEFAULT NULL,
  `recipient` varchar(255) DEFAULT NULL,
  `bcc` varchar(255) DEFAULT NULL,
  `cc` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `mailer_klass` varchar(255) DEFAULT NULL,
  `mailer_action` varchar(255) DEFAULT NULL,
  `configuration_set` varchar(255) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `delivery_count` int(11) DEFAULT NULL,
  `last_opened_at` datetime DEFAULT NULL,
  `open_count` int(11) DEFAULT NULL,
  `last_link_clicked_at` datetime DEFAULT NULL,
  `link_open_count` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_emails_on_entity_type_and_entity_id` (`entity_type`,`entity_id`),
  KEY `index_emails_on_company_id` (`company_id`),
  KEY `index_emails_on_message_id` (`message_id`),
  KEY `index_emails_on_sender` (`sender`),
  KEY `index_emails_on_recipient` (`recipient`),
  KEY `index_emails_on_bcc` (`bcc`),
  KEY `index_emails_on_cc` (`cc`),
  KEY `index_emails_on_subject` (`subject`),
  KEY `index_emails_on_mailer_klass` (`mailer_klass`),
  KEY `index_emails_on_mailer_action` (`mailer_action`),
  KEY `index_emails_on_sent_at` (`sent_at`),
  KEY `index_emails_on_delivered_at` (`delivered_at`),
  KEY `index_emails_on_delivery_count` (`delivery_count`),
  KEY `index_emails_on_last_opened_at` (`last_opened_at`),
  KEY `index_emails_on_open_count` (`open_count`),
  KEY `index_emails_on_last_link_clicked_at` (`last_link_clicked_at`),
  KEY `index_emails_on_link_open_count` (`link_open_count`)
) ENGINE=InnoDB AUTO_INCREMENT=3704 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `enforce_budget_configurations`
--

DROP TABLE IF EXISTS `enforce_budget_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enforce_budget_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enforce_purchase_order_budget` tinyint(1) DEFAULT NULL,
  `enforce_payment_budget` tinyint(1) DEFAULT NULL,
  `enforce_expense_budget` tinyint(1) DEFAULT NULL,
  `enforce_invoice_budget` tinyint(1) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `enforce_purchase_request_budget` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_enforce_budget_configurations_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `enforce_policies`
--

DROP TABLE IF EXISTS `enforce_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enforce_policies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enforceable_id` int(11) NOT NULL,
  `enforceable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_enforce_policies_on_enforceable_type_and_enforceable_id` (`enforceable_type`,`enforceable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erp_sync_attempts`
--

DROP TABLE IF EXISTS `erp_sync_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erp_sync_attempts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_id` int(11) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `status_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `macro_id` int(11) DEFAULT NULL,
  `macro_job_id` int(11) DEFAULT NULL,
  `message` text,
  `reference_id` text,
  `attempted_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_erp_sync_attempts_on_record_id` (`record_id`),
  KEY `index_erp_sync_attempts_on_record_type` (`record_type`),
  KEY `index_erp_sync_attempts_on_status_id` (`status_id`),
  KEY `index_erp_sync_attempts_on_company_id` (`company_id`),
  KEY `index_erp_sync_attempts_on_macro_id` (`macro_id`),
  KEY `index_erp_sync_attempts_on_macro_job_id` (`macro_job_id`),
  KEY `index_erp_sync_attempts_on_deleted_at` (`deleted_at`),
  KEY `index_erp_sync_attempts_on_created_at` (`created_at`),
  KEY `index_erp_sync_attempts_on_updated_at` (`updated_at`),
  KEY `index_erp_sync_attempts_on_record_id_and_record_type` (`record_id`,`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erp_sync_statuses`
--

DROP TABLE IF EXISTS `erp_sync_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erp_sync_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_erp_sync_statuses_on_name` (`name`),
  KEY `index_erp_sync_statuses_on_deleted_at` (`deleted_at`),
  KEY `index_erp_sync_statuses_on_created_at` (`created_at`),
  KEY `index_erp_sync_statuses_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exchange_rates`
--

DROP TABLE IF EXISTS `exchange_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exchange_rates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `rate` float DEFAULT NULL,
  `date` date DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=341 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_data_extract_sources`
--

DROP TABLE IF EXISTS `expense_data_extract_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_data_extract_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_data_extract_statuses`
--

DROP TABLE IF EXISTS `expense_data_extract_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_data_extract_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_data_extracts`
--

DROP TABLE IF EXISTS `expense_data_extracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_data_extracts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `time` time DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `sourcable_id` int(11) DEFAULT NULL,
  `sourcable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `extractable_id` int(11) NOT NULL,
  `extractable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `datetime` datetime DEFAULT NULL,
  `expense_data_extract_source_id` int(11) DEFAULT NULL,
  `status_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expense_data_extracts_on_amount_id` (`amount_id`),
  KEY `index_expense_data_extracts_on_category_id` (`category_id`),
  KEY `index_expense_data_extracts_on_sourcable_id` (`sourcable_id`),
  KEY `index_expense_data_extracts_on_sourcable_type` (`sourcable_type`),
  CONSTRAINT `fk_rails_46ed0e37ba` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_74addf846f` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_rule_types`
--

DROP TABLE IF EXISTS `expense_rule_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_rule_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_rules`
--

DROP TABLE IF EXISTS `expense_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `greater_than_amount_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `days_after` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rule_type_id` int(11) DEFAULT NULL,
  `expense_rule_type_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expense_rules_on_greater_than_amount_id` (`greater_than_amount_id`),
  KEY `index_expense_rules_on_category_id` (`category_id`),
  KEY `index_expense_rules_on_rule_type_id` (`rule_type_id`),
  KEY `index_expense_rules_on_expense_rule_type_id` (`expense_rule_type_id`),
  KEY `index_expense_rules_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_385d848701` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_cce7e38e8f` FOREIGN KEY (`expense_rule_type_id`) REFERENCES `expense_rule_types` (`id`),
  CONSTRAINT `fk_rails_d7176fff3f` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_e23500572d` FOREIGN KEY (`rule_type_id`) REFERENCES `rule_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_statuses`
--

DROP TABLE IF EXISTS `expense_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_tax_types`
--

DROP TABLE IF EXISTS `expense_tax_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_tax_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expense_tax_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expense_types`
--

DROP TABLE IF EXISTS `expense_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount_id` int(11) DEFAULT NULL,
  `expense_status_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `date` date DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `expense_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `manager_memo` text COLLATE utf8_unicode_ci,
  `rejecting_manager_id` int(11) DEFAULT NULL,
  `report_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `transcribed` tinyint(1) DEFAULT '0',
  `personal` tinyint(1) DEFAULT '0',
  `reimbursable` tinyint(1) DEFAULT NULL,
  `synced_with_quickbooks` tinyint(1) DEFAULT '0',
  `split_link` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_to_split` tinyint(1) DEFAULT '0',
  `from_cash_on_hand` tinyint(1) DEFAULT '0',
  `cash_on_hand_blocked` tinyint(1) DEFAULT NULL,
  `expense_tax_type_id` int(11) DEFAULT NULL,
  `gst_percentage` decimal(10,5) DEFAULT NULL,
  `tds_percentage` decimal(10,5) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `gst_amount_id` int(11) DEFAULT NULL,
  `usage_date_start` datetime DEFAULT NULL,
  `usage_date_end` datetime DEFAULT NULL,
  `usage_date_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `spent_from_id` int(11) DEFAULT NULL,
  `custom_conversion_rate` tinyint(1) DEFAULT '0',
  `cost_center_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `modified_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `gstin_location_id` int(11) DEFAULT NULL,
  `state_of_expense_id` int(11) DEFAULT NULL,
  `hsn_sac` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `merchant_bill_no` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expenses_on_amount_id` (`amount_id`),
  KEY `index_expenses_on_expense_status_id` (`expense_status_id`),
  KEY `index_expenses_on_user_id` (`user_id`),
  KEY `index_expenses_on_expense_type_id` (`expense_type_id`),
  KEY `index_expenses_on_report_id` (`report_id`),
  KEY `index_expenses_on_category_id` (`category_id`),
  KEY `index_expenses_on_expense_tax_type_id` (`expense_tax_type_id`),
  KEY `index_expenses_on_created_at` (`created_at`),
  KEY `index_expenses_on_reimbursable` (`reimbursable`),
  CONSTRAINT `fk_rails_06966d0da0` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_244a1b7a3e` FOREIGN KEY (`expense_type_id`) REFERENCES `expense_types` (`id`),
  CONSTRAINT `fk_rails_39be32d1e4` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  CONSTRAINT `fk_rails_585bbaa305` FOREIGN KEY (`expense_status_id`) REFERENCES `expense_statuses` (`id`),
  CONSTRAINT `fk_rails_c0c9dbe19d` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_c3ee69df61` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_cf1a8af1a8` FOREIGN KEY (`expense_tax_type_id`) REFERENCES `expense_tax_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1813 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_config_types`
--

DROP TABLE IF EXISTS `export_config_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_config_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_config_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_configs`
--

DROP TABLE IF EXISTS `export_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `export_config_type_id` int(11) NOT NULL,
  `field_reference_id` int(11) DEFAULT NULL,
  `field_reference_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  `field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `spreadsheet` tinyint(1) DEFAULT '1',
  `pdf` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_configs_on_company_id` (`company_id`),
  KEY `index_export_configs_on_export_config_type_id` (`export_config_type_id`),
  CONSTRAINT `fk_rails_31d929aea1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_c9de755753` FOREIGN KEY (`export_config_type_id`) REFERENCES `export_config_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_fields`
--

DROP TABLE IF EXISTS `export_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_formats`
--

DROP TABLE IF EXISTS `export_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_formats` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_formats_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_job_statuses`
--

DROP TABLE IF EXISTS `export_job_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_job_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_job_statuses_on_name` (`name`),
  KEY `index_export_job_statuses_on_created_at` (`created_at`),
  KEY `index_export_job_statuses_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_jobs`
--

DROP TABLE IF EXISTS `export_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_jobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `export_type` varchar(255) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `company_id` bigint(20) NOT NULL,
  `request_params` longtext,
  `completed_at` datetime DEFAULT NULL,
  `total_records` int(11) DEFAULT NULL,
  `completed_records` int(11) DEFAULT NULL,
  `completion_percentage` int(11) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` bigint(20) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `master` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `record_id` bigint(20) DEFAULT NULL,
  `crash_stacktrace` text,
  `message` text,
  `note` text,
  PRIMARY KEY (`id`),
  KEY `index_export_jobs_on_name` (`name`),
  KEY `index_export_jobs_on_export_type` (`export_type`),
  KEY `index_export_jobs_on_created_by_id` (`created_by_id`),
  KEY `index_export_jobs_on_company_id` (`company_id`),
  KEY `index_export_jobs_on_completed_at` (`completed_at`),
  KEY `index_export_jobs_on_total_records` (`total_records`),
  KEY `index_export_jobs_on_completed_records` (`completed_records`),
  KEY `index_export_jobs_on_completion_percentage` (`completion_percentage`),
  KEY `index_export_jobs_on_created_at` (`created_at`),
  KEY `index_export_jobs_on_updated_at` (`updated_at`),
  KEY `index_export_jobs_on_record_type_and_record_id` (`record_type`,`record_id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_preferences`
--

DROP TABLE IF EXISTS `export_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `export_field_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_preferences_on_company_id` (`company_id`),
  KEY `index_export_preferences_on_export_field_id` (`export_field_id`),
  CONSTRAINT `fk_rails_845eba03bc` FOREIGN KEY (`export_field_id`) REFERENCES `export_fields` (`id`),
  CONSTRAINT `fk_rails_d216cc140c` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_requests`
--

DROP TABLE IF EXISTS `export_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `model_class` varchar(255) DEFAULT NULL,
  `export_name` varchar(255) DEFAULT NULL,
  `export_template_id` int(11) NOT NULL,
  `file_file_name` varchar(255) DEFAULT NULL,
  `file_content_type` varchar(255) DEFAULT NULL,
  `file_file_size` bigint(20) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  `scheduled_on` datetime DEFAULT NULL,
  `expires_on` datetime DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_requests_on_model_class` (`model_class`),
  KEY `index_export_requests_on_export_name` (`export_name`),
  KEY `index_export_requests_on_export_template_id` (`export_template_id`),
  KEY `index_export_requests_on_scheduled_on` (`scheduled_on`),
  KEY `index_export_requests_on_expires_on` (`expires_on`),
  KEY `index_export_requests_on_user_id` (`user_id`),
  KEY `index_export_requests_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_resources`
--

DROP TABLE IF EXISTS `export_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_resources` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `route` varchar(255) DEFAULT NULL,
  `resolver` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_resources_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_template_news`
--

DROP TABLE IF EXISTS `export_template_news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_template_news` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `export_format` varchar(255) NOT NULL,
  `resource` varchar(255) NOT NULL,
  `template` longtext,
  `query` longtext,
  `active` tinyint(1) DEFAULT '1',
  `personal` tinyint(1) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `default` tinyint(1) DEFAULT '0',
  `modified` tinyint(1) DEFAULT '0',
  `master` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_template_news_on_name` (`name`),
  KEY `index_export_template_news_on_export_format` (`export_format`),
  KEY `index_export_template_news_on_resource` (`resource`),
  KEY `index_export_template_news_on_active` (`active`),
  KEY `index_export_template_news_on_personal` (`personal`),
  KEY `index_export_template_news_on_company_id` (`company_id`),
  KEY `index_export_template_news_on_created_by_id` (`created_by_id`),
  KEY `index_export_template_news_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_template_user_role_mappings`
--

DROP TABLE IF EXISTS `export_template_user_role_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_template_user_role_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) DEFAULT NULL,
  `user_role_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_template_user_role_mappings_on_template_id` (`template_id`),
  KEY `index_export_template_user_role_mappings_on_user_role_id` (`user_role_id`),
  KEY `index_export_template_user_role_mappings_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_templates`
--

DROP TABLE IF EXISTS `export_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_templates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `template_type` varchar(255) NOT NULL,
  `configuration` longtext,
  `model_class` varchar(255) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `personal` tinyint(1) DEFAULT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_export_templates_on_name` (`name`),
  KEY `index_export_templates_on_template_type` (`template_type`),
  KEY `index_export_templates_on_model_class` (`model_class`),
  KEY `index_export_templates_on_active` (`active`),
  KEY `index_export_templates_on_personal` (`personal`),
  KEY `index_export_templates_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_export_templates_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feature_subscriptions`
--

DROP TABLE IF EXISTS `feature_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscribable_id` int(11) NOT NULL,
  `subscribable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ocr_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `expense_management_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `gift_card_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `gift_voucher_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `meal_card_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `fuel_card_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `medical_card_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `expense_card_enabled` tinyint(1) DEFAULT '0',
  `reimbursement_card_enabled` tinyint(1) DEFAULT '0',
  `hard_copy_receipt` tinyint(1) DEFAULT '0',
  `itz_cash_d_code_enabled` tinyint(1) DEFAULT '0',
  `yes_bank_account` tinyint(1) DEFAULT NULL,
  `bank_account_reimbursement` tinyint(1) DEFAULT NULL,
  `payroll_card_enabled` tinyint(1) DEFAULT '0',
  `current_account_connected` tinyint(1) DEFAULT NULL,
  `invoicing_system` tinyint(1) DEFAULT '0',
  `travel_request` tinyint(1) DEFAULT '0',
  `budgeting_system` tinyint(1) DEFAULT '0',
  `em_tax_tracking` tinyint(1) DEFAULT '0',
  `procurement` tinyint(1) DEFAULT '0',
  `custom_currency_conversion` tinyint(1) DEFAULT '0',
  `vendor_empanelment_workflow` tinyint(1) DEFAULT '0',
  `purchase_requisition_system` tinyint(1) DEFAULT NULL,
  `bank_service_provider` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `group_entity_structure` tinyint(1) DEFAULT '0',
  `grn_enabled` tinyint(1) DEFAULT '1',
  `srn_enabled` tinyint(1) DEFAULT '0',
  `vendor_portal` tinyint(1) DEFAULT '0',
  `agreement_based_payment_system` tinyint(1) DEFAULT '0',
  `gstin_verification_enabled` tinyint(1) DEFAULT '0',
  `utility_bills_enabled` tinyint(1) DEFAULT '0',
  `analytics_system` tinyint(1) DEFAULT NULL,
  `request_encryption_enabled` tinyint(1) DEFAULT '0',
  `user_level_custom_fields` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `sso_login_enforced` tinyint(1) DEFAULT '0',
  `enforce_budget_limit` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  `awaiting_approval_summary_enabled` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_feature_subscriptions_on_subscribable_id` (`subscribable_id`),
  KEY `index_feature_subscriptions_on_subscribable_type` (`subscribable_type`),
  KEY `index_feature_subscriptions_on_grn_enabled` (`grn_enabled`),
  KEY `index_feature_subscriptions_on_srn_enabled` (`srn_enabled`),
  KEY `index_feature_subscriptions_on_vendor_portal` (`vendor_portal`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedback_types`
--

DROP TABLE IF EXISTS `feedback_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedback_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feedback_type_id` int(11) NOT NULL,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_feedbacks_on_feedback_type_id` (`feedback_type_id`),
  KEY `index_feedbacks_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_1c7059e56d` FOREIGN KEY (`feedback_type_id`) REFERENCES `feedback_types` (`id`),
  CONSTRAINT `fk_rails_c57bb6cf28` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_amounts`
--

DROP TABLE IF EXISTS `field_amounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_amounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_amounts_on_value_id` (`value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_booleans`
--

DROP TABLE IF EXISTS `field_booleans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_booleans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_category_mappings`
--

DROP TABLE IF EXISTS `field_category_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_category_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `field_configuration_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_category_mappings_on_category_id` (`category_id`),
  KEY `index_field_category_mappings_on_field_configuration_id` (`field_configuration_id`),
  CONSTRAINT `fk_rails_766f76d8a0` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`),
  CONSTRAINT `fk_rails_9b6ff772ed` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=604 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_configurations`
--

DROP TABLE IF EXISTS `field_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `field_type_id` int(11) NOT NULL,
  `mandatory` tinyint(1) NOT NULL DEFAULT '0',
  `company_id` int(11) NOT NULL,
  `configurable_id` int(11) DEFAULT NULL,
  `configurable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `field_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `default_value_id` int(11) DEFAULT NULL,
  `default_value_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `global` tinyint(1) DEFAULT '1',
  `external_reference_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_reference_id` int(11) DEFAULT NULL,
  `field_parent_type_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `root_field` tinyint(1) DEFAULT '1',
  `field_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence_number` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `printable` tinyint(1) DEFAULT '1',
  `user_level_field` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_field_configurations_on_field_type_id` (`field_type_id`),
  KEY `index_field_configurations_on_company_id` (`company_id`),
  KEY `index_field_configurations_on_configurable_id` (`configurable_id`),
  KEY `index_field_configurations_on_configurable_type` (`configurable_type`),
  CONSTRAINT `fk_rails_d39aded5c7` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_e4d392ff26` FOREIGN KEY (`field_type_id`) REFERENCES `field_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=170 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_customizations`
--

DROP TABLE IF EXISTS `field_customizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_customizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `field_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `presence` tinyint(1) NOT NULL DEFAULT '0',
  `show_in_pdf` tinyint(1) NOT NULL DEFAULT '0',
  `scopable_id` int(11) NOT NULL,
  `scopable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_customizations_on_class_name` (`class_name`),
  KEY `index_field_customizations_on_field_name` (`field_name`),
  KEY `index_field_customizations_on_enabled` (`enabled`),
  KEY `index_field_customizations_on_presence` (`presence`),
  KEY `index_field_customizations_on_show_in_pdf` (`show_in_pdf`),
  KEY `index_field_customizations_on_scopable_type_and_scopable_id` (`scopable_type`,`scopable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_date_times`
--

DROP TABLE IF EXISTS `field_date_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_date_times` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_dates`
--

DROP TABLE IF EXISTS `field_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` date NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_decimals`
--

DROP TABLE IF EXISTS `field_decimals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_decimals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_drop_down_items`
--

DROP TABLE IF EXISTS `field_drop_down_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_drop_down_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `field_configuration_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `field_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_drop_down_items_on_field_configuration_id` (`field_configuration_id`),
  CONSTRAINT `fk_rails_7b91b9c732` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_drop_down_selections`
--

DROP TABLE IF EXISTS `field_drop_down_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_drop_down_selections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_drop_down_selections_on_value_id` (`value_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11421 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_multiselect_items`
--

DROP TABLE IF EXISTS `field_multiselect_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_multiselect_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `field_configuration_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_multiselect_selection_items`
--

DROP TABLE IF EXISTS `field_multiselect_selection_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_multiselect_selection_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `field_multiselect_selection_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_multiselect_selection_items_on_value_id` (`value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_multiselect_selections`
--

DROP TABLE IF EXISTS `field_multiselect_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_multiselect_selections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_numbers`
--

DROP TABLE IF EXISTS `field_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_parent_mappings`
--

DROP TABLE IF EXISTS `field_parent_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_parent_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_configuration_id` int(11) NOT NULL,
  `field_parent_type_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_parent_mappings_on_field_configuration_id` (`field_configuration_id`),
  KEY `index_field_parent_mappings_on_field_parent_type_id` (`field_parent_type_id`),
  CONSTRAINT `fk_rails_082777be6f` FOREIGN KEY (`field_parent_type_id`) REFERENCES `field_parent_types` (`id`),
  CONSTRAINT `fk_rails_2838f739c9` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_parent_type_mappings`
--

DROP TABLE IF EXISTS `field_parent_type_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_parent_type_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_parent_type_id` int(11) NOT NULL,
  `field_configuration_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_parent_type_mappings_on_field_parent_type_id` (`field_parent_type_id`),
  KEY `index_field_parent_type_mappings_on_field_configuration_id` (`field_configuration_id`),
  CONSTRAINT `fk_rails_ab70f42d3b` FOREIGN KEY (`field_parent_type_id`) REFERENCES `field_parent_types` (`id`),
  CONSTRAINT `fk_rails_c2058c21bb` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_parent_types`
--

DROP TABLE IF EXISTS `field_parent_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_parent_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_texts`
--

DROP TABLE IF EXISTS `field_texts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_texts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41869 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_types`
--

DROP TABLE IF EXISTS `field_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `finly_transactions`
--

DROP TABLE IF EXISTS `finly_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `finly_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `finly_account_id` int(11) NOT NULL,
  `finly_account_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_type_id` int(11) NOT NULL,
  `amount_id` int(11) NOT NULL,
  `transaction_reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `status_id` int(11) NOT NULL,
  `payment_purpose_id` int(11) NOT NULL,
  `opening_balance_id` int(11) DEFAULT NULL,
  `closing_balance_id` int(11) DEFAULT NULL,
  `associated_transaction_id` int(11) DEFAULT NULL,
  `associated_transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `date` datetime DEFAULT NULL,
  `sequence_number` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_finly_transactions_on_finly_account_id` (`finly_account_id`),
  KEY `index_finly_transactions_on_finly_account_type` (`finly_account_type`),
  KEY `index_finly_transactions_on_transaction_type_id` (`transaction_type_id`),
  KEY `index_finly_transactions_on_amount_id` (`amount_id`),
  KEY `index_finly_transactions_on_transaction_reference_id` (`transaction_reference_id`),
  KEY `index_finly_transactions_on_status_id` (`status_id`),
  KEY `index_finly_transactions_on_payment_purpose_id` (`payment_purpose_id`),
  KEY `index_finly_transactions_on_opening_balance_id` (`opening_balance_id`),
  KEY `index_finly_transactions_on_closing_balance_id` (`closing_balance_id`),
  KEY `index_finly_transactions_on_associated_transaction_id` (`associated_transaction_id`),
  KEY `index_finly_transactions_on_associated_transaction_type` (`associated_transaction_type`),
  KEY `index_finly_transactions_on_payment_id` (`payment_id`),
  KEY `index_finly_transactions_on_company_id` (`company_id`),
  KEY `index_finly_transactions_on_deleted_at` (`deleted_at`),
  KEY `index_transactions_on_account` (`finly_account_type`,`finly_account_id`),
  CONSTRAINT `fk_rails_13dd6f0e29` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_32a3ad4804` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_703b2649fa` FOREIGN KEY (`transaction_type_id`) REFERENCES `transaction_types` (`id`),
  CONSTRAINT `fk_rails_899b41fa68` FOREIGN KEY (`payment_purpose_id`) REFERENCES `payment_purposes` (`id`),
  CONSTRAINT `fk_rails_cbf70a5a45` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2708 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_choice_dependencies`
--

DROP TABLE IF EXISTS `form_choice_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_choice_dependencies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `dependent_entity_id` varchar(36) NOT NULL,
  `controlling_entity_id` varchar(36) NOT NULL,
  `dependency_id` varchar(255) DEFAULT NULL,
  `custom` tinyint(1) DEFAULT NULL,
  `is_updated` tinyint(1) DEFAULT NULL,
  `can_be_updated` tinyint(1) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `internal` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_choice_dependencies_on_uuid` (`uuid`),
  KEY `index_form_choice_dependencies_on_company_id` (`company_id`),
  KEY `index_form_choice_dependencies_on_form_id` (`form_id`),
  KEY `index_form_choice_dependencies_on_dependent_entity_id` (`dependent_entity_id`),
  KEY `index_form_choice_dependencies_on_controlling_entity_id` (`controlling_entity_id`),
  KEY `index_form_choice_dependencies_on_dependency_id` (`dependency_id`),
  KEY `index_form_choice_dependencies_on_created_by_id` (`created_by_id`),
  KEY `index_form_choice_dependencies_on_updated_by_id` (`updated_by_id`),
  KEY `index_form_choice_dependencies_on_deleted_at` (`deleted_at`),
  KEY `index_form_choice_dependencies_on_created_at` (`created_at`),
  KEY `index_form_choice_dependencies_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_choice_dependency_mappings`
--

DROP TABLE IF EXISTS `form_choice_dependency_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_choice_dependency_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dependency_id` varchar(36) DEFAULT NULL,
  `dependent_choice_id` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `controlling_choice_id` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_choice_dependency_mappings_on_dependency_id` (`dependency_id`),
  KEY `index_form_choice_dependency_mappings_on_dependent_choice_id` (`dependent_choice_id`),
  KEY `index_form_choice_dependency_mappings_on_deleted_at` (`deleted_at`),
  KEY `index_form_choice_dependency_mappings_on_created_at` (`created_at`),
  KEY `index_form_choice_dependency_mappings_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=364 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_condition_actions`
--

DROP TABLE IF EXISTS `form_condition_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_condition_actions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `form_condition_id` varchar(255) DEFAULT NULL,
  `property` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_condition_actions_on_uuid` (`uuid`),
  KEY `index_form_condition_actions_on_company_id` (`company_id`),
  KEY `index_form_condition_actions_on_form_id` (`form_id`),
  KEY `index_form_condition_actions_on_form_condition_id` (`form_condition_id`),
  KEY `index_form_condition_actions_on_created_at` (`created_at`),
  KEY `index_form_condition_actions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5621 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_condition_types`
--

DROP TABLE IF EXISTS `form_condition_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_condition_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_condition_types_on_name` (`name`),
  KEY `index_form_condition_types_on_deleted_at` (`deleted_at`),
  KEY `index_form_condition_types_on_created_at` (`created_at`),
  KEY `index_form_condition_types_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_conditions`
--

DROP TABLE IF EXISTS `form_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_conditions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `condition_id` varchar(255) DEFAULT NULL,
  `custom` tinyint(1) DEFAULT NULL,
  `internal` tinyint(1) DEFAULT NULL,
  `is_updated` tinyint(1) DEFAULT NULL,
  `can_be_updated` tinyint(1) DEFAULT NULL,
  `rule` text,
  `referencable_id` varchar(255) DEFAULT NULL,
  `referencable_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_conditions_on_uuid` (`uuid`),
  KEY `index_form_conditions_on_company_id` (`company_id`),
  KEY `index_form_conditions_on_form_id` (`form_id`),
  KEY `index_form_conditions_on_created_by_id` (`created_by_id`),
  KEY `index_form_conditions_on_updated_by_id` (`updated_by_id`),
  KEY `index_form_conditions_on_deleted_at` (`deleted_at`),
  KEY `index_form_conditions_on_created_at` (`created_at`),
  KEY `index_form_conditions_on_updated_at` (`updated_at`),
  KEY `index_form_conditions_on_referencable_id_and_referencable_type` (`referencable_id`,`referencable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2133 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_currencies`
--

DROP TABLE IF EXISTS `form_currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_currencies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `currency` varchar(255) DEFAULT NULL,
  `currency_code` varchar(255) DEFAULT NULL,
  `symbol` varchar(255) DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_currencies_on_company_id` (`company_id`),
  KEY `index_form_currencies_on_created_at` (`created_at`),
  KEY `index_form_currencies_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=505 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_custom_fields`
--

DROP TABLE IF EXISTS `form_custom_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_custom_fields` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `document_type` varchar(255) DEFAULT NULL,
  `document_id` varchar(255) DEFAULT NULL,
  `form_id` varchar(255) NOT NULL,
  `form_entity_id` varchar(255) NOT NULL,
  `field_key` varchar(255) NOT NULL,
  `value` text,
  `value_text` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_custom_fields_on_uuid` (`uuid`),
  KEY `index_form_custom_fields_on_document_type` (`document_type`),
  KEY `index_form_custom_fields_on_document_id` (`document_id`),
  KEY `index_form_custom_fields_on_form_id` (`form_id`),
  KEY `index_form_custom_fields_on_form_entity_id` (`form_entity_id`),
  KEY `index_form_custom_fields_on_field_key` (`field_key`),
  KEY `index_form_custom_fields_on_value_text` (`value_text`),
  KEY `index_form_custom_fields_on_document_type_and_document_id` (`document_type`,`document_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2909 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_entities`
--

DROP TABLE IF EXISTS `form_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_entities` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` int(11) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `form_section_id` varchar(36) NOT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `entity_key` varchar(255) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `placeholder` varchar(255) DEFAULT NULL,
  `hint` varchar(255) DEFAULT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  `default_value` varchar(255) DEFAULT NULL,
  `editable` tinyint(1) DEFAULT NULL,
  `required` tinyint(1) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `unique` tinyint(1) DEFAULT NULL,
  `visible` tinyint(1) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `system_field` tinyint(1) DEFAULT NULL,
  `can_visible_be_changed` tinyint(1) DEFAULT NULL,
  `can_editable_be_changed` tinyint(1) DEFAULT NULL,
  `can_required_be_changed` tinyint(1) DEFAULT NULL,
  `can_uniqueness_be_changed` tinyint(1) DEFAULT NULL,
  `can_be_disabled` tinyint(1) DEFAULT NULL,
  `can_label_be_renamed` tinyint(1) DEFAULT NULL,
  `can_choices_be_changed` tinyint(1) DEFAULT NULL,
  `allow_clearing_default_value` tinyint(1) DEFAULT NULL,
  `options` text,
  `data_provider` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `choices_scope` text,
  `internal` tinyint(1) DEFAULT '0',
  `is_modified` tinyint(1) DEFAULT '0',
  `entity_path` varchar(255) DEFAULT NULL,
  `parent_id` varchar(255) DEFAULT NULL,
  `populate_if_empty` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `config` text,
  `associate_custom_fields` tinyint(1) DEFAULT NULL,
  `compute_enabled` tinyint(1) DEFAULT NULL,
  `compute_type_id` int(11) DEFAULT NULL,
  `compute_lookup_entity_id` varchar(255) DEFAULT NULL,
  `compute_formula` text,
  `filters` text,
  `config_path` varchar(255) DEFAULT NULL,
  `compute_lookup_assignments` text,
  PRIMARY KEY (`id`),
  KEY `index_form_entities_on_uuid` (`uuid`),
  KEY `index_form_entities_on_company_id` (`company_id`),
  KEY `index_form_entities_on_form_id` (`form_id`),
  KEY `index_form_entities_on_form_section_id` (`form_section_id`),
  KEY `index_form_entities_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_form_entities_on_entity_key` (`entity_key`),
  KEY `index_form_entities_on_deleted_at` (`deleted_at`),
  KEY `index_form_entities_on_created_at` (`created_at`),
  KEY `index_form_entities_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5410 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_entity_choices`
--

DROP TABLE IF EXISTS `form_entity_choices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_entity_choices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` int(11) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `form_section_id` varchar(36) NOT NULL,
  `form_entity_id` varchar(36) NOT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `position` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_entity_choices_on_uuid` (`uuid`),
  KEY `index_form_entity_choices_on_company_id` (`company_id`),
  KEY `index_form_entity_choices_on_form_id` (`form_id`),
  KEY `index_form_entity_choices_on_form_section_id` (`form_section_id`),
  KEY `index_form_entity_choices_on_form_entity_id` (`form_entity_id`),
  KEY `index_form_entity_choices_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_form_entity_choices_on_active` (`active`),
  KEY `index_form_entity_choices_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_entity_computation_types`
--

DROP TABLE IF EXISTS `form_entity_computation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_entity_computation_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_entity_computation_types_on_name` (`name`),
  KEY `index_form_entity_computation_types_on_deleted_at` (`deleted_at`),
  KEY `index_form_entity_computation_types_on_created_at` (`created_at`),
  KEY `index_form_entity_computation_types_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_entity_validations`
--

DROP TABLE IF EXISTS `form_entity_validations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_entity_validations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `error_message` varchar(255) NOT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `validation_id` varchar(255) DEFAULT NULL,
  `system_validation` tinyint(1) DEFAULT NULL,
  `internal` tinyint(1) DEFAULT NULL,
  `is_updated` tinyint(1) DEFAULT NULL,
  `can_be_updated` tinyint(1) DEFAULT NULL,
  `rule` text,
  `form_entity_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_entity_validations_on_uuid` (`uuid`),
  KEY `index_form_entity_validations_on_company_id` (`company_id`),
  KEY `index_form_entity_validations_on_form_id` (`form_id`),
  KEY `index_form_entity_validations_on_created_by_id` (`created_by_id`),
  KEY `index_form_entity_validations_on_updated_by_id` (`updated_by_id`),
  KEY `index_form_entity_validations_on_deleted_at` (`deleted_at`),
  KEY `index_form_entity_validations_on_created_at` (`created_at`),
  KEY `index_form_entity_validations_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_rule_types`
--

DROP TABLE IF EXISTS `form_rule_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_rule_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_rule_types_on_name` (`name`),
  KEY `index_form_rule_types_on_deleted_at` (`deleted_at`),
  KEY `index_form_rule_types_on_created_at` (`created_at`),
  KEY `index_form_rule_types_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_rules`
--

DROP TABLE IF EXISTS `form_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_rules` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `rule_parent_id` varchar(255) NOT NULL,
  `rule_parent_type` varchar(255) NOT NULL,
  `entity_path` varchar(255) NOT NULL,
  `predicate` varchar(255) NOT NULL,
  `rule_type_id` int(11) NOT NULL,
  `match_value` text,
  `match_formula` varchar(255) DEFAULT NULL,
  `match_entity_path` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_rules_on_company_id` (`company_id`),
  KEY `index_form_rules_on_form_id` (`form_id`),
  KEY `index_form_rules_on_rule_parent_id` (`rule_parent_id`),
  KEY `index_form_rules_on_rule_parent_type` (`rule_parent_type`),
  KEY `index_form_rules_on_entity_path` (`entity_path`),
  KEY `index_form_rules_on_rule_type_id` (`rule_type_id`),
  KEY `index_form_rules_on_match_entity_path` (`match_entity_path`),
  KEY `index_form_rules_on_deleted_at` (`deleted_at`),
  KEY `index_form_rules_on_created_at` (`created_at`),
  KEY `index_form_rules_on_updated_at` (`updated_at`),
  KEY `index_form_rules_on_rule_parent_id_and_rule_parent_type` (`rule_parent_id`,`rule_parent_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_sections`
--

DROP TABLE IF EXISTS `form_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_sections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `section_id` varchar(255) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `company_id` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `associate_custom_fields` tinyint(1) DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_form_sections_on_uuid` (`uuid`),
  KEY `index_form_sections_on_section_id` (`section_id`),
  KEY `index_form_sections_on_form_id` (`form_id`),
  KEY `index_form_sections_on_company_id` (`company_id`),
  KEY `index_form_sections_on_active` (`active`),
  KEY `index_form_sections_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=614 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `forms`
--

DROP TABLE IF EXISTS `forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forms` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `klass_name` varchar(255) NOT NULL,
  `model` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_forms_on_uuid` (`uuid`),
  KEY `index_forms_on_klass_name` (`klass_name`),
  KEY `index_forms_on_model` (`model`),
  KEY `index_forms_on_company_id` (`company_id`),
  KEY `index_forms_on_deleted_at` (`deleted_at`),
  KEY `index_forms_on_created_at` (`created_at`),
  KEY `index_forms_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gatekeeper_blocks`
--

DROP TABLE IF EXISTS `gatekeeper_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gatekeeper_blocks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `params` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `headers` text,
  `act` varchar(255) DEFAULT NULL,
  `premise` varchar(255) DEFAULT NULL,
  `verdict` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rule` varchar(255) DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT '1',
  `admin_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gatekeeper_blocks_on_user_id` (`user_id`),
  KEY `index_gatekeeper_blocks_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `general_invoices`
--

DROP TABLE IF EXISTS `general_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `general_invoices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `auto_pay` tinyint(1) DEFAULT NULL,
  `note` text,
  `billing_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `address_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `invoice_number` text,
  `tax_type_id` int(11) DEFAULT NULL,
  `discount` decimal(64,12) DEFAULT NULL,
  `discount_type_id` int(11) DEFAULT NULL,
  `gross_amount_id` int(11) DEFAULT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `tds` decimal(64,12) DEFAULT NULL,
  `tds_type_id` int(11) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `tax` decimal(64,12) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `original_amount_id` int(11) DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `advance_type_id` int(11) DEFAULT NULL,
  `advance` decimal(20,10) DEFAULT NULL,
  `freight_amount_id` int(11) DEFAULT NULL,
  `freight_type_id` int(11) DEFAULT NULL,
  `freight` decimal(20,10) DEFAULT NULL,
  `roundoff_amount` decimal(20,10) DEFAULT NULL,
  `balance_due_id` int(11) DEFAULT NULL,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `invoice_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `paid_amount_id` int(11) DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `receiving_account_type` varchar(255) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `remaining_amount_id` int(11) DEFAULT NULL,
  `invoice_type_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `is_template` tinyint(1) DEFAULT '0',
  `template_name` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `resource_template_id` int(11) DEFAULT NULL,
  `invoice_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `gstin_location_id` int(11) DEFAULT NULL,
  `transaction_service_period_from` date DEFAULT NULL,
  `transaction_service_period_to` date DEFAULT NULL,
  `cost_allocation_items` tinyint(1) DEFAULT '0',
  `narration` text,
  `po_number` varchar(255) DEFAULT NULL,
  `payment_agreement_id` int(11) DEFAULT NULL,
  `bank_account_id` int(11) DEFAULT NULL,
  `vendor_location_id` int(11) DEFAULT NULL,
  `rejection_note` text,
  `invoice_frequency_id` int(11) DEFAULT NULL,
  `billing_start_date` datetime DEFAULT NULL,
  `billing_day_of_month` int(11) DEFAULT NULL,
  `payment_agreement_upcoming_date` date DEFAULT NULL,
  `is_payment_agreement_upcoming_invoice` tinyint(1) DEFAULT NULL,
  `recurring_invoice_id` int(11) DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  `client_note` text,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `lock_in_period` int(11) DEFAULT NULL,
  `rent_free_period` int(11) DEFAULT NULL,
  `tenancy_period` int(11) DEFAULT NULL,
  `po_adjusted_advance` int(11) DEFAULT NULL,
  `po_advance` int(11) DEFAULT NULL,
  `po_prev_adjusted_advance` int(11) DEFAULT NULL,
  `advance_amount_required` tinyint(1) DEFAULT NULL,
  `proforma_invoice_id` int(11) DEFAULT NULL,
  `proforma_advance` int(11) DEFAULT NULL,
  `total_proforma_advance` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `template_invoice_id` int(11) DEFAULT NULL,
  `prepaid` tinyint(1) DEFAULT NULL,
  `fixed_periodic_template` tinyint(1) DEFAULT NULL,
  `escalation_percentage` float DEFAULT NULL,
  `override_invoice_id` varchar(255) DEFAULT NULL,
  `total_invoice_amount_id` int(11) DEFAULT NULL,
  `available_invoice_amount_id` int(11) DEFAULT NULL,
  `include_tax_and_tds` tinyint(1) DEFAULT '0',
  `rcm_enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_general_invoices_on_template_invoice_id` (`template_invoice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `google_maps_configs`
--

DROP TABLE IF EXISTS `google_maps_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_maps_configs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `device` varchar(255) NOT NULL,
  `api_token` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_google_maps_configs_on_device` (`device`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gst_state_codes`
--

DROP TABLE IF EXISTS `gst_state_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gst_state_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gst_types`
--

DROP TABLE IF EXISTS `gst_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gst_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gst_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gstin_locations`
--

DROP TABLE IF EXISTS `gstin_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gstin_locations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gstin_id` int(11) DEFAULT NULL,
  `gstin` varchar(255) DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `poc_name` varchar(255) DEFAULT NULL,
  `poc_mobile_number` varchar(255) DEFAULT NULL,
  `poc_email` varchar(255) DEFAULT NULL,
  `poc_fax` varchar(255) DEFAULT NULL,
  `poc_designation` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `address` text,
  `deleted_at` datetime DEFAULT NULL,
  `gst_status` varchar(255) DEFAULT NULL,
  `gst_expiry_date` date DEFAULT NULL,
  `verified` tinyint(1) DEFAULT NULL,
  `gstin_fetch_details` text,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gstin_locations_on_vendor_id` (`vendor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=322 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gstins`
--

DROP TABLE IF EXISTS `gstins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gstins` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gstin` varchar(255) DEFAULT NULL,
  `legal_name_of_business` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `date_of_registration` date DEFAULT NULL,
  `constitution_of_business` varchar(255) DEFAULT NULL,
  `taxpayer_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `api_response` mediumtext,
  `api_provider` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `address` text,
  `trade_name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1248 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icici_bank_company_accounts`
--

DROP TABLE IF EXISTS `icici_bank_company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icici_bank_company_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icici_bank_configs`
--

DROP TABLE IF EXISTS `icici_bank_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icici_bank_configs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `alias_id` varchar(255) DEFAULT NULL,
  `urn` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icici_bank_transactions`
--

DROP TABLE IF EXISTS `icici_bank_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icici_bank_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `aggr_id` varchar(255) DEFAULT NULL,
  `aggr_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `corp_id` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `debit_acc` varchar(255) DEFAULT NULL,
  `credit_acc` varchar(255) DEFAULT NULL,
  `txn_type` varchar(255) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `ifsc` varchar(255) DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `otp` varchar(255) DEFAULT NULL,
  `payee_name` text,
  `remarks` text,
  `customer_induced` tinyint(1) DEFAULT NULL,
  `transfer_type` varchar(255) DEFAULT NULL,
  `unique_request_number` varchar(255) DEFAULT NULL,
  `utr` varchar(255) DEFAULT NULL,
  `transfer_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `request_id` varchar(255) DEFAULT NULL,
  `transfer_mode_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `bank_error_message` mediumtext,
  PRIMARY KEY (`id`),
  KEY `index_icici_bank_transactions_on_transfer_mode_id` (`transfer_mode_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icici_statements`
--

DROP TABLE IF EXISTS `icici_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icici_statements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cheque_no` varchar(255) DEFAULT NULL,
  `txn_date` datetime DEFAULT NULL,
  `amount` decimal(20,10) DEFAULT NULL,
  `balance` decimal(20,10) DEFAULT NULL,
  `value_date` datetime DEFAULT NULL,
  `transaction_type` varchar(255) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `request_id` varchar(255) DEFAULT NULL,
  `bank_transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `remarks` text,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icici_transaction_callbacks`
--

DROP TABLE IF EXISTS `icici_transaction_callbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icici_transaction_callbacks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `AGGRNAME` varchar(255) DEFAULT NULL,
  `AGGRID` varchar(255) DEFAULT NULL,
  `URN` varchar(255) DEFAULT NULL,
  `UNIQUEID` varchar(255) DEFAULT NULL,
  `REQUESTID` varchar(255) DEFAULT NULL,
  `TXNSTATUS` varchar(255) DEFAULT NULL,
  `UTRNUMBER` varchar(255) DEFAULT NULL,
  `CORPID` varchar(255) DEFAULT NULL,
  `USERID` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `reconciled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `index_view_segments`
--

DROP TABLE IF EXISTS `index_view_segments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `index_view_segments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `screen` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `filters` text,
  `columns` text,
  `system_view` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `last_viewed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `default` tinyint(1) DEFAULT '0',
  `application` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_index_view_segments_on_uuid` (`uuid`),
  KEY `index_index_view_segments_on_screen` (`screen`),
  KEY `index_index_view_segments_on_name` (`name`),
  KEY `index_index_view_segments_on_system_view` (`system_view`),
  KEY `index_index_view_segments_on_company_id` (`company_id`),
  KEY `index_index_view_segments_on_user_id` (`user_id`),
  KEY `index_index_view_segments_on_last_viewed_at` (`last_viewed_at`),
  KEY `index_index_view_segments_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `individual_kyc_track_actions`
--

DROP TABLE IF EXISTS `individual_kyc_track_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual_kyc_track_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_individual_kyc_track_actions_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `individual_kyc_tracks`
--

DROP TABLE IF EXISTS `individual_kyc_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual_kyc_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `individual_kyc_id` int(11) NOT NULL,
  `action_resource_id` int(11) DEFAULT NULL,
  `action_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_id` int(11) NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_individual_kyc_tracks_on_individual_kyc_id` (`individual_kyc_id`),
  KEY `index_individual_kyc_tracks_on_action_resource_id` (`action_resource_id`),
  KEY `index_individual_kyc_tracks_on_action_resource_type` (`action_resource_type`),
  KEY `index_individual_kyc_tracks_on_action_id` (`action_id`),
  CONSTRAINT `fk_rails_fc781ecd3b` FOREIGN KEY (`individual_kyc_id`) REFERENCES `individual_kycs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `individual_kyc_types`
--

DROP TABLE IF EXISTS `individual_kyc_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual_kyc_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `individual_kycs`
--

DROP TABLE IF EXISTS `individual_kycs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual_kycs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kyc_status_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `address_proof_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_proof_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_proof_file_size` int(11) DEFAULT NULL,
  `address_proof_updated_at` datetime DEFAULT NULL,
  `review_position` int(11) DEFAULT NULL,
  `admin_review_workflow_id` int(11) NOT NULL,
  `upgraded_by_resource_id` int(11) DEFAULT NULL,
  `proof_file_1_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `proof_file_1_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `proof_file_1_file_size` int(11) DEFAULT NULL,
  `proof_file_1_updated_at` datetime DEFAULT NULL,
  `proof_file_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `proof_file_2_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `proof_file_2_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `proof_file_2_file_size` int(11) DEFAULT NULL,
  `proof_file_2_updated_at` datetime DEFAULT NULL,
  `proof_file_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `kyc_file_1_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_file_1_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_file_1_file_size` int(11) DEFAULT NULL,
  `kyc_file_1_updated_at` datetime DEFAULT NULL,
  `kyc_file_2_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_file_2_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_file_2_file_size` int(11) DEFAULT NULL,
  `kyc_file_2_updated_at` datetime DEFAULT NULL,
  `kyc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `admin_note` text COLLATE utf8_unicode_ci,
  `submitted_on` datetime DEFAULT NULL,
  `upgraded_on` datetime DEFAULT NULL,
  `aadhar_front_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_front_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_front_file_size` int(11) DEFAULT NULL,
  `aadhar_front_updated_at` datetime DEFAULT NULL,
  `aadhar_back_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_back_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aadhar_back_file_size` int(11) DEFAULT NULL,
  `aadhar_back_updated_at` datetime DEFAULT NULL,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `signature_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature_file_size` int(11) DEFAULT NULL,
  `signature_updated_at` datetime DEFAULT NULL,
  `combined_kyc_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `combined_kyc_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `combined_kyc_file_size` int(11) DEFAULT NULL,
  `combined_kyc_updated_at` datetime DEFAULT NULL,
  `kyc_1_front_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_1_front_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_1_front_file_size` int(11) DEFAULT NULL,
  `kyc_1_front_updated_at` datetime DEFAULT NULL,
  `kyc_1_back_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_1_back_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_1_back_file_size` int(11) DEFAULT NULL,
  `kyc_1_back_updated_at` datetime DEFAULT NULL,
  `kyc_2_front_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_2_front_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_2_front_file_size` int(11) DEFAULT NULL,
  `kyc_2_front_updated_at` datetime DEFAULT NULL,
  `kyc_2_back_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_2_back_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_2_back_file_size` int(11) DEFAULT NULL,
  `kyc_2_back_updated_at` datetime DEFAULT NULL,
  `kyc_1_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kyc_2_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `initiated` tinyint(1) DEFAULT NULL,
  `id_proof_front_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id_proof_front_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id_proof_front_file_size` bigint(20) DEFAULT NULL,
  `id_proof_front_updated_at` datetime DEFAULT NULL,
  `id_proof_back_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id_proof_back_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id_proof_back_file_size` bigint(20) DEFAULT NULL,
  `id_proof_back_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_individual_kycs_on_user_id` (`user_id`),
  KEY `index_individual_kycs_on_admin_review_workflow_id` (`admin_review_workflow_id`),
  KEY `index_individual_kycs_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_0ba75e4c33` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_96602f6f29` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_c85f3af3d0` FOREIGN KEY (`admin_review_workflow_id`) REFERENCES `admin_review_workflows` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insight_dashboards`
--

DROP TABLE IF EXISTS `insight_dashboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insight_dashboards` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `user_role_id` int(11) DEFAULT NULL,
  `application` varchar(255) NOT NULL,
  `dashboard` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `app` varchar(255) DEFAULT NULL,
  `admin_user_id` int(11) DEFAULT NULL,
  `priority` int(11) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `can_filter_date` tinyint(1) DEFAULT NULL,
  `can_filter_policy` tinyint(1) DEFAULT '0',
  `can_filter_department` tinyint(1) DEFAULT '0',
  `can_filter_location` tinyint(1) DEFAULT '0',
  `can_filter_cost_center` tinyint(1) DEFAULT '0',
  `can_filter_category` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_insight_dashboards_on_uuid` (`uuid`),
  KEY `index_insight_dashboards_on_company_id` (`company_id`),
  KEY `index_insight_dashboards_on_user_id` (`user_id`),
  KEY `index_insight_dashboards_on_policy_id` (`policy_id`),
  KEY `index_insight_dashboards_on_user_role_id` (`user_role_id`),
  KEY `index_insight_dashboards_on_application` (`application`),
  KEY `index_insight_dashboards_on_dashboard` (`dashboard`),
  KEY `index_insight_dashboards_on_name` (`name`),
  KEY `index_insight_dashboards_on_app` (`app`),
  KEY `index_insight_dashboards_on_admin_user_id` (`admin_user_id`),
  KEY `index_insight_dashboards_on_priority` (`priority`),
  KEY `index_insight_dashboards_on_deleted_at` (`deleted_at`),
  KEY `index_insight_dashboards_on_active` (`active`),
  KEY `index_insight_dashboards_on_created_at` (`created_at`),
  KEY `index_insight_dashboards_on_updated_at` (`updated_at`),
  CONSTRAINT `fk_rails_196839ba8a` FOREIGN KEY (`user_role_id`) REFERENCES `user_roles` (`id`),
  CONSTRAINT `fk_rails_48ef95e90c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c105924996` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_c27718b94f` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invites`
--

DROP TABLE IF EXISTS `invites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invites` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `token` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `expires_at` datetime NOT NULL DEFAULT '2019-09-05 00:00:00',
  `accepted_at` datetime DEFAULT NULL,
  `accepted` tinyint(1) DEFAULT '0',
  `company_id` int(11) NOT NULL,
  `gstin_location_id` int(11) NOT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  `expired` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_invites_on_token` (`token`),
  KEY `index_invites_on_email` (`email`),
  KEY `index_invites_on_user_id` (`user_id`),
  KEY `index_invites_on_vendor_id` (`vendor_id`),
  KEY `index_invites_on_gstin_location_id` (`gstin_location_id`),
  KEY `index_invites_on_expired` (`expired`),
  KEY `index_invites_on_company_id` (`company_id`),
  KEY `index_invites_on_accepted` (`accepted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_attachments`
--

DROP TABLE IF EXISTS `invoice_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attached_file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_file_size` int(11) DEFAULT NULL,
  `attached_file_updated_at` datetime DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoice_attachments_on_invoice_id` (`invoice_id`),
  CONSTRAINT `fk_rails_e84fe2a3e5` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_frequencies`
--

DROP TABLE IF EXISTS `invoice_frequencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_frequencies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `number` int(11) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoice_frequencies_on_period_id` (`period_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_line_items`
--

DROP TABLE IF EXISTS `invoice_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_line_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `quantity` decimal(20,5) DEFAULT NULL,
  `rate` decimal(20,10) DEFAULT NULL,
  `tax` decimal(20,10) DEFAULT NULL,
  `discount` decimal(20,10) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `hsn_sac` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `inventory_line_item_id` int(11) DEFAULT NULL,
  `item_info` text COLLATE utf8_unicode_ci,
  `comment` text COLLATE utf8_unicode_ci,
  `account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `buying_price` decimal(10,5) DEFAULT NULL,
  `markup` decimal(10,5) DEFAULT NULL,
  `profit` decimal(10,5) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `brand` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `model_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_of_inward` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `year_of_registration` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kms_driven` decimal(10,5) DEFAULT NULL,
  `expected_selling_price` decimal(10,5) DEFAULT NULL,
  `owner_details` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parking_charges` decimal(10,5) DEFAULT NULL,
  `billable` tinyint(1) DEFAULT NULL,
  `registration_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `unit_of_measurement` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `sgst` decimal(20,5) DEFAULT '0.00000',
  `cgst` decimal(20,5) DEFAULT '0.00000',
  `igst` decimal(20,5) DEFAULT '0.00000',
  `billable_amount_id` int(11) DEFAULT NULL,
  `purchase_order_item_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `tds_applicable` tinyint(1) DEFAULT '0',
  `discount_rate` decimal(10,0) DEFAULT NULL,
  `tax_percentage` decimal(20,5) DEFAULT NULL,
  `item_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_type_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gl_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `item_tds_amount` decimal(20,5) DEFAULT NULL,
  `item_net_amount` decimal(20,5) DEFAULT NULL,
  `item_tax_amount` decimal(20,5) DEFAULT NULL,
  `item_taxable_amount` decimal(20,5) DEFAULT NULL,
  `item_discount_amount` decimal(20,5) DEFAULT NULL,
  `item_gross_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_gross_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_discount_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_taxable_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_tax_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_tds_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_net_amount` decimal(20,5) DEFAULT NULL,
  `item_billable_amount` decimal(20,5) DEFAULT NULL,
  `reporting_item_billable_amount` decimal(20,5) DEFAULT NULL,
  `tax_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `item_rate` decimal(20,5) DEFAULT '0.00000',
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoice_line_items_on_invoice_id` (`invoice_id`),
  KEY `index_invoice_line_items_on_category_id` (`category_id`),
  KEY `index_invoice_line_items_on_gst_type_id` (`gst_type_id`),
  KEY `index_invoice_line_items_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_invoice_line_items_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_invoice_line_items_on_department_id` (`department_id`),
  KEY `index_invoice_line_items_on_purchase_order_item_id` (`purchase_order_item_id`),
  CONSTRAINT `fk_rails_450c9f5e1b` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_80427eb9d3` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3375 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_number_config_types`
--

DROP TABLE IF EXISTS `invoice_number_config_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_number_config_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_number_configs`
--

DROP TABLE IF EXISTS `invoice_number_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_number_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `invoice_number_config_type_id` int(11) DEFAULT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoice_number_configs_on_invoice_number_config_type_id` (`invoice_number_config_type_id`),
  KEY `index_invoice_number_configs_on_purpose_id` (`purpose_id`),
  CONSTRAINT `fk_rails_01e1dd4b51` FOREIGN KEY (`invoice_number_config_type_id`) REFERENCES `invoice_number_config_types` (`id`),
  CONSTRAINT `fk_rails_4ccf00261a` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_reminders`
--

DROP TABLE IF EXISTS `invoice_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `days` int(11) DEFAULT NULL,
  `reference_date_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timeframe_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_transaction_mappings`
--

DROP TABLE IF EXISTS `invoice_transaction_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_transaction_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) DEFAULT NULL,
  `va_transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoice_transaction_mappings_on_invoice_id` (`invoice_id`),
  KEY `index_invoice_transaction_mappings_on_va_transaction_id` (`va_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `invoice_number` text COLLATE utf8_unicode_ci,
  `tax_type_id` int(11) DEFAULT NULL,
  `discount` decimal(64,12) DEFAULT NULL,
  `discount_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gross_amount_id` int(11) DEFAULT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `tds` decimal(64,12) DEFAULT NULL,
  `tds_type_id` int(11) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `tax` decimal(64,12) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `original_amount_id` int(11) DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `advance_type_id` int(11) DEFAULT NULL,
  `advance` decimal(20,10) DEFAULT NULL,
  `freight_amount_id` int(11) DEFAULT NULL,
  `freight_type_id` int(11) DEFAULT NULL,
  `freight` decimal(20,10) DEFAULT NULL,
  `roundoff_amount` decimal(20,10) DEFAULT NULL,
  `balance_due_id` int(11) DEFAULT NULL,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `invoice_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `paid_amount_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `receiving_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `procurement_id` int(11) DEFAULT NULL,
  `remaining_amount_id` int(11) DEFAULT NULL,
  `invoice_type_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `controlling_user_id` int(11) DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `billing_address` text COLLATE utf8_unicode_ci,
  `shipping_address` text COLLATE utf8_unicode_ci,
  `is_template` tinyint(1) DEFAULT '0',
  `template_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `resource_template_id` int(11) DEFAULT NULL,
  `invoice_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `po_adjusted_advance` int(11) DEFAULT NULL,
  `po_advance` decimal(20,2) DEFAULT NULL,
  `po_prev_adjusted_advance` decimal(20,2) DEFAULT NULL,
  `advance_amount_required` tinyint(1) DEFAULT '0',
  `gstin_location_id` bigint(20) DEFAULT NULL,
  `transaction_service_period_from` date DEFAULT NULL,
  `transaction_service_period_to` date DEFAULT NULL,
  `proforma_invoice_id` int(11) DEFAULT NULL,
  `proforma_advance` int(11) DEFAULT NULL,
  `total_proforma_advance` decimal(20,2) DEFAULT NULL,
  `cost_allocation_items` tinyint(1) DEFAULT '0',
  `po_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `narration` text COLLATE utf8_unicode_ci,
  `bank_account_id` int(11) DEFAULT NULL,
  `payment_agreement_id` int(11) DEFAULT NULL,
  `vendor_location_id` int(11) DEFAULT NULL,
  `rejection_note` text COLLATE utf8_unicode_ci,
  `billing_type_id` int(11) DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  `client_note` text COLLATE utf8_unicode_ci,
  `agreement_item_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `agreement_item_id` int(11) DEFAULT NULL,
  `payable` tinyint(1) DEFAULT '0',
  `cn_adjusted_amount_id` int(11) DEFAULT NULL,
  `rcm_enabled` tinyint(1) DEFAULT '0',
  `tds_percentage` decimal(20,5) DEFAULT NULL,
  `vendor_bank_account_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_bank_account_ifsc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_gross_amount` decimal(20,5) DEFAULT NULL,
  `invoice_discount_amount` decimal(20,5) DEFAULT NULL,
  `invoice_tax_amount` decimal(20,5) DEFAULT NULL,
  `invoice_tds_amount` decimal(20,5) DEFAULT NULL,
  `base_currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_sequence_id` text COLLATE utf8_unicode_ci,
  `vendor_gstin` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_freight_amount` decimal(20,5) DEFAULT NULL,
  `reporting_currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `conversion_date` date DEFAULT NULL,
  `conversion_rate` decimal(10,5) DEFAULT NULL,
  `retrieve_conversion_rate` tinyint(1) DEFAULT '1',
  `invoice_taxable_amount` decimal(20,5) DEFAULT NULL,
  `invoice_roundoff_amount` decimal(20,5) DEFAULT NULL,
  `invoice_balance_due` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_gross_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_discount_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_taxable_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_tax_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_tds_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_freight_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_sub_total_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_roundoff_amount` decimal(20,5) DEFAULT NULL,
  `invoice_advance_paid_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_advance_paid_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_total_amount` decimal(20,5) DEFAULT NULL,
  `invoice_net_total_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_net_total_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_paid_outside_amount` decimal(20,5) DEFAULT NULL,
  `reporting_invoice_balance_due` decimal(20,5) DEFAULT NULL,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text COLLATE utf8_unicode_ci,
  `erp_sync_reference_id` text COLLATE utf8_unicode_ci,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  `approval_workflow_version` int(11) DEFAULT NULL,
  `is_workflow_v2` tinyint(1) DEFAULT '0',
  `vendor_trade_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_paid_outside_amount` decimal(20,5) DEFAULT NULL,
  `invoice_sub_total_amount` decimal(20,5) DEFAULT NULL,
  `invoice_total_amount` decimal(20,5) DEFAULT NULL,
  `payment_term_days` int(11) DEFAULT '0',
  `vendor_bank_account_swift_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `vendor_country` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `discount_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `overall_discount_amount` decimal(10,0) DEFAULT '0',
  `total_line_item_discount_amount` decimal(10,0) DEFAULT '0',
  `is_domestic` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_invoices_on_address_id` (`address_id`),
  KEY `index_invoices_on_tax_type_id` (`tax_type_id`),
  KEY `index_invoices_on_discount_type_id` (`discount_type_id`),
  KEY `index_invoices_on_payment_term_id` (`payment_term_id`),
  KEY `index_invoices_on_invoice_type_id` (`invoice_type_id`),
  KEY `index_invoices_on_invoice_status_id` (`invoice_status_id`),
  KEY `index_invoices_on_gstin_location_id` (`gstin_location_id`),
  KEY `index_invoices_on_transaction_service_period_from` (`transaction_service_period_from`),
  KEY `index_invoices_on_transaction_service_period_to` (`transaction_service_period_to`),
  KEY `index_invoices_on_proforma_invoice_id` (`proforma_invoice_id`),
  KEY `index_invoices_on_po_number` (`po_number`),
  KEY `index_invoices_on_controlling_level_id` (`controlling_level_id`),
  KEY `index_invoices_on_vendor_poc_id` (`vendor_poc_id`),
  KEY `index_invoices_on_vlpm_id` (`vlpm_id`),
  KEY `index_invoices_on_payable` (`payable`),
  KEY `index_invoice_ct_lvl_cmpny_id` (`company_id`,`controlling_level_id`,`deleted_at`),
  KEY `index_invoice_awaiting_approval_fields` (`deleted_at`,`invoice_status_id`,`policy_id`,`controlling_level_id`,`company_id`),
  KEY `index_invoice_awaiting_approval_fields_2` (`deleted_at`,`invoice_status_id`,`policy_id`,`controlling_level_id`,`company_id`,`invoice_type_id`),
  KEY `index_invoice_awaiting_approval_fields_3` (`deleted_at`,`invoice_status_id`,`policy_id`,`controlling_level_id`,`company_id`,`created_by_user_id`,`invoice_type_id`),
  KEY `index_invoice_awaiting_approval_fields_4` (`deleted_at`,`company_id`,`created_by_user_id`,`invoice_type_id`),
  KEY `index_invoice_awaiting_approval_fields_5` (`deleted_at`,`company_id`,`policy_id`),
  CONSTRAINT `fk_rails_96852a06c9` FOREIGN KEY (`gstin_location_id`) REFERENCES `gstin_locations` (`id`),
  CONSTRAINT `fk_rails_9f0ce18fd4` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `fk_rails_f558c6adad` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10595 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inward_document_items`
--

DROP TABLE IF EXISTS `inward_document_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inward_document_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_order_item_id` int(11) DEFAULT NULL,
  `inward_document_id` int(11) DEFAULT NULL,
  `inventory_line_item_id` int(11) DEFAULT NULL,
  `product_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `quantity` decimal(20,5) DEFAULT NULL,
  `delivered` decimal(20,5) DEFAULT NULL,
  `accepted` decimal(20,5) DEFAULT NULL,
  `rejected` decimal(20,5) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `previously_delivered` decimal(20,5) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `billable_amount` decimal(20,5) DEFAULT '0.00000',
  `order_amount` decimal(20,5) DEFAULT '0.00000',
  `previously_billed_amount` decimal(20,5) DEFAULT '0.00000',
  `product_type_id` int(11) DEFAULT '1',
  `accepting_item_amount_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inward_document_items_on_purchase_order_item_id` (`purchase_order_item_id`),
  KEY `index_inward_document_items_on_inward_document_id` (`inward_document_id`),
  KEY `index_inward_document_items_on_inventory_line_item_id` (`inventory_line_item_id`),
  KEY `index_inward_document_items_on_product_type_id` (`product_type_id`),
  KEY `index_inward_document_items_on_accepting_item_amount_id` (`accepting_item_amount_id`),
  KEY `index_inward_item_po_item_item_id` (`purchase_order_item_id`,`inventory_line_item_id`),
  CONSTRAINT `fk_rails_392376e314` FOREIGN KEY (`inventory_line_item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `fk_rails_3c9700ea65` FOREIGN KEY (`inward_document_id`) REFERENCES `inward_documents` (`id`),
  CONSTRAINT `fk_rails_73978f1e19` FOREIGN KEY (`purchase_order_item_id`) REFERENCES `purchase_order_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1335 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inward_documents`
--

DROP TABLE IF EXISTS `inward_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inward_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `doc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `override_doc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `transported_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transporter_document_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vehicle_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `grn_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inward_documents_on_company_id` (`company_id`),
  KEY `index_inward_documents_on_procurement_id` (`procurement_id`),
  KEY `index_inward_documents_on_vendor_id` (`vendor_id`),
  KEY `index_inward_documents_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_040a4c58ec` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_91897e84db` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_f0adc3a297` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inward_invoice_statuses`
--

DROP TABLE IF EXISTS `inward_invoice_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inward_invoice_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inward_invoice_types`
--

DROP TABLE IF EXISTS `inward_invoice_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inward_invoice_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_expense_types`
--

DROP TABLE IF EXISTS `item_expense_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_expense_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tax` decimal(20,10) DEFAULT NULL,
  `discount` decimal(20,10) DEFAULT NULL,
  `hsn_sac` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `sku` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rate` decimal(20,10) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `tax_rate_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `item_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `supply_item_type_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `product_type_id` int(11) DEFAULT '1',
  `item_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unit_of_measurement` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `item_expense_type_id` int(11) DEFAULT NULL,
  `tds_applicable` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_items_on_company_id` (`company_id`),
  KEY `index_items_on_category_id` (`category_id`),
  KEY `index_items_on_tax_rate_id` (`tax_rate_id`),
  KEY `index_items_on_supply_item_type_id` (`supply_item_type_id`),
  KEY `index_items_on_product_type_id` (`product_type_id`),
  KEY `index_items_on_user_id` (`user_id`),
  KEY `index_items_on_active` (`active`),
  KEY `index_items_on_item_expense_type_id` (`item_expense_type_id`),
  KEY `index_items_on_company_id_and_active` (`company_id`,`active`),
  KEY `index_items_on_supply_item_type_id_and_product_type_id` (`supply_item_type_id`,`product_type_id`),
  CONSTRAINT `fk_rails_49497a7fbe` FOREIGN KEY (`tax_rate_id`) REFERENCES `tax_rates` (`id`),
  CONSTRAINT `fk_rails_63963d172a` FOREIGN KEY (`supply_item_type_id`) REFERENCES `supply_item_types` (`id`),
  CONSTRAINT `fk_rails_7f2964cc00` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_f0f8a88ba9` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_card_programs`
--

DROP TABLE IF EXISTS `itz_cash_card_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_card_programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `charge_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bank` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_company_accounts`
--

DROP TABLE IF EXISTS `itz_cash_company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_company_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `wallet_balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_itz_cash_company_accounts_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_e9331fab12` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_dmt_beneficiaries`
--

DROP TABLE IF EXISTS `itz_cash_dmt_beneficiaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_dmt_beneficiaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `relation` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ifsc_option` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ifsc_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `bank_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `beneficiary_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `beneficiary_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_updatable` tinyint(1) NOT NULL,
  `itz_cash_dmt_sender_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `reimbursement` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_itz_cash_dmt_beneficiaries_on_itz_cash_dmt_sender_id` (`itz_cash_dmt_sender_id`),
  KEY `index_itz_cash_dmt_beneficiaries_on_status_id` (`status_id`),
  CONSTRAINT `fk_rails_ca138d94ad` FOREIGN KEY (`itz_cash_dmt_sender_id`) REFERENCES `itz_cash_dmt_senders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_dmt_beneficiary_statuses`
--

DROP TABLE IF EXISTS `itz_cash_dmt_beneficiary_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_dmt_beneficiary_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_dmt_sender_statuses`
--

DROP TABLE IF EXISTS `itz_cash_dmt_sender_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_dmt_sender_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_dmt_senders`
--

DROP TABLE IF EXISTS `itz_cash_dmt_senders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_dmt_senders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `registration_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status_id` int(11) NOT NULL,
  `otp_verified` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_itz_cash_dmt_senders_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_df4f7efb2a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itz_cash_properties`
--

DROP TABLE IF EXISTS `itz_cash_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itz_cash_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `d_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `easy_account_no` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_itz_cash_properties_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_c6798d71d9` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kotak_bank_company_accounts`
--

DROP TABLE IF EXISTS `kotak_bank_company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kotak_bank_company_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kotak_bank_configs`
--

DROP TABLE IF EXISTS `kotak_bank_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kotak_bank_configs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kotak_bank_transactions`
--

DROP TABLE IF EXISTS `kotak_bank_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kotak_bank_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amount_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `transfer_status_id` int(11) DEFAULT NULL,
  `beneficiary_account_id` int(11) DEFAULT NULL,
  `utr` varchar(255) DEFAULT NULL,
  `response_status_code` varchar(255) DEFAULT NULL,
  `unique_reference_number` varchar(255) DEFAULT NULL,
  `transfer_type` varchar(255) DEFAULT NULL,
  `beneficiary_account_number` varchar(255) DEFAULT NULL,
  `beneficiary_account_ifsc` varchar(255) DEFAULT NULL,
  `beneficiary_name` varchar(255) DEFAULT NULL,
  `narration` text,
  `payment_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bank_response` text,
  `reversal_status_code` varchar(255) DEFAULT NULL,
  `reversal_response` text,
  `reversal_api_counter` int(11) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `bank_error_message` mediumtext,
  PRIMARY KEY (`id`),
  KEY `index_kotak_bank_transactions_on_amount_id` (`amount_id`),
  KEY `index_kotak_bank_transactions_on_company_id` (`company_id`),
  KEY `index_kotak_bank_transactions_on_transfer_status_id` (`transfer_status_id`),
  KEY `index_kotak_bank_transactions_on_beneficiary_account_id` (`beneficiary_account_id`),
  KEY `index_kotak_bank_transactions_on_unique_reference_number` (`unique_reference_number`),
  KEY `index_kotak_bank_transactions_on_response_status_code` (`response_status_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kyc_documents`
--

DROP TABLE IF EXISTS `kyc_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kyc_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_kyc_document_type_id` int(11) DEFAULT NULL,
  `company_kyc_id` int(11) DEFAULT NULL,
  `doc_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `doc_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `doc_file_size` int(11) DEFAULT NULL,
  `doc_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `identifier` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kyc_documents_on_company_kyc_document_type_id` (`company_kyc_document_type_id`),
  KEY `index_kyc_documents_on_company_kyc_id` (`company_kyc_id`),
  CONSTRAINT `fk_rails_316273dc0c` FOREIGN KEY (`company_kyc_id`) REFERENCES `company_kycs` (`id`),
  CONSTRAINT `fk_rails_b0973792c0` FOREIGN KEY (`company_kyc_document_type_id`) REFERENCES `company_kyc_document_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kyc_statuses`
--

DROP TABLE IF EXISTS `kyc_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kyc_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `level_reviewer_mappings`
--

DROP TABLE IF EXISTS `level_reviewer_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `level_reviewer_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level_id` int(11) DEFAULT NULL,
  `reviewer_id` int(11) DEFAULT NULL,
  `threshold` decimal(20,5) DEFAULT '0.00000',
  `exception` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `wo_exception` tinyint(1) DEFAULT '1',
  `min` decimal(20,5) DEFAULT '0.00000',
  `max` decimal(20,5) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_level_reviewer_mappings_on_level_id` (`level_id`),
  KEY `index_level_reviewer_mappings_on_reviewer_id` (`reviewer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `level_user_reviewer_mappings`
--

DROP TABLE IF EXISTS `level_user_reviewer_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `level_user_reviewer_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `reviewer_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `threshold` decimal(20,5) DEFAULT '0.00000',
  `exception` tinyint(1) DEFAULT '1',
  `wo_exception` tinyint(1) DEFAULT '1',
  `min` decimal(20,5) DEFAULT '0.00000',
  `max` decimal(20,5) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_level_user_reviewer_mappings_on_level_id` (`level_id`),
  KEY `index_level_user_reviewer_mappings_on_user_id` (`user_id`),
  KEY `index_level_user_reviewer_mappings_on_reviewer_id` (`reviewer_id`),
  KEY `index_level_user_reviewer_mappings_on_policy_id` (`policy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `locatable_id` int(11) DEFAULT NULL,
  `locatable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` decimal(30,15) DEFAULT NULL,
  `longitude` decimal(30,15) DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `address` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `order` int(11) DEFAULT NULL,
  `maps_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_locatable_id` (`locatable_id`),
  KEY `index_locations_on_locatable_type` (`locatable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=335 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `login_agreement_mappings`
--

DROP TABLE IF EXISTS `login_agreement_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_agreement_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `agreement_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_login_agreement_mappings_on_user_id` (`user_id`),
  KEY `index_login_agreement_mappings_on_agreement_id` (`agreement_id`),
  CONSTRAINT `fk_rails_df0a74e417` FOREIGN KEY (`agreement_id`) REFERENCES `agreements` (`id`),
  CONSTRAINT `fk_rails_ea7b466f04` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manager_mappings`
--

DROP TABLE IF EXISTS `manager_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `manager_type_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_manager_mappings_on_user_id` (`user_id`),
  KEY `index_manager_mappings_on_manager_type_id` (`manager_type_id`),
  KEY `index_manager_mappings_on_location_id` (`location_id`),
  KEY `index_manager_mappings_on_department_id` (`department_id`),
  CONSTRAINT `fk_rails_6e8e4489f7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_b1e6ebe2c1` FOREIGN KEY (`manager_type_id`) REFERENCES `manager_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=126 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manager_summary_mail_configs`
--

DROP TABLE IF EXISTS `manager_summary_mail_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager_summary_mail_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `period_id` int(11) NOT NULL,
  `scheduled_day_of_month` int(11) DEFAULT NULL,
  `scheduled_day_of_week` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `scheduled_time` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `entity_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_manager_summary_mail_configs_on_user_id` (`user_id`),
  KEY `index_manager_summary_mail_configs_on_period_id` (`period_id`),
  KEY `index_manager_summary_mail_configs_on_scheduled_day_of_month` (`scheduled_day_of_month`),
  KEY `index_manager_summary_mail_configs_on_scheduled_day_of_week` (`scheduled_day_of_week`),
  KEY `index_manager_summary_mail_configs_on_scheduled_time` (`scheduled_time`),
  KEY `index_manager_summary_mail_configs_on_entity_type` (`entity_type`),
  KEY `index_manager_summary_mail_configs_on_application` (`application`),
  CONSTRAINT `fk_rails_a51229ec43` FOREIGN KEY (`period_id`) REFERENCES `periods` (`id`),
  CONSTRAINT `fk_rails_cdedb374c9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manager_types`
--

DROP TABLE IF EXISTS `manager_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manual_expenses`
--

DROP TABLE IF EXISTS `manual_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manual_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expense_id` int(11) DEFAULT NULL,
  `merchant` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_manual_expenses_on_expense_id` (`expense_id`),
  CONSTRAINT `fk_rails_b21754b328` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1446 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_location_details`
--

DROP TABLE IF EXISTS `map_location_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_location_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `place_id` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `address` longtext,
  `result` longtext,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `latitude` decimal(20,10) DEFAULT NULL,
  `longitude` decimal(20,10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_map_location_details_on_uuid` (`uuid`),
  KEY `index_map_location_details_on_name` (`name`),
  KEY `index_map_location_details_on_place_id` (`place_id`),
  KEY `index_map_location_details_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_location_searches`
--

DROP TABLE IF EXISTS `map_location_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_location_searches` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `input` varchar(255) DEFAULT NULL,
  `result` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_map_location_searches_on_uuid` (`uuid`),
  KEY `index_map_location_searches_on_input` (`input`),
  KEY `index_map_location_searches_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_location_user_queries`
--

DROP TABLE IF EXISTS `map_location_user_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_location_user_queries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address` text,
  `place_id` varchar(255) DEFAULT NULL,
  `map_location_detail_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `latitude` decimal(20,10) DEFAULT NULL,
  `longitude` decimal(20,10) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_map_location_user_queries_on_uuid` (`uuid`),
  KEY `index_map_location_user_queries_on_user_id` (`user_id`),
  KEY `index_map_location_user_queries_on_place_id` (`place_id`),
  KEY `index_map_location_user_queries_on_map_location_detail_id` (`map_location_detail_id`),
  KEY `index_map_location_user_queries_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mcc_category_mappings`
--

DROP TABLE IF EXISTS `mcc_category_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mcc_category_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `mcc_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mcc_category_mappings_on_category_id` (`category_id`),
  CONSTRAINT `fk_rails_f996857bf3` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mcc_groups`
--

DROP TABLE IF EXISTS `mcc_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mcc_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ml_model_dependent_entities`
--

DROP TABLE IF EXISTS `ml_model_dependent_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ml_model_dependent_entities` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `ml_model_id` int(11) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `form_entity_id` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ml_model_dependent_entities_on_company_id` (`company_id`),
  KEY `index_ml_model_dependent_entities_on_ml_model_id` (`ml_model_id`),
  KEY `index_ml_model_dependent_entities_on_form_id` (`form_id`),
  KEY `index_ml_model_dependent_entities_on_form_entity_id` (`form_entity_id`),
  KEY `index_ml_model_dependent_entities_on_deleted_at` (`deleted_at`),
  KEY `index_ml_model_dependent_entities_on_created_at` (`created_at`),
  KEY `index_ml_model_dependent_entities_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ml_model_pmmls`
--

DROP TABLE IF EXISTS `ml_model_pmmls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ml_model_pmmls` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `ml_model_id` int(11) NOT NULL,
  `pmml` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ml_model_pmmls_on_company_id` (`company_id`),
  KEY `index_ml_model_pmmls_on_ml_model_id` (`ml_model_id`),
  KEY `index_ml_model_pmmls_on_deleted_at` (`deleted_at`),
  KEY `index_ml_model_pmmls_on_created_at` (`created_at`),
  KEY `index_ml_model_pmmls_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ml_model_predictions`
--

DROP TABLE IF EXISTS `ml_model_predictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ml_model_predictions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `ml_model_id` bigint(20) DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `record_id` bigint(20) DEFAULT NULL,
  `actual_value` varchar(255) DEFAULT NULL,
  `predicted_value` varchar(255) DEFAULT NULL,
  `is_accurate_prediction` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ml_model_predictions_on_company_id` (`company_id`),
  KEY `index_ml_model_predictions_on_ml_model_id` (`ml_model_id`),
  KEY `index_ml_model_predictions_on_record_type_and_record_id` (`record_type`,`record_id`),
  KEY `index_ml_model_predictions_on_deleted_at` (`deleted_at`),
  KEY `index_ml_model_predictions_on_created_at` (`created_at`),
  KEY `index_ml_model_predictions_on_updated_at` (`updated_at`),
  CONSTRAINT `fk_rails_be457e314c` FOREIGN KEY (`ml_model_id`) REFERENCES `ml_models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ml_models`
--

DROP TABLE IF EXISTS `ml_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ml_models` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `config` longtext,
  `built_at` datetime DEFAULT NULL,
  `build_schedule` varchar(255) DEFAULT NULL,
  `track_schedule` varchar(255) DEFAULT NULL,
  `build_duration` int(11) DEFAULT NULL,
  `tracked_at` datetime DEFAULT NULL,
  `algorithm` varchar(255) DEFAULT NULL,
  `target_key` varchar(255) NOT NULL,
  `target_key_type` varchar(255) NOT NULL,
  `split_key` varchar(255) DEFAULT NULL,
  `split_key_type` varchar(255) DEFAULT NULL,
  `model_klass` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `form_id` varchar(255) DEFAULT NULL,
  `parent_id` varchar(255) DEFAULT NULL,
  `parent_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ml_models_on_company_id` (`company_id`),
  KEY `index_ml_models_on_type` (`type`),
  KEY `index_ml_models_on_built_at` (`built_at`),
  KEY `index_ml_models_on_tracked_at` (`tracked_at`),
  KEY `index_ml_models_on_target_key` (`target_key`),
  KEY `index_ml_models_on_target_key_type` (`target_key_type`),
  KEY `index_ml_models_on_split_key` (`split_key`),
  KEY `index_ml_models_on_split_key_type` (`split_key_type`),
  KEY `index_ml_models_on_model_klass` (`model_klass`),
  KEY `index_ml_models_on_deleted_at` (`deleted_at`),
  KEY `index_ml_models_on_created_at` (`created_at`),
  KEY `index_ml_models_on_updated_at` (`updated_at`),
  KEY `index_ml_models_on_parent_type_and_parent_id` (`parent_type`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_actions`
--

DROP TABLE IF EXISTS `money_request_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_comment_actions`
--

DROP TABLE IF EXISTS `money_request_comment_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_comment_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_comments`
--

DROP TABLE IF EXISTS `money_request_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `money_request_id` int(11) NOT NULL,
  `comment_action_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `updated_field` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `updated_from` text COLLATE utf8_unicode_ci,
  `updated_to` text COLLATE utf8_unicode_ci,
  `rejected_to_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_comments_on_money_request_id` (`money_request_id`),
  KEY `index_money_request_comments_on_comment_action_id` (`comment_action_id`),
  KEY `index_money_request_comments_on_user_id` (`user_id`),
  KEY `index_money_request_comments_on_expense_id` (`expense_id`),
  KEY `index_money_request_comments_on_payment_id` (`payment_id`),
  KEY `index_money_request_comments_on_rejected_to_id` (`rejected_to_id`),
  CONSTRAINT `fk_rails_2231ef9b45` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_a734537104` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`),
  CONSTRAINT `fk_rails_d332cdc2c4` FOREIGN KEY (`money_request_id`) REFERENCES `money_requests` (`id`),
  CONSTRAINT `fk_rails_f787ea816e` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_item_categories`
--

DROP TABLE IF EXISTS `money_request_item_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_item_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gl_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_item_categories_on_company_id` (`company_id`),
  KEY `index_money_request_item_categories_on_name` (`name`),
  KEY `index_money_request_item_categories_on_active` (`active`),
  CONSTRAINT `fk_rails_b8704290f1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_items`
--

DROP TABLE IF EXISTS `money_request_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `money_request_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `amount_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `money_request_item_category_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_items_on_money_request_id` (`money_request_id`),
  KEY `index_money_request_items_on_category_id` (`category_id`),
  KEY `index_money_request_items_on_amount_id` (`amount_id`),
  CONSTRAINT `fk_rails_36d9ce8e53` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_rails_c2dcd041b9` FOREIGN KEY (`money_request_id`) REFERENCES `money_requests` (`id`),
  CONSTRAINT `fk_rails_f6d0782fa2` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_processor_mappings`
--

DROP TABLE IF EXISTS `money_request_processor_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_processor_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `processor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `processor_accountable_id` int(11) DEFAULT NULL,
  `processor_accountable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `marked_as_completed` tinyint(1) DEFAULT '0',
  `status_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `bank_reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_processor_mappings_on_processor_id` (`processor_id`),
  KEY `index_money_request_processor_mappings_on_user_id` (`user_id`),
  KEY `index_money_request_processor_mappings_on_amount_id` (`amount_id`),
  KEY `index_money_request_processor_mappings_on_status_id` (`status_id`),
  KEY `index_money_request_processor_mappings_on_payment_id` (`payment_id`),
  KEY `index_money_request_processor_mappings_on_bank_reference_number` (`bank_reference_number`),
  CONSTRAINT `fk_rails_3814f3a82d` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c016d83bd4` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_f7ec3f3eae` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_processor_statuses`
--

DROP TABLE IF EXISTS `money_request_processor_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_processor_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_processor_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_processors`
--

DROP TABLE IF EXISTS `money_request_processors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_processors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `payment_file_generated` tinyint(1) DEFAULT '0',
  `payment_file_generated_at` datetime DEFAULT NULL,
  `scheduled_at` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `total_amount_id` int(11) NOT NULL,
  `processed_amount_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `created_by_user_role_id` int(11) DEFAULT NULL,
  `source_account_id` int(11) DEFAULT NULL,
  `source_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `marked_as_completed` tinyint(1) DEFAULT '0',
  `payment_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `payment_order_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_processors_on_status_id` (`status_id`),
  KEY `index_money_request_processors_on_scheduled_at` (`scheduled_at`),
  KEY `index_money_request_processors_on_total_amount_id` (`total_amount_id`),
  KEY `index_money_request_processors_on_processed_amount_id` (`processed_amount_id`),
  KEY `index_money_request_processors_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_money_request_processors_on_created_by_user_role_id` (`created_by_user_role_id`),
  KEY `index_money_request_processors_on_source_account_id` (`source_account_id`),
  KEY `index_money_request_processors_on_source_account_type` (`source_account_type`),
  KEY `index_money_request_processors_on_company_id` (`company_id`),
  KEY `index_money_request_processors_on_payment_order_id` (`payment_order_id`),
  CONSTRAINT `fk_rails_30dcadb932` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_d05595e8ec` FOREIGN KEY (`payment_order_id`) REFERENCES `payment_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_statuses`
--

DROP TABLE IF EXISTS `money_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `order` int(11) NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_tracking_actions`
--

DROP TABLE IF EXISTS `money_request_tracking_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_tracking_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_request_tracks`
--

DROP TABLE IF EXISTS `money_request_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_request_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `money_request_id` int(11) NOT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `modified_user_id` int(11) DEFAULT NULL,
  `money_request_tracking_action_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `modified_user_role_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `action_id` int(11) DEFAULT NULL,
  `action_user_role_id` int(11) DEFAULT NULL,
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_request_tracks_on_money_request_id` (`money_request_id`),
  KEY `index_money_request_tracks_on_action_user_id` (`action_user_id`),
  KEY `index_money_request_tracks_on_modified_user_id` (`modified_user_id`),
  KEY `index_money_request_tracks_on_money_request_tracking_action_id` (`money_request_tracking_action_id`),
  KEY `index_money_request_tracks_on_status_id` (`status_id`),
  KEY `index_money_request_tracks_on_modified_user_role_id` (`modified_user_role_id`),
  KEY `index_money_request_tracks_on_payment_id` (`payment_id`),
  CONSTRAINT `fk_rails_040e5554cc` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`),
  CONSTRAINT `fk_rails_3ad8c4d45d` FOREIGN KEY (`money_request_id`) REFERENCES `money_requests` (`id`),
  CONSTRAINT `fk_rails_3b8c4455bf` FOREIGN KEY (`money_request_tracking_action_id`) REFERENCES `money_request_tracking_actions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `money_requests`
--

DROP TABLE IF EXISTS `money_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `payment_mode_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `required_by_date` date DEFAULT NULL,
  `status_id` int(11) NOT NULL,
  `controlling_user_id` int(11) DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `loaded_by` int(11) DEFAULT NULL,
  `loaded_at` datetime DEFAULT NULL,
  `submitted_at` datetime(6) DEFAULT NULL,
  `memo` text COLLATE utf8_unicode_ci,
  `accounted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `submitted_amount_id` int(11) DEFAULT NULL,
  `processed_amount_id` int(11) DEFAULT NULL,
  `money_request_processor_mapping_id` int(11) DEFAULT NULL,
  `auto_approve` tinyint(1) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `travel_request_id` int(11) DEFAULT NULL,
  `destination_pocket_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `modified_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `bank_reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_money_requests_on_user_id` (`user_id`),
  KEY `index_money_requests_on_policy_id` (`policy_id`),
  KEY `index_money_requests_on_payment_mode_id` (`payment_mode_id`),
  KEY `index_money_requests_on_payment_id` (`payment_id`),
  KEY `index_money_requests_on_status_id` (`status_id`),
  KEY `index_money_requests_on_controlling_user_id` (`controlling_user_id`),
  KEY `index_money_requests_on_controlling_user_role_id` (`controlling_user_role_id`),
  KEY `index_money_requests_on_controlling_for_user_id` (`controlling_for_user_id`),
  KEY `index_money_requests_on_controlling_for_user_role_id` (`controlling_for_user_role_id`),
  KEY `index_money_requests_on_loaded_by` (`loaded_by`),
  KEY `index_money_requests_on_name` (`name`),
  KEY `index_money_requests_on_travel_request_id` (`travel_request_id`),
  CONSTRAINT `fk_rails_64ca43edcb` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`),
  CONSTRAINT `fk_rails_928481e420` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_ae35dcf60b` FOREIGN KEY (`travel_request_id`) REFERENCES `travel_requests` (`id`),
  CONSTRAINT `fk_rails_c9b68f2238` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_d26cd5854c` FOREIGN KEY (`payment_mode_id`) REFERENCES `payment_modes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `new_card_requests`
--

DROP TABLE IF EXISTS `new_card_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `new_card_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `requesting_user_id` int(11) DEFAULT NULL,
  `card_type_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_new_card_requests_on_company_id` (`company_id`),
  KEY `index_new_card_requests_on_requesting_user_id` (`requesting_user_id`),
  KEY `index_new_card_requests_on_card_type_id` (`card_type_id`),
  KEY `index_new_card_requests_on_status_id` (`status_id`),
  CONSTRAINT `fk_rails_86075ae2f2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_9254255a20` FOREIGN KEY (`card_type_id`) REFERENCES `card_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notification_action_types`
--

DROP TABLE IF EXISTS `notification_action_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_action_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notification_types`
--

DROP TABLE IF EXISTS `notification_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `object_id` int(11) DEFAULT NULL,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path_object_id` int(11) DEFAULT NULL,
  `path_object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_type_id` int(11) DEFAULT NULL,
  `changed_from` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `changed_to` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `read` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `link` text COLLATE utf8_unicode_ci,
  `view_role_id` int(11) DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_notification_type_id` (`notification_type_id`),
  KEY `index_notifications_on_user_id` (`user_id`),
  KEY `index_notifications_on_action_user_id` (`action_user_id`),
  KEY `index_notifications_on_amount_id` (`amount_id`),
  KEY `index_notifications_on_action_type_id` (`action_type_id`),
  CONSTRAINT `fk_rails_75cdc2096d` FOREIGN KEY (`notification_type_id`) REFERENCES `notification_types` (`id`),
  CONSTRAINT `fk_rails_b080fb4855` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2362 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifier_type_configurations`
--

DROP TABLE IF EXISTS `notifier_type_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifier_type_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `allow_push_notification` tinyint(1) DEFAULT NULL,
  `allow_mailer` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifier_type_configurations_on_user_id` (`user_id`),
  KEY `index_notifier_type_configurations_on_event_id` (`event_id`),
  CONSTRAINT `fk_rails_9c25169439` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_ae37bb343e` FOREIGN KEY (`event_id`) REFERENCES `notifier_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifier_types`
--

DROP TABLE IF EXISTS `notifier_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifier_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `has_push_notification` tinyint(1) NOT NULL,
  `has_mailer` tinyint(1) NOT NULL,
  `configurable_push_notification` tinyint(1) NOT NULL,
  `configurable_mailer` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notify_users`
--

DROP TABLE IF EXISTS `notify_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notify_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `document_id` int(11) DEFAULT NULL,
  `document_type` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_access_grants`
--

DROP TABLE IF EXISTS `oauth_access_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_grants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `expires_in` int(11) NOT NULL,
  `redirect_uri` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_grants_on_token` (`token`),
  KEY `fk_rails_b4b53e07b8` (`application_id`),
  CONSTRAINT `fk_rails_b4b53e07b8` FOREIGN KEY (`application_id`) REFERENCES `oauth_applications` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_access_tokens`
--

DROP TABLE IF EXISTS `oauth_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int(11) DEFAULT NULL,
  `application_id` int(11) DEFAULT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `refresh_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires_in` int(11) DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `previous_refresh_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `status_id` int(11) DEFAULT '1',
  `message` text COLLATE utf8_unicode_ci,
  `admin_user_id` int(11) DEFAULT NULL,
  `authentication_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'password',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_tokens_on_token` (`token`),
  UNIQUE KEY `index_oauth_access_tokens_on_refresh_token` (`refresh_token`),
  KEY `index_oauth_access_tokens_on_resource_owner_id` (`resource_owner_id`),
  KEY `fk_rails_732cb83ab7` (`application_id`),
  CONSTRAINT `fk_rails_732cb83ab7` FOREIGN KEY (`application_id`) REFERENCES `oauth_applications` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1302 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_applications`
--

DROP TABLE IF EXISTS `oauth_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `uid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `secret` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `redirect_uri` text COLLATE utf8_unicode_ci NOT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `confidential` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_applications_on_uid` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `old_passwords`
--

DROP TABLE IF EXISTS `old_passwords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_passwords` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `encrypted_password` varchar(255) NOT NULL,
  `password_archivable_type` varchar(255) NOT NULL,
  `password_archivable_id` int(11) NOT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_password_archivable` (`password_archivable_type`,`password_archivable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opro_auth_grants`
--

DROP TABLE IF EXISTS `opro_auth_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opro_auth_grants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `access_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `refresh_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `permissions` text COLLATE utf8_unicode_ci,
  `access_token_expires_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `application_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_opro_auth_grants_on_code` (`code`),
  UNIQUE KEY `index_opro_auth_grants_on_access_token` (`access_token`),
  UNIQUE KEY `index_opro_auth_grants_on_refresh_token` (`refresh_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opro_client_apps`
--

DROP TABLE IF EXISTS `opro_client_apps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opro_client_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `app_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `app_secret` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `permissions` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_opro_client_apps_on_app_id` (`app_id`),
  UNIQUE KEY `index_opro_client_apps_on_app_id_and_app_secret` (`app_id`,`app_secret`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `otp_request_types`
--

DROP TABLE IF EXISTS `otp_request_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otp_request_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoice_attachments`
--

DROP TABLE IF EXISTS `outward_invoice_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoice_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attachment_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attachment_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `outward_invoice_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_outward_invoice_attachments_on_outward_invoice_id` (`outward_invoice_id`),
  KEY `index_outward_invoice_attachments_on_company_id` (`company_id`),
  KEY `index_outward_invoice_attachments_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_694a2e9def` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_8f1db01f2f` FOREIGN KEY (`outward_invoice_id`) REFERENCES `outward_invoices` (`id`),
  CONSTRAINT `fk_rails_cda3aa24b5` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoice_statuses`
--

DROP TABLE IF EXISTS `outward_invoice_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoice_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoice_trail_actions`
--

DROP TABLE IF EXISTS `outward_invoice_trail_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoice_trail_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoice_trails`
--

DROP TABLE IF EXISTS `outward_invoice_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoice_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_id` int(11) DEFAULT NULL,
  `outward_invoice_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `note` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `associated_entity_id` int(11) DEFAULT NULL,
  `associated_entity_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `associated_transaction_id` int(11) DEFAULT NULL,
  `associated_transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_outward_invoice_trails_on_action_id` (`action_id`),
  KEY `index_outward_invoice_trails_on_outward_invoice_id` (`outward_invoice_id`),
  KEY `index_outward_invoice_trails_on_user_id` (`user_id`),
  KEY `index_outward_invoice_trails_on_amount_id` (`amount_id`),
  KEY `index_outward_inv_trail_on_assoc_entty_type_and_assoc_entity_id` (`associated_entity_type`,`associated_entity_id`),
  KEY `index_outward_inv_trail_on_assoc_tranx_type_and_assoc_tranx_id` (`associated_transaction_type`,`associated_transaction_id`),
  CONSTRAINT `fk_rails_7bdc2a01c5` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_9bf98adc67` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_ce32df0ae2` FOREIGN KEY (`outward_invoice_id`) REFERENCES `outward_invoices` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoice_types`
--

DROP TABLE IF EXISTS `outward_invoice_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoice_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outward_invoices`
--

DROP TABLE IF EXISTS `outward_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outward_invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `paid_amount_id` int(11) DEFAULT NULL,
  `advance` decimal(10,5) DEFAULT NULL,
  `freight_amount_id` int(11) DEFAULT NULL,
  `balance_due_id` int(11) DEFAULT NULL,
  `roundoff_amount` decimal(10,5) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `invoice_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `invoice_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `virtual_account_id` int(11) DEFAULT NULL,
  `billing_address` text COLLATE utf8_unicode_ci,
  `shipping_address` text COLLATE utf8_unicode_ci,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `override_invoice_number` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `total_payable_id` int(11) DEFAULT NULL,
  `roundoff_total_enabled` tinyint(1) DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `customer_memo` text COLLATE utf8_unicode_ci,
  `reminders` text COLLATE utf8_unicode_ci,
  `payment_term_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `outward_invoice_type_id` int(11) DEFAULT '1',
  `terms` text COLLATE utf8_unicode_ci,
  `location_id` int(11) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `tds` decimal(10,5) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `quikr_invoice_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_outward_invoices_on_customer_id` (`customer_id`),
  KEY `index_outward_invoices_on_amount_id` (`amount_id`),
  KEY `index_outward_invoices_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_outward_invoices_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_outward_invoices_on_paid_amount_id` (`paid_amount_id`),
  KEY `index_outward_invoices_on_freight_amount_id` (`freight_amount_id`),
  KEY `index_outward_invoices_on_balance_due_id` (`balance_due_id`),
  KEY `index_outward_invoices_on_payment_term_id` (`payment_term_id`),
  KEY `index_outward_invoices_on_user_id` (`user_id`),
  KEY `index_outward_invoices_on_outward_invoice_type_id` (`outward_invoice_type_id`),
  KEY `index_outward_invoices_on_location_id` (`location_id`),
  CONSTRAINT `fk_rails_173d6fe016` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_2b80873bee` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_rails_5e6a802466` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_86bc38d63d` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_rails_a4e2b820e2` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`),
  CONSTRAINT `fk_rails_f5810706dd` FOREIGN KEY (`outward_invoice_type_id`) REFERENCES `outward_invoice_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=228 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parent_dependent_field_configuration_mappings`
--

DROP TABLE IF EXISTS `parent_dependent_field_configuration_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parent_dependent_field_configuration_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dependent_field_configuration_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_agreement_escalations`
--

DROP TABLE IF EXISTS `payment_agreement_escalations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_agreement_escalations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `period_id` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `percentage_increment` decimal(10,0) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `revised_amount_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_agreement_escalations_on_period_id` (`period_id`),
  KEY `index_payment_agreement_escalations_on_invoice_id` (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_agreement_statuses`
--

DROP TABLE IF EXISTS `payment_agreement_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_agreement_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_agreement_types`
--

DROP TABLE IF EXISTS `payment_agreement_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_agreement_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_agreements`
--

DROP TABLE IF EXISTS `payment_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_agreements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_number` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `agreement_date` datetime DEFAULT NULL,
  `execution_date` datetime DEFAULT NULL,
  `expiration_date` datetime DEFAULT NULL,
  `renewal_date` datetime DEFAULT NULL,
  `note` text,
  `no_expiration` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `reject_note` text,
  `company_id` int(11) DEFAULT NULL,
  `renewal_reminder_date` datetime DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `override_order_number` varchar(255) DEFAULT NULL,
  `terminated_at` datetime DEFAULT NULL,
  `terminated_by_id` int(11) DEFAULT NULL,
  `termination_reason` text,
  `deleted_at` datetime DEFAULT NULL,
  `revision_of_pa_id` int(11) DEFAULT NULL,
  `revision_reason` text,
  `revised_by_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_agreements_on_total_amount_id` (`total_amount_id`),
  KEY `index_payment_agreements_on_policy_id` (`policy_id`),
  KEY `index_payment_agreements_on_creator_id` (`creator_id`),
  KEY `index_payment_agreements_on_status_id` (`status_id`),
  KEY `payment_agreement_joined_indeexes` (`company_id`,`status_id`,`policy_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_file_configurations`
--

DROP TABLE IF EXISTS `payment_file_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_file_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_format` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `options` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_file_configurations_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_a0eed4d9de` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_modes`
--

DROP TABLE IF EXISTS `payment_modes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_modes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_order_attachments`
--

DROP TABLE IF EXISTS `payment_order_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_order_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attached_file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_file_size` int(11) DEFAULT NULL,
  `attached_file_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_order_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `uploader_id` int(11) DEFAULT NULL,
  `allow_delete` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_order_attachments_on_allow_delete` (`allow_delete`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_order_statuses`
--

DROP TABLE IF EXISTS `payment_order_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_order_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_orders`
--

DROP TABLE IF EXISTS `payment_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scheduled_at` date DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `initiating_user_id` int(11) NOT NULL,
  `payment_order_status_id` int(11) NOT NULL,
  `payment_file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_file_file_size` int(11) DEFAULT NULL,
  `payment_file_updated_at` datetime DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `amount_requested_id` int(11) DEFAULT NULL,
  `amount_processed_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `initiating_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_purpose_id` int(11) NOT NULL,
  `currency_id` int(11) NOT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `post_operation` text COLLATE utf8_unicode_ci,
  `post_operation_payload` text COLLATE utf8_unicode_ci,
  `payment_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `api_initiated` tinyint(1) DEFAULT '0',
  `bank_account_provider_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `transfer_mode_id` int(11) DEFAULT NULL,
  `reporting_amount_processed` decimal(10,0) DEFAULT '0',
  `reporting_amount_requested` decimal(10,0) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_payment_orders_on_initiating_user_id` (`initiating_user_id`),
  KEY `index_payment_orders_on_payment_order_status_id` (`payment_order_status_id`),
  KEY `index_payment_orders_on_company_id` (`company_id`),
  KEY `index_payment_orders_on_amount_requested_id` (`amount_requested_id`),
  KEY `index_payment_orders_on_amount_processed_id` (`amount_processed_id`),
  KEY `index_payment_orders_on_payment_purpose_id` (`payment_purpose_id`),
  KEY `index_payment_orders_on_transfer_mode_id` (`transfer_mode_id`),
  KEY `index_bpr_order_fields` (`deleted_at`,`payment_purpose_id`,`payment_order_status_id`),
  KEY `index_bpr_order_fields_2` (`deleted_at`,`payment_order_status_id`),
  KEY `index_bpr_order_fields_3` (`deleted_at`,`payment_purpose_id`),
  CONSTRAINT `fk_rails_336e8bcc41` FOREIGN KEY (`payment_order_status_id`) REFERENCES `payment_order_statuses` (`id`),
  CONSTRAINT `fk_rails_7cd8337265` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=289 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_purposes`
--

DROP TABLE IF EXISTS `payment_purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_receivable_statuses`
--

DROP TABLE IF EXISTS `payment_receivable_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_receivable_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_receivable_transaction_trails`
--

DROP TABLE IF EXISTS `payment_receivable_transaction_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_receivable_transaction_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) DEFAULT NULL,
  `find_payment_receivable` tinyint(1) DEFAULT NULL,
  `creating_payment` tinyint(1) DEFAULT NULL,
  `update_company_balance` tinyint(1) DEFAULT NULL,
  `payment_receivable_updation` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_receivable_transaction_trails_on_transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_receivables`
--

DROP TABLE IF EXISTS `payment_receivables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_receivables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `purpose` text COLLATE utf8_unicode_ci,
  `expire_by` date DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `initiating_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_receivable_status_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_receivables_on_customer_id` (`customer_id`),
  KEY `index_payment_receivables_on_amount_id` (`amount_id`),
  KEY `index_payment_receivables_on_company_id` (`company_id`),
  KEY `index_payment_receivables_on_initiating_user_id` (`initiating_user_id`),
  KEY `index_payment_receivables_on_payment_receivable_status_id` (`payment_receivable_status_id`),
  CONSTRAINT `fk_rails_1043dedae4` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_1dbe5e262a` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_rails_9a4e8deed0` FOREIGN KEY (`payment_receivable_status_id`) REFERENCES `payment_receivable_statuses` (`id`),
  CONSTRAINT `fk_rails_b75ace2b78` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_statuses`
--

DROP TABLE IF EXISTS `payment_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_terms`
--

DROP TABLE IF EXISTS `payment_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `days_after` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `company_id` int(11) DEFAULT NULL,
  `default` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_trails`
--

DROP TABLE IF EXISTS `payment_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `initiating_account_id` int(11) DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `initiating_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_status_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `initiating_user_id` int(11) DEFAULT NULL,
  `initiating_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_user_id` int(11) DEFAULT NULL,
  `receiving_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_trails_on_initiating_account_id` (`initiating_account_id`),
  KEY `index_payment_trails_on_receiving_account_id` (`receiving_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_types`
--

DROP TABLE IF EXISTS `payment_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `payment_type_id` int(11) NOT NULL,
  `initiating_user_id` int(11) DEFAULT NULL,
  `receiving_user_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `initiating_account_id` int(11) DEFAULT NULL,
  `initiating_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `receiving_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_order_id` int(11) DEFAULT NULL,
  `payment_status_id` int(11) NOT NULL,
  `initiating_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_purpose_id` int(11) DEFAULT NULL,
  `reference_resource_id` int(11) DEFAULT NULL,
  `reference_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `post_operation` text COLLATE utf8_unicode_ci,
  `post_operation_payload` text COLLATE utf8_unicode_ci,
  `retry_count` int(11) DEFAULT '0',
  `invoice_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `scheduled_at` date DEFAULT NULL,
  `api_initiated` tinyint(1) DEFAULT '0',
  `processed_at` date DEFAULT NULL,
  `original_payment_for_refund_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `destination_pocket_id` int(11) DEFAULT NULL,
  `transaction_reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `external_reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purchase_order_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `beneficiary_payment_id` int(11) DEFAULT NULL,
  `bank_account_provider_id` int(11) DEFAULT NULL,
  `otp` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `otp_attempts` int(11) DEFAULT NULL,
  `on_hold` tinyint(1) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `transfer_mode_id` int(11) DEFAULT NULL,
  `last_retried_at` datetime DEFAULT NULL,
  `utr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text COLLATE utf8_unicode_ci,
  `erp_sync_reference_id` text COLLATE utf8_unicode_ci,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payments_on_amount_id` (`amount_id`),
  KEY `index_payments_on_payment_type_id` (`payment_type_id`),
  KEY `index_payments_on_initiating_user_id` (`initiating_user_id`),
  KEY `index_payments_on_receiving_user_id` (`receiving_user_id`),
  KEY `index_payments_on_category_id` (`category_id`),
  KEY `fk_rails_65acc3c87d` (`purchase_order_id`),
  KEY `fk_rails_b1fc8a9b0f` (`procurement_id`),
  KEY `index_payments_on_beneficiary_payment_id` (`beneficiary_payment_id`),
  KEY `index_payments_on_external_reference_id` (`external_reference_id`),
  KEY `index_payments_on_company_id` (`company_id`),
  KEY `index_payments_on_reference_id` (`reference_id`),
  KEY `index_payments_on_payment_order_id` (`payment_order_id`),
  KEY `index_payments_on_reference_resource` (`reference_resource_type`,`reference_resource_id`),
  KEY `index_payments_on_created_at` (`created_at`),
  KEY `index_payments_on_date` (`date`),
  KEY `index_payments_on_transfer_mode_id` (`transfer_mode_id`),
  KEY `index_payments_on_date_and_created_at` (`date`,`created_at`),
  CONSTRAINT `fk_rails_53ab80214c` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_5d8e0b0538` FOREIGN KEY (`payment_type_id`) REFERENCES `payment_types` (`id`),
  CONSTRAINT `fk_rails_65acc3c87d` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `fk_rails_b1fc8a9b0f` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_f3edfa09f5` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10248 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `per_diem_expense_configs`
--

DROP TABLE IF EXISTS `per_diem_expense_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `per_diem_expense_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `policy_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `per_diem_expenses`
--

DROP TABLE IF EXISTS `per_diem_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `per_diem_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `per_diem_id` int(11) DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `quantity` decimal(10,4) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_per_diem_expenses_on_per_diem_id` (`per_diem_id`),
  KEY `index_per_diem_expenses_on_expense_id` (`expense_id`),
  CONSTRAINT `fk_rails_6ccbbb0b96` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`),
  CONSTRAINT `fk_rails_b9be41775d` FOREIGN KEY (`per_diem_id`) REFERENCES `per_diems` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `per_diems`
--

DROP TABLE IF EXISTS `per_diems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `per_diems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rate_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `configurable_id` int(11) DEFAULT NULL,
  `configurable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_per_diems_on_rate_id` (`rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `periods`
--

DROP TABLE IF EXISTS `periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `periods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `physical_units`
--

DROP TABLE IF EXISTS `physical_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `physical_units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `symbol` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pin_code_city_id_mappings`
--

DROP TABLE IF EXISTS `pin_code_city_id_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pin_code_city_id_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pin_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7486 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policies`
--

DROP TABLE IF EXISTS `policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci,
  `base_currency_id` int(11) DEFAULT '1',
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `settlement_currency_id` int(11) NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policies_on_company_id` (`company_id`),
  KEY `index_policies_on_owner_id` (`owner_id`),
  CONSTRAINT `fk_rails_96cc37057e` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_configurations`
--

DROP TABLE IF EXISTS `policy_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) NOT NULL,
  `require_category` tinyint(1) NOT NULL DEFAULT '0',
  `default_billable_set` tinyint(1) NOT NULL DEFAULT '0',
  `report_currency_id` int(11) DEFAULT NULL,
  `technical_contact_id` int(11) DEFAULT NULL,
  `mandate_expense_tagging` tinyint(1) NOT NULL DEFAULT '0',
  `default_tag_id` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `booking_type_flight` tinyint(1) DEFAULT '1',
  `booking_type_car_rental` tinyint(1) DEFAULT '1',
  `booking_type_bus` tinyint(1) DEFAULT '1',
  `booking_type_train` tinyint(1) DEFAULT '1',
  `booking_type_hotel` tinyint(1) DEFAULT '1',
  `booking_type_restaurant` tinyint(1) DEFAULT '1',
  `booking_type_other` tinyint(1) DEFAULT '1',
  `trips_money_request` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policy_configurations_on_policy_id` (`policy_id`),
  KEY `index_policy_configurations_on_report_currency_id` (`report_currency_id`),
  KEY `index_policy_configurations_on_technical_contact_id` (`technical_contact_id`),
  KEY `index_policy_configurations_on_default_tag_id` (`default_tag_id`),
  CONSTRAINT `fk_rails_cbc4c7b07e` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_cost_center_mappings`
--

DROP TABLE IF EXISTS `policy_cost_center_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_cost_center_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cost_center_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_department_mappings`
--

DROP TABLE IF EXISTS `policy_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_department_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=265 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_designation_mappings`
--

DROP TABLE IF EXISTS `policy_designation_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_designation_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) NOT NULL,
  `designation_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policy_designation_mappings_on_policy_id` (`policy_id`),
  KEY `index_policy_designation_mappings_on_designation_id` (`designation_id`),
  CONSTRAINT `fk_rails_b6d26c7e3b` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_field_mappings`
--

DROP TABLE IF EXISTS `policy_field_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_field_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_configuration_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policy_field_mappings_on_field_configuration_id` (`field_configuration_id`),
  KEY `index_policy_field_mappings_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_317e6543df` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_4e29f277ac` FOREIGN KEY (`field_configuration_id`) REFERENCES `field_configurations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_location_department_mappings`
--

DROP TABLE IF EXISTS `policy_location_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_location_department_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_location_mappings`
--

DROP TABLE IF EXISTS `policy_location_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_location_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_user_mappings`
--

DROP TABLE IF EXISTS `policy_user_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_user_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policy_user_mappings_on_user_id` (`user_id`),
  KEY `index_policy_user_mappings_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_393c9226f9` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_cfe243b040` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_user_roles`
--

DROP TABLE IF EXISTS `policy_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `policy_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_role_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `min_amount` decimal(20,5) DEFAULT '0.00000',
  `max_amount` decimal(20,5) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_policy_user_roles_on_policy_id` (`policy_id`),
  KEY `index_policy_user_roles_on_user_id` (`user_id`),
  KEY `index_policy_user_roles_on_user_role_id` (`user_role_id`),
  CONSTRAINT `fk_rails_6f0e0ca0b9` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_dbaf876455` FOREIGN KEY (`user_role_id`) REFERENCES `user_roles` (`id`),
  CONSTRAINT `fk_rails_e76fc3fc2a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2147 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `post_operation_actions`
--

DROP TABLE IF EXISTS `post_operation_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_operation_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operation` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `payload` text COLLATE utf8_unicode_ci,
  `post_operatable_id` int(11) NOT NULL,
  `post_operatable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_operation_actions_on_operation` (`operation`),
  KEY `index_post_operation_actions_on_post_operatable_id` (`post_operatable_id`),
  KEY `index_post_operation_actions_on_post_operatable_type` (`post_operatable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `preview_registrations`
--

DROP TABLE IF EXISTS `preview_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preview_registrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company` text COLLATE utf8_unicode_ci,
  `phone_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `source` text COLLATE utf8_unicode_ci,
  `source_description` text COLLATE utf8_unicode_ci,
  `referrer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_attachments`
--

DROP TABLE IF EXISTS `procurement_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_file_size` int(11) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `procurement_document_id` int(11) DEFAULT NULL,
  `procurement_document_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_attachments_on_user_id` (`user_id`),
  KEY `index_procurement_attachments_on_procurement_document` (`procurement_document_id`,`procurement_document_type`),
  KEY `index_procurement_attachments_on_vendor_poc_id` (`vendor_poc_id`),
  CONSTRAINT `fk_rails_0c11007c10` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=743 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_charges`
--

DROP TABLE IF EXISTS `procurement_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_charges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charge_type` int(11) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `taxable` tinyint(1) DEFAULT NULL,
  `tax` decimal(10,0) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `chargable_id` int(11) DEFAULT NULL,
  `chargable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_charges_on_amount_id` (`amount_id`),
  KEY `index_procurement_charges_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_procurement_charges_on_total_amount_id` (`total_amount_id`),
  KEY `index_procurement_charges_on_chargable_type_and_chargable_id` (`chargable_type`,`chargable_id`),
  CONSTRAINT `fk_rails_4110c4ac95` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_comments`
--

DROP TABLE IF EXISTS `procurement_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `parent_commentable_id` int(11) DEFAULT NULL,
  `parent_commentable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_comments_on_user_id` (`user_id`),
  KEY `indx_prcurmnt_cmments_on_prnt_cmmentble_typ_n_prnt_cmmentble_id` (`parent_commentable_type`,`parent_commentable_id`),
  CONSTRAINT `fk_rails_14debdd41c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_status_taggables`
--

DROP TABLE IF EXISTS `procurement_status_taggables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_status_taggables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `procurement_id` int(11) DEFAULT NULL,
  `status_tag_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurement_status_taggables_on_procurement_id` (`procurement_id`),
  KEY `index_procurement_status_taggables_on_status_tag_id` (`status_tag_id`),
  CONSTRAINT `fk_rails_ad039c8b20` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_f23366d597` FOREIGN KEY (`status_tag_id`) REFERENCES `status_tags` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1684 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_statuses`
--

DROP TABLE IF EXISTS `procurement_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_terms`
--

DROP TABLE IF EXISTS `procurement_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_procurement_terms_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_a23e4f508f` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurement_tracks`
--

DROP TABLE IF EXISTS `procurement_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurement_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procurements`
--

DROP TABLE IF EXISTS `procurements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `procurement_track_id` int(11) DEFAULT NULL,
  `procurement_status_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `note` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `procurement_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_procurements_on_procurement_track_id` (`procurement_track_id`),
  KEY `index_procurements_on_procurement_status_id` (`procurement_status_id`),
  KEY `index_procurements_on_vendor_id` (`vendor_id`),
  KEY `index_procurements_on_user_id` (`user_id`),
  KEY `index_procurements_on_company_id` (`company_id`),
  KEY `index_procurements_on_procurement_type` (`procurement_type`),
  KEY `index_procurements_on_vendor_poc_id` (`vendor_poc_id`),
  KEY `index_procurements_on_vlpm_id` (`vlpm_id`),
  CONSTRAINT `fk_rails_51c3c4d7df` FOREIGN KEY (`procurement_status_id`) REFERENCES `procurement_statuses` (`id`),
  CONSTRAINT `fk_rails_7f4b88f8bc` FOREIGN KEY (`procurement_track_id`) REFERENCES `procurement_tracks` (`id`),
  CONSTRAINT `fk_rails_84440564cc` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_cffad3c828` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=666 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_combinations`
--

DROP TABLE IF EXISTS `product_combinations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_combinations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_pricing_queries`
--

DROP TABLE IF EXISTS `product_pricing_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_pricing_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `employees` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accounting_system` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `monthly_transactions` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `monthly_invoices` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `product` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prepaid_cards` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_types`
--

DROP TABLE IF EXISTS `product_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_order_items`
--

DROP TABLE IF EXISTS `purchase_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_order_id` int(11) DEFAULT NULL,
  `inventory_line_item_id` int(11) DEFAULT NULL,
  `product_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `hsn_sac` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` decimal(20,5) DEFAULT NULL,
  `rate` decimal(20,5) DEFAULT NULL,
  `tax` decimal(20,5) DEFAULT NULL,
  `tds` decimal(20,5) DEFAULT NULL,
  `discount` decimal(20,5) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `comment` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `delivered` decimal(20,5) DEFAULT '0.00000',
  `accepted` decimal(20,5) DEFAULT '0.00000',
  `rejected` decimal(20,5) DEFAULT '0.00000',
  `category_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `unit_of_measurement` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purchase_request_item_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cgst` decimal(20,10) DEFAULT NULL,
  `sgst` decimal(20,5) DEFAULT '0.00000',
  `igst` decimal(20,5) DEFAULT '0.00000',
  `taxable_amount_id` int(11) DEFAULT NULL,
  `previously_billed_amount` decimal(20,5) DEFAULT '0.00000',
  `tds_applicable` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_purchase_order_items_on_purchase_order_id` (`purchase_order_id`),
  KEY `index_purchase_order_items_on_inventory_line_item_id` (`inventory_line_item_id`),
  KEY `index_purchase_order_items_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_purchase_order_items_on_tds_amount_id` (`tds_amount_id`),
  KEY `index_purchase_order_items_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_purchase_order_items_on_total_amount_id` (`total_amount_id`),
  KEY `index_purchase_order_items_on_department_id` (`department_id`),
  KEY `index_purchase_order_items_on_taxable_amount_id` (`taxable_amount_id`),
  CONSTRAINT `fk_rails_3dc8582641` FOREIGN KEY (`inventory_line_item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `fk_rails_f247068a39` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4151 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_order_statuses`
--

DROP TABLE IF EXISTS `purchase_order_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_order_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `procurement_term_id` int(11) DEFAULT NULL,
  `purchase_order_status_id` int(11) DEFAULT NULL,
  `indent_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `indent_date` date DEFAULT NULL,
  `po_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `override_po_number` tinyint(1) DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `roundoff_total_enabled` tinyint(1) DEFAULT NULL,
  `roundoff_amount` decimal(10,5) DEFAULT NULL,
  `transaction_amount_id` int(11) DEFAULT NULL,
  `total_before_tax_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `total_after_tax_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `balance_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `procurement_term_text` mediumtext COLLATE utf8_unicode_ci,
  `controlling_user_id` int(11) DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `cost_center_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `billing_address` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `shipping_address` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `is_template` tinyint(1) DEFAULT '0',
  `template_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `resource_template_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `advance_amount_status_id` int(11) DEFAULT NULL,
  `bank_account_id` int(11) DEFAULT NULL,
  `revised_po_id` int(11) DEFAULT NULL,
  `revision_of_id` int(11) DEFAULT NULL,
  `revision_number` int(11) DEFAULT '0',
  `note` text COLLATE utf8_unicode_ci,
  `advance_tds_slab_id` int(11) DEFAULT NULL,
  `advance_tds_amount_id` int(11) DEFAULT NULL,
  `advance_amount_required` tinyint(1) DEFAULT '0',
  `requested_advance_amount_id` int(11) DEFAULT NULL,
  `gstin_location_id` bigint(20) DEFAULT NULL,
  `cost_allocation_items` tinyint(1) DEFAULT '0',
  `internal_note` text COLLATE utf8_unicode_ci,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `vendor_address` text COLLATE utf8_unicode_ci,
  `discount_type_id` int(11) DEFAULT NULL,
  `vendor_poc_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_poc_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_poc_mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rejection_note` text COLLATE utf8_unicode_ci,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  `vendor_note` text COLLATE utf8_unicode_ci,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_purchase_orders_on_company_id` (`company_id`),
  KEY `index_purchase_orders_on_procurement_id` (`procurement_id`),
  KEY `index_purchase_orders_on_location_id` (`location_id`),
  KEY `index_purchase_orders_on_delivery_location_id` (`delivery_location_id`),
  KEY `index_purchase_orders_on_vendor_id` (`vendor_id`),
  KEY `index_purchase_orders_on_payment_term_id` (`payment_term_id`),
  KEY `index_purchase_orders_on_procurement_term_id` (`procurement_term_id`),
  KEY `index_purchase_orders_on_purchase_order_status_id` (`purchase_order_status_id`),
  KEY `index_purchase_orders_on_transaction_amount_id` (`transaction_amount_id`),
  KEY `index_purchase_orders_on_total_before_tax_id` (`total_before_tax_id`),
  KEY `index_purchase_orders_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_purchase_orders_on_total_after_tax_id` (`total_after_tax_id`),
  KEY `index_purchase_orders_on_discount_amount_id` (`discount_amount_id`),
  KEY `index_purchase_orders_on_balance_amount_id` (`balance_amount_id`),
  KEY `index_purchase_orders_on_user_id` (`user_id`),
  KEY `index_purchase_orders_on_policy_id` (`policy_id`),
  KEY `fk_rails_a50fbe2826` (`gst_type_id`),
  KEY `index_purchase_orders_on_advance_amount_id` (`advance_amount_id`),
  KEY `index_purchase_orders_on_advance_amount_status_id` (`advance_amount_status_id`),
  KEY `index_purchase_orders_on_due_date_and_created_at` (`due_date`,`created_at`),
  KEY `index_purchase_orders_on_bank_account_id` (`bank_account_id`),
  KEY `index_purchase_orders_on_revised_po_id` (`revised_po_id`),
  KEY `index_purchase_orders_on_revision_of_id` (`revision_of_id`),
  KEY `index_purchase_orders_on_revision_number` (`revision_number`),
  KEY `index_purchase_orders_on_gstin_location_id` (`gstin_location_id`),
  KEY `index_purchase_orders_on_vendor_poc_id` (`vendor_poc_id`),
  KEY `index_purchase_orders_on_vlpm_id` (`vlpm_id`),
  KEY `index_po_ct_lvl_cmpny_id` (`company_id`,`controlling_level_id`,`deleted_at`),
  CONSTRAINT `fk_rails_2d9ce1a8af` FOREIGN KEY (`gstin_location_id`) REFERENCES `gstin_locations` (`id`),
  CONSTRAINT `fk_rails_3079d73660` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_311502bb6d` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_762f6f7a08` FOREIGN KEY (`procurement_term_id`) REFERENCES `procurement_terms` (`id`),
  CONSTRAINT `fk_rails_8ffccc9a07` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_918a143b49` FOREIGN KEY (`purchase_order_status_id`) REFERENCES `purchase_order_statuses` (`id`),
  CONSTRAINT `fk_rails_a50fbe2826` FOREIGN KEY (`gst_type_id`) REFERENCES `gst_types` (`id`),
  CONSTRAINT `fk_rails_a7d26f3dd9` FOREIGN KEY (`procurement_id`) REFERENCES `procurements` (`id`),
  CONSTRAINT `fk_rails_bf1c954a1b` FOREIGN KEY (`payment_term_id`) REFERENCES `payment_terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=422 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_request_item_statuses`
--

DROP TABLE IF EXISTS `purchase_request_item_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_request_item_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_request_items`
--

DROP TABLE IF EXISTS `purchase_request_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_request_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `purchase_request_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `purpose` text,
  `quantity` decimal(20,5) DEFAULT NULL,
  `per_unit_estimated_amount_id` int(11) DEFAULT NULL,
  `estimated_amount_id` int(11) DEFAULT NULL,
  `required_by_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `approved` tinyint(1) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `purchase_order_id` int(11) DEFAULT NULL,
  `rejected` tinyint(1) DEFAULT NULL,
  `unit_of_measurement` varchar(255) DEFAULT NULL,
  `reject_note` varchar(255) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `hsn_sac` varchar(255) DEFAULT NULL,
  `rate_contract_item_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_purchase_request_items_on_purchase_request_id` (`purchase_request_id`),
  KEY `index_purchase_request_items_on_item_id` (`item_id`),
  KEY `index_purchase_request_items_on_vendor_id` (`vendor_id`),
  KEY `index_purchase_request_items_on_delivery_location_id` (`delivery_location_id`),
  KEY `index_purchase_request_items_on_per_unit_estimated_amount_id` (`per_unit_estimated_amount_id`),
  KEY `index_purchase_request_items_on_estimated_amount_id` (`estimated_amount_id`),
  KEY `index_purchase_request_items_on_required_by_date` (`required_by_date`),
  KEY `index_purchase_request_items_on_approved` (`approved`),
  KEY `index_purchase_request_items_on_department_id` (`department_id`),
  KEY `index_purchase_request_items_on_cost_center_id` (`cost_center_id`),
  KEY `index_purchase_request_items_on_category_id` (`category_id`),
  KEY `index_purchase_request_items_on_hsn_sac` (`hsn_sac`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_request_statuses`
--

DROP TABLE IF EXISTS `purchase_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_request_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_requests`
--

DROP TABLE IF EXISTS `purchase_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `purchase_request_status_id` int(11) DEFAULT NULL,
  `note` text,
  `creator_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
  `reject_note` text,
  `cost_center_id` int(11) DEFAULT NULL,
  `total_amount_id` int(11) DEFAULT NULL,
  `cost_allocation_items` tinyint(1) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_purchase_requests_on_purchase_request_status_id` (`purchase_request_status_id`),
  KEY `index_purchase_requests_on_order_number` (`order_number`),
  KEY `index_purchase_requests_on_total_amount_id` (`total_amount_id`),
  KEY `index_po_ct_lvl_cmpny_id` (`company_id`,`controlling_level_id`,`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purposes`
--

DROP TABLE IF EXISTS `purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_categories`
--

DROP TABLE IF EXISTS `quickbooks_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `quickbooks_category_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_integration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_updated_at` datetime DEFAULT NULL,
  `quickbooks_additional_information` mediumtext COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_company_tag`
--

DROP TABLE IF EXISTS `quickbooks_company_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_company_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_tags_id` int(11) DEFAULT NULL,
  `quickbooks_tag_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_integration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_external_information` mediumtext COLLATE utf8_unicode_ci,
  `quickbooks_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_configurations`
--

DROP TABLE IF EXISTS `quickbooks_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `default_quickbooks_payment_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `auto_import` tinyint(1) DEFAULT NULL,
  `auto_export` tinyint(1) DEFAULT NULL,
  `transaction_date_field` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `quickbooks_payment_type_id` int(11) DEFAULT NULL,
  `reimbursable_account_id` int(11) DEFAULT NULL,
  `non_reimbursable_account_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quickbooks_configurations_on_user_id` (`user_id`),
  KEY `index_quickbooks_configurations_on_quickbooks_payment_type_id` (`quickbooks_payment_type_id`),
  CONSTRAINT `fk_rails_84de3c707d` FOREIGN KEY (`quickbooks_payment_type_id`) REFERENCES `quickbooks_payment_types` (`id`),
  CONSTRAINT `fk_rails_c6c7c02a56` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_departments`
--

DROP TABLE IF EXISTS `quickbooks_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `additional_information` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quickbooks_departments_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_48fdb29360` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_finly_integrations_users`
--

DROP TABLE IF EXISTS `quickbooks_finly_integrations_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_finly_integrations_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_integration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_updated_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `quickbooks_additional_information` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `quickbooks_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quickbooks_finly_integrations_users_on_user_id` (`user_id`),
  KEY `index_quickbooks_finly_integrations_users_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_5b44433398` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_78e2ffc2c8` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_payment_types`
--

DROP TABLE IF EXISTS `quickbooks_payment_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_payment_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `quickbooks_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_integration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quickbooks_updated_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `quickbooks_additional_information` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quickbooks_payment_types_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_4b22ac7944` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_reference_types`
--

DROP TABLE IF EXISTS `quickbooks_reference_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_reference_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quickbooks_references`
--

DROP TABLE IF EXISTS `quickbooks_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quickbooks_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `reference_type_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quotations`
--

DROP TABLE IF EXISTS `quotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vendor_name` varchar(255) DEFAULT NULL,
  `vendor_location` varchar(255) DEFAULT NULL,
  `estimated_delivery_time` varchar(255) DEFAULT NULL,
  `total_amount` decimal(20,2) DEFAULT NULL,
  `advance_amount` decimal(20,2) DEFAULT NULL,
  `credit_period` varchar(255) DEFAULT NULL,
  `note` text,
  `selected` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purchase_order_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `quotation_number` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quotations_on_purchase_order_id` (`purchase_order_id`),
  KEY `index_quotations_on_is_deleted` (`is_deleted`),
  KEY `index_quotations_on_deleted_at` (`deleted_at`),
  KEY `index_quotations_on_quotation_number` (`quotation_number`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rate_contract_line_items`
--

DROP TABLE IF EXISTS `rate_contract_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rate_contract_line_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `rate_contract_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rate_contracts`
--

DROP TABLE IF EXISTS `rate_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rate_contracts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `renewable` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `renewal_alert_number` int(11) DEFAULT NULL,
  `renewal_alert_period_id` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `rate_contract_number` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rate_types`
--

DROP TABLE IF EXISTS `rate_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rate_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receipt_email_attachments`
--

DROP TABLE IF EXISTS `receipt_email_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipt_email_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `receipt_email_id` int(11) DEFAULT NULL,
  `original_attachment_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_attachment_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_attachment_file_size` int(11) DEFAULT NULL,
  `original_attachment_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `attachment_url` text COLLATE utf8_unicode_ci,
  `attachment_url_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipt_email_attachments_on_receipt_email_id` (`receipt_email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receipt_email_parse_failures`
--

DROP TABLE IF EXISTS `receipt_email_parse_failures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipt_email_parse_failures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `body_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body_file_size` int(11) DEFAULT NULL,
  `body_updated_at` datetime DEFAULT NULL,
  `raw_text_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_text_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_text_file_size` int(11) DEFAULT NULL,
  `raw_text_updated_at` datetime DEFAULT NULL,
  `raw_html_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_html_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_html_file_size` int(11) DEFAULT NULL,
  `raw_html_updated_at` datetime DEFAULT NULL,
  `raw_header_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_header_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_header_file_size` int(11) DEFAULT NULL,
  `raw_header_updated_at` datetime DEFAULT NULL,
  `original_source_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_source_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_source_file_size` int(11) DEFAULT NULL,
  `original_source_updated_at` datetime DEFAULT NULL,
  `email_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_file_size` int(11) DEFAULT NULL,
  `source_updated_at` datetime DEFAULT NULL,
  `fixed` tinyint(1) DEFAULT '0',
  `parsed_merchant` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parsed_amount_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parsed_currency_id` int(11) DEFAULT NULL,
  `parsed_datetime` datetime DEFAULT NULL,
  `parsed_note` text COLLATE utf8_unicode_ci,
  `parsed_category_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipt_email_parse_failures_on_user_id` (`user_id`),
  KEY `index_receipt_email_parse_failures_on_parsed_currency_id` (`parsed_currency_id`),
  KEY `index_receipt_email_parse_failures_on_parsed_category_id` (`parsed_category_id`),
  CONSTRAINT `fk_rails_8aa317810b` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receipt_email_statuses`
--

DROP TABLE IF EXISTS `receipt_email_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipt_email_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipt_email_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receipt_emails`
--

DROP TABLE IF EXISTS `receipt_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipt_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` text COLLATE utf8_unicode_ci,
  `sent_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `body_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body_file_size` int(11) DEFAULT NULL,
  `body_updated_at` datetime DEFAULT NULL,
  `raw_text_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_text_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_text_file_size` int(11) DEFAULT NULL,
  `raw_text_updated_at` datetime DEFAULT NULL,
  `raw_html_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_html_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_html_file_size` int(11) DEFAULT NULL,
  `raw_html_updated_at` datetime DEFAULT NULL,
  `raw_header_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_header_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_header_file_size` int(11) DEFAULT NULL,
  `raw_header_updated_at` datetime DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `email_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_source_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_source_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_source_file_size` int(11) DEFAULT NULL,
  `original_source_updated_at` datetime DEFAULT NULL,
  `receipt_email_status_id` bigint(20) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipt_emails_on_user_id` (`user_id`),
  KEY `index_receipt_emails_on_expense_id` (`expense_id`),
  KEY `index_receipt_emails_on_receipt_email_status_id` (`receipt_email_status_id`),
  CONSTRAINT `fk_rails_09950f8cad` FOREIGN KEY (`receipt_email_status_id`) REFERENCES `receipt_email_statuses` (`id`),
  CONSTRAINT `fk_rails_b620fa6867` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receipts`
--

DROP TABLE IF EXISTS `receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `receipt_email_id` int(11) DEFAULT NULL,
  `to_be_transcribed` tinyint(1) DEFAULT '0',
  `hard_copy_received` tinyint(1) DEFAULT '1',
  `sourcable_id` int(11) DEFAULT NULL,
  `sourcable_type` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_by_id` int(11) DEFAULT NULL,
  `modified_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipts_on_user_id` (`user_id`),
  KEY `index_receipts_on_parent_type_and_parent_id` (`parent_type`,`parent_id`),
  KEY `index_receipts_on_receipt_email_id` (`receipt_email_id`),
  KEY `index_receipts_on_created_at` (`created_at`),
  KEY `index_receipts_on_parent_id` (`parent_id`),
  KEY `index_receipts_id_user_parent_parent_id` (`id`,`user_id`,`parent_id`,`parent_type`,`to_be_transcribed`),
  CONSTRAINT `fk_rails_4c5a1ad6db` FOREIGN KEY (`receipt_email_id`) REFERENCES `receipt_emails` (`id`),
  CONSTRAINT `fk_rails_b2d4d3fa14` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `referrers`
--

DROP TABLE IF EXISTS `referrers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `referrers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rental_invoices`
--

DROP TABLE IF EXISTS `rental_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rental_invoices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `invoice_number` text,
  `tax_type_id` int(11) DEFAULT NULL,
  `discount` decimal(10,0) DEFAULT NULL,
  `discount_type_id` int(11) DEFAULT NULL,
  `gross_amount_id` int(11) DEFAULT NULL,
  `net_amount_id` int(11) DEFAULT NULL,
  `inclusive_of_taxes` tinyint(1) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `tds` decimal(10,0) DEFAULT NULL,
  `tds_type_id` int(11) DEFAULT NULL,
  `gst_type_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `discount_amount_id` int(11) DEFAULT NULL,
  `tds_amount_id` int(11) DEFAULT NULL,
  `tax_amount_id` int(11) DEFAULT NULL,
  `tax` decimal(10,0) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `original_amount_id` int(11) DEFAULT NULL,
  `advance_amount_id` int(11) DEFAULT NULL,
  `advance_type_id` int(11) DEFAULT NULL,
  `advance` decimal(10,0) DEFAULT NULL,
  `freight_amount_id` int(11) DEFAULT NULL,
  `freight_type_id` int(11) DEFAULT NULL,
  `freight` decimal(10,0) DEFAULT NULL,
  `roundoff_amount` decimal(10,0) DEFAULT NULL,
  `balance_due_id` int(11) DEFAULT NULL,
  `taxable_amount_id` int(11) DEFAULT NULL,
  `tds_slab_id` int(11) DEFAULT NULL,
  `invoice_status_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `paid_amount_id` int(11) DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `receiving_account_type` varchar(255) DEFAULT NULL,
  `procurement_id` int(11) DEFAULT NULL,
  `remaining_amount_id` int(11) DEFAULT NULL,
  `invoice_type_id` int(11) DEFAULT NULL,
  `delivery_location_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `is_template` tinyint(1) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `resource_template_id` int(11) DEFAULT NULL,
  `invoice_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `gstin_location_id` int(11) DEFAULT NULL,
  `transaction_service_period_from` date DEFAULT NULL,
  `transaction_service_period_to` date DEFAULT NULL,
  `cost_allocation_items` tinyint(1) DEFAULT NULL,
  `narration` text,
  `po_number` varchar(255) DEFAULT NULL,
  `payment_agreement_id` int(11) DEFAULT NULL,
  `bank_account_id` int(11) DEFAULT NULL,
  `vendor_location_id` int(11) DEFAULT NULL,
  `rejection_note` text,
  `payment_agreement_escalation_id` int(11) DEFAULT NULL,
  `invoice_frequency_id` int(11) DEFAULT NULL,
  `billing_start_date` datetime DEFAULT NULL,
  `billing_day_of_month` int(11) DEFAULT NULL,
  `payment_agreement_upcoming_date` date DEFAULT NULL,
  `is_payment_agreement_upcoming_invoice` tinyint(1) DEFAULT NULL,
  `recurring_invoice_id` int(11) DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `vlpm_id` int(11) DEFAULT NULL,
  `client_note` text,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `lock_in_period` int(11) DEFAULT NULL,
  `rent_free_period` int(11) DEFAULT NULL,
  `tenancy_period` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `note` text,
  `billing_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `po_adjusted_advance` int(11) DEFAULT NULL,
  `po_advance` int(11) DEFAULT NULL,
  `po_prev_adjusted_advance` int(11) DEFAULT NULL,
  `advance_amount_required` tinyint(1) DEFAULT NULL,
  `proforma_invoice_id` int(11) DEFAULT NULL,
  `proforma_advance` int(11) DEFAULT NULL,
  `total_proforma_advance` int(11) DEFAULT NULL,
  `template_invoice_id` int(11) DEFAULT NULL,
  `notice_period` int(11) DEFAULT NULL,
  `square_feet` decimal(10,5) DEFAULT NULL,
  `prepaid` tinyint(1) DEFAULT NULL,
  `fixed_periodic_template` tinyint(1) DEFAULT NULL,
  `escalation_percentage` float DEFAULT NULL,
  `override_invoice_id` varchar(255) DEFAULT NULL,
  `rcm_enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rental_invoices_on_gross_amount_id` (`gross_amount_id`),
  KEY `index_rental_invoices_on_net_amount_id` (`net_amount_id`),
  KEY `index_rental_invoices_on_amount_id` (`amount_id`),
  KEY `index_rental_invoices_on_tds_amount_id` (`tds_amount_id`),
  KEY `index_rental_invoices_on_tax_amount_id` (`tax_amount_id`),
  KEY `index_rental_invoices_on_original_amount_id` (`original_amount_id`),
  KEY `index_rental_invoices_on_advance_amount_id` (`advance_amount_id`),
  KEY `index_rental_invoices_on_advance_type_id` (`advance_type_id`),
  KEY `index_rental_invoices_on_freight_amount_id` (`freight_amount_id`),
  KEY `index_rental_invoices_on_balance_due_id` (`balance_due_id`),
  KEY `index_rental_invoices_on_taxable_amount_id` (`taxable_amount_id`),
  KEY `index_rental_invoices_on_paid_amount_id` (`paid_amount_id`),
  KEY `index_rental_invoices_on_remaining_amount_id` (`remaining_amount_id`),
  KEY `index_rental_invoices_on_template_invoice_id` (`template_invoice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_comment_actions`
--

DROP TABLE IF EXISTS `report_comment_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_comment_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_comments`
--

DROP TABLE IF EXISTS `report_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `report_comment_action_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `updated_field` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `updated_from` text COLLATE utf8_unicode_ci,
  `updated_to` text COLLATE utf8_unicode_ci,
  `rejected_to_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_comments_on_report_id` (`report_id`),
  KEY `index_report_comments_on_report_comment_action_id` (`report_comment_action_id`),
  KEY `index_report_comments_on_user_id` (`user_id`),
  KEY `index_report_comments_on_expense_id` (`expense_id`),
  KEY `index_report_comments_on_rejected_to_id` (`rejected_to_id`),
  CONSTRAINT `fk_rails_1ffff53e1c` FOREIGN KEY (`report_comment_action_id`) REFERENCES `report_comment_actions` (`id`),
  CONSTRAINT `fk_rails_7275193832` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_95e4666705` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`),
  CONSTRAINT `fk_rails_f29d9e2f5c` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=379 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_processor_group_mappings`
--

DROP TABLE IF EXISTS `report_processor_group_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_processor_group_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `processor_group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `processor_accountable_id` int(11) DEFAULT NULL,
  `processor_accountable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `marked_as_completed` tinyint(1) DEFAULT '0',
  `status_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `marked_as_closed` tinyint(1) DEFAULT NULL,
  `bank_reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_processor_group_mappings_on_processor_group_id` (`processor_group_id`),
  KEY `index_report_processor_group_mappings_on_user_id` (`user_id`),
  KEY `index_report_processor_group_mappings_on_amount_id` (`amount_id`),
  KEY `index_report_processor_group_mappings_on_status_id` (`status_id`),
  KEY `index_report_processor_group_mappings_on_payment_id` (`payment_id`),
  KEY `index_report_processor_group_mappings_on_bank_reference_number` (`bank_reference_number`),
  CONSTRAINT `fk_rails_0eabfef7c2` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`),
  CONSTRAINT `fk_rails_43829e9a3f` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_59b00dabfd` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_processor_group_statuses`
--

DROP TABLE IF EXISTS `report_processor_group_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_processor_group_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_processor_group_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_processor_groups`
--

DROP TABLE IF EXISTS `report_processor_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_processor_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `payment_file_generated` tinyint(1) DEFAULT '0',
  `payment_file_generated_at` datetime DEFAULT NULL,
  `scheduled_at` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `total_amount_id` int(11) NOT NULL,
  `processed_amount_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) DEFAULT NULL,
  `source_account_id` int(11) DEFAULT NULL,
  `source_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `marked_as_completed` tinyint(1) DEFAULT '0',
  `payment_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_mode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_order_id` int(11) DEFAULT NULL,
  `created_by_user_role_id` int(11) DEFAULT NULL,
  `marked_as_closed` tinyint(1) DEFAULT NULL,
  `tally_exported` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_processor_groups_on_status_id` (`status_id`),
  KEY `index_report_processor_groups_on_scheduled_at` (`scheduled_at`),
  KEY `index_report_processor_groups_on_total_amount_id` (`total_amount_id`),
  KEY `index_report_processor_groups_on_processed_amount_id` (`processed_amount_id`),
  KEY `index_report_processor_groups_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_report_processor_groups_on_source_account_id` (`source_account_id`),
  KEY `index_report_processor_groups_on_source_account_type` (`source_account_type`),
  KEY `index_report_processor_groups_on_company_id` (`company_id`),
  KEY `index_report_processor_groups_on_payment_order_id` (`payment_order_id`),
  CONSTRAINT `fk_rails_89e50052c0` FOREIGN KEY (`payment_order_id`) REFERENCES `payment_orders` (`id`),
  CONSTRAINT `fk_rails_afcc532142` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_statuses`
--

DROP TABLE IF EXISTS `report_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `order` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_sync_statuses`
--

DROP TABLE IF EXISTS `report_sync_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_sync_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_sync_types`
--

DROP TABLE IF EXISTS `report_sync_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_sync_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_sync_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_tracking_actions`
--

DROP TABLE IF EXISTS `report_tracking_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_tracking_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_tracks`
--

DROP TABLE IF EXISTS `report_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `modified_user_id` int(11) DEFAULT NULL,
  `report_tracking_action_id` int(11) DEFAULT NULL,
  `report_status_id` int(11) NOT NULL,
  `modified_user_role_id` int(11) DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `action_user_role_id` int(11) DEFAULT NULL,
  `cash_in_hand_deduction_id` int(11) DEFAULT NULL,
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_report_tracks_on_report_id` (`report_id`),
  KEY `index_report_tracks_on_action_user_id` (`action_user_id`),
  KEY `index_report_tracks_on_modified_user_id` (`modified_user_id`),
  KEY `index_report_tracks_on_report_tracking_action_id` (`report_tracking_action_id`),
  KEY `index_report_tracks_on_report_status_id` (`report_status_id`),
  KEY `index_report_tracks_on_modified_user_role_id` (`modified_user_role_id`),
  CONSTRAINT `fk_rails_2352308545` FOREIGN KEY (`report_tracking_action_id`) REFERENCES `report_tracking_actions` (`id`),
  CONSTRAINT `fk_rails_b2cd0ee0c1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  CONSTRAINT `fk_rails_b4006f1df5` FOREIGN KEY (`report_status_id`) REFERENCES `report_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=530 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `report_status_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `submitted_at` datetime(6) DEFAULT NULL,
  `controlling_user_id` int(11) DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `reimbursement_id` int(11) DEFAULT NULL,
  `accounted` tinyint(1) NOT NULL DEFAULT '0',
  `archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `auto_submit` tinyint(1) NOT NULL DEFAULT '0',
  `auto_approve` tinyint(1) NOT NULL DEFAULT '0',
  `accounted_at` date DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `cash_in_hand_deduction_id` int(11) DEFAULT NULL,
  `submitted_amount_id` int(11) DEFAULT NULL,
  `reimbursable_expenses_total_id` int(11) DEFAULT NULL,
  `card_expenses_total_id` int(11) DEFAULT NULL,
  `non_reimbursable_expenses_total_id` int(11) DEFAULT NULL,
  `sync_status_id` int(11) DEFAULT NULL,
  `report_processor_group_mapping_id` int(11) DEFAULT NULL,
  `sync_type_id` int(11) DEFAULT NULL,
  `travel_request_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `modified_by_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `bank_reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text COLLATE utf8_unicode_ci,
  `erp_sync_reference_id` text COLLATE utf8_unicode_ci,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reports_on_user_id` (`user_id`),
  KEY `index_reports_on_report_status_id` (`report_status_id`),
  KEY `index_reports_on_policy_id` (`policy_id`),
  KEY `index_reports_on_controlling_user_id` (`controlling_user_id`),
  KEY `index_reports_on_controlling_user_role_id` (`controlling_user_role_id`),
  KEY `index_reports_on_controlling_for_user_id` (`controlling_for_user_id`),
  KEY `index_reports_on_controlling_for_user_role_id` (`controlling_for_user_role_id`),
  KEY `index_reports_on_name` (`name`),
  KEY `index_reports_on_report_processor_group_mapping_id` (`report_processor_group_mapping_id`),
  KEY `report_joined_index_plcy_status` (`policy_id`,`report_status_id`),
  CONSTRAINT `fk_rails_38312d3976` FOREIGN KEY (`report_processor_group_mapping_id`) REFERENCES `report_processor_group_mappings` (`id`),
  CONSTRAINT `fk_rails_9040d54724` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`),
  CONSTRAINT `fk_rails_c7699d537d` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_d1dbb38e4a` FOREIGN KEY (`report_status_id`) REFERENCES `report_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=304 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_impressions`
--

DROP TABLE IF EXISTS `request_impressions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_impressions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL,
  `ip_type` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `referrer` text,
  `referring_domain` varchar(255) DEFAULT NULL,
  `landing_page` text,
  `app_version` varchar(255) DEFAULT NULL,
  `continent_name` varchar(255) DEFAULT NULL,
  `continent_code` varchar(255) DEFAULT NULL,
  `country_name` varchar(255) DEFAULT NULL,
  `country_code` varchar(255) DEFAULT NULL,
  `region_code` varchar(255) DEFAULT NULL,
  `region_name` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `latitude` decimal(20,10) DEFAULT NULL,
  `longitude` decimal(20,10) DEFAULT NULL,
  `accuracy_radius` int(11) DEFAULT NULL,
  `utm_source` varchar(255) DEFAULT NULL,
  `utm_medium` varchar(255) DEFAULT NULL,
  `utm_term` varchar(255) DEFAULT NULL,
  `utm_content` varchar(255) DEFAULT NULL,
  `utm_campaign` varchar(255) DEFAULT NULL,
  `http_method` varchar(255) NOT NULL,
  `app` varchar(255) DEFAULT NULL,
  `path` varchar(255) NOT NULL,
  `controller` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `view` varchar(255) DEFAULT NULL,
  `blocked` tinyint(1) DEFAULT NULL,
  `blocked_by` varchar(255) DEFAULT NULL,
  `block_reason` varchar(255) DEFAULT NULL,
  `response_code` decimal(10,0) DEFAULT NULL,
  `response_time` decimal(10,0) DEFAULT NULL,
  `user_session_id` int(11) DEFAULT NULL,
  `access_token_id` int(11) DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  `user_ip_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_request_impressions_on_ip` (`ip`),
  KEY `index_request_impressions_on_user_agent` (`user_agent`),
  KEY `index_request_impressions_on_username` (`username`),
  KEY `index_request_impressions_on_user_id` (`user_id`),
  KEY `index_request_impressions_on_company_id` (`company_id`),
  KEY `index_request_impressions_on_country_name` (`country_name`),
  KEY `index_request_impressions_on_app` (`app`),
  KEY `index_request_impressions_on_path` (`path`),
  KEY `index_request_impressions_on_controller` (`controller`),
  KEY `index_request_impressions_on_action` (`action`),
  KEY `index_request_impressions_on_blocked` (`blocked`),
  KEY `index_request_impressions_on_blocked_by` (`blocked_by`),
  KEY `index_request_impressions_on_block_reason` (`block_reason`),
  KEY `index_request_impressions_on_response_code` (`response_code`),
  KEY `index_request_impressions_on_response_time` (`response_time`),
  KEY `index_request_impressions_on_user_session_id` (`user_session_id`),
  KEY `index_request_impressions_on_access_token_id` (`access_token_id`),
  KEY `index_request_impressions_on_user_device_id` (`user_device_id`),
  KEY `index_request_impressions_on_user_ip_id` (`user_ip_id`)
) ENGINE=InnoDB AUTO_INCREMENT=450665 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_requests`
--

DROP TABLE IF EXISTS `resource_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `resource_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` text COLLATE utf8_unicode_ci,
  `source_description` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_templates`
--

DROP TABLE IF EXISTS `resource_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `resource_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_resource_templates_on_name` (`name`),
  KEY `index_resource_templates_on_resource_type` (`resource_type`),
  KEY `index_resource_templates_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_b936dba856` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reviewal_levels`
--

DROP TABLE IF EXISTS `reviewal_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviewal_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level_number` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `associated_entity_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reviewal_levels_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_cca201b433` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=302 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rule_types`
--

DROP TABLE IF EXISTS `rule_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rule_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `security_deposit_statuses`
--

DROP TABLE IF EXISTS `security_deposit_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `security_deposit_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `security_deposits`
--

DROP TABLE IF EXISTS `security_deposits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `security_deposits` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) DEFAULT NULL,
  `vendor_location_id` int(11) DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `note` text,
  `description` text,
  `payable_amount_id` int(11) DEFAULT NULL,
  `original_amount_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payment_agreement_id` int(11) DEFAULT NULL,
  `bank_account_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `payment_agreement_upcoming_date` date DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_security_deposits_on_bank_account_id` (`bank_account_id`),
  KEY `index_security_deposits_on_company_id` (`company_id`),
  KEY `index_security_deposits_on_creator_id` (`creator_id`),
  KEY `index_security_deposits_on_status_id` (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `signedup_users`
--

DROP TABLE IF EXISTS `signedup_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `signedup_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `products` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `single_sign_on_configurations`
--

DROP TABLE IF EXISTS `single_sign_on_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `single_sign_on_configurations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `assertion_consumer_service_url` varchar(255) DEFAULT NULL,
  `assertion_consumer_service_binding` varchar(255) DEFAULT NULL,
  `name_identifier_format` varchar(255) DEFAULT NULL,
  `issuer` varchar(255) DEFAULT NULL,
  `idp_sso_target_url` varchar(255) DEFAULT NULL,
  `idp_cert_fingerprint` varchar(255) DEFAULT NULL,
  `idp_cert` varchar(255) DEFAULT NULL,
  `idp_cert_fingerprint_algorithm` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `single_sign_on_type_id` int(11) DEFAULT NULL,
  `authentication_context` varchar(255) DEFAULT NULL,
  `finly_sso_path` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `sso_type` varchar(255) DEFAULT '',
  `logo` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_single_sign_on_configurations_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `single_sign_on_types`
--

DROP TABLE IF EXISTS `single_sign_on_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `single_sign_on_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sso_keys`
--

DROP TABLE IF EXISTS `sso_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sso_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `xor_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sha512_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sso_keys_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_fab5687dab` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `states`
--

DROP TABLE IF EXISTS `states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `status_tags`
--

DROP TABLE IF EXISTS `status_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `status_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `font_icon` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `font_icon_color` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `icon_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `supply_item_types`
--

DROP TABLE IF EXISTS `supply_item_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supply_item_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_resource_id` int(11) NOT NULL,
  `log_resource_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type_id` int(11) NOT NULL,
  `value` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_logs_on_log_resource_id` (`log_resource_id`),
  KEY `index_system_logs_on_log_resource_type` (`log_resource_type`),
  KEY `index_system_logs_on_type_id` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_message_types`
--

DROP TABLE IF EXISTS `system_message_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_message_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_messages`
--

DROP TABLE IF EXISTS `system_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `system_message_type_id` int(11) NOT NULL,
  `messagable_id` int(11) DEFAULT NULL,
  `messagable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `message_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_messages_on_system_message_type_id` (`system_message_type_id`),
  KEY `index_system_messages_on_messagable_type_and_messagable_id` (`messagable_type`,`messagable_id`),
  KEY `index_system_messages_on_message_type` (`message_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tally_configurations`
--

DROP TABLE IF EXISTS `tally_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tally_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `company_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `voucher_expense_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_voucher` tinyint(1) DEFAULT '0',
  `excel_export` tinyint(1) DEFAULT '0',
  `invoice_voucher_enabled` tinyint(1) DEFAULT NULL,
  `invoice_voucher_configuration` longtext COLLATE utf8_unicode_ci,
  `bpr_voucher_enabled` tinyint(1) DEFAULT NULL,
  `bpr_voucher_configuration` longtext COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tally_configurations_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_55ab74e289` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task_file_manager_actions`
--

DROP TABLE IF EXISTS `task_file_manager_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_file_manager_actions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_workflow_id` int(11) NOT NULL,
  `export_template_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_task_file_manager_actions_on_event_workflow_id` (`event_workflow_id`),
  KEY `index_task_file_manager_actions_on_export_template_id` (`export_template_id`),
  CONSTRAINT `fk_rails_20fc81b1e7` FOREIGN KEY (`export_template_id`) REFERENCES `export_templates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task_schedules`
--

DROP TABLE IF EXISTS `task_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_schedules` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `every` int(11) DEFAULT NULL,
  `hour` int(11) DEFAULT NULL,
  `minute` int(11) DEFAULT NULL,
  `day_of_the_week` int(11) DEFAULT NULL,
  `day_of_the_month` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task_workflows`
--

DROP TABLE IF EXISTS `task_workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_workflows` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `trigger_type` int(11) NOT NULL,
  `conditions` text,
  `model_class` varchar(255) NOT NULL,
  `event_key` varchar(255) DEFAULT NULL,
  `personal` tinyint(1) DEFAULT '1',
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `task_schedule_id` int(11) DEFAULT NULL,
  `uuid` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_task_workflows_on_trigger_type` (`trigger_type`),
  KEY `index_task_workflows_on_model_class` (`model_class`),
  KEY `index_task_workflows_on_event_key` (`event_key`),
  KEY `index_task_workflows_on_personal` (`personal`),
  KEY `index_task_workflows_on_user_id` (`user_id`),
  KEY `index_task_workflows_on_company_id` (`company_id`),
  KEY `index_task_workflows_on_created_at` (`created_at`),
  KEY `index_task_workflows_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_per_items`
--

DROP TABLE IF EXISTS `tax_per_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_per_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `document_type` varchar(255) DEFAULT NULL,
  `document_id` bigint(20) DEFAULT NULL,
  `tax_rate_type` varchar(255) DEFAULT NULL,
  `tax_rate_id` bigint(20) DEFAULT NULL,
  `cgst_id` int(11) DEFAULT NULL,
  `sgst_id` int(11) DEFAULT NULL,
  `igst_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tax_per_items_on_document_type_and_document_id` (`document_type`,`document_id`),
  KEY `index_tax_per_items_on_tax_rate_type_and_tax_rate_id` (`tax_rate_type`,`tax_rate_id`),
  KEY `index_tax_per_items_on_cgst_id` (`cgst_id`),
  KEY `index_tax_per_items_on_sgst_id` (`sgst_id`),
  KEY `index_tax_per_items_on_igst_id` (`igst_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_rates`
--

DROP TABLE IF EXISTS `tax_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rate` decimal(20,5) DEFAULT NULL,
  `internal_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `cgst` decimal(10,5) DEFAULT NULL,
  `sgst` decimal(10,5) DEFAULT NULL,
  `igst` decimal(10,5) DEFAULT NULL,
  `igst_internal_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cgst_internal_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sgst_internal_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tax_rates_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_742a454c02` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_types`
--

DROP TABLE IF EXISTS `tax_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country_name` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT '',
  `tax_name` varchar(255) DEFAULT '',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tax_types_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tds_rates_lists`
--

DROP TABLE IF EXISTS `tds_rates_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tds_rates_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tds` decimal(10,5) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `gl_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=209 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temporary_files`
--

DROP TABLE IF EXISTS `temporary_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temporary_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_file_size` bigint(20) DEFAULT NULL,
  `file_updated_at` datetime DEFAULT NULL,
  `expires_on` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_temporary_files_on_expires_on` (`expires_on`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_expense_configs`
--

DROP TABLE IF EXISTS `time_expense_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `time_expense_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `default_category_id` int(11) DEFAULT NULL,
  `rate_id` int(11) DEFAULT NULL,
  `period_id` int(11) DEFAULT NULL,
  `policy_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_expenses`
--

DROP TABLE IF EXISTS `time_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `time_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expense_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_object_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_time_expenses_on_expense_id` (`expense_id`),
  CONSTRAINT `fk_rails_0a7476aee7` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_objects`
--

DROP TABLE IF EXISTS `time_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `time_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` decimal(10,4) DEFAULT NULL,
  `physical_unit_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_time_objects_on_physical_unit_id` (`physical_unit_id`),
  CONSTRAINT `fk_rails_c78bbf061b` FOREIGN KEY (`physical_unit_id`) REFERENCES `physical_units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trail_actions`
--

DROP TABLE IF EXISTS `trail_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trail_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trails`
--

DROP TABLE IF EXISTS `trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `action_user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `action_user_role_id` int(11) DEFAULT NULL,
  `action_level_id` int(11) DEFAULT NULL,
  `modified_level_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `original_track_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_track_id` int(11) DEFAULT NULL,
  `cash_on_hand_deduction_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trails_on_parent_type_and_parent_id` (`parent_type`,`parent_id`),
  KEY `index_trails_on_action_user_id` (`action_user_id`),
  KEY `index_trails_on_action_id` (`action_id`),
  KEY `index_trails_on_action_user_role_id` (`action_user_role_id`),
  KEY `index_trails_on_action_level_id` (`action_level_id`),
  KEY `index_trails_on_modified_level_id` (`modified_level_id`),
  KEY `index_trails_on_action_user_type` (`action_user_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4991 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_details`
--

DROP TABLE IF EXISTS `transaction_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_reference_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_purpose` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `merchant` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `note` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `finly_transaction_id` int(11) DEFAULT NULL,
  `opening_balance_id` int(11) DEFAULT NULL,
  `closing_balance_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sequence_number` int(11) DEFAULT NULL,
  `payment_id` bigint(20) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transaction_details_on_company_id` (`company_id`),
  KEY `fk_rails_12e08cc879` (`amount_id`),
  KEY `fk_rails_db0f67a401` (`finly_transaction_id`),
  KEY `index_transaction_details_on_payment_id` (`payment_id`),
  CONSTRAINT `fk_rails_12e08cc879` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_db0f67a401` FOREIGN KEY (`finly_transaction_id`) REFERENCES `finly_transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2613 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_statuses`
--

DROP TABLE IF EXISTS `transaction_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_types`
--

DROP TABLE IF EXISTS `transaction_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcribed_expenses`
--

DROP TABLE IF EXISTS `transcribed_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcribed_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `merchant` text COLLATE utf8_unicode_ci,
  `note` text COLLATE utf8_unicode_ci,
  `receipt_id` int(11) DEFAULT NULL,
  `expense_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transcribed_expenses_on_amount_id` (`amount_id`),
  KEY `index_transcribed_expenses_on_receipt_id` (`receipt_id`),
  KEY `index_transcribed_expenses_on_expense_id` (`expense_id`),
  KEY `index_transcribed_expenses_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_25f96febb4` FOREIGN KEY (`receipt_id`) REFERENCES `receipts` (`id`),
  CONSTRAINT `fk_rails_79c7944954` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_8ac078d572` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`),
  CONSTRAINT `fk_rails_cbf3296489` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transfer_mode_company_mappings`
--

DROP TABLE IF EXISTS `transfer_mode_company_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transfer_mode_company_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `mode_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transfer_mode_company_mappings_on_company_id` (`company_id`),
  KEY `index_transfer_mode_company_mappings_on_mode_id` (`mode_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transfer_modes`
--

DROP TABLE IF EXISTS `transfer_modes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transfer_modes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transfer_modes_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_members`
--

DROP TABLE IF EXISTS `travel_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `child` tinyint(1) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `booking_request_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_travel_members_on_booking_id` (`booking_id`),
  KEY `index_travel_members_on_booking_request_id` (`booking_request_id`),
  CONSTRAINT `fk_rails_24651978a4` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `fk_rails_faa2c43124` FOREIGN KEY (`booking_request_id`) REFERENCES `booking_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_comment_actions`
--

DROP TABLE IF EXISTS `travel_request_comment_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_comment_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_comments`
--

DROP TABLE IF EXISTS `travel_request_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `travel_request_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `previous_value` text COLLATE utf8_unicode_ci,
  `new_value` text COLLATE utf8_unicode_ci,
  `edited_field` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `action_id` int(11) DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `booking_request_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_travel_request_comments_on_travel_request_id` (`travel_request_id`),
  KEY `index_travel_request_comments_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_73a7285ba1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_cfc39e912a` FOREIGN KEY (`travel_request_id`) REFERENCES `travel_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_destinations`
--

DROP TABLE IF EXISTS `travel_request_destinations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_destinations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `travel_request_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_travel_request_destinations_on_travel_request_id` (`travel_request_id`),
  CONSTRAINT `fk_rails_5701dc2f2d` FOREIGN KEY (`travel_request_id`) REFERENCES `travel_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_statuses`
--

DROP TABLE IF EXISTS `travel_request_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_trail_actions`
--

DROP TABLE IF EXISTS `travel_request_trail_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_trail_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_request_trails`
--

DROP TABLE IF EXISTS `travel_request_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_request_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `travel_request_id` int(11) DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `action_user_id` int(11) DEFAULT NULL,
  `action_user_role_id` int(11) DEFAULT NULL,
  `modified_user_id` int(11) DEFAULT NULL,
  `modified_user_role_id` int(11) DEFAULT NULL,
  `action_for_user_id` int(11) DEFAULT NULL,
  `action_for_user_role_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `delegated_action_user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_travel_request_trails_on_travel_request_id` (`travel_request_id`),
  KEY `index_travel_request_trails_on_action_id` (`action_id`),
  KEY `index_travel_request_trails_on_action_user_id` (`action_user_id`),
  KEY `index_travel_request_trails_on_action_user_role_id` (`action_user_role_id`),
  KEY `index_travel_request_trails_on_modified_user_id` (`modified_user_id`),
  KEY `index_travel_request_trails_on_modified_user_role_id` (`modified_user_role_id`),
  KEY `index_travel_request_trails_on_action_for_user_id` (`action_for_user_id`),
  KEY `index_travel_request_trails_on_action_for_user_role_id` (`action_for_user_role_id`),
  CONSTRAINT `fk_rails_72955de4ed` FOREIGN KEY (`travel_request_id`) REFERENCES `travel_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `travel_requests`
--

DROP TABLE IF EXISTS `travel_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `travel_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `status_id` int(11) NOT NULL,
  `controlling_user_id` int(11) DEFAULT NULL,
  `controlling_user_role_id` int(11) DEFAULT NULL,
  `controlling_for_user_id` int(11) DEFAULT NULL,
  `controlling_for_user_role_id` int(11) DEFAULT NULL,
  `submitted_at` datetime(6) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `rejection_note` text COLLATE utf8_unicode_ci,
  `auto_approved` tinyint(1) DEFAULT NULL,
  `memo` text COLLATE utf8_unicode_ci,
  `from_date` date DEFAULT NULL,
  `to_date` date DEFAULT NULL,
  `trip_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purpose_of_travel` text COLLATE utf8_unicode_ci,
  `approved_at` datetime DEFAULT NULL,
  `selection_requested_at` datetime DEFAULT NULL,
  `booking_confirmed_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `modified_by_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `booking_submitted_at` datetime DEFAULT NULL,
  `booking_approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_travel_requests_on_user_id` (`user_id`),
  KEY `index_travel_requests_on_policy_id` (`policy_id`),
  KEY `index_travel_requests_on_status_id` (`status_id`),
  KEY `index_travel_requests_on_controlling_user_id` (`controlling_user_id`),
  KEY `index_travel_requests_on_controlling_user_role_id` (`controlling_user_role_id`),
  KEY `index_travel_requests_on_controlling_for_user_id` (`controlling_for_user_id`),
  KEY `index_travel_requests_on_controlling_for_user_role_id` (`controlling_for_user_role_id`),
  KEY `index_travel_requests_on_company_id` (`company_id`),
  KEY `index_travel_requests_on_created_by_id` (`created_by_id`),
  KEY `index_travel_requests_on_modified_by_id` (`modified_by_id`),
  CONSTRAINT `fk_rails_7eb2b66464` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_dc1ada5c05` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_hotel_requests`
--

DROP TABLE IF EXISTS `trip_hotel_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_hotel_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `traveller_id` int(11) DEFAULT NULL,
  `company_id` bigint(20) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `preferred_area` varchar(255) DEFAULT NULL,
  `checkin_at` datetime DEFAULT NULL,
  `checkout_at` datetime DEFAULT NULL,
  `description` text,
  `budget_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_hotel_requests_on_uuid` (`uuid`),
  KEY `index_trip_hotel_requests_on_trip_id` (`trip_id`),
  KEY `index_trip_hotel_requests_on_created_by_id` (`created_by_id`),
  KEY `index_trip_hotel_requests_on_traveller_id` (`traveller_id`),
  KEY `index_trip_hotel_requests_on_company_id` (`company_id`),
  KEY `index_trip_hotel_requests_on_budget_id` (`budget_id`),
  KEY `index_trip_hotel_requests_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_local_conveyance_requests`
--

DROP TABLE IF EXISTS `trip_local_conveyance_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_local_conveyance_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `traveller_id` int(11) DEFAULT NULL,
  `company_id` bigint(20) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `pickup_area` varchar(255) DEFAULT NULL,
  `pickup_at` datetime DEFAULT NULL,
  `drop_at` datetime DEFAULT NULL,
  `description` text,
  `budget_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_local_conveyance_requests_on_uuid` (`uuid`),
  KEY `index_trip_local_conveyance_requests_on_trip_id` (`trip_id`),
  KEY `index_trip_local_conveyance_requests_on_created_by_id` (`created_by_id`),
  KEY `index_trip_local_conveyance_requests_on_traveller_id` (`traveller_id`),
  KEY `index_trip_local_conveyance_requests_on_company_id` (`company_id`),
  KEY `index_trip_local_conveyance_requests_on_budget_id` (`budget_id`),
  KEY `index_trip_local_conveyance_requests_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_passengers`
--

DROP TABLE IF EXISTS `trip_passengers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_passengers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `contact_number` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_passengers_on_uuid` (`uuid`),
  KEY `index_trip_passengers_on_trip_id` (`trip_id`),
  KEY `index_trip_passengers_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_routes`
--

DROP TABLE IF EXISTS `trip_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_routes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `from_location` varchar(255) DEFAULT NULL,
  `to_location` varchar(255) DEFAULT NULL,
  `depart_on` date DEFAULT NULL,
  `return_on` date DEFAULT NULL,
  `require_transport` tinyint(1) DEFAULT '0',
  `require_hotel` tinyint(1) DEFAULT '0',
  `require_local_conveyance` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_routes_on_uuid` (`uuid`),
  KEY `index_trip_routes_on_trip_id` (`trip_id`),
  KEY `index_trip_routes_on_from_location` (`from_location`),
  KEY `index_trip_routes_on_to_location` (`to_location`),
  KEY `index_trip_routes_on_depart_on` (`depart_on`),
  KEY `index_trip_routes_on_return_on` (`return_on`),
  KEY `index_trip_routes_on_require_transport` (`require_transport`),
  KEY `index_trip_routes_on_require_hotel` (`require_hotel`),
  KEY `index_trip_routes_on_require_local_conveyance` (`require_local_conveyance`),
  KEY `index_trip_routes_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_statuses`
--

DROP TABLE IF EXISTS `trip_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_transport_requests`
--

DROP TABLE IF EXISTS `trip_transport_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_transport_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `traveller_id` int(11) DEFAULT NULL,
  `company_id` bigint(20) DEFAULT NULL,
  `from_location` varchar(255) DEFAULT NULL,
  `to_location` varchar(255) DEFAULT NULL,
  `mode` varchar(255) DEFAULT NULL,
  `depart_on` date DEFAULT NULL,
  `preferred_timeframe` varchar(255) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `description` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_transport_requests_on_uuid` (`uuid`),
  KEY `index_trip_transport_requests_on_trip_id` (`trip_id`),
  KEY `index_trip_transport_requests_on_created_by_id` (`created_by_id`),
  KEY `index_trip_transport_requests_on_traveller_id` (`traveller_id`),
  KEY `index_trip_transport_requests_on_company_id` (`company_id`),
  KEY `index_trip_transport_requests_on_from_location` (`from_location`),
  KEY `index_trip_transport_requests_on_to_location` (`to_location`),
  KEY `index_trip_transport_requests_on_mode` (`mode`),
  KEY `index_trip_transport_requests_on_depart_on` (`depart_on`),
  KEY `index_trip_transport_requests_on_budget_id` (`budget_id`),
  KEY `index_trip_transport_requests_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_types`
--

DROP TABLE IF EXISTS `trip_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trip_types_on_name` (`name`),
  KEY `index_trip_types_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trips`
--

DROP TABLE IF EXISTS `trips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trips` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `trip_id` varchar(255) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `purpose` text,
  `estimated_booking_cost_id` int(11) DEFAULT NULL,
  `booking_cost_id` int(11) DEFAULT NULL,
  `advance_requested_id` int(11) DEFAULT NULL,
  `advance_processed_id` int(11) DEFAULT NULL,
  `expenses_total_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `trip_type_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trips_on_uuid` (`uuid`),
  KEY `index_trips_on_company_id` (`company_id`),
  KEY `index_trips_on_created_by_id` (`created_by_id`),
  KEY `index_trips_on_status_id` (`status_id`),
  KEY `index_trips_on_trip_id` (`trip_id`),
  KEY `index_trips_on_policy_id` (`policy_id`),
  KEY `index_trips_on_start_date` (`start_date`),
  KEY `index_trips_on_end_date` (`end_date`),
  KEY `index_trips_on_estimated_booking_cost_id` (`estimated_booking_cost_id`),
  KEY `index_trips_on_booking_cost_id` (`booking_cost_id`),
  KEY `index_trips_on_advance_requested_id` (`advance_requested_id`),
  KEY `index_trips_on_advance_processed_id` (`advance_processed_id`),
  KEY `index_trips_on_expenses_total_id` (`expenses_total_id`),
  KEY `index_trips_on_deleted_at` (`deleted_at`),
  KEY `index_trips_on_trip_type_id` (`trip_type_id`),
  CONSTRAINT `fk_rails_68b82e6772` FOREIGN KEY (`trip_type_id`) REFERENCES `trip_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unique_identifiers`
--

DROP TABLE IF EXISTS `unique_identifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unique_identifiers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `sequence_start` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `purpose_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_unique_identifiers_on_purpose_id` (`purpose_id`),
  KEY `index_unique_identifiers_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_41866fca17` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_c20394d0e0` FOREIGN KEY (`purpose_id`) REFERENCES `purposes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `value` varchar(255) DEFAULT '',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_units_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_agent_client_statuses`
--

DROP TABLE IF EXISTS `user_agent_client_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_agent_client_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_agent_client_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_agent_clients`
--

DROP TABLE IF EXISTS `user_agent_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_agent_clients` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_agent` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `verification_mode` varchar(255) DEFAULT NULL,
  `verification_key` varchar(255) DEFAULT NULL,
  `verification_code_sent_at` datetime DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_code_count` int(11) DEFAULT NULL,
  `verification_code_failed_attempts` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_finly_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_agent_clients_on_user_agent` (`user_agent`),
  KEY `index_user_agent_clients_on_user_id` (`user_id`),
  KEY `index_user_agent_clients_on_status_id` (`status_id`),
  KEY `index_user_agent_clients_on_verification_mode` (`verification_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_auth_failures`
--

DROP TABLE IF EXISTS `user_auth_failures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_auth_failures` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `locked` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `blank_username` tinyint(1) DEFAULT '0',
  `blank_password` tinyint(1) DEFAULT '0',
  `invalid_username` tinyint(1) DEFAULT '0',
  `invalid_password` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_auth_failures_on_user_id` (`user_id`),
  KEY `index_user_auth_failures_on_locked` (`locked`)
) ENGINE=InnoDB AUTO_INCREMENT=363 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_balance_histories`
--

DROP TABLE IF EXISTS `user_balance_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_balance_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `card_balance_id` int(11) DEFAULT NULL,
  `card_withdrawal_id` int(11) DEFAULT NULL,
  `card_load_id` int(11) DEFAULT NULL,
  `card_expenses_id` int(11) DEFAULT NULL,
  `finly_money_balance_id` int(11) DEFAULT NULL,
  `finly_money_withdrawal_id` int(11) DEFAULT NULL,
  `finly_money_load_id` int(11) DEFAULT NULL,
  `cash_on_hand_balance_id` int(11) DEFAULT NULL,
  `cash_on_hand_withdrawal_id` int(11) DEFAULT NULL,
  `cash_on_hand_load_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `card_atm_withdrawal_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_balance_histories_on_user_id` (`user_id`),
  KEY `index_user_balance_histories_on_company_id` (`company_id`),
  KEY `index_user_balance_histories_on_card_balance_id` (`card_balance_id`),
  KEY `index_user_balance_histories_on_card_withdrawal_id` (`card_withdrawal_id`),
  KEY `index_user_balance_histories_on_card_load_id` (`card_load_id`),
  KEY `index_user_balance_histories_on_card_expenses_id` (`card_expenses_id`),
  KEY `index_user_balance_histories_on_finly_money_balance_id` (`finly_money_balance_id`),
  KEY `index_user_balance_histories_on_finly_money_withdrawal_id` (`finly_money_withdrawal_id`),
  KEY `index_user_balance_histories_on_finly_money_load_id` (`finly_money_load_id`),
  KEY `index_user_balance_histories_on_cash_on_hand_balance_id` (`cash_on_hand_balance_id`),
  KEY `index_user_balance_histories_on_cash_on_hand_withdrawal_id` (`cash_on_hand_withdrawal_id`),
  KEY `index_user_balance_histories_on_cash_on_hand_load_id` (`cash_on_hand_load_id`),
  CONSTRAINT `fk_rails_236459b1ca` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_5d655a2497` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1197 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_branch_location_mappings`
--

DROP TABLE IF EXISTS `user_branch_location_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_branch_location_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `branch_location_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_branch_location_mappings_on_user_id` (`user_id`),
  KEY `index_user_branch_location_mappings_on_branch_location_id` (`branch_location_id`),
  CONSTRAINT `fk_rails_2a7da85367` FOREIGN KEY (`branch_location_id`) REFERENCES `branch_locations` (`id`),
  CONSTRAINT `fk_rails_bb7514efd9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_delegate_mappings`
--

DROP TABLE IF EXISTS `user_delegate_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_delegate_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `delegate_for_user_id` int(11) DEFAULT NULL,
  `expense_create` tinyint(1) DEFAULT NULL,
  `expense_update` tinyint(1) DEFAULT NULL,
  `receipt_create` tinyint(1) DEFAULT NULL,
  `receipt_add_to_expense` tinyint(1) DEFAULT NULL,
  `receipt_update` tinyint(1) DEFAULT NULL,
  `report_create` tinyint(1) DEFAULT NULL,
  `report_submit` tinyint(1) DEFAULT NULL,
  `report_retract` tinyint(1) DEFAULT NULL,
  `report_update` tinyint(1) DEFAULT NULL,
  `money_request_create` tinyint(1) DEFAULT NULL,
  `money_request_update` tinyint(1) DEFAULT NULL,
  `money_request_submit` tinyint(1) DEFAULT NULL,
  `money_request_retract` tinyint(1) DEFAULT NULL,
  `travel_request_create` tinyint(1) DEFAULT NULL,
  `travel_request_update` tinyint(1) DEFAULT NULL,
  `travel_request_submit` tinyint(1) DEFAULT NULL,
  `travel_request_retract` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_delegate_mappings_on_user_id` (`user_id`),
  KEY `index_user_delegate_mappings_on_delegate_for_user_id` (`delegate_for_user_id`),
  CONSTRAINT `fk_rails_5513aa0cac` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_department_mappings`
--

DROP TABLE IF EXISTS `user_department_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_department_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_department_mappings_on_user_id` (`user_id`),
  KEY `index_user_department_mappings_on_department_id` (`department_id`),
  CONSTRAINT `fk_rails_61199adc2e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_d1faf37492` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_device_browsers`
--

DROP TABLE IF EXISTS `user_device_browsers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_device_browsers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `fingerprint` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `system_language` varchar(255) DEFAULT NULL,
  `browser` varchar(255) DEFAULT NULL,
  `browser_version` varchar(255) DEFAULT NULL,
  `browser_engine` varchar(255) DEFAULT NULL,
  `browser_engine_version` varchar(255) DEFAULT NULL,
  `os_name` varchar(255) DEFAULT NULL,
  `os_version` varchar(255) DEFAULT NULL,
  `screen_width` int(11) DEFAULT NULL,
  `screen_height` int(11) DEFAULT NULL,
  `device_x_dpi` int(11) DEFAULT NULL,
  `device_y_dpi` int(11) DEFAULT NULL,
  `color_depth` int(11) DEFAULT NULL,
  `java_enabled` tinyint(1) DEFAULT NULL,
  `java_version` varchar(255) DEFAULT NULL,
  `flash_enabled` tinyint(1) DEFAULT NULL,
  `flash_version` varchar(255) DEFAULT NULL,
  `silver_light_enabled` tinyint(1) DEFAULT NULL,
  `silver_light_version` varchar(255) DEFAULT NULL,
  `is_mime_types` tinyint(1) DEFAULT NULL,
  `mime_types_list` varchar(255) DEFAULT NULL,
  `fonts_list` text,
  `is_local_storage` tinyint(1) DEFAULT NULL,
  `is_session_storage` tinyint(1) DEFAULT NULL,
  `is_cookie` tinyint(1) DEFAULT NULL,
  `plugins` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_mobile` tinyint(1) DEFAULT NULL,
  `status_id` int(11) NOT NULL,
  `message` text,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_device_statuses`
--

DROP TABLE IF EXISTS `user_device_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_device_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_device_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_devices`
--

DROP TABLE IF EXISTS `user_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_devices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `fingerprint` varchar(255) DEFAULT NULL,
  `status_id` int(11) NOT NULL,
  `verification_mode` varchar(255) DEFAULT NULL,
  `verification_key` varchar(255) DEFAULT NULL,
  `verification_code_sent_at` datetime DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_code_count` int(11) DEFAULT NULL,
  `verification_failed_attempts` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `client_id` int(11) DEFAULT NULL,
  `client_type` varchar(255) DEFAULT NULL,
  `message` text,
  `user_finly_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_devices_on_user_id` (`user_id`),
  KEY `index_user_devices_on_company_id` (`company_id`),
  KEY `index_user_devices_on_fingerprint` (`fingerprint`),
  KEY `index_user_devices_on_status_id` (`status_id`),
  KEY `index_user_devices_on_verification_mode` (`verification_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=171 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_drop_down_item_mappings`
--

DROP TABLE IF EXISTS `user_drop_down_item_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_drop_down_item_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `drop_down_item_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_drop_down_item_mappings_on_user_id` (`user_id`),
  KEY `index_user_drop_down_item_mappings_on_drop_down_item_id` (`drop_down_item_id`),
  KEY `index_user_drop_down_item_mappings_on_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_field_mappings`
--

DROP TABLE IF EXISTS `user_field_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_field_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `field_configuration_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_field_mappings_on_user_id` (`user_id`),
  KEY `index_user_field_mappings_on_field_configuration_id` (`field_configuration_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_department_location_mappings`
--

DROP TABLE IF EXISTS `user_group_department_location_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_department_location_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_department_location_mappings_on_location_id` (`location_id`),
  KEY `index_user_group_department_location_mappings_on_department_id` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_departments`
--

DROP TABLE IF EXISTS `user_group_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_departments_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_d656b77195` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_designations`
--

DROP TABLE IF EXISTS `user_group_designations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_designations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_designations_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_0d64a82502` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_item_mappings`
--

DROP TABLE IF EXISTS `user_group_item_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_item_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `user_group_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `user_group_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_item_mappings_on_user_id` (`user_id`),
  KEY `index_user_group_item_mappings_on_user_group_item_id` (`user_group_item_id`),
  KEY `index_user_group_item_mappings_on_user_group_id` (`user_group_id`),
  CONSTRAINT `fk_rails_4a04e44e4a` FOREIGN KEY (`user_group_id`) REFERENCES `user_groups` (`id`),
  CONSTRAINT `fk_rails_546e317f9d` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_fba480881f` FOREIGN KEY (`user_group_item_id`) REFERENCES `user_group_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_items`
--

DROP TABLE IF EXISTS `user_group_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_group_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_items_on_name` (`name`),
  KEY `index_user_group_items_on_user_group_id` (`user_group_id`),
  CONSTRAINT `fk_rails_4549e25a49` FOREIGN KEY (`user_group_id`) REFERENCES `user_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_locations`
--

DROP TABLE IF EXISTS `user_group_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_group_locations_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_f335784695` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_groups`
--

DROP TABLE IF EXISTS `user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_groups_on_name` (`name`),
  KEY `index_user_groups_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_cefbffa692` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_ip_statuses`
--

DROP TABLE IF EXISTS `user_ip_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_ip_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_ip_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_ips`
--

DROP TABLE IF EXISTS `user_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_ips` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL,
  `ip_type` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `verification_mode` varchar(255) DEFAULT NULL,
  `verification_key` varchar(255) DEFAULT NULL,
  `verification_code_sent_at` datetime DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verification_code_count` int(11) DEFAULT NULL,
  `verification_code_failed_attempts` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `continent_name` varchar(255) DEFAULT NULL,
  `continent_code` varchar(255) DEFAULT NULL,
  `country_name` varchar(255) DEFAULT NULL,
  `country_code` varchar(255) DEFAULT NULL,
  `region_code` varchar(255) DEFAULT NULL,
  `region_name` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `latitude` decimal(20,10) DEFAULT NULL,
  `longitude` decimal(20,10) DEFAULT NULL,
  `accuracy_radius` int(11) DEFAULT NULL,
  `user_finly_id` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_ips_on_ip` (`ip`),
  KEY `index_user_ips_on_ip_type` (`ip_type`),
  KEY `index_user_ips_on_user_id` (`user_id`),
  KEY `index_user_ips_on_status_id` (`status_id`),
  KEY `index_user_ips_on_verification_mode` (`verification_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_login_tracks`
--

DROP TABLE IF EXISTS `user_login_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_login_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referrer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_login_tracks_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_7e7f57061a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=409 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_manager_mappings`
--

DROP TABLE IF EXISTS `user_manager_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_manager_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `finance_manager_id` int(11) DEFAULT NULL,
  `approves_to_id` int(11) DEFAULT NULL,
  `approves_finance_to_id` int(11) DEFAULT NULL,
  `greater_than_amount_id` int(11) DEFAULT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `policy_id` int(11) NOT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `travel_manager_id` int(11) DEFAULT NULL,
  `manager_violation_only` tinyint(1) DEFAULT NULL,
  `finance_violation_only` tinyint(1) DEFAULT NULL,
  `travel_booking_selector_id` int(11) DEFAULT NULL,
  `travel_booking_approves_to_id` int(11) DEFAULT NULL,
  `travel_approves_to_id` int(11) DEFAULT NULL,
  `approves_to_violation_only` tinyint(1) DEFAULT '0',
  `approves_finance_to_violation_only` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_manager_mappings_on_user_id` (`user_id`),
  KEY `index_user_manager_mappings_on_manager_id` (`manager_id`),
  KEY `index_user_manager_mappings_on_finance_manager_id` (`finance_manager_id`),
  KEY `index_user_manager_mappings_on_approves_to_id` (`approves_to_id`),
  KEY `index_user_manager_mappings_on_approves_finance_to_id` (`approves_finance_to_id`),
  KEY `index_user_manager_mappings_on_greater_than_amount_id` (`greater_than_amount_id`),
  KEY `index_user_manager_mappings_on_policy_id` (`policy_id`),
  CONSTRAINT `fk_rails_2b23ed2dd5` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_d33534d01d` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=596 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_manager_type_mappings`
--

DROP TABLE IF EXISTS `user_manager_type_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_manager_type_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `manager_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `location_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_manager_type_mappings_on_user_id` (`user_id`),
  KEY `index_user_manager_type_mappings_on_manager_type_id` (`manager_type_id`),
  CONSTRAINT `fk_rails_58790b50c7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_b1e8c0c9ea` FOREIGN KEY (`manager_type_id`) REFERENCES `manager_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_panel_subscriptions`
--

DROP TABLE IF EXISTS `user_panel_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_panel_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `disburse` tinyint(1) DEFAULT NULL,
  `expense_management` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `yes_bank_account_transfer` tinyint(1) DEFAULT NULL,
  `invoicing_system` tinyint(1) DEFAULT '0',
  `travel_request` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `weekly_summary_enabled` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_panel_subscriptions_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_164e273225` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=309 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `create_beneficiaries` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `edit_terms_within_po` tinyint(1) DEFAULT '0',
  `crud_inventory_item_po` tinyint(1) DEFAULT '1',
  `crud_inventory_item_non_po` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_permissions_on_user_id` (`user_id`),
  KEY `index_user_permissions_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_b29e483ce4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f5139b91d0` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_pocket_types`
--

DROP TABLE IF EXISTS `user_pocket_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_pocket_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_pockets`
--

DROP TABLE IF EXISTS `user_pockets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_pockets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `user_pocket_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `account_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `atm_withdrawal_pocket` tinyint(1) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `base_currency_id` int(11) DEFAULT NULL,
  `company_pocket_template_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_pockets_on_balance_id` (`balance_id`),
  KEY `index_user_pockets_on_user_pocket_type_id` (`user_pocket_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=501 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `avatar_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_file_size` int(11) DEFAULT NULL,
  `avatar_updated_at` datetime DEFAULT NULL,
  `kyc_verified` tinyint(1) DEFAULT NULL,
  `gcm_sender_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `employee_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payroll_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_currency_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `pin_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature_file_size` int(11) DEFAULT NULL,
  `signature_updated_at` datetime DEFAULT NULL,
  `signature_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vp_web_client_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vp_web_client_theme` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `em_web_client_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `em_web_client_theme` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_profiles_on_user_id` (`user_id`),
  KEY `index_user_profiles_on_default_currency_id` (`default_currency_id`),
  KEY `fk_rails_9207fd1f96` (`state_id`),
  KEY `index_user_profiles_on_pan` (`pan`),
  CONSTRAINT `fk_rails_87a6352e58` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_9207fd1f96` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=314 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_role_mappings`
--

DROP TABLE IF EXISTS `user_role_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `user_role_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `company_department_id` int(11) DEFAULT NULL,
  `branch_location_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_role_mappings_on_user_id` (`user_id`),
  KEY `index_user_role_mappings_on_user_role_id` (`user_role_id`),
  CONSTRAINT `fk_rails_e84071773e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_ed968f7768` FOREIGN KEY (`user_role_id`) REFERENCES `user_roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=747 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_session_events`
--

DROP TABLE IF EXISTS `user_session_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_session_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_session_id` int(11) NOT NULL,
  `http_method` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `app` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `controller` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `view` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `response_code` int(11) DEFAULT NULL,
  `current_resolution_height` int(11) DEFAULT NULL,
  `current_resolution_width` int(11) DEFAULT NULL,
  `mouse_pos_x` int(11) DEFAULT NULL,
  `mouse_pos_y` int(11) DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_session_events_on_user_session_id` (`user_session_id`),
  KEY `index_user_session_events_on_app` (`app`),
  KEY `index_user_session_events_on_path` (`path`),
  KEY `index_user_session_events_on_controller` (`controller`),
  KEY `index_user_session_events_on_action` (`action`)
) ENGINE=InnoDB AUTO_INCREMENT=517688 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_session_notifications`
--

DROP TABLE IF EXISTS `user_session_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_session_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `app` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `device` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `view` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status_id` int(11) DEFAULT NULL,
  `message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_session_notifications_on_user_id` (`user_id`),
  KEY `index_user_session_notifications_on_company_id` (`company_id`),
  KEY `index_user_session_notifications_on_app` (`app`),
  KEY `index_user_session_notifications_on_device` (`device`),
  KEY `index_user_session_notifications_on_view` (`view`),
  CONSTRAINT `fk_rails_53084c07c1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_e4cb036032` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_session_statuses`
--

DROP TABLE IF EXISTS `user_session_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_session_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_session_statuses_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ip_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referrer` text COLLATE utf8_unicode_ci,
  `referring_domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `landing_page` text COLLATE utf8_unicode_ci,
  `app_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `continent_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `continent_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` decimal(20,10) DEFAULT NULL,
  `longitude` decimal(20,10) DEFAULT NULL,
  `utm_source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `utm_medium` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `utm_term` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `utm_content` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `utm_campaign` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `started_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `access_token_id` int(11) DEFAULT NULL,
  `last_request_at` datetime DEFAULT NULL,
  `duration` bigint(20) DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `login_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accuracy_radius` int(11) DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  `user_agent` text COLLATE utf8_unicode_ci,
  `user_ip_id` int(11) DEFAULT NULL,
  `user_agent_client_id` int(11) DEFAULT NULL,
  `admin_user_id` int(11) DEFAULT NULL,
  `admin_access_reason` text COLLATE utf8_unicode_ci,
  `admin_access_reason_details` text COLLATE utf8_unicode_ci,
  `scopes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin_access_requested_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_sessions_on_user_id` (`user_id`),
  KEY `index_user_sessions_on_company_id` (`company_id`),
  KEY `index_user_sessions_on_ip` (`ip`),
  KEY `index_user_sessions_on_latitude` (`latitude`),
  KEY `index_user_sessions_on_longitude` (`longitude`),
  KEY `index_user_sessions_on_started_at` (`started_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_tags`
--

DROP TABLE IF EXISTS `user_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_tags_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_ea0382482a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_team_group_item_mappings`
--

DROP TABLE IF EXISTS `user_team_group_item_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_team_group_item_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) NOT NULL,
  `user_group_item_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_team_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_team_group_item_mappings_on_user_group_id` (`user_group_id`),
  KEY `index_user_team_group_item_mappings_on_user_group_item_id` (`user_group_item_id`),
  KEY `index_user_team_group_item_mappings_on_user_team_id` (`user_team_id`),
  CONSTRAINT `fk_rails_e04c9e724f` FOREIGN KEY (`user_group_id`) REFERENCES `user_groups` (`id`),
  CONSTRAINT `fk_rails_e2f241bfc8` FOREIGN KEY (`user_team_id`) REFERENCES `user_teams` (`id`),
  CONSTRAINT `fk_rails_fc3a8658a3` FOREIGN KEY (`user_group_item_id`) REFERENCES `user_group_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_teams`
--

DROP TABLE IF EXISTS `user_teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_teams_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_wallet_track_actions`
--

DROP TABLE IF EXISTS `user_wallet_track_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_wallet_track_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CreateUserWallets` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_wallet_tracks`
--

DROP TABLE IF EXISTS `user_wallet_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_wallet_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_wallet_id` int(11) NOT NULL,
  `user_wallet_track_action_id` int(11) NOT NULL,
  `amount_id` int(11) NOT NULL,
  `action_user_id` int(11) NOT NULL,
  `balance_after_action_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_wallet_tracks_on_user_wallet_id` (`user_wallet_id`),
  KEY `index_user_wallet_tracks_on_user_wallet_track_action_id` (`user_wallet_track_action_id`),
  KEY `index_user_wallet_tracks_on_amount_id` (`amount_id`),
  KEY `index_user_wallet_tracks_on_action_user_id` (`action_user_id`),
  KEY `index_user_wallet_tracks_on_balance_after_action_id` (`balance_after_action_id`),
  CONSTRAINT `fk_rails_659b656d96` FOREIGN KEY (`user_wallet_track_action_id`) REFERENCES `user_wallet_track_actions` (`id`),
  CONSTRAINT `fk_rails_d702eb873e` FOREIGN KEY (`user_wallet_id`) REFERENCES `user_wallets` (`id`),
  CONSTRAINT `fk_rails_fd6b8256d3` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_wallets`
--

DROP TABLE IF EXISTS `user_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `balance_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_wallets_on_balance_id` (`balance_id`),
  KEY `index_user_wallets_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_82b7604640` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT '0',
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) NOT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `invitation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invitation_created_at` datetime DEFAULT NULL,
  `invitation_sent_at` datetime DEFAULT NULL,
  `invitation_accepted_at` datetime DEFAULT NULL,
  `invitation_limit` int(11) DEFAULT NULL,
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_by_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invitations_count` int(11) DEFAULT '0',
  `otp` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `otp_sent_at` datetime DEFAULT NULL,
  `otp_verified_at` datetime DEFAULT NULL,
  `otp_verified` tinyint(1) NOT NULL DEFAULT '0',
  `otp_count` int(11) NOT NULL DEFAULT '0',
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_only_invite` tinyint(1) DEFAULT '0',
  `mothers_maiden_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `verified` tinyint(1) DEFAULT '0',
  `otp_request_type_id` int(11) DEFAULT NULL,
  `default_password` tinyint(1) DEFAULT '0',
  `point_of_contact` tinyint(1) DEFAULT '0',
  `otp_attempts` int(11) DEFAULT '0',
  `user_group_location_id` int(11) DEFAULT NULL,
  `user_group_department_id` int(11) DEFAULT NULL,
  `user_group_designation_id` int(11) DEFAULT NULL,
  `user_delegate_id` int(11) DEFAULT NULL,
  `delegation_enabled` tinyint(1) DEFAULT NULL,
  `gl_config` text COLLATE utf8_unicode_ci,
  `vacation_delegate_enabled` tinyint(1) DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `expired_at` datetime DEFAULT NULL,
  `cost_center_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `default_company_id` int(11) DEFAULT NULL,
  `finly_id` varchar(36) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `pending_activation` tinyint(1) DEFAULT '0',
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text COLLATE utf8_unicode_ci,
  `erp_sync_reference_id` text COLLATE utf8_unicode_ci,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_invitation_token` (`invitation_token`),
  KEY `index_users_on_company_id` (`company_id`),
  KEY `index_users_on_invitations_count` (`invitations_count`),
  KEY `index_users_on_invited_by_id` (`invited_by_id`),
  KEY `index_users_on_email` (`email`),
  CONSTRAINT `fk_rails_7682a3bdfe` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_with_group_mappings`
--

DROP TABLE IF EXISTS `users_with_group_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_with_group_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_with_group_mappings_on_user_id` (`user_id`),
  KEY `index_users_with_group_mappings_on_company_id` (`company_id`),
  KEY `index_users_with_group_mappings_on_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `utility_bills_accounts`
--

DROP TABLE IF EXISTS `utility_bills_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `utility_bills_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `balance_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_utility_bills_accounts_on_balance_id` (`balance_id`),
  KEY `index_utility_bills_accounts_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_rates`
--

DROP TABLE IF EXISTS `vehicle_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicle_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `rate_id` int(11) NOT NULL,
  `distance_unit_id` int(11) NOT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vehicle_rates_on_rate_id` (`rate_id`),
  KEY `index_vehicle_rates_on_distance_unit_id` (`distance_unit_id`),
  KEY `index_vehicle_rates_on_policy_id` (`policy_id`),
  KEY `index_vehicle_rates_on_is_deleted` (`is_deleted`),
  CONSTRAINT `fk_rails_5cb7a2eca3` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_account_transactions`
--

DROP TABLE IF EXISTS `vendor_account_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_account_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_account_id` int(11) DEFAULT NULL,
  `transaction_type_id` int(11) DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_account_transactions_on_vendor_account_id` (`vendor_account_id`),
  KEY `index_vendor_account_transactions_on_transaction_type_id` (`transaction_type_id`),
  KEY `index_vendor_account_transactions_on_amount_id` (`amount_id`),
  KEY `index_vendor_account_transactions_on_payment_id` (`payment_id`),
  CONSTRAINT `fk_rails_9c0a54134b` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`),
  CONSTRAINT `fk_rails_ba2e20972a` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_be5c638f02` FOREIGN KEY (`vendor_account_id`) REFERENCES `vendor_accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_accounts`
--

DROP TABLE IF EXISTS `vendor_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `balance_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_accounts_on_balance_id` (`balance_id`),
  KEY `index_vendor_accounts_on_vendor_id` (`vendor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=278 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_attachments`
--

DROP TABLE IF EXISTS `vendor_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attached_file_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attached_file_file_size` int(11) DEFAULT NULL,
  `attached_file_updated_at` datetime DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `yes_bank_vendor_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `attachment_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_attachments_on_yes_bank_vendor_id` (`yes_bank_vendor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_location_poc_mappings`
--

DROP TABLE IF EXISTS `vendor_location_poc_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_location_poc_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gstin_location_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `vendor_poc_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_dealers_on_vendor_information` (`vendor_id`,`gstin_location_id`,`vendor_poc_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_payment_wallets`
--

DROP TABLE IF EXISTS `vendor_payment_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_payment_wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `balance_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_payment_wallets_on_balance_id` (`balance_id`),
  KEY `index_vendor_payment_wallets_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_ac5ae7a171` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_pocs`
--

DROP TABLE IF EXISTS `vendor_pocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_pocs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT '0',
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `account_activated` tinyint(1) DEFAULT '0',
  `vendor_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `mobile_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_vendor_pocs_on_email` (`email`),
  UNIQUE KEY `index_vendor_pocs_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_vendor_pocs_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_vendor_pocs_on_unlock_token` (`unlock_token`),
  KEY `index_vendor_pocs_on_account_activated` (`account_activated`),
  KEY `index_vendor_pocs_on_vendor_id` (`vendor_id`),
  KEY `index_vendor_pocs_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_statuses`
--

DROP TABLE IF EXISTS `vendor_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_statuses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_tds_rates`
--

DROP TABLE IF EXISTS `vendor_tds_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_tds_rates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `tds_rates_list_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_tds_rates_on_vendor_id` (`vendor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_types`
--

DROP TABLE IF EXISTS `vendor_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendor_types_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_9cf7943655` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `version_associations`
--

DROP TABLE IF EXISTS `version_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `version_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version_id` int(11) DEFAULT NULL,
  `foreign_key_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `foreign_key_id` int(11) DEFAULT NULL,
  `foreign_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_version_associations_on_version_id` (`version_id`),
  KEY `index_version_associations_on_foreign_key` (`foreign_key_name`,`foreign_key_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1519 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(191) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` longtext,
  `created_at` datetime(6) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `user_ip` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `object_changes` text,
  `item_subtype` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `document_number` varchar(255) DEFAULT NULL,
  `parent_document_type` varchar(255) DEFAULT NULL,
  `user_transaction_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`),
  KEY `index_versions_on_transaction_id` (`transaction_id`),
  KEY `index_versions_on_company_id` (`company_id`),
  KEY `versions_event_company_id` (`company_id`,`event`,`parent_document_type`),
  KEY `versions_index_company_item_type` (`company_id`,`user_transaction_id`,`item_type`,`parent_document_type`),
  KEY `index_versions_on_user_transaction_id` (`user_transaction_id`),
  KEY `index_versions_on_created_at` (`created_at`),
  KEY `index_versions_on_deleted_at` (`deleted_at`),
  KEY `index_versions_on_item_type` (`item_type`),
  KEY `index_versions_on_item_id` (`item_id`),
  KEY `index_versions_on_event` (`event`),
  KEY `index_versions_on_whodunnit` (`whodunnit`),
  KEY `index_versions_on_user_ip` (`user_ip`),
  KEY `index_versions_on_user_agent` (`user_agent`),
  KEY `index_versions_on_item_subtype` (`item_subtype`),
  KEY `index_versions_on_created_by_id` (`created_by_id`),
  KEY `index_versions_on_document_number` (`document_number`),
  KEY `index_versions_on_parent_document_type` (`parent_document_type`)
) ENGINE=InnoDB AUTO_INCREMENT=629 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_account_collect_trails`
--

DROP TABLE IF EXISTS `virtual_account_collect_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_account_collect_trails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `found_virtual_account` tinyint(1) DEFAULT NULL,
  `update_company_balance` tinyint(1) DEFAULT NULL,
  `create_payment` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_account_purposes`
--

DROP TABLE IF EXISTS `virtual_account_purposes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_account_purposes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_account_transactions`
--

DROP TABLE IF EXISTS `virtual_account_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_account_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `beneficiary_account_ifsc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `beneficiary_full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_timestamp` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_amount` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remitter_account_no` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remitter_account_ifsc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remitter_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remitter_full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remitter_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `credited_at` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `virtual_account_id` int(11) DEFAULT NULL,
  `processed` tinyint(1) DEFAULT NULL,
  `receiving_account_credited` tinyint(1) DEFAULT NULL,
  `beneficiary_account_no` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_bank_accounts`
--

DROP TABLE IF EXISTS `virtual_bank_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ifsc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `expires_by` date DEFAULT NULL,
  `purpose_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `initiating_user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `receiving_account_id` int(11) DEFAULT NULL,
  `receiving_account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `maximum_transaction_amount_id` int(11) DEFAULT NULL,
  `minimum_transaction_amount_id` int(11) DEFAULT NULL,
  `allowed_transaction_count` int(11) DEFAULT NULL,
  `neft` tinyint(1) DEFAULT '1',
  `imps` tinyint(1) DEFAULT '1',
  `rtgs` tinyint(1) DEFAULT '1',
  `current_account` tinyint(1) DEFAULT '1',
  `savings_account` tinyint(1) DEFAULT '1',
  `upi` tinyint(1) DEFAULT '1',
  `active_after` date DEFAULT NULL,
  `active_on` date DEFAULT NULL,
  `maximum_amount_id` int(11) DEFAULT NULL,
  `exact_transaction_amount_id` int(11) DEFAULT NULL,
  `application` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `default_account` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_clients`
--

DROP TABLE IF EXISTS `web_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_clients` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_web_clients_on_deleted_at` (`deleted_at`),
  KEY `index_web_clients_on_created_at` (`created_at`),
  KEY `index_web_clients_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_hook_event_mappings`
--

DROP TABLE IF EXISTS `web_hook_event_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_hook_event_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `web_hook_id` int(11) NOT NULL,
  `web_hook_event_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_web_hook_event_mappings_on_web_hook_id` (`web_hook_id`),
  KEY `index_web_hook_event_mappings_on_web_hook_event_id` (`web_hook_event_id`),
  KEY `index_web_hook_event_mappings_on_is_deleted` (`is_deleted`),
  CONSTRAINT `fk_rails_99948293ca` FOREIGN KEY (`web_hook_event_id`) REFERENCES `web_hook_events` (`id`),
  CONSTRAINT `fk_rails_db4d72788f` FOREIGN KEY (`web_hook_id`) REFERENCES `web_hooks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_hook_events`
--

DROP TABLE IF EXISTS `web_hook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_hook_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_web_hook_events_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_hook_tracks`
--

DROP TABLE IF EXISTS `web_hook_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_hook_tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `web_hook_id` int(11) DEFAULT NULL,
  `web_hook_event_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `request_body` text COLLATE utf8_unicode_ci,
  `request_header` text COLLATE utf8_unicode_ci,
  `response_time` decimal(10,0) DEFAULT NULL,
  `response_body` mediumtext COLLATE utf8_unicode_ci,
  `response_status` int(11) DEFAULT NULL,
  `attempt` int(11) DEFAULT NULL,
  `last_attempted_at` datetime DEFAULT NULL,
  `attempt_success` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_web_hook_tracks_on_web_hook_id` (`web_hook_id`),
  KEY `index_web_hook_tracks_on_web_hook_event_id` (`web_hook_event_id`),
  KEY `index_web_hook_tracks_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_37c66061aa` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_rails_a4d92ce2c2` FOREIGN KEY (`web_hook_event_id`) REFERENCES `web_hook_events` (`id`),
  CONSTRAINT `fk_rails_f1e72a99fa` FOREIGN KEY (`web_hook_id`) REFERENCES `web_hooks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_hooks`
--

DROP TABLE IF EXISTS `web_hooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_hooks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text COLLATE utf8_unicode_ci NOT NULL,
  `secret` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `headers` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_web_hooks_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_web_hooks_on_company_id` (`company_id`),
  KEY `index_web_hooks_on_is_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `whitelisted_ip_types`
--

DROP TABLE IF EXISTS `whitelisted_ip_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_ip_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `whitelisted_ips`
--

DROP TABLE IF EXISTS `whitelisted_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_ips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `whitelisted_ip_type_id` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_whitelisted_ips_on_ip_address` (`ip_address`),
  KEY `index_whitelisted_ips_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_3f48875447` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yes_bank_company_accounts`
--

DROP TABLE IF EXISTS `yes_bank_company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yes_bank_company_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `wallet_balance_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `balance_id` int(11) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_yes_bank_company_accounts_on_company_id` (`company_id`),
  CONSTRAINT `fk_rails_b8b7f39cec` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yes_bank_configurations`
--

DROP TABLE IF EXISTS `yes_bank_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yes_bank_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_bank_account` tinyint(1) DEFAULT '0',
  `company_id` int(11) DEFAULT NULL,
  `yes_bank_api_enabled` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yes_bank_transactions`
--

DROP TABLE IF EXISTS `yes_bank_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yes_bank_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unique_request_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unique_response_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_id` int(11) DEFAULT NULL,
  `beneficiary_bank_account_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `transfer_status_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bank_response` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `refunded` tinyint(1) DEFAULT NULL,
  `error_sub_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_transaction_type_id` int(11) DEFAULT NULL,
  `account_name_check` tinyint(1) DEFAULT '0',
  `beneficiary_full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_mode_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `bank_error_message` mediumtext COLLATE utf8_unicode_ci,
  `reference_payment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_yes_bank_transactions_on_amount_id` (`amount_id`),
  KEY `index_yes_bank_transactions_on_beneficiary_bank_account_id` (`beneficiary_bank_account_id`),
  KEY `index_yes_bank_transactions_on_company_id` (`company_id`),
  KEY `index_yes_bank_transactions_on_transfer_status_id` (`transfer_status_id`),
  KEY `index_yes_bank_transactions_on_unique_request_number` (`unique_request_number`),
  KEY `index_yes_bank_transactions_on_transfer_mode_id` (`transfer_mode_id`),
  CONSTRAINT `fk_rails_156b850eae` FOREIGN KEY (`amount_id`) REFERENCES `amounts` (`id`),
  CONSTRAINT `fk_rails_3143bfc28d` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yes_bank_vendors`
--

DROP TABLE IF EXISTS `yes_bank_vendors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yes_bank_vendors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authorized` tinyint(1) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `pan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tin` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gst` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gst_registered` tinyint(1) DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_code_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `vendor_type_id` int(11) DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `business_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payment_term_id` int(11) DEFAULT NULL,
  `currency_id` int(11) DEFAULT NULL,
  `tds_rates_list_id` int(11) DEFAULT NULL,
  `vendor_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `msme_registered` tinyint(1) DEFAULT '0',
  `msme_registration_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status_id` int(11) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `controlling_level_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `vedor_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `trade_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reject_note` text COLLATE utf8_unicode_ci,
  `rcm_enabled` tinyint(1) DEFAULT '0',
  `vendor_country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ldc_effective_start_date` date DEFAULT NULL,
  `ldc_effective_end_date` date DEFAULT NULL,
  `tds_effective_start_date` date DEFAULT NULL,
  `tds_effective_end_date` date DEFAULT NULL,
  `bank_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tax_rate_id` int(11) DEFAULT NULL,
  `erp_sync_status_id` int(11) DEFAULT NULL,
  `erp_sync_message` text COLLATE utf8_unicode_ci,
  `erp_sync_reference_id` text COLLATE utf8_unicode_ci,
  `erp_sync_attempts_count` int(11) DEFAULT '0',
  `erp_sync_attempted_at` datetime DEFAULT NULL,
  `ldc_upper_limit_amount` decimal(20,5) DEFAULT NULL,
  `is_workflow_v2` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_yes_bank_vendors_on_company_id` (`company_id`),
  KEY `index_yes_bank_vendors_on_vendor_type_id` (`vendor_type_id`),
  KEY `index_yes_bank_vendors_on_tds_rates_list_id` (`tds_rates_list_id`),
  KEY `index_yes_bank_vendors_on_name` (`name`),
  KEY `index_yes_bank_vendors_on_vendor_id` (`vendor_id`),
  KEY `index_vendors_ct_lvl_cmpny_id` (`company_id`,`controlling_level_id`,`deleted_at`),
  CONSTRAINT `fk_rails_25ebdd5b2c` FOREIGN KEY (`vendor_type_id`) REFERENCES `vendor_types` (`id`),
  CONSTRAINT `fk_rails_285e18ac70` FOREIGN KEY (`tds_rates_list_id`) REFERENCES `tds_rates_lists` (`id`),
  CONSTRAINT `fk_rails_77e9fde23a` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=296 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-07 16:57:13
