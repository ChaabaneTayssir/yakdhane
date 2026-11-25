# Yakdhane – E-commerce Mobile App

Full-stack e-commerce application with a **Flutter** mobile app and a **Spring Boot** REST API.

## Tech stack
- **Mobile:** Flutter (Dart)
- **Backend:** Java, Spring Boot, Spring Security, Maven
- **Other:** REST API, email service

## Project structure
```
backend/   → Spring Boot REST API
mobile/    → Flutter mobile app
```

## Run the project
**Backend**
1. Copy `application.properties.example` to `application.properties` in `backend/src/main/resources/` and fill in your own values.
2. Run `mvnw spring-boot:run` in the `backend/` folder.

**Mobile**
1. Run `flutter pub get` in the `mobile/` folder.
2. Run `flutter run` on an emulator or a device.

## Credits
UI based on an open-source Flutter e-commerce template (GPL-3.0).
