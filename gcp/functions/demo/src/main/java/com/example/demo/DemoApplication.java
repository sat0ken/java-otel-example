package com.example.demo;

import com.google.cloud.functions.HttpFunction;
import com.google.cloud.functions.HttpRequest;
import com.google.cloud.functions.HttpResponse;
import com.google.cloud.opentelemetry.trace.TraceConfiguration;
import com.google.cloud.opentelemetry.trace.TraceExporter;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.context.Scope;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.common.CompletableResultCode;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import io.opentelemetry.sdk.trace.export.SpanExporter;
import io.opentelemetry.semconv.resource.attributes.ResourceAttributes;

import java.io.BufferedWriter;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class DemoApplication implements HttpFunction {
    private static final String INSTRUMENTATION_SCOPE_NAME = DemoApplication.class.getName();
    private static final Random random = new Random();
    private static OpenTelemetrySdk openTelemetrySdk;
    public DemoApplication() {
        TraceConfiguration configuration = TraceConfiguration.builder().setDeadline(Duration.ofMillis(30000)).build();
        Resource resource = Resource.getDefault().merge(Resource.create(Attributes.of(ResourceAttributes.SERVICE_NAME, "java-http-function")));
        SpanExporter traceExporter = TraceExporter.createWithConfiguration(configuration);
        openTelemetrySdk = OpenTelemetrySdk.builder()
                .setTracerProvider(
                    SdkTracerProvider.builder().addSpanProcessor(
                            BatchSpanProcessor.builder(traceExporter).build()
                    ).setResource(resource).build()).buildAndRegisterGlobal();
    }

    private static void doWork(String description) {
        Span span = openTelemetrySdk.getTracer(INSTRUMENTATION_SCOPE_NAME).spanBuilder(description).startSpan();
        try (Scope scope = span.makeCurrent()) {
            span.addEvent("doWork function");
            span.setAttribute("Start sleep", LocalDateTime.now().toString());
            Thread.sleep(100 + random.nextInt(5) * 100);
            span.setAttribute("End sleep", LocalDateTime.now().toString());
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            span.end();
        }
    }

    @Override
    public void service(HttpRequest request, HttpResponse response) throws IOException {
        Span span = openTelemetrySdk.getTracer(INSTRUMENTATION_SCOPE_NAME).spanBuilder("/java-http-function")
                .setSpanKind(SpanKind.SERVER).startSpan();
        BufferedWriter writer = response.getWriter();
        writer.write("Hello World!");
        span.addEvent("HTTP Request");
        span.setAttribute("http.method", request.getMethod());
        span.setAttribute("http.path", request.getPath());
        doWork("doWork called");
        span.end();
        // Flush all bufferd traces
        CompletableResultCode completableResultCode = openTelemetrySdk.getSdkTracerProvider().shutdown();
        // wait till export finished
        completableResultCode.join(10000, TimeUnit.MILLISECONDS);
    }
}
