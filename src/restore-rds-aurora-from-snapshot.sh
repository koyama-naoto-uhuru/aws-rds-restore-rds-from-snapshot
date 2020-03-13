#!/bin/bash

DB_CLUSTER_IDENTIFIER="cluster_name"
DB_INSTANCE_IDENTIFIER="instance_name"

SNAPSHOT_NAME=`aws rds describe-db-cluster-snapshots \
  --query "reverse(sort_by(DBClusterSnapshots[?DBClusterIdentifier=='test-rds'],&SnapshotCreateTime))[0].DBClusterSnapshotIdentifier"`
SNAPSHOT_NAME=`echo $SNAPSHOT_NAME | sed "s/\"//g"`

rds_cluster_exists=`aws rds restore-db-cluster-from-snapshot \
  --snapshot-identifier $SNAPSHOT_NAME \
  --db-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --engine "aurora-postgresql" \
  --engine-version "11.6" \
  --db-subnet-group-name "xxxx" \
  --vpc-security-group-ids "xxxx" \
  --db-cluster-parameter-group-name "xxxx"` || true
echo "rds_cluster_exists='$rds_cluster_exists'"
if [[ $rds_cluster_exists =~ 'DBClusterAlreadyExistsFault' ]] ;
then
  echo 'DBClusterAlreadyExistsFault !!'
fi

rds_instance_exists=`aws rds create-db-instance \
  --db-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --db-instance-class db.t2.small \
  --engine aurora-postgresql \
  --publicly-accessible 2>&1` || true
echo "rds_instance_exists='$rds_instance_exists'"
if [[ $rds_instance_exists =~ 'DBInstanceAlreadyExists' ]] ;
then
  echo 'DBInstanceAlreadyExists !!'
fi

rds_wait="1"
while [ $rds_wait != "0" ]
do
  rds_wait=`aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_IDENTIFIER; echo $?`
  rds_wait=`echo $rds_wait | tail -n1`
  echo "waiting..."
  sleep 1
done

echo "Restore Complete!!"