import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Function ARN: {context.invoked_function_arn}")
    logger.info(f"Request ID: {context.aws_request_id}")
    logger.info(f"Event Type: {type(event)}")
    logger.info(f"Event Detail: {json.dumps(event)}")

    try:
        print("Received event:", json.dumps(event))

        # Loop through each record in the list (sent from EventBridge Pipe)
        for record in event:
            # Step 1: Decode the SQS body (it's a stringified JSON)
            outer_body_str = record.get("body", "{}")
            outer_body = json.loads(outer_body_str)

            # Step 2: Extract inner "Records" from the decoded S3 event inside the SQS message
            s3_event = outer_body.get("Records", [])[0]
            s3_record = s3_event["s3"]

            # Step 3: Extract bucket/key
            bucket = s3_record["bucket"]["name"]
            key = s3_record["object"]["key"]
            s3_url = f"s3://{bucket}/{key}"

            # Extract SQS message ID as GUID
            guid = record.get("messageId", "unknown")

            print(f"S3 URL: {s3_url}")
            print(f"Key: {key}")
            print(f"GUID: {guid}")

            # Return from the loop if you're only handling one message at a time
            return {
                "s3_url": s3_url,
                "guid": guid
            }

    except Exception as e:
        print(f"Error occurred: {e}")
        logger.error(f"Error occurred: {str(e)}", exc_info=True)
        raise e
