package com.example.demo.controller;

import com.example.demo.Modele.Produit;
import com.example.demo.Modele.categories;
import com.example.demo.repository.CategoriesRepositories;
import com.example.demo.repository.ProduitRepository;
import com.example.demo.service.CategorieService;
import com.example.demo.service.ProduitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/produits")
public class ProduitController {


    @Autowired
    private CategorieService categorieService;
    @Autowired
    private CategoriesRepositories categorieRepository;
    @Autowired
    private ProduitRepository produitRepository;
    @Autowired
    private ProduitService produitService;
    // Récupérer toutes les catégories
    @GetMapping("/categories")
    public List<categories> getAllCategories() {
        return categorieService.getAllCategories();
    }
    @GetMapping("/{id}/products")
    public List<Produit> getProductsByCategory(@PathVariable Long id) {
        return produitRepository.findByCategorieId(id);
    }




    // Ajouter une catégorie
    @PostMapping("/categorie/ajouter")
    public ResponseEntity<String> ajouterCategorie(@RequestBody categories categorie) {
        if (categorieService.categoryExists(categorie.getNom())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cette catégorie existe déjà.");
        }
        categorieService.ajouterCategorie(categorie);
        return ResponseEntity.status(HttpStatus.CREATED).body("Catégorie ajoutée avec succès !");
    }
    @GetMapping("/populaires")
    public List<Produit> getPopularProducts() {
        return produitService.getPopularProducts();
    }

    // Vérifier si une catégorie existe
    @GetMapping("/categorie/check")
    public ResponseEntity<Map<String, Boolean>> checkCategoryExists(@RequestParam String nom) {
        boolean exists = categorieService.categoryExists(nom);
        return ResponseEntity.ok(Map.of("exists", exists));
    }
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> createProduit(
            @RequestParam("nom") String nom,
            @RequestParam("description") String description,
            @RequestParam("prix") double prix,
            @RequestParam("quantite") int quantite,
            @RequestParam("categorie_id") Long categorieId,
            @RequestParam("image") MultipartFile image,
            @RequestParam("adresse_ip") String adresseIp) { // Ajout de l'adresse IP

        try {
            // Trouver la catégorie associée
            categories categorie = categorieRepository.findById(categorieId)
                    .orElseThrow(() -> new RuntimeException("Catégorie introuvable"));

            // Sauvegarder l'image sur le serveur
            String imagePath = saveImage(image);

            // Créer le produit avec l'adresse IP
            Produit produit = new Produit(nom, description, prix, quantite, imagePath, categorie,adresseIp);
            produit.setAdresse_ip(adresseIp); // Ajouter l'adresse IP au produit

            produitRepository.save(produit);

            return ResponseEntity.status(HttpStatus.CREATED).body("Produit ajouté avec succès");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur : " + e.getMessage());
        }
    }

    private String saveImage(MultipartFile image) throws IOException {
        String folderPath = "uploads/"; // Dossier pour stocker les images
        String fileName = UUID.randomUUID() + "_" + image.getOriginalFilename();
        Path path = Paths.get(folderPath + fileName);
        Files.createDirectories(path.getParent());
        Files.write(path, image.getBytes());
        return path.toString();
    }




    @PutMapping("/modifier")
    public ResponseEntity<categories> updateCategory(@RequestBody Map<String, String> requestBody) {
        String ancienNom = requestBody.get("ancienNom");
        String nouveauNom = requestBody.get("nouveauNom");

        // Appel au service pour mettre à jour la catégorie
        categories updatedCategory = categorieService.updateCategory(ancienNom, nouveauNom);

        if (updatedCategory == null) {
            // Si la catégorie n'existe pas, retourner une réponse 404 Not Found
            return ResponseEntity.notFound().build();
        }

        // Si la mise à jour réussie, retourner la catégorie mise à jour avec un statut 200 OK
        return ResponseEntity.ok(updatedCategory);
    }




    // Supprimer une catégorie
    @DeleteMapping("/categories/supprimer")
    public ResponseEntity<?> supprimerCategorie(@RequestParam Long id) {
        System.out.println("Suppression de la catégorie avec ID : " + id);
        boolean estSupprime = categorieService.supprimerCategorieParId(id);
        if (estSupprime) {
            return ResponseEntity.ok("Catégorie supprimée avec succès !");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Catégorie non trouvée.");
        }
    }




    // Supprimer un produit
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProduit(@PathVariable Long id) {
        if (!produitRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Produit non trouvé");
        }

        produitRepository.deleteById(id);
        return ResponseEntity.ok("Produit supprimé avec succès !");
    }



    @PutMapping("/update/{id}")
    public ResponseEntity<String> modifierProduit(
            @PathVariable Long id,
            @RequestBody Produit produitRequest) {

        try {
            // Trouver le produit à modifier
            Produit produit = produitRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Produit non trouvé"));

            // Mettre à jour les propriétés du produit
            produit.setNom(produitRequest.getNom());
            produit.setDescription(produitRequest.getDescription());
            produit.setPrix(produitRequest.getPrix());
            produit.setQuantite(produitRequest.getQuantite());
            produit.setAdresse_ip(produitRequest.getAdresse_ip());

            // Vérification et mise à jour de la catégorie
            if (produitRequest.getCategorie() != null &&
                    categorieRepository.existsById(produitRequest.getCategorie().getId())) {
                categories categorie = categorieRepository.findById(produitRequest.getCategorie().getId())
                        .orElseThrow(() -> new RuntimeException("Catégorie non trouvée"));
                produit.setCategorie(categorie);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Catégorie non trouvée");
            }

            // Mettre à jour l'image si un chemin est fourni
            if (produitRequest.getImagePath() != null && !produitRequest.getImagePath().isEmpty()) {
                produit.setImagePath(produitRequest.getImagePath());
            }

            produitRepository.save(produit);
            return ResponseEntity.ok("Produit modifié avec succès");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur : " + e.getMessage());
        }
    }




}
