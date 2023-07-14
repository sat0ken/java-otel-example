FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /workspace/app

COPY . /workspace/app
RUN --mount=type=cache,target=/root/.gradle ./gradlew bootJar

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar
ADD https://repo1.maven.org/maven2/com/google/cloud/opentelemetry/exporter-auto/0.25.2-alpha/exporter-auto-0.25.2-alpha.jar /app/exporter-auto.jar
ENV JAVA_TOOL_OPTIONS "-javaagent:/app/aws-opentelemetry-agent.jar"
ENV OTEL_JAVAAGENT_EXTENSIONS "/app/exporter-auto.jar"
ENV OTEL_TRACES_EXPORTER "google_cloud_trace"
ENV OTEL_METRICS_EXPORTER "google_cloud_monitoring"
COPY --from=build /workspace/app/build/libs/*.jar /app
ENTRYPOINT ["java","-jar","/app/demo-0.0.1-SNAPSHOT.jar"]
