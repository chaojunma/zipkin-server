/*
 Navicat Premium Data Transfer

 Source Server         : 10.32.15.80
 Source Server Type    : MySQL
 Source Server Version : 50724
 Source Host           : 10.32.15.80:3306
 Source Schema         : zipkin

 Target Server Type    : MySQL
 Target Server Version : 50724
 File Encoding         : 65001

 Date: 06/12/2019 11:19:47
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for zipkin_annotations
-- ----------------------------
DROP TABLE IF EXISTS `zipkin_annotations`;
CREATE TABLE `zipkin_annotations`  (
  `trace_id` bigint(20) NOT NULL COMMENT 'coincides with zipkin_spans.trace_id',
  `span_id` bigint(20) NOT NULL COMMENT 'coincides with zipkin_spans.id',
  `a_key` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'BinaryAnnotation.key or Annotation.value if type == -1',
  `a_value` blob NULL COMMENT 'BinaryAnnotation.value(), which must be smaller than 64KB',
  `a_type` int(11) NOT NULL COMMENT 'BinaryAnnotation.type() or -1 if Annotation',
  `a_timestamp` bigint(20) NULL DEFAULT NULL COMMENT 'Used to implement TTL; Annotation.timestamp or zipkin_spans.timestamp',
  `endpoint_ipv4` int(11) NULL DEFAULT NULL COMMENT 'Null when Binary/Annotation.endpoint is null',
  `endpoint_ipv6` binary(16) NULL DEFAULT NULL COMMENT 'Null when Binary/Annotation.endpoint is null, or no IPv6 address',
  `endpoint_port` smallint(6) NULL DEFAULT NULL COMMENT 'Null when Binary/Annotation.endpoint is null',
  `endpoint_service_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Null when Binary/Annotation.endpoint is null',
  `trace_id_high` bigint(20) NOT NULL DEFAULT 0,
  UNIQUE INDEX `trace_id_high`(`trace_id_high`, `trace_id`, `span_id`, `a_key`, `a_timestamp`) USING BTREE,
  INDEX `trace_id_2`(`trace_id`, `span_id`) USING BTREE COMMENT 'for joining with zipkin_spans',
  INDEX `trace_id_3`(`trace_id`) USING BTREE COMMENT 'for getTraces/ByIds',
  INDEX `endpoint_service_name`(`endpoint_service_name`) USING BTREE COMMENT 'for getTraces and getServiceNames',
  INDEX `a_type`(`a_type`) USING BTREE COMMENT 'for getTraces',
  INDEX `a_key`(`a_key`) USING BTREE COMMENT 'for getTraces'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compressed;

-- ----------------------------
-- Table structure for zipkin_dependencies
-- ----------------------------
DROP TABLE IF EXISTS `zipkin_dependencies`;
CREATE TABLE `zipkin_dependencies`  (
  `day` date NOT NULL,
  `parent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `child` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `call_count` bigint(20) NULL DEFAULT NULL,
  UNIQUE INDEX `day`(`day`, `parent`, `child`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compressed;

-- ----------------------------
-- Table structure for zipkin_spans
-- ----------------------------
DROP TABLE IF EXISTS `zipkin_spans`;
CREATE TABLE `zipkin_spans`  (
  `trace_id` bigint(20) NOT NULL,
  `id` bigint(20) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `parent_id` bigint(20) NULL DEFAULT NULL,
  `debug` bit(1) NULL DEFAULT NULL,
  `start_ts` bigint(20) NULL DEFAULT NULL COMMENT 'Span.timestamp(): epoch micros used for endTs query and to implement TTL',
  `duration` bigint(20) NULL DEFAULT NULL COMMENT 'Span.duration(): micros used for minDuration and maxDuration query',
  `trace_id_high` bigint(20) NOT NULL DEFAULT 0,
  UNIQUE INDEX `trace_id_high`(`trace_id_high`, `trace_id`, `id`) USING BTREE,
  INDEX `trace_id_2`(`trace_id`, `id`) USING BTREE COMMENT 'for joining with zipkin_annotations',
  INDEX `trace_id_3`(`trace_id`) USING BTREE COMMENT 'for getTracesByIds',
  INDEX `name`(`name`) USING BTREE COMMENT 'for getTraces and getSpanNames',
  INDEX `start_ts`(`start_ts`) USING BTREE COMMENT 'for getTraces ordering and range'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compressed;

SET FOREIGN_KEY_CHECKS = 1;
