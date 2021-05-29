#!/usr/bin/env bash

# Author: suporte3@dati.com.br
# Creates the cost & usage report

# IMPORT and RUN SHARED FUNCTIONS
source ./shared_functions.sh 

# VARS
#ACCOUNT_ID="$(get_account_id)"
#ACCOUNT_ALIAS="$(get_account_alias)"

ReportName="DatiCostReport"
TimeUnit="HOURLY"
Format="textORcsv"
Compression="ZIP"
S3Bucket="${ACCOUNT_ID}-dati-cost-report"
S3Prefix="/cost-report"
S3Region="us-east-1"
RefreshClosedReports="true"
ReportVersioning="CREATE_NEW_REPORT"

# FUNCTIONS
create_bucket_policy() {
echo "{
  \"Version\":\"2008-10-17\",
  \"Id\":\"CostReportBucketPolicy\",
  \"Statement\":
  [
    {
      \"Sid\":\"AllowBillingGetPolicy\",
      \"Effect\":\"Allow\",
      \"Principal\":
      {
        \"Service\":\"billingreports.amazonaws.com\"
      },
      \"Action\":
      [
        \"s3:GetBucketAcl\",
        \"s3:GetBucketPolicy\"
      ],
      \"Resource\":\"arn:aws:s3:::${S3Bucket}\"
    },
    {
      \"Sid\":\"AllowBillingPutObject\",
      \"Effect\":\"Allow\",
      \"Principal\":
      {
        \"Service\":\"billingreports.amazonaws.com\"
      },
      \"Action\":\"s3:PutObject\",
      \"Resource\":\"arn:aws:s3:::${S3Bucket}/*\"
    }
  ]
}" > ${ACCOUNT_ID}/cost_report_bucket_policy.json

}

create_cost_report_s3bucket() {
  # Create the bucket
  aws s3 mb s3://"${S3Bucket}" --region "${S3Region}" > /dev/null

  # Block all public access
  aws s3api put-public-access-block \
    --bucket "${S3Bucket}" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

  # Put billing bucket policy
  aws s3api put-bucket-policy --bucket "${S3Bucket}" --policy file://"${ACCOUNT_ID}"/cost_report_bucket_policy.json
}
create_report_definition() {
  echo "{
  \"ReportName\": \"${ReportName}\",
  \"TimeUnit\": \"${TimeUnit}\",
  \"Format\": \"${Format}\",
  \"Compression\": \"${Compression}\",
  \"AdditionalSchemaElements\": [
    \"RESOURCES\"
  ],
  \"S3Bucket\": \"${S3Bucket}\",
  \"S3Prefix\": \"${S3Prefix}\",
  \"S3Region\": \"${S3Region}\",
  \"AdditionalArtifacts\": [],
  \"RefreshClosedReports\": ${RefreshClosedReports},
  \"ReportVersioning\": \"${ReportVersioning}\"
}" > "${ACCOUNT_ID}"/cost_report_definition.json

}

create_cost_report() {
  LIST_REPORTS=$(aws cur --region us-east-1 describe-report-definitions | grep -c "DatiCostReport" )
  if [ "${LIST_REPORTS}" -eq 0 ]
  then
    aws cur --region "${S3Region}" put-report-definition --report-definition file://"${ACCOUNT_ID}"/cost_report_definition.json
  else
    echo "There is already a \"DatiCostReport\" in this account."
    echo "Exiting"
    exit 1
  fi
}

# MAIN
request_confirmation "Creating: \n\t - Bucket \"${S3Bucket}\",\n\t - CostReport \"${ReportName}\""
create_bucket_policy
create_cost_report_s3bucket
create_report_definition
create_cost_report

echo ""
echo "Bucket Name.....: ${S3Bucket}"
echo "Report Path/Name: ${S3Prefix}/${ReportName}"
