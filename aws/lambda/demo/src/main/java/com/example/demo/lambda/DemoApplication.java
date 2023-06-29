package com.example.demo.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ListBucketsResponse;

public class DemoApplication implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

	/*
	example codes
	https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/java-events/src/main/java/example/HandlerApiGatewayV1.java
	https://github.com/open-telemetry/opentelemetry-lambda/blob/c6a7138f19999f2c0adb7b5752b263ad76581647/java/sample-apps/aws-sdk/src/main/java/io/opentelemetry/lambda/sampleapps/awssdk/AwsSdkRequestHandler.java
	 */
	@Override
	public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent event, Context context) {
		LambdaLogger logger = context.getLogger();
		logger.log("EVENT TYPE: " + event.getClass().toString());
		APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
		try (S3Client s3 = S3Client.create()) {
			ListBucketsResponse listBucketsResponse = s3.listBuckets();
			response.setBody(
					"Hello lambda - found " + listBucketsResponse.buckets().size() + " bucket."
			);
		}
		return response;
	}

}
