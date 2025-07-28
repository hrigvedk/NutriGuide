# NutriGuide: Personalized Nutrition & Allergen Management

<img src="images/logo.png" alt="NutriGuide logo" width="200"/>

NutriGuide is a mobile application that empowers individuals to manage their nutrition with precision, especially when navigating allergies, dietary restrictions, and chronic health conditions. Unlike traditional food-tracking apps, NutriGuide provides **personalized recommendations** using user-specific health data and AI-powered analysis.

## 🚀 Features

- **🔒 Secure Authentication**
  - Firebase Authentication for registration, login, and guest mode access.

- **📝 Comprehensive Onboarding**
  - Collects data like allergies, medications, dietary preferences, and health conditions.

- **📷 Barcode Scanning**
  - Scan food product barcodes for instant analysis based on health profile.

- **🤖 Virtual Nutrition Assistant**
  - AI-powered analysis of food products, including fast food items, considering allergies and conditions.

- **⌚ Apple Watch Integration**
  - Syncs critical health information for use in emergencies.

- **📊 Health Dashboard**
  - Displays BMI, macronutrient needs, and nutritional summaries.

- **📔 Food Diary**
  - Stores scanned food items and tracks consumption patterns.

- **🆘 Emergency Card**
  - Generates emergency health card with user’s critical health data.

## 📱 Screenshots

- Welcome, Signup, and Login screens (light/dark mode)
- Onboarding and Home pages
- Health Reports and Emergency Card
- Barcode Scanning & Nutrition Analysis
- Food Diary and Nutrition Dashboard

## 🏗️ Architecture Overview

### Mobile App
- Built with **SwiftUI** (iOS)
- Acts as the central hub for barcode scanning, profile management, and data sync

### Firebase (Google Cloud)
- **Authentication**: Manages login/registration securely
- **Cloud Firestore**: Stores user health profiles and syncs across devices

### AWS Cloud
- **Amazon API Gateway**: Routes requests from the app
- **AWS Lambda**: Processes API requests and runs backend logic
- **Gemini LLM**: Performs personalized product analysis
- **External API**: Fetches product details via barcode

## 🛠️ Methodology

- **Market Analysis**: Identified gaps in existing nutrition apps
- **Architecture Design**: Combined Firebase & AWS for scalable, secure architecture
- **Incremental Development**: Built in stages—auth, scanning, analysis, etc.
- **Testing & Feedback**: Iterative improvement through user testing

## 🔮 Future Scope

- 🧾 **Recipe Suggestions**: AI-based meal planning
- 🥘 **Product Comparison**: Compare food items side-by-side
- 🌍 **Localization**: Multi-language and regional support
- 🛒 **Expanded Database**: Broader food product integration

## ✅ Benefits

- Personalized dietary insights
- Allergen safety alerts
- Quick product analysis with barcode scanning
- Better meal decision-making
- Emergency readiness via synced Apple Watch data

## 📂 Tech Stack

- **Frontend**: iOS (SwiftUI)
- **Backend**: AWS Lambda, API Gateway
- **Database/Auth**: Firebase Firestore & Authentication
- **AI**: Gemini LLM for nutritional analysis

---

> NutriGuide bridges the gap between generic nutrition tracking and personalized health needs, offering users an intelligent assistant for everyday dietary choices.

