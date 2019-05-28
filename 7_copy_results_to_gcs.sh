#!/usr/bin/env bash
#

version_date=`date +%y%m%d`

# Copy results
gsutil -m rsync -r results gs://genetics-portal-staging/coloc/$version_date

# Tar the logs and copy over
tar -zcvf logs.tar.gz logs
gsutil -m cp logs.tar.gz gs://genetics-portal-staging/coloc/$version_date/logs.tar.gz

# Tar the plots and copy over
tar -zcvf plots.tar.gz plots
gsutil -m cp plots.tar.gz gs://genetics-portal-staging/coloc/$version_date/plots.tar.gz

# Copy overlap table
gsutil -m rsync configs/overlap_table gs://genetics-portal-staging/coloc/$version_date/overlap_table