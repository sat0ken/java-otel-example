package com.example.demo;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.api.trace.Tracer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;

@RestController
public class DemoController {
    private static final Logger logger = LoggerFactory.getLogger(DemoController.class);
    private static final String INSTRUMENTATION_SCOPE_NAME = DemoController.class.getName();
    private final Tracer tracer;

    @Autowired
    DemoController(OpenTelemetry openTelemetry) {
        tracer = openTelemetry.getTracer(DemoApplication.class.getName());
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
}
