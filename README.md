# Overview
This directory contains the Infrastructure as Code implementation for the Meeting Summarization System. The IaC automates the provisioning and management of cloud resources required to run the meeting summarization service.

## Architecture

![alt text](/architecture/summarizerAI-sw-flow-dark.png)

## Infrastructure Components

## Compute Resources
### Lambda Functions
- **lambda_step_function_parser**
    - Purpose: Parses and processes Step Function execution data
    - Manages workflow state transitions
    - Handles data transformation and validation

- **lambda_prompt_builder**
    - Purpose: Constructs and manages prompts for summarization
    - Handles prompt template management
    - Processes context and input parameters

- **lambda_bedrock_summary**
    - Purpose: Processes text using Amazon Bedrock for generating summaries
    - Serverless execution for efficient resource utilization
    - Integrates with Bedrock APIs for AI/ML processing


## Storage Resources
### S3 Buckets
- **s3_upload_bucket**
    - Purpose: Initial storage for raw meeting recordings
    - Triggers event notifications for processing pipeline
    - Manages upload lifecycle

- **s3_transcript_bucket**
    - Purpose: Stores meeting transcripts
    - Maintains processed speech-to-text output
    - Integrates with transcription workflow

- **s3_prompt_text_bucket**
    - Purpose: Stores prompt templates and configurations
    - Manages versioned prompt content
    - Supports dynamic prompt generation

- **s3_story_summary_bucket**
    - Purpose: Stores final summarized content
    - Maintains processed Bedrock responses
    - Archives completed summaries

## Event Processing
### Event Bridge
- **event_bridge_pipe**
    - Purpose: Manages event flow between services
    - Coordinates pipeline execution
    - Routes events to appropriate targets

### Message Queues
- **sqs_queue**
    - Purpose: Handles asynchronous message processing
    - Manages processing backlog
    - Provides message buffering

### Notifications
- **sns_topic**
    - Purpose: Manages system notifications

## Workflow Management
- **Step Functions** 
![alt text](/architecture/step_function.png)

    - Purpose: Orchestrates transcription workflow
    - Manages state transitions
    - Coordinates service interactions
    - Lambda functions
    - Amazon Transcribe for speech-to-text conversion
    - Amazon Comprehend for text analysis
    - Amazon S3 for storage

## IAM Roles
### Service Roles
- **iam_lambda_exec_role**
    - Purpose: Execution permissions for Lambda functions
    - Manages service access
    - Implements least privilege

- **iam_eventbridge_pipe_role**
    - Purpose: Permissions for EventBridge Pipe
    - Controls event routing
    - Manages service integrations

- **iam_lambda_step_function_parser**
    - Purpose: Permissions for Step Function parser
    - Manages workflow permissions
    - Controls resource access

- **iam_step_function_role**
    - Purpose: Execution permissions for Step Functions
    - Manages workflow orchestration
    - Controls service interactions

## Security Features
- IAM role-based access control
- Secure service communications
- Audit logging and monitoring

## Monitoring and Logging
- CloudWatch integration
- Metric collection
- Error tracking
- Performance monitoring

## Deployment Instructions

### Prerequisites
- Terraform installed (version 1.0.0 or later)
- AWS CLI configured
- Appropriate AWS credentials with necessary permissions
- Git (for version control)

```bash
git clone <repository-url>
cd summarAIzer/meeting-summarization/IaC
```

## Environment and Workspace Management

### Initialize Terraform in your project directory
```bash
terraform init
```

### List existing workspaces (default workspace is created automatically)
```bash
terraform workspace list
```

### Create new workspace
```bash
terraform workspace new {workspace-name}
```

### Verify current workspace
```bash
terraform workspace show
```

### Switch between workspaces
```bash
terraform workspace select {workspace-name}
```

### Initialize Terraform (if not done)
```bash
terraform init
```

### validate with development variables
```bash
terraform validate
```

### Plan with development variables
```bash
terraform plan
```
### Apply development configuration
```bash
terraform apply
```
