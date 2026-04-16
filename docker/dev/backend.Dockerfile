# Development Dockerfile for Spring Boot Backend

FROM eclipse-temurin:25-jdk

WORKDIR /app

# Optional: only if you really need them
#RUN apt-get update && apt-get install -y curl wget && rm -rf /var/lib/apt/lists/*

# Maven wrapper + config
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Ensure wrapper is executable
RUN chmod +x mvnw

# Cache dependencies
RUN ./mvnw dependency:go-offline -B || true

# Optional for image-only startup without bind mount
COPY src ./src

EXPOSE 8080 5005

CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=dev", "-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"]
