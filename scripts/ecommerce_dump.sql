-- MySQL dump 10.13  Distrib 8.0.43, for Linux (x86_64)
--
-- Host: localhost    Database: ecommerce
-- ------------------------------------------------------
-- Server version	8.0.43-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
INSERT INTO `alembic_version` VALUES ('00e0e2af63a3');
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `hashed_password` text NOT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `phone_number` varchar(100) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `ix_users_email` (`email`),
  KEY `ix_users_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'Anthony Rodriguez','smorgan@example.net','$2b$12$HIDEZ4XQ6T.QyjvATbwICeVU5uk.jtW2WbTIHQVGcfVa9alINK5Vq','844 Heath Rapid Apt. 576\nPhillipsland, GU 06823','2025-09-29 22:42:33','524-316-6230x3179','https://picsum.photos/353/197'),(3,'Kenneth Davila','staceymorrison@example.com','$2b$12$nVBsmTmYdY1eVamikz5lj.pKGtUTmozbnk5QHjdw/mDF5G2XPmFgq','406 Webb Orchard\nPort Ivan, OR 36968','2025-09-29 22:42:33','404.242.6691x514','https://picsum.photos/774/53'),(4,'Jose Tyler','joshuabrown@example.org','$2b$12$BuAcgywUHAi6sE8eYI003.W.RvfOUerJSyXY/gzy.VBHo7tAVOLmy','59849 Cox Dale\nGarciaburgh, WA 34526','2025-09-29 22:42:33','587-465-8285x195','https://dummyimage.com/187x719'),(5,'Kathleen Calhoun','chelseyduke@example.com','$2b$12$y7VMfKThXuNIyxf81XnfleL/CnbyP/Eue70e0lGtoglA7fCoL495O','02900 Mendez Via\nCalderonhaven, OR 90478','2025-09-29 22:42:33','+1-231-655-0450x9989','https://placekitten.com/319/593'),(6,'Kevin Jackson','dfarley@example.net','$2b$12$d8i9VoNrs7u/pFtrR/yj3eu1dBsTf/kF6IN8wbmwLbKfapKqAh90O','86715 Carrie Islands Suite 893\nPort Justinchester, KY 90902','2025-09-29 22:42:33','(313)790-0501','https://dummyimage.com/367x619'),(7,'Greg Garcia','johnjordan@example.com','$2b$12$Oq4eO.zm2W/GDidYQ7gHC.A41e.tAs8vea3tnLKXxwFqogmsJAByK','30909 Matthew Junctions\nEast Pennyfurt, MH 01012','2025-09-29 22:42:33','344-326-5362x9491','https://dummyimage.com/186x858'),(8,'Kara Byrd','curtis60@example.org','$2b$12$XwwHlioDSpyhMyo5G8O9L.e1zHCrTkzbJIpchFtUOQzB2RKf9cz2e','64503 David Green\nDariusland, OR 18305','2025-09-29 22:42:33','+1-845-623-1249x38207','https://placekitten.com/845/692'),(9,'Jay Escobar','robert39@example.com','$2b$12$jF2HJKDvy/ylJ9OWV/mG6ubkRVhrOXIYKfYH9YfALxiDTE5RSkI5u','25776 Grimes Cove\nAguilarfurt, NV 02818','2025-09-29 22:42:33','+1-616-440-6247x595','https://dummyimage.com/1015x432'),(10,'Jason Hernandez','rebeccabentley@example.org','$2b$12$eOF9J.L1jGaxuZrHPA5lfuZF01vqTCRBk6CDfIQ5UA0PgianKwdJe','3806 Tyler Turnpike\nWest Rebecca, HI 44328','2025-09-29 22:42:33','699-656-5988','https://dummyimage.com/556x758'),(11,'mohamed','user@gmail.com','$2b$12$XW3nBb7j3swO0qL6bi5o7uogBEXfWfgfmhlV1xaPU.UhFZB2h7UQC','egypt','2025-09-29 23:15:59','012','kjnac.png');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-30  2:21:02
