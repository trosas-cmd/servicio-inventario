# servicio-inventario

Proyecto final **IAI-GENAI-3.02 – Proyecto Middleware**.
Microservicio de gestión de inventario de productos con **Java 17 + Spring Boot 3**. Expone una API REST con operaciones CRUD y se ejecuta en un contenedor **Docker** construido en varias etapas.

## Tecnologías

| Elemento | Tecnología |
|---|---|
| Lenguaje | Java 17 |
| Framework | Spring Boot 3.5 (Web, Data JPA, Validation, Actuator) |
| Base de datos | H2 en memoria (con 4 productos precargados en `data.sql`) |
| Utilidades | Lombok |
| Build | Maven |
| Contenedor | Docker multi-stage (`maven:3.9-eclipse-temurin-17` → `eclipse-temurin:17-jre-alpine`) |

## Estructura

```
src/main/java/com/example/inventory/
├── InventoryApplication.java
├── model/Product.java                  # Entidad JPA: id, nombre, cantidad, precio
├── dto/ProductRequest.java             # Entrada con validaciones
├── dto/ProductResponse.java            # Salida
├── mapper/ProductMapper.java           # Conversión entre entidad y DTOs
├── repository/ProductRepository.java   # JpaRepository<Product, Long>
├── service/ProductService.java         # Lógica de negocio
├── controller/ProductController.java   # Endpoints REST
└── exception/                          # ProductNotFoundException + GlobalExceptionHandler (ProblemDetail)
```

## Endpoints

Base: `http://localhost:8080/api/products`

| Método | Ruta | Descripción | Respuesta |
|---|---|---|---|
| GET | `/api/products` | Lista todos los productos | 200 |
| GET | `/api/products/{id}` | Obtiene un producto | 200 / 404 |
| POST | `/api/products` | Crea un producto | 201 + `Location` / 400 |
| PUT | `/api/products/{id}` | Actualiza un producto | 200 / 400 / 404 |
| DELETE | `/api/products/{id}` | Elimina un producto | 204 / 404 |

Cuerpo de POST y PUT:

```json
{ "nombre": "Audífonos Bluetooth", "cantidad": 40, "precio": 799.90 }
```

Validaciones: `nombre` es obligatorio y no puede estar vacío (máximo 120 caracteres); `cantidad` es obligatoria y ≥ 0; `precio` es obligatorio, ≥ 0 y tiene como máximo 2 decimales. Los errores se devuelven en formato `application/problem+json`:

```json
{
  "type": "about:blank",
  "title": "Error de validación",
  "status": 400,
  "detail": "La petición contiene datos inválidos",
  "instance": "/api/products",
  "errores": { "nombre": "El nombre es obligatorio" }
}
```

## Ejecución con Docker (recomendado)

Solo necesitas tener Docker instalado.

```bash
# 1. Construir la imagen
docker build -t servicio-inventario:1.0 .

# 2. Ejecutar el contenedor
docker run -d --name inventario -p 8080:8080 servicio-inventario:1.0

# 3. Verificar el estado (UP)
curl http://localhost:8080/actuator/health

# Ver logs / detener
docker logs -f inventario
docker stop inventario && docker rm inventario
```

El Dockerfile tiene dos etapas:
1. **build**: imagen con Maven y JDK 17. Primero descarga las dependencias (`dependency:go-offline`) para aprovechar la caché de capas y después empaqueta el JAR.
2. **runtime**: imagen ligera con solo el JRE 17 sobre Alpine. Ejecuta la app con un usuario sin privilegios, incluye un `HEALTHCHECK` contra Actuator y limita la memoria de la JVM al 75 % de la disponible en el contenedor.

## Ejecución local (sin Docker)

Requisitos: JDK 17+ y Maven 3.9+.

```bash
mvn clean package        # compila y ejecuta las pruebas
mvn spring-boot:run      # o bien: java -jar target/servicio-inventario.jar
```

Consola H2: http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:inventorydb`, usuario `sa`, sin contraseña).

## Pruebas

- **Automáticas**: `mvn test` ejecuta `ProductControllerIntegrationTest` (MockMvc), que cubre el ciclo CRUD completo, la validación (400) y el caso de producto inexistente (404).
- **Manuales con curl**: `./scripts/test-api.sh` (acepta la URL base como argumento).
- **Postman**: importa `postman/servicio-inventario.postman_collection.json`.

Ejemplos con curl:

```bash
curl http://localhost:8080/api/products
curl -i -X POST http://localhost:8080/api/products -H "Content-Type: application/json" \
     -d '{"nombre":"Webcam HD","cantidad":10,"precio":899.90}'
curl -X PUT http://localhost:8080/api/products/1 -H "Content-Type: application/json" \
     -d '{"nombre":"Laptop Dell Latitude","cantidad":12,"precio":17999.00}'
curl -i -X DELETE http://localhost:8080/api/products/1
```

## GitHub Copilot

- Instrucciones personalizadas del equipo: [`.github/copilot-instructions.md`](./.github/copilot-instructions.md)
- Prompts usados en cada modo: [`COPILOT.md`](./COPILOT.md)
