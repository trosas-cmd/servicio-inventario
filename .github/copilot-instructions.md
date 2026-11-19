# Instrucciones personalizadas para GitHub Copilot – servicio-inventario

Sigue estas convenciones del equipo al generar código en este repositorio.

## Stack
- Java 17, Spring Boot 3, Maven.
- Persistencia con Spring Data JPA; base de datos H2 en memoria.
- Paquete base: `com.example.inventory`, organizado en `model`, `dto`, `mapper`, `repository`, `service`, `controller` y `exception`.

## Lombok
- Usa siempre anotaciones de Lombok en lugar de getters, setters, constructores o builders escritos a mano.
- **DTOs**: `@Data`, `@Builder`, `@NoArgsConstructor` y `@AllArgsConstructor`.
- **Entidades JPA**: `@Getter`, `@Setter`, `@Builder`, `@NoArgsConstructor` y `@AllArgsConstructor`. No uses `@Data` en entidades, porque el equals/hashCode generado da problemas con los proxies de Hibernate.
- Inyecta dependencias por constructor con `@RequiredArgsConstructor` y campos `private final`. Nunca uses `@Autowired` en campos del código de producción.

## API REST
- Los controladores nunca exponen entidades: reciben `*Request` y devuelven `*Response`.
- Valida las entradas con Jakarta Validation (`@Valid`, `@NotBlank`, `@NotNull`, `@PositiveOrZero`…) y escribe los mensajes en español.
- Códigos HTTP: `201 Created` con cabecera `Location` en POST, `200` en GET y PUT, `204` en DELETE, `404` cuando el recurso no existe y `400` cuando la validación falla.
- Los errores se manejan en `GlobalExceptionHandler` (`@RestControllerAdvice`) y se devuelven como `ProblemDetail` (RFC 7807).

## Estilo
- Usa nombres de dominio en español (`nombre`, `cantidad`, `precio`) y nombres técnicos en inglés (`ProductService`, `findById`).
- Los servicios usan `@Transactional`, con `readOnly = true` en las lecturas.
- Usa `BigDecimal` para importes monetarios.
- Escribe una prueba de integración con MockMvc por cada endpoint nuevo.
