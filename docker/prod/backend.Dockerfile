# Production Dockerfile for Spring Boot Backend

FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app

COPY .mvn .mvn
COPY pom.xml .

RUN java -classpath .mvn/wrapper/maven-wrapper.jar \
    -Dmaven.multiModuleProjectDirectory=/app \
    org.apache.maven.wrapper.MavenWrapperMain dependency:go-offline -B

COPY src ./src

RUN java -classpath .mvn/wrapper/maven-wrapper.jar \
    -Dmaven.multiModuleProjectDirectory=/app \
    org.apache.maven.wrapper.MavenWrapperMain clean package -DskipTests

FROM eclipse-temurin:25-jre

WORKDIR /app

# Optional, only for healthcheck
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN groupadd --system spring && useradd --system --gid spring spring

COPY --from=builder /app/target/*.jar /app/app.jar

RUN chown -R spring:spring /app

USER spring

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Dspring.profiles.active=prod", "-jar", "/app/app.jar"]
