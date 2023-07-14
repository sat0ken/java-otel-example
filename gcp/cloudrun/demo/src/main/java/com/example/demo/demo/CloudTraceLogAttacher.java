package com.example.demo.demo;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.filter.Filter;
import ch.qos.logback.core.spi.FilterReply;
import com.google.cloud.ServiceOptions;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.SpanContext;
import io.opentelemetry.context.Context;


public class CloudTraceLogAttacher  extends Filter<ILoggingEvent> {
    private static final String TRACE_ID = "gcp.trace_id";
    private static final String SPAN_ID = "gcp.span_id";
    private static final String SAMPLED = "gcp.trace_sampled";
    private final String projectId;
    private final String tracePrefix;

    public CloudTraceLogAttacher() {
        this.projectId = lookupProjectId();
        this.tracePrefix = "projects/" + (projectId == null ? "" : projectId) + "/traces/";
    }

    @Override
    public FilterReply decide(ILoggingEvent event) {
        SpanContext span = Span.fromContext(Context.current()).getSpanContext();
        if (span.isValid()) {
            org.slf4j.MDC.put(TRACE_ID, tracePrefix + span.getTraceId());
            org.slf4j.MDC.put(SPAN_ID, span.getSpanId());
            org.slf4j.MDC.put(SAMPLED, Boolean.toString(span.isSampled()));
        }
        return FilterReply.ACCEPT;
    }

    private static String lookupProjectId(){
        return ServiceOptions.getDefaultProjectId();
    }
}
