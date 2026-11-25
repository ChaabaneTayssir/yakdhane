package com.example.demo.Modele;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
public class Produit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "nom")
    private String nom;

    @Column(name = "description")
    private String description;

    @Column(name = "prix")
    private double prix;

    @Column(name = "quantite")
    private int quantite;

    @Column(name = "image_path")
    private String imagePath; // Chemin de l'image

    @Column(name = "ip_adresse")
    private String adresse_ip;

    @ManyToOne
    @JoinColumn(name = "categorie_id",referencedColumnName = "id")
    @JsonIgnoreProperties({"produits"})
    private categories categorie;


    public Produit(String nom, String description, double prix, int quantite, String imagePath, categories categorie,String adresse_ip) {
        this.nom = nom;
        this.description = description;
        this.prix = prix;
        this.quantite = quantite;
        this.imagePath = imagePath;
        this.categorie = categorie;
        this.adresse_ip=adresse_ip;

    }

    public Produit() {

    }


    // Getters et setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrix() {
        return prix;
    }

    public void setPrix(double prix) {
        this.prix = prix;
    }

    public int getQuantite() {
        return quantite;
    }

    public void setQuantite(int quantite) {
        this.quantite = quantite;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getAdresse_ip() {
        return adresse_ip;
    }

    public void setAdresse_ip(String adresse_ip) {
        this.adresse_ip = adresse_ip;
    }

    public categories getCategorie() {
        return categorie;
    }

    public void setCategorie(categories categorie) {
        this.categorie = categorie;
    }


}
