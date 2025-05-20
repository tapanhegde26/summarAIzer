# 🎙️ summarAIzer

> An AI-powered, serverless meeting summarization system built with AWS, Bedrock, and Terraform.

Turn your client meetings into beautifully summarized notes — automatically. Just upload a `.wav` file and receive polished summaries, action points, and decisions directly in your S3 bucket or via email.

---

## 📌 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Terraform Modules](#-terraform-modules)
- [Setup Instructions](#-setup-instructions)
- [Testing](#-testing)
- [Optional Integrations](#-optional-integrations)
- [Cleanup](#-cleanup)
- [Contributing](#-contributing)
- [License](#-license)
- [Maintainers](#-maintainers)

---

## 🚀 Features

- 🎧 Upload `.wav` or `.mp3` recordings to S3
- 🔊 Automatic transcription using AWS Transcribe
- 🧠 Smart prompt generation using Lambda
- 🤖 AI summary generation using AWS Bedrock (Claude Haiku)
- 📦 Serverless orchestration with Step Functions
- 📥 Summaries stored in S3 or sent via SNS/email
- 🔐 Modular Terraform implementation with environment support

---

## 🧱 Architecture

```text
                   +-----------------------+
                   |   Client Uploads .wav |
                   +----------+------------+
                              |
                              v
                 +----------------------------+
                 | Amazon S3 (Input Bucket)   |
                 +----------------------------+
                              |
                              v
                 +----------------------------+
                 |     Amazon SQS Queue       |
                 +----------------------------+
                              |
                              v
                 +----------------------------+
                 |   EventBridge Pipe         |
                 +----------------------------+
                              |
                              v
                 +----------------------------+
                 | AWS Step Functions         |
                 +----------------------------+
                              |
             +----------------------+--------------------+
             |                      |                    |
             v                      v                    v
    +----------------+    +----------------+    +----------------+
    | AWS Transcribe | -> | Lambda: Prompt | -> | Bedrock: Claude|
    +----------------+    +----------------+    +----------------+
             |                                             |
             v                                             v
     +-------------------+                      +-----------------------+
     | Transcript to JSON|                      |   Summarized Output   |
     +-------------------+                      +-----------------------+
                              | 
                              v
                 +----------------------------+
                 | Output S3 Bucket / SNS     |
                 +----------------------------+
