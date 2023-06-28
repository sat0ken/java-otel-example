package com.example.demo.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.metrics.LongUpDownCounter;
import io.opentelemetry.api.metrics.Meter;

import javax.print.attribute.Attribute;

public class DemoApplication implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

	private static final Meter sampleMeter = GlobalOpenTelemetry.meterBuilder("aws-otel")
			.setInstrumentationVersion("1.0").build();
	private static final LongUpDownCounter queueSizeCounter =
			sampleMeter
					.upDownCounterBuilder("queueSizeChange")
					.setDescription("Queue Size change")
					.setUnit("one")
					.build();
	private static final AttributeKey<String> API_NAME = AttributeKey.stringKey("apiName");
	private static final AttributeKey<String> STATUS_CODE = AttributeKey.stringKey("statusCode");
	private static final Attributes METRIC_ATTRIBUTES =
			Attributes.builder().put(API_NAME, "apiName").put(STATUS_CODE, "200").build();

	@Override
	public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent event, Context context) {
		LambdaLogger logger = context.getLogger();
		logger.log("EVENT TYPE : " + event.getClass().toString());
		APIGatewayV2HTTPResponse response = new APIGatewayV2HTTPResponse();
		response.setIsBase64Encoded(false);
		response.setStatusCode(200);
		response.setBody("hello");

		queueSizeCounter.add(2, METRIC_ATTRIBUTES);

		return response;
	}
}
