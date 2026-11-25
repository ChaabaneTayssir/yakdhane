package com.example.demo.service;

import com.example.demo.Modele.categories;
import com.example.demo.repository.CategoriesRepositories;
import org.apache.el.stream.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategorieService {

    @Autowired
    private CategoriesRepositories categorieRepository;

    public categories ajouterCategorie(categories categorie) {
        return categorieRepository.save(categorie);
    }

    public categories getCategorieByNom(String nom) {
        return categorieRepository.findByNom(nom);
    }

    public categories getCategorieById(Long id) {
        return categorieRepository.findById(id).orElse(null); // Renvoie null si la catégorie n'existe pas
    }

    public List<categories> getAllCategories() {
        return categorieRepository.findAll();
    }


    public boolean categoryExists(String nom) {
        categories categorie = categorieRepository.findByNom(nom);
        return categorie != null;  // Si la catégorie existe, renvoie true
    }







    public categories findByNom(String nom) {
        return categorieRepository.findByNom(nom); // Assurez-vous que cette méthode existe dans votre repository
    }

    public categories save(categories categorie) {
        return categorieRepository.save(categorie);
    }



    public boolean supprimerCategorieParId(Long id) {
        return categorieRepository.findById(id).map(categorie -> {
            categorieRepository.deleteById(id);
            return true;
        }).orElse(false);
    }






    public categories updateCategory(String ancienNom, String nouveauNom) {
        categories category = categorieRepository.findByNom(ancienNom);

        if (category != null) {
            category.setNom(nouveauNom);
            return categorieRepository.save(category);
        } else {
            // Si la catégorie n'existe pas, retourner null ou une exception
            return null;
        }
    }

}