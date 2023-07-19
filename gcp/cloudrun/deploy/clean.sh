#!/bin/bash

gcloud run services delete opentelemetry-cloud-run
gcloud secrets delete otel-config