CREATE STREAM swarm_journal_json(
  `@timestamp` STRING,
  container STRUCT<id STRING, name STRING>,
  event STRUCT<created STRING>,
  host STRUCT<hostname STRING>,
  journald STRUCT<custom STRUCT<image_name STRING>>,
  log STRUCT<syslog STRUCT<facility_name STRING, priority INTEGER>>,
  message STRING,
  process STRUCT<name STRING>,
  syslog STRUCT<identifier STRING>,
  systemd STRUCT<transport STRING>)
WITH (KAFKA_TOPIC='swarm_journal_raw', VALUE_FORMAT='JSON');

CREATE STREAM swarm_journal_avro WITH (KAFKA_TOPIC='swarm_journal_avro',VALUE_FORMAT='AVRO') AS
SELECT  CASE WHEN SUBSTRING(message,1,1) = '{' THEN
          CASE  WHEN journald->custom->image_name LIKE '%metricbeat%' AND SUBSTRING(message,1,1) = '{' THEN 'metricbeat'
                WHEN EXTRACTJSONFIELD(message, '$.source') IS NOT NULL THEN EXTRACTJSONFIELD(message, '$.source')
          END
        ELSE 'logs' END AS destination,
        `@timestamp` AS ingested,
        CASE WHEN container IS NULL THEN '' ELSE container->id END AS containerId,
        CASE WHEN container IS NULL THEN '' ELSE container->name END AS containername,
        event->created AS created,
        host->hostname AS node,
        CASE WHEN journald IS NULL THEN '' ELSE journald->custom->image_name END AS imagename,
        log->syslog->facility_name AS logfacility,
        log->syslog->priority AS logpriority,
        message,
        CASE WHEN process IS NULL THEN '' ELSE process->name END AS processname,
        syslog->identifier AS syslogidentifier,
        systemd->transport AS systemdtransport
FROM swarm_journal_json
EMIT CHANGES;
