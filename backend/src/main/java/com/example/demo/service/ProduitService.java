package com.example.demo.service;


import com.example.demo.Modele.Produit;
import com.example.demo.repository.ProduitRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProduitService {

    private final ProduitRepository produitRepository;

    @Autowired
    public ProduitService(ProduitRepository produitRepository) {
        this.produitRepository = produitRepository;
    }

    public List<Produit> getPopularProducts() {
        // Fetch popular products from the database (for simplicity, we assume all products are popular)
        // You can filter them based on your logic (e.g., `isPopular` flag or other criteria)
        return produitRepository.findAll();
    }
}
