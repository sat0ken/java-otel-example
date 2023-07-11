package com.example.demo;

import com.google.cloud.functions.HttpFunction;
import com.google.cloud.functions.HttpRequest;
import com.google.cloud.functions.HttpResponse;
import com.google.cloud.opentelemetry.trace.TraceConfiguration;
import com.google.cloud.opentelemetry.trace.TraceExporter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import io.opentelemetry.sdk.trace.export.SpanExporter;

import java.io.BufferedWriter;
import java.io.IOException;
import java.time.Duration;

public class DemoApplication implements HttpFunction {
    private static final String INSTRUMENTATION_SCOPE_NAME = DemoApplication.class.getName();
    private static OpenTelemetrySdk openTelemetrySdk;
    public DemoApplication() {
        TraceConfiguration configuration = TraceConfiguration.builder().setDeadline(Duration.ofMillis(30000)).build();
        SpanExporter traceExporter = TraceExporter.createWithConfiguration(configuration);
        openTelemetrySdk = OpenTelemetrySdk.builder()
                .setTracerProvider(
                    SdkTracerProvider.builder().addSpanProcessor(
                            BatchSpanProcessor.builder(traceExporter).build()
                    ).build()).buildAndRegisterGlobal();
    }

    @Override
    public void service(HttpRequest request, HttpResponse response) throws IOException {
        Span span = openTelemetrySdk.getTracer(INSTRUMENTATION_SCOPE_NAME).spanBuilder("service function").startSpan();
        BufferedWriter writer = response.getWriter();
        writer.write("Hello World!");
        span.addEvent("HTTP Request");
        span.end();
    }
}
