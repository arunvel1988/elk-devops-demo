#!/bin/bash
echo "=== Elasticsearch Toolkit ==="

read -p "Use HTTPS? (yes/no): " USE_HTTPS
if [[ "$USE_HTTPS" == "yes" ]]; then
  SCHEME="https"
  read -p "Use --insecure to skip SSL verify? (yes/no): " SKIP_VERIFY
  [[ "$SKIP_VERIFY" == "yes" ]] && CURL_EXTRA="--insecure" || CURL_EXTRA=""
else
  SCHEME="http"
  CURL_EXTRA=""
fi

read -p "Elasticsearch host or IP (without port): " ES_HOST
read -p "Elasticsearch username: " ES_USER
read -s -p "Elasticsearch password: " ES_PASS
echo ""

AUTH="-u $ES_USER:$ES_PASS"
BASE_URL="$SCHEME://$ES_HOST:9200"

function runCurl() {
  echo "---"
  curl -X"$1" $AUTH "$BASE_URL$2" $CURL_EXTRA -H 'Content-Type: application/json' ${3:+-d "$3"}
  echo -e "\n---"
}

while true; do
  cat <<EOF

Choose an operation:
 1) Cluster health
 2) Cluster stats
 3) List all indexes
 4) Index name, health & stats
 5) Get index mapping
 6) Get index settings
 7) Search documents (match_all)
 8) Search with simple query
 9) Create index
10) Delete index
11) Get node info
12) Get node stats
13) Get cluster settings
14) Get cluster state
15) Get document by ID
16) Index a document
17) Update a document
18) Delete a document
19) Exit
EOF

  read -p "Enter choice [1-19]: " choice
  case $choice in
    1) runCurl GET "/_cluster/health?pretty" ;;
    2) runCurl GET "/_cluster/stats?pretty" ;;
    3) runCurl GET "/_cat/indices?v" ;;
    4)
       read -p "Index name: " IDX
       runCurl GET "/_cat/indices/$IDX?v" ;;
    5)
       read -p "Index name: " IDX
       runCurl GET "/$IDX/_mapping?pretty" ;;
    6)
       read -p "Index name: " IDX
       runCurl GET "/$IDX/_settings?pretty" ;;
    7)
       read -p "Index name or pattern: " IDX
       runCurl GET "/$IDX/_search?pretty" '{"query":{"match_all":{}},"size":5}' ;;
    8)
       read -p "Index name or pattern: " IDX
       read -p "Field to query: " FLD
       read -p "Search term: " TERM
       runCurl GET "/$IDX/_search?pretty" "{\"query\":{\"match\":{\"$FLD\":\"$TERM\"}},\"size\":5}" ;;
    9)
       read -p "New index name: " IDX
       runCurl PUT "/$IDX?pretty" ;;
    10)
       read -p "Index name to delete: " IDX
       read -p "Confirm deletion (yes/no): " CONF
       [[ "$CONF" == "yes" ]] && runCurl DELETE "/$IDX?pretty" || echo "Cancelled." ;;
    11) runCurl GET "/_nodes?pretty" ;;
    12) runCurl GET "/_nodes/stats?pretty" ;;
    13) runCurl GET "/_cluster/settings?pretty" ;;
    14) runCurl GET "/_cluster/state?pretty" ;;
    15)
       read -p "Index name: " IDX
       read -p "Document ID: " DID
       runCurl GET "/$IDX/_doc/$DID?pretty" ;;
    16)
       read -p "Index name: " IDX
       read -p "JSON document ({\"field\":\"value\"}): " DOC
       runCurl POST "/$IDX/_doc?pretty" "$DOC" ;;
    17)
       read -p "Index name: " IDX
       read -p "Document ID: " DID
       read -p "JSON update doc ({\"doc\":{…}}): " UP
       runCurl POST "/$IDX/_update/$DID?pretty" "$UP" ;;
    18)
       read -p "Index name: " IDX
       read -p "Document ID to delete: " DID
       runCurl DELETE "/$IDX/_doc/$DID?pretty" ;;
    19) echo "Bye!"; exit ;;
    *) echo "Invalid selection." ;;
  esac
done
