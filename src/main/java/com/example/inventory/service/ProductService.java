package com.example.inventory.service;

import com.example.inventory.dto.ProductRequest;
import com.example.inventory.dto.ProductResponse;
import com.example.inventory.exception.ProductNotFoundException;
import com.example.inventory.mapper.ProductMapper;
import com.example.inventory.model.Product;
import com.example.inventory.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    // Obtener todos los productos
    @Transactional(readOnly = true)
    public List<ProductResponse> findAll() {
        return productRepository.findAll().stream()
                .map(ProductMapper::toResponse)
                .toList();
    }

    // Obtener un producto por id o lanzar ProductNotFoundException
    @Transactional(readOnly = true)
    public ProductResponse findById(Long id) {
        return ProductMapper.toResponse(getOrThrow(id));
    }

    // Crear un nuevo producto
    @Transactional
    public ProductResponse create(ProductRequest request) {
        Product saved = productRepository.save(ProductMapper.toEntity(request));
        return ProductMapper.toResponse(saved);
    }

    // Actualizar un producto existente
    @Transactional
    public ProductResponse update(Long id, ProductRequest request) {
        Product product = getOrThrow(id);
        ProductMapper.updateEntity(product, request);
        return ProductMapper.toResponse(productRepository.save(product));
    }

    // Eliminar un producto existente
    @Transactional
    public void delete(Long id) {
        if (!productRepository.existsById(id)) {
            throw new ProductNotFoundException(id);
        }
        productRepository.deleteById(id);
    }

    private Product getOrThrow(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));
    }
}
