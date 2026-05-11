# Serverless AI Resume Chatbot
A distributed web application featuring an interactive AI assistant.

## ÌøóÔ∏è Architecture
- **Frontend:** Static HTML/CSS hosted on **Amazon S3**.
- **DNS/Routing:** Managed via **Amazon Route 53**.
- **API Layer:** **Amazon API Gateway** (REST/HTTP).
- **Compute:** **AWS Lambda** (Python 3.12).
- **Intelligence:** **Amazon Bedrock** (Amazon Nova Micro model).

## Ì∫Ä Key Features
- **Video Introduction:** Personal welcome video hosted on S3.
- **AI Chatbot:** Real-time responses based on my professional experience.
- **Serverless Design:** Optimized for cost (Pay-as-you-go).

## Ìª†Ô∏è Setup & Deployment
1. Upload files to S3 bucket `muneeflab.com`.
2. Deploy Lambda function with Bedrock permissions.
3. Connect API Gateway to Lambda.
