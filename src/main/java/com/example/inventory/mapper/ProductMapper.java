package com.example.inventory.mapper;

import com.example.inventory.dto.ProductRequest;
import com.example.inventory.dto.ProductResponse;
import com.example.inventory.model.Product;

/** Conversión entre la entidad Product y sus DTOs. */
public final class ProductMapper {

    private ProductMapper() {
    }

    public static Product toEntity(ProductRequest request) {
        return Product.builder()
                .nombre(request.getNombre().trim())
                .cantidad(request.getCantidad())
                .precio(request.getPrecio())
                .build();
    }

    public static void updateEntity(Product product, ProductRequest request) {
        product.setNombre(request.getNombre().trim());
        product.setCantidad(request.getCantidad());
        product.setPrecio(request.getPrecio());
    }

    public static ProductResponse toResponse(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .nombre(product.getNombre())
                .cantidad(product.getCantidad())
                .precio(product.getPrecio())
                .build();
    }
}
