#!/bin/bash

# Variables to set
LOG_GROUP_NAME="/example/basic/app2"  # Replace with your log group name
LOG_STREAM_NAME="1728028000"  # Replace with your log stream name
LOG_FILE="web_server_log_to_cloudwatch.log"  # Replace with the path to your log file in ELF format

# Get the sequence token for the log stream
SEQUENCE_TOKEN=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --log-stream-name-prefix "$LOG_STREAM_NAME" --query 'logStreams[0].uploadSequenceToken' --output text)

# Handle if the log stream does not have an existing sequence token
if [[ "$SEQUENCE_TOKEN" == "None" ]]; then
    SEQUENCE_TOKEN=""
fi

# Process each log line from the file
while IFS= read -r LOG_LINE || [[ -n "$LOG_LINE" ]]; do
  # Skip the comment line (the one that starts with "#")
  if [[ "$LOG_LINE" == \#* ]]; then
    continue
  fi

  # Create a timestamp and the log message
  TIMESTAMP=$(date +%s%3N)  # Current timestamp in milliseconds
  MESSAGE=$LOG_LINE

  # Construct the log event in JSON format
  LOG_EVENT=$(cat <<EOF
  {
    "logGroupName": "$LOG_GROUP_NAME",
    "logStreamName": "$LOG_STREAM_NAME",
    "logEvents": [
      {
        "timestamp": $TIMESTAMP,
        "message": "$MESSAGE"
      }
    ]
  }
EOF
)

  # Send the log event to CloudWatch Logs
  if [[ -z "$SEQUENCE_TOKEN" ]]; then
    aws logs put-log-events --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME" --log-events timestamp="$TIMESTAMP",message="$MESSAGE"
  else
    aws logs put-log-events --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME" --log-events timestamp="$TIMESTAMP",message="$MESSAGE" --sequence-token "$SEQUENCE_TOKEN"
  fi

  # Update the sequence token after each request
  SEQUENCE_TOKEN=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --log-stream-name-prefix "$LOG_STREAM_NAME" --query 'logStreams[0].uploadSequenceToken' --output text)

done < "$LOG_FILE"