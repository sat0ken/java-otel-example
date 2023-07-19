package com.example.demo;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.metrics.LongHistogram;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.context.Scope;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.api.trace.Tracer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;

@RestController
public class DemoController {
    private static final Logger logger = LoggerFactory.getLogger(DemoController.class);
    private final AttributeKey<String> ATTR_METHOD = AttributeKey.stringKey("method");
    
    private final Random random = new Random();
    private final Tracer tracer;
    private final LongHistogram longHistogram;

    @Autowired
    DemoController(OpenTelemetry openTelemetry) {
        tracer = openTelemetry.getTracer(DemoApplication.class.getName());
        Meter meter = openTelemetry.getMeter(DemoApplication.class.getName());
        longHistogram = meter.histogramBuilder("do-work").ofLongs().build();
    }

    @GetMapping("/rolldice")
    public String index(@RequestParam("player") Optional<String> player) {
        Span span = tracer.spanBuilder("/rolldice").startSpan();
        span.addEvent("/rolldice called");
        int result = this.getRandomNumber(1, 6);
        span.setAttribute("result number", result);
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

    @GetMapping("/ping")
    public String ping() throws InterruptedException {
        int sleepTime = random.nextInt(200);
        doWork(sleepTime);
        longHistogram.record(sleepTime, Attributes.of(ATTR_METHOD, "ping"));
        return "pong";
    }

    private void doWork(int sleepTime) throws InterruptedException {
        Span span = tracer.spanBuilder("doWork").startSpan();
        try (Scope ignored = span.makeCurrent()) {
            Thread.sleep(sleepTime);
            logger.info("A sample log message!");
        } finally {
            span.end();
        }
    }
}
