#!/bin/sh
npm run build
aws s3 sync dist s3://$S3_BUCKET --delete
