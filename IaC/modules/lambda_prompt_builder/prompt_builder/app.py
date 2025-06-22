import boto3
import json
import os

s3 = boto3.client("s3")
comprehend = boto3.client("comprehend")

FINANCIAL_PII_TYPES = {
    "BANK_ACCOUNT_NUMBER",
    "BANK_ROUTING",
    "CREDIT_DEBIT_NUMBER", 
    "CREDIT_DEBIT_CVV",
    "CREDIT_DEBIT_EXPIRY",
    "PIN",
    "SWIFT_CODE",
    "ADDRESS",
    "SSN",
    "PASSPORT_NUMBER",
    "DRIVER_ID",
    "USERNAME",
    "PASSWORD",
    "AGE",
    "PHONE"
    }


def redact_financial_pii(text):
    response = comprehend.detect_pii_entities(
        Text=text,
        LanguageCode='en'
    )

    entities = sorted(response["Entities"], key=lambda x: x["BeginOffset"], reverse=True)

    for entity in entities:
        print(f"Detected: {entity['Type']} — {text[entity['BeginOffset']:entity['EndOffset']]}")
        if entity["Type"] in FINANCIAL_PII_TYPES:
            print(f"Removing: {entity['Type']} — {text[entity['BeginOffset']:entity['EndOffset']]}")
            begin = entity["BeginOffset"]
            end = entity["EndOffset"]
            text = text[:begin] + "[REDACTED]" + text[end:]

    return text

def handler(event, context):
    try:
        print("Received event:", json.dumps(event))

        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        prompt_bucket = os.environ['PROMPT_BUCKET']
        prompt_key = os.environ['PROMPT_KEY']
        redact_bucket = os.environ['REDACTED_BUCKET']

        print(f"Reading transcript from s3://{bucket}/{key}")
        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read().decode("utf-8")
        transcript_json = json.loads(content)

        transcript_text = transcript_json["results"]["transcripts"][0]["transcript"]
        print("Original transcript_text:", transcript_text)
        
        redacted_text = redact_financial_pii(transcript_text)
        print("Redacted transcript_text:", redacted_text) 
        
        # Save redacted transcript
        print(f"Saving redacted transcript from s3://{redact_bucket}/{key}")
        s3.put_object(
            Bucket=redact_bucket,
            Key=key,
            Body=redacted_text.encode("utf-8"),
            ContentType="application/json"
        )

        print(f"Created transcript at s3://{redact_bucket}/{key} with redacted version")

        # Delete the original unredacted file
        print(f"Deleting original file: s3://{bucket}/{key}")
        s3.delete_object(Bucket=bucket, Key=key)
        print(f"Deleted original file: s3://{bucket}/{key}")
        
        # Generate final prompt
        prompt_response = s3.get_object(Bucket=prompt_bucket, Key=prompt_key)
        prompt_template = prompt_response['Body'].read().decode('utf-8')
        final_prompt = prompt_template.format(transcript_text=transcript_text)
        print("Formatted Prompt:", final_prompt)

        return {
            "statusCode": 200,
            "prompt": final_prompt,
            "source_bucket": redact_bucket,
            "source_key": key
        }

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        return {
            "statusCode": 500,
            "error": str(e),
            "traceback": traceback.format_exc()
        }
