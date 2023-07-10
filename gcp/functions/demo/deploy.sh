#!/bin/bash

gcloud functions deploy java-http-function \
--gen2 \
--runtime=java17 \
--region=asia-northeast1 \
--source=. \
--entry-point=com.example.demo.DemoApplication \
--memory=512MB \
--trigger-http \
--allow-unauthenticated