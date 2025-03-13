# Foodam - Meal Subscription App

A Flutter application for customizing and subscribing to daily meal plans. Foodam allows users to select, customize, and manage meal subscriptions with a rich, interactive UI.

![App Banner](https://via.placeholder.com/800x200.png?text=Foodam+Meal+Subscription+App)

## Features

- **User Authentication**: Login functionality with mock data
- **Plan Browsing**: Browse various meal subscription plans with different durations
- **Plan Customization**: Customize meal selections for each day of the week
- **Thali Selection**: Choose from different thali options for breakfast, lunch, and dinner
- **Meal Customization**: Modify individual meals within a thali
- **Draft Plans**: Save and resume customization with draft plans
- **Active Plan Management**: View and manage active subscriptions
- **Order Summary**: Detailed payment summary with price breakdown
- **Responsive UI**: Works across different screen sizes

## Architecture

The app is built using Clean Architecture principles with a focus on:

- **Domain-Driven Design**: Clear separation of business logic from UI
- **BLoC Pattern**: Using Cubits for state management
- **Repository Pattern**: Abstraction over data sources
- **Dependency Injection**: Using GetIt for service locator pattern

### Architectural Layers:

1. **Presentation Layer**: UI components, Cubits for state management
2. **Domain Layer**: Business entities, Use cases, Repository interfaces
3. **Data Layer**: Repository implementations, Data sources, Models

## Technologies & Libraries

- **Flutter**: UI framework
- **flutter_bloc**: State management
- **equatable**: Value equality
- **dartz**: Functional programming
- **get_it**: Dependency injection
- **shared_preferences**: Local storage for draft plans

## Getting Started

### Prerequisites

- Flutter SDK (2.0 or later)
- Dart SDK (2.12 or later)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-username/foodam.git
   ```

2. Navigate to the project directory:
   ```
   cd foodam
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

### Authentication
- Use the demo login (user@example.com / password123) for quick access

### Browse Plans
- Select plan duration (7, 14, or 28 days)
- Choose plan type (Veg/Non-Veg)
- View plan details

### Customize Meals
- Select different thalis for each meal and day
- Customize thali contents
- View price updates in real-time

### Order & Payment
- Review complete order summary with price breakdown
- Complete mock payment process
- View active subscription

## Project Structure

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App constants
│   ├── errors/                # Error handling
│   ├── network/               # Network services
│   └── route/                 # Navigation
├── src/
│   ├── data/                  # Data layer
│   │   ├── datasource/        # Remote & local data sources
│   │   ├── models/            # Data models
│   │   └── repo/              # Repository implementations
│   ├── domain/                # Domain layer
│   │   ├── entities/          # Business entities
│   │   └── repo/              # Repository interfaces
│   └── presentation/          # Presentation layer
│       ├── cubits/            # State management
│       ├── utils/             # UI utilities
│       ├── views/             # Screens
│       └── widgets/           # Reusable UI components
├── injection_container.dart   # Dependency injection setup
└── main.dart                  # App entry point
```

## State Management

The app uses BLoC pattern (via Cubits) for state management:

- **AuthCubit**: Handles authentication state
- **ActivePlanCubit**: Manages active subscription state
- **PlanBrowseCubit**: Handles browsing available plans
- **PlanCustomizationCubit**: Manages plan customization
- **MealCustomizationCubit**: Handles meal selection within thalis
- **DraftPlanCubit**: Manages saving and loading draft plans

## Mock Data Implementation

The app currently uses mock data for all API calls. Mock data is implemented in:
- **MockData** class: Provides mock users, meals, thalis and plans
- **RemoteDataSourceImpl**: Simulates network requests
- **LocalDataSourceImpl**: Uses SharedPreferences for local storage

A toggle on the Home page allows switching between having an active plan or not for testing purposes.

## Developer Notes

- **API Integration**: The app is designed with real API integration in mind and can be easily connected to a backend
- **State Persistence**: Draft plans are persisted using SharedPreferences
- **Pricing Logic**: The app implements complex pricing logic with customization charges and duration-based discounts
- **Mock Delays**: Network calls have simulated delays to replicate real-world conditions

## Future Enhancements

- [ ] Backend integration with real API endpoints
- [ ] User registration and profile management
- [ ] Payment gateway integration
- [ ] Order history and reordering
- [ ] Meal ratings and reviews
- [ ] Dietary preference filtering
- [ ] Push notifications for meal deliveries
- [ ] Offline support with better caching

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by various food delivery and subscription services
- UI design elements from Material Design guidelines
