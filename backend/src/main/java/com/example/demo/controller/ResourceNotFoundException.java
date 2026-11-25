package com.example.demo.controller;



import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {

    // Constructeur avec message d'erreur
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
