package com.example.demo.demo;

import com.google.cloud.opentelemetry.trace.TraceConfiguration;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.metrics.SdkMeterProvider;
import io.opentelemetry.sdk.metrics.export.MetricExporter;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.google.cloud.opentelemetry.trace.TraceExporter;
import io.opentelemetry.sdk.trace.export.SpanExporter;

import java.io.IOException;
import java.time.Duration;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;

@RestController
public class DemoController {
    private static final Logger logger = LoggerFactory.getLogger(DemoController.class);
    private static final String INSTRUMENTATION_SCOPE_NAME = DemoController.class.getName();

    private static OpenTelemetrySdk openTelemetrySdk;
    private static SdkMeterProvider METER_PROVIDER;
    private static Meter METER;

    public DemoController() {
        TraceConfiguration configuration = TraceConfiguration.builder().setDeadline(Duration.ofMillis(3000)).build();
        SpanExporter traceExporter = TraceExporter.createWithConfiguration(configuration);
        openTelemetrySdk = OpenTelemetrySdk.builder()
                .setTracerProvider(
                        SdkTracerProvider.builder()
                                .addSpanProcessor(BatchSpanProcessor.builder(traceExporter).build())
                                .build()
                ).buildAndRegisterGlobal();
    }

    @GetMapping("/rolldice")
    public String index(@RequestParam("player") Optional<String> player) {
        Span span = openTelemetrySdk.getTracer(INSTRUMENTATION_SCOPE_NAME).spanBuilder("/rolldice").startSpan();
        int result = this.getRandomNumber(1, 6);
        if (player.isPresent()) {
            logger.info("{} is rolling the dice: {}", player.get(), result);
        } else {
            logger.info("Anonymous player is rolling the dice: {}", result);
        }
        span.end();
        return "{\"number\" : %s}\n".formatted(Integer.toString(result));
    }

    public int getRandomNumber(int min, int max) {
        return ThreadLocalRandom.current().nextInt(min, max + 1);
    }

    @GetMapping("/health")
    public String health() {
        return "{\"status\" : \"ok\"}\n";
    }
}
