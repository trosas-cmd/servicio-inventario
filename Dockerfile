# syntax=docker/dockerfile:1

# ---------- Etapa 1: construcción ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Descargar dependencias primero para aprovechar la caché de capas
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Compilar y empaquetar
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---------- Etapa 2: ejecución ----------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Usuario sin privilegios
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=build /app/target/servicio-inventario.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
