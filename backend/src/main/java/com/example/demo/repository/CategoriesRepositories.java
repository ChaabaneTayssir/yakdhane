package com.example.demo.repository;

import com.example.demo.Modele.categories;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CategoriesRepositories extends JpaRepository<categories, Long> {
    categories findByNom(String nom);

    categories save(categories categorie);

}
