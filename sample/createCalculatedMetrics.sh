#!/bin/bash

# Usage:
# ./createCalculatedMetrics.sh CONTEXTLESS sampleservice-hardening

DT_TENANT=$(cat ../common/creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat ../common/creds_dt.json | jq -r '.dynatraceApiToken')
TAG_CONTEXT=$1
TAG_KEY=$2
TAG_VALUE=$3

echo "============================================================="
echo "About to create 3 service metrics with condition [$1]$2:$3 on Dynatrace Tenant: $DT_TENANT!"
echo "============================================================="
echo "Usage: ./createCalculatedMetric TAG_CONTEXT TAG_KEY TAG_VALUE"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

####################################################################################################################
## createCalculatedMetric(METRICKEY, METRICNAME, BASEMETRIC, UNIT, CONTEXT, KEY, VALUE, DIMENSIONNAME, DIMENSIONDEF DIMENSIONAGGR)
####################################################################################################################
# Example: createCalculatedMetric("calc:service.topurlresponsetime", "Top URL Response Time", "RESPONSE_TIME", "CONTEXTLESS", "keptn_project", "simpleproject", "URL", "{URL}" "COUNT")
# Full List of possible BASEMETRICS: CPU_TIME, DATABASE_CHILD_CALL_COUNT, DATABASE_CHILD_CALL_TIME, EXCEPTION_COUNT, FAILED_REQUEST_COUNT, FAILED_REQUEST_COUNT_CLIENT, FAILURE_RATE, FAILURE_RATE_CLIENT, HTTP_4XX_ERROR_COUNT, HTTP_4XX_ERROR_COUNT_CLIENT, HTTP_5XX_ERROR_COUNT, HTTP_5XX_ERROR_COUNT_CLIENT, IO_TIME, LOCK_TIME, NON_DATABASE_CHILD_CALL_COUNT, NON_DATABASE_CHILD_CALL_TIME, REQUEST_ATTRIBUTE, REQUEST_COUNT, RESPONSE_TIME, RESPONSE_TIME_CLIENT, SUCCESSFUL_REQUEST_COUNT, SUCCESSFUL_REQUEST_COUNT_CLIENT, TOTAL_PROCESSING_TIME, WAIT_TIME
function createCalculatedMetric() {
    METRICKEY=$1
    METRICNAME=$2
    BASEMETRIC=$3
    METRICUNIT=$4
    CONDITION_CONTEXT=$5
    CONDITION_KEY=$6
    CONDITION_VALUE=$7
    DIMENSION_NAME=$8
    DIMENSION_DEFINTION=$9
    DIMENSION_AGGREGATE=${10}

    PAYLOAD='{
            "tsmMetricKey": "'$METRICKEY'",
            "name": "'$METRICNAME'",
            "enabled": true,
            "metricDefinition": {
                "metric": "'$BASEMETRIC'",
                "requestAttribute": null
            },
            "unit": "'$METRICUNIT'",
            "unitDisplayName": "",
            "conditions": [
                {
                "attribute": "SERVICE_TAG",
                "comparisonInfo": {
                    "type": "TAG",
                    "comparison": "EQUALS",
                    "value": {
                        "context": "'$CONDITION_CONTEXT'",
                        "key": "'$CONDITION_KEY'",
                        "value": "'$CONDITION_VALUE'"
                    },
                    "negate": false
                }
                }
            ],
            "dimensionDefinition": {
                "name": "'$DIMENSION_NAME'",
                "dimension": "'$DIMENSION_DEFINTION'",
                "placeholders": [],
                "topX": 10,
                "topXDirection": "DESCENDING",
                "topXAggregation": "'$DIMENSION_AGGREGATE'"
            }
        }'

    echo "Creating Metric $METRICNAME($METRICKEY)"
    echo "$PAYLOAD"

    curl -X PUT \
        "https://$DT_TENANT/api/config/v1/customMetric/service/$METRICKEY" \
        -H 'accept: application/json; charset=utf-8' \
        -H "Authorization: Api-Token $DT_API_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d "$PAYLOAD" \
        -o curloutput.txt

    cat curloutput.txt
}

## Creates a Calculated Service Metrics "Top URL Response Time""
## Metrics Id: calc:service.topurlresponsetime
## Base Metric: Response Time (RESPONSE_TIME)
## Dimension: URL
## Condition: service tag [$TAG_CONTEXT]$TAG_KEY:TAG_VALUE
createCalculatedMetric "calc:service.topurlresponsetime" "Top URL Response Time" "RESPONSE_TIME" "MICRO_SECOND" "$TAG_CONTEXT" "$TAG_KEY" "$TAG_VALUE" "URL" "{URL:Path}" "SUM"


## Creates a Calculated Service Metrics "Top URL Service Calls"
## Metrics Id: calc:service.topurlservicecalls
## Base Metric: Number of calls to other services (NON_DATABASE_CHILD_CALL_COUNT)
## Dimension: URL
## Condition: service tag [$TAG_CONTEXT]$TAG_KEY:TAG_VALUE
createCalculatedMetric "calc:service.topurlservicecalls" "Top URL Service Calls" "NON_DATABASE_CHILD_CALL_COUNT" "COUNT" "$TAG_CONTEXT" "$TAG_KEY" "$TAG_VALUE" "URL" "{URL:Path}" "SINGLE_VALUE"

## Creates a Calculated Service Metrics "Top URL Service Calls"
## Metrics Id: calc:service.topurlservicecalls
## Base Metric: Number of calls to other services (NON_DATABASE_CHILD_CALL_COUNT)
## Dimension: URL
## Condition: service tag [$TAG_CONTEXT]$TAG_KEY:TAG_VALUE
createCalculatedMetric "calc:service.topurldbcalls" "Top URL DB Calls" "DATABASE_CHILD_CALL_COUNT" "COUNT" "$TAG_CONTEXT" "$TAG_KEY" "$TAG_VALUE" "URL" "{URL:Path}" "SINGLE_VALUE"















# curl -X PUT \
#         "https://$DT_TENANT/api/config/v1/customMetric/service/calc%3Aservice.topurlresponsetime" \
#         -H 'accept: application/json; charset=utf-8' \
#         -H "Authorization: Api-Token $DT_API_TOKEN" \
#         -H 'Content-Type: application/json; charset=utf-8' \
#         -d '{
#             "tsmMetricKey": "calc:service.topurlresponsetime",
#             "name": "Top URL Response Time",
#             "enabled": true,
#             "metricDefinition": {
#                 "metric": "RESPONSE_TIME",
#                 "requestAttribute": null
#             },
#             "unit": "MICRO_SECOND",
#             "unitDisplayName": "",
#             "conditions": [
#                 {
#                 "attribute": "SERVICE_TAG",
#                 "comparisonInfo": {
#                     "type": "TAG",
#                     "comparison": "EQUALS",
#                     "value": {
#                         "context": "'$TAG_CONTEXT'",
#                         "key": "'$TAG_KEY'",
#                         "value": "'$TAG_VALUE'"
#                     },
#                     "negate": false
#                 }
#                 }
#             ],
#             "dimensionDefinition": {
#                 "name": "URL",
#                 "dimension": "{URL}",
#                 "placeholders": [],
#                 "topX": 10,
#                 "topXDirection": "DESCENDING",
#                 "topXAggregation": "SUM"
#             }
#         }' \
#         -o curloutput.txt