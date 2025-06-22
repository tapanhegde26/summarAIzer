import boto3
import json
import os
import base64

s3 = boto3.client("s3")
bedrock = boto3.client("bedrock-runtime")
sns = boto3.client("sns")

OUTPUT_BUCKET = os.environ.get("OUTPUT_BUCKET")
BEDROCK_MODEL_ID = os.environ.get("BEDROCK_MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")


def process_streaming_response(response):
    full_response = ""
    if not response or not response.get("body"):
        return full_response
        
    for event in response.get("body"):
        try:
            if isinstance(event, dict) and "chunk" in event:
                chunk_data = json.loads(event["chunk"].get("bytes", b"").decode())
                if chunk_data and "delta" in chunk_data and "text" in chunk_data["delta"]:
                    full_response += chunk_data["delta"]["text"]
        except Exception as e:
            print(f"Error processing chunk: {e}")
            continue
    return full_response

def handler(event, context):
    try:
        print("Received event:", json.dumps(event))

        # Direct access to event keys since the event is already a dictionary
        prompt_text = event.get("prompt")
        if not prompt_text:
            raise ValueError("Prompt is required")

# Claude expects a list of {"role": "user"/"assistant", "content": "..."}
        prompt = [{"role": "user", "content": prompt_text}]


        original_key = event.get("original_key")
        if not original_key:
            raise ValueError("Original key is required")

        print("=========")
        print("prompt :", prompt)
        print("=========")
        print("original_key :", original_key)

        model_payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "messages": prompt,
            "max_tokens": 1000,
            "temperature": 0.7,
            "top_p": 0.9
        }

        print("Invoking Bedrock model...")
        bedrock_response = bedrock.invoke_model_with_response_stream(
            modelId=BEDROCK_MODEL_ID,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(model_payload)
        )

        if not bedrock_response:
            raise ValueError("Empty response from Bedrock")

        output = process_streaming_response(bedrock_response)
        if not output:
            raise ValueError("No output generated from Bedrock response")

        print("Bedrock output:", output[:200])

        file_name = os.path.basename(original_key).replace(".json", "_summary.json")
        output_key = f"summaries/{file_name}"

        output_content = {
            "messages": prompt,
            "completion": output
        }

        s3.put_object(
            Bucket=OUTPUT_BUCKET,
            Key=output_key,
            Body=json.dumps(output_content, ensure_ascii=False),
            ContentType="application/json"
        )
        print(f"Summary saved at: s3://{OUTPUT_BUCKET}/{output_key}")

        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps({
                    "source_file": original_key,
                    "summary": output,
                    "s3_summary": f"s3://{OUTPUT_BUCKET}/{output_key}"
                }),
                Subject="Meeting Summary"
            )
            print("SNS notification sent.")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "output_location": f"s3://{OUTPUT_BUCKET}/{output_key}",
                "sns_topic": SNS_TOPIC_ARN
            })
        }

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e),
                "traceback": traceback.format_exc()
            })
        }
