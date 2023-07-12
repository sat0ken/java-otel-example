FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /workspace/app

COPY . /workspace/app
RUN --mount=type=cache,target=/root/.gradle ./gradlew bootJar

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/download/v1.27.0/aws-opentelemetry-agent.jar /app/aws-opentelemetry-agent.jar
ENV JAVA_TOOL_OPTIONS "-javaagent:/app/aws-opentelemetry-agent.jar"
COPY --from=build /workspace/app/build/libs/*.jar /app
ENTRYPOINT ["java","-jar","/app/demo-0.0.1-SNAPSHOT.jar"]
