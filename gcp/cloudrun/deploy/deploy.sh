#!/bin/bash

gcloud secrets create otel-config --data-file=config.yaml
gcloud run services replace cloudrun_service.yaml --region asia-northeast1
gcloud run services set-iam-policy opentelemetry-cloud-run policy.yaml
