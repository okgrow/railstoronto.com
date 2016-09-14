#!/bin/bash

fail() {
	echo "ERROR: $1"
	exit -1
}

echo "👉 Building middleman site..."
bundle exec middleman build --clean || fail "Middleman build failed."

echo "👉 Deploying to S3 bucket..."
aws s3 sync --profile okgrow --delete build "s3://www.railstoronto.com"
