
CREATE STREAM CONTAINER_LOGS_RAW_JSON ( `@timestamp` string, host struct< name varchar>, log struct< file struct< path varchar >, offset bigint >, message varchar ) WITH ( KAFKA_TOPIC='container_logs_raw', VALUE_FORMAT='JSON' );

CREATE STREAM CONTAINER_LOGS_RAW_AVRO WITH (KAFKA_TOPIC='container_logs_avro',VALUE_FORMAT='AVRO') AS
SELECT `@timestamp` AS timestamp, message AS message2 FROM CONTAINER_LOGS_RAW_JSON;


CREATE STREAM node_journalctl_raw_json (
  `@timestamp` VARCHAR,
  host STRUCT<name VARCHAR>,
  log STRUCT<offset INT, file STRUCT<path VARCHAR>>,
  message VARCHAR
) WITH (KAFKA_TOPIC='node_journalctl_raw', VALUE_FORMAT='JSON');

CREATE STREAM node_journalctl_raw_avro WITH (KAFKA_TOPIC='node_journalctl_avro', VALUE_FORMAT='AVRO') AS
SELECT  `@timestamp` AS timestamp,
        log->offset AS offset,
        log->file->path AS filepath,
        host->name AS node,
        TIMESTAMPTOSTRING(CAST(EXTRACTJSONFIELD(message, '$.__REALTIME_TIMESTAMP') AS BIGINT)/1000,ROWTIME, 'yyyy-MM-dd HH:mm:ss.SSS') AS timestamp2,
        EXTRACTJSONFIELD(message, '$._COMM') AS comm,
        EXTRACTJSONFIELD(message, '$._CMDLINE') AS commandline,
        EXTRACTJSONFIELD(message, '$._PID') AS pid,
        EXTRACTJSONFIELD(message, '$.MESSAGE') AS message,
        EXTRACTJSONFIELD(message, '$.SYSLOG_IDENTIFIER') AS syslogidentifier,
        'INFO' AS level
FROM    node_journalctl_raw_json;
