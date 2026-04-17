# Development Dockerfile for Spring Boot Backend

FROM eclipse-temurin:25-jdk

WORKDIR /app

COPY .mvn .mvn
COPY pom.xml .

# Cache dependencies
RUN java -classpath .mvn/wrapper/maven-wrapper.jar \
    -Dmaven.multiModuleProjectDirectory=/app \
    org.apache.maven.wrapper.MavenWrapperMain dependency:go-offline -B || true

# Optional for image-only startup without bind mount
COPY src ./src

EXPOSE 8080 5005

CMD ["java", "-classpath", ".mvn/wrapper/maven-wrapper.jar", "-Dmaven.multiModuleProjectDirectory=/app", "org.apache.maven.wrapper.MavenWrapperMain", "spring-boot:run", "-Dspring-boot.run.profiles=dev", "-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"]
