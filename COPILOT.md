# Bitácora de uso de GitHub Copilot

## 0. Instrucciones personalizadas

Archivo: `.github/copilot-instructions.md`. VS Code lo aplica automáticamente a Chat, Agente y Edición (opción `github.copilot.chat.codeGeneration.useInstructionFiles` activada).
Convenciones principales: Lombok siempre (`@Data` + `@Builder` en DTOs; `@Getter`/`@Setter` + `@Builder` en entidades), inyección por constructor, DTOs de request/response, validación con mensajes en español y errores como `ProblemDetail`.

## 1. Creación del proyecto – Modo Agente

> Crea un nuevo proyecto de Spring Boot 3 con Maven llamado "servicio-inventario". Incluye las dependencias: Spring Web, Spring Data JPA, H2 Database y Lombok.

Después se añadieron `spring-boot-starter-validation` (validación) y `spring-boot-starter-actuator` (health check para Docker).

## 2. Entidad y repositorio – Finalizaciones en línea

En `com.example.inventory.model.Product`:

```java
// Una entidad JPA para un producto con id, nombre, cantidad y precio.
```

Copilot sugirió los campos y las anotaciones `@Entity`, `@Id` y `@GeneratedValue`, además de las de Lombok según las instrucciones personalizadas.
En `repository.ProductRepository` basta con escribir `extends JpaRepository<` para que autocomplete `<Product, Long>`.

## 3. Lógica de negocio – Modo Preguntar + Finalizaciones en línea

Pregunta en Modo Preguntar:

> ¿Cómo se implementa un endpoint POST en Spring Boot para crear un nuevo producto, validando que el nombre no esté vacío y devolviendo un código de estado 201 Created?

Patrón aplicado: `@Valid @RequestBody ProductRequest`, `@NotBlank` en el DTO y `ResponseEntity.created(location).body(...)`.

Preguntas de buenas prácticas adicionales:

> ¿Cuál es la mejor práctica para manejar excepciones de forma global en Spring Boot 3?

→ `@RestControllerAdvice` + `ProblemDetail` (RFC 7807).

> ¿Debo exponer entidades JPA directamente en el controlador?

→ No; usar DTOs y un mapper.

Comentarios guía para generar el resto de métodos con Finalizaciones en línea:

```java
// GET /api/products/{id} -> 200 OK o 404 Not Found
// PUT /api/products/{id} -> 200 OK, 400 o 404
// DELETE /api/products/{id} -> 204 No Content o 404
```

## 4. Dockerfile – Modo Agente

> @workspace Analiza este proyecto Spring Boot y genera un Dockerfile optimizado que utilice una construcción de múltiples etapas para crear una imagen ligera.

Resultado revisado y aceptado: etapa de build con `maven:3.9-eclipse-temurin-17` (con caché de dependencias) y etapa de runtime con `eclipse-temurin:17-jre-alpine`, usuario sin privilegios y `HEALTHCHECK`. Se añadió `.dockerignore`.

## 5. Pruebas manuales

```bash
docker build -t servicio-inventario:1.0 .
docker run -d -p 8080:8080 --name inventario servicio-inventario:1.0
./scripts/test-api.sh
```
