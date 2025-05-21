# Foodam - A Meal Subscription & Delivery Platform

![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)
![BLoC](https://img.shields.io/badge/State_Management-BLoC/Cubit-purple.svg)

A comprehensive food subscription platform built with Flutter and clean architecture principles, allowing users to subscribe to meal plans, customize their meal slots, and manage deliveries.

## 🌟 Features

- **Authentication System** - Secure login/signup with multiple authentication methods (email/password, mobile OTP)
- **Subscription Management** - Create, pause, resume and cancel meal subscriptions
- **Meal Customization** - Select meals for different slots (breakfast, lunch, dinner) across days
- **Order Tracking** - Track upcoming and past orders with real-time status updates
- **Payment Integration** - Seamless payment experience with Razorpay integration
- **Location Services** - Address management and serviceability check with cloud kitchens
- **Profile Management** - User profile and preferences management

## 🏗️ Architecture

The application follows a **Clean Architecture** approach with three main layers:

### Domain Layer
- **Entities**: Core business models
- **Repositories (Interfaces)**: Define data operations contracts
- **Use Cases**: Encapsulate business logic for specific functionalities

### Data Layer
- **Models**: Data representations with serialization/deserialization
- **Repository Implementations**: Implement domain repository interfaces
- **Data Sources**: Remote (API) and local (SharedPreferences) data sources
- **API Client**: DIO-based HTTP client for network operations

### Presentation Layer
- **Cubits**: Manage UI state with the BLoC pattern
- **UI Components**: Flutter widgets and screens
- **Navigation**: Centralized navigation service

## 🛠️ Technology Stack

- **Flutter**: UI framework
- **Dart**: Programming language
- **BLoC/Cubit**: State management
- **Dio**: HTTP client
- **Get_It**: Dependency injection
- **Dartz**: Functional programming features (Either type for error handling)
- **Equatable**: Value equality
- **Razorpay**: Payment processing
- **GoogleMaps**: Location services
- **SharedPreferences**: Local storage

## 📱 Key UI Features

- **Responsive Design**: Adapts to different screen sizes
- **Dynamic Theming**: Support for light and dark modes
- **Error Handling**: User-friendly error states and recovery
- **Skeletons & Shimmer Effects**: Enhance loading experiences
- **Pull-to-refresh**: Modern refresh patterns

## 🚀 Performance Optimizations

- **Lazy Loading**: Load data only when needed
- **Efficient Resource Management**: Proper disposal of resources
- **Dependency Injection**: Optimized object creation and lifecycle management
- **Memory Management**: Avoid memory leaks with proper stream disposal

## 📊 Architecture Diagram

```
┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│                         │     │                         │     │                         │
│   Presentation Layer    │     │     Domain Layer        │     │      Data Layer         │
│                         │     │                         │     │                         │
│  ┌─────────────────┐    │     │  ┌─────────────────┐    │     │  ┌─────────────────┐    │
│  │                 │    │     │  │                 │    │     │  │                 │    │
│  │      Cubits     │────┼─────┼─▶│    Use Cases    │────┼─────┼─▶│  Repositories   │    │
│  │                 │    │     │  │                 │    │     │  │                 │    │
│  └─────────────────┘    │     │  └─────────────────┘    │     │  └────────┬────────┘    │
│           ▲             │     │           ▲             │     │           │             │
│           │             │     │           │             │     │  ┌────────▼────────┐    │
│  ┌────────▼────────┐    │     │  ┌────────▼────────┐    │     │  │                 │    │
│  │                 │    │     │  │                 │    │     │  │   Data Sources  │    │
│  │       UI        │    │     │  │   Repositories  │◀───┼─────┼──│                 │    │
│  │                 │    │     │  │   (Interfaces)  │    │     │  └────────┬────────┘    │
│  └─────────────────┘    │     │  └─────────────────┘    │     │           │             │
│                         │     │           ▲             │     │  ┌────────▼────────┐    │
│                         │     │           │             │     │  │                 │    │
│                         │     │  ┌────────▼────────┐    │     │  │    API Client   │    │
│                         │     │  │                 │    │     │  │                 │    │
│                         │     │  │     Entities    │◀───┼─────┼──│     Models      │    │
│                         │     │  │                 │    │     │  │                 │    │
│                         │     │  └─────────────────┘    │     │  └─────────────────┘    │
│                         │     │                         │     │                         │
└─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

## 📝 Resume Points

Here are some key achievements and skills you can showcase on your resume:

1. **Designed and developed a comprehensive food delivery application with Flutter, implementing end-to-end features from authentication to payment processing**

2. **Architected a scalable mobile application following Clean Architecture principles for separation of concerns and testability**

3. **Implemented BLoC pattern with Cubit for state management, ensuring a unidirectional data flow and predictable app states**

4. **Integrated third-party services including Razorpay for payments and Google Maps for location services**

5. **Built a responsive UI that adapts to various screen sizes and orientations with custom widgets and reusable components**

6. **Designed and implemented complex business logic for subscription management, order tracking, and meal customization**

7. **Developed robust error handling mechanisms and recovery strategies for optimal user experience**

8. **Created efficient data caching strategies to minimize network requests and improve app performance**

9. **Implemented secure authentication with multiple methods (email/password, OTP) with proper token management**

10. **Built a modular codebase with dependency injection for testability and maintainability**

11. **Optimized API calls and local storage operations for improved performance and reduced battery consumption**

12. **Led the development of complex features such as subscription management system with customizable meal slots**

## 🏆 Skills to Showcase

- **Flutter & Dart**: Advanced knowledge and implementation
- **Clean Architecture**: Domain-driven design principles
- **State Management**: BLoC/Cubit implementation
- **REST API Integration**: Dio for efficient network requests
- **Error Handling**: Graceful error management with user feedback
- **Dependency Injection**: Get_It for service locator pattern
- **UI/UX**: Custom widgets, responsive layouts, animations
- **Payment Integration**: Razorpay SDK integration
- **Location Services**: Google Maps and geocoding
- **Authentication**: Multi-method secure authentication flows
- **Local Storage**: Efficient caching and persistence strategies
- **Testing**: Unit and widget testing strategies
- **Performance Optimization**: Memory management and resource efficiency
