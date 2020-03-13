#!/bin/bash

DB_INSTANCE_IDENTIFIER="instance_name"

SNAPSHOT_NAME=`aws rds describe-db-snapshots \
  --query "reverse(sort_by(DBSnapshots[?DBInstanceIdentifier=='test-rds'],&SnapshotCreateTime))[0].DBSnapshotIdentifier"`
SNAPSHOT_NAME=`echo $SNAPSHOT_NAME | sed "s/\"//g"`

rds_instance_exists=`aws rds restore-db-instance-from-db-snapshot  \
  --db-snapshot-identifier $SNAPSHOT_NAME  \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER  \
  --db-subnet-group-name "xxxx"  \
  --db-instance-class db.t2.small  \
  --vpc-security-group-ids "xxxx"  \
  --db-parameter-group-name "xxxx"  \
  --publicly-accessible 2>&1` || true
echo "rds_instance_exists='$rds_instance_exists'"
if [[ $rds_instance_exists =~ 'DBInstanceAlreadyExists' ]] ;
then
  echo "DBInstanceAlreadyExists !!"
fi

aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_IDENTIFIER

echo "Restore Complete!!"