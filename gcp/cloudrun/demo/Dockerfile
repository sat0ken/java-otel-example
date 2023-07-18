FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /workspace/app
COPY . /workspace/app
RUN --mount=type=cache,target=/root/.gradle ./gradlew bootJar

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar
ENV JAVA_TOOL_OPTIONS "-javaagent:/app/opentelemetry-javaagent.jar"
COPY --from=build /workspace/app/build/libs/*.jar /app
ENTRYPOINT ["java","-jar","/app/demo-0.0.1-SNAPSHOT.jar"]
