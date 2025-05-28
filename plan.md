# Location Processing Service

A smart location data processing system for the Guardian Bubble app that converts raw GPS tracking data into meaningful walking sessions while filtering out local movement noise.

## 📋 Overview

The Location Processing Service transforms noisy GPS location data from child devices into clean, meaningful walking sessions. It intelligently distinguishes between actual outdoor walking activities and local movement (pacing at home, moving between rooms, yard activities) to provide parents with accurate insights into their child's mobility patterns.

## ✨ Key Features

- **Smart Local Movement Filtering**: Eliminates pacing, yard walking, and room-to-room movement
- **Radius-Based Detection**: Uses 200m radius threshold to identify significant movement
- **State-Aware Processing**: Different logic for stationary vs walking states
- **Session Merging**: Combines walking sessions separated by brief stops
- **Accuracy Filtering**: Removes poor GPS readings (>30m accuracy)
- **Distance Calculation**: Precise distance measurement using Haversine formula
- **Mini Map Generation**: Creates visual representations of walking paths

## 🏗️ System Architecture

```
Raw GPS Data → Filter → Group → Smart Filter → Merge → Sessions → Final Output
```

### Processing Pipeline

1. **Data Validation**: Clean and filter raw location points
2. **Activity Grouping**: Group consecutive same-activity points  
3. **Smart Grouping**: Apply radius-based local movement filtering
4. **Session Merging**: Combine related walking activities
5. **Metric Calculation**: Generate distance, speed, and timing data
6. **Quality Filtering**: Remove insignificant sessions

## 🔄 Processing Logic

### Step 1: Filter & Validate Data
```dart
// Remove poor accuracy readings
if (point.accuracy > 30.0) → FILTER OUT

// Keep only relevant activities  
if (point.activityType in ['walking', 'stationary']) → KEEP

// Sort chronologically
sortBy(capturedAt)
```

### Step 2: Group Consecutive Activities
Groups adjacent location points with the same activity type into ActivityGroups.

```dart
ActivityGroup {
  String activityType;        // 'walking' or 'stationary'
  List<LocationPoint> points; // Location data points
  DateTime startTime;         // First point timestamp
  DateTime endTime;           // Last point timestamp  
  Duration duration;          // Total duration
}
```

### Step 3: Smart Grouping Enhancement ⭐

**Core Innovation**: State-based radius filtering to eliminate local movement.

#### State Management
- `currentSessionState`: `'STATIONARY'` | `'WALKING'`
- `firstStationaryPoint`: Reference point for radius calculations
- `radiusThreshold`: 200 meters

#### Decision Logic

**When Current State = STATIONARY:**
```dart
if (new walking events detected) {
  double maxDistance = calculateMaxDistance(walkingPoints, firstStationaryPoint);
  
  if (maxDistance <= 200m) {
    // Local movement - absorb into stationary session
    extendStationarySession(walkingPoints);
  } else {
    // Significant movement - start walking session  
    startWalkingSession();
    currentSessionState = 'WALKING';
  }
}
```

**When Current State = WALKING:**
```dart
// Process all events normally - no radius checking
// Apply standard merge logic for brief stops
processNormally();
```

### Step 4: Smart Merging
Combines walking sessions separated by brief stationary periods.

```dart
// Merge Criteria
if (walking → stationary(≤1 min) → walking) {
  mergeIntoSingleSession();
} else {
  createSeparateSessions();
}
```

### Step 5: Create Walking Sessions
Generates final session objects with comprehensive metrics.

```dart
WalkingSession {
  DateTime startTime, endTime;
  Duration totalDuration, activeDuration;
  double distanceKm, averageSpeedKmh;
  List<LatLng> pathPoints;
  LatLngBounds mapBounds;
  String miniMapUrl;
  int walkingSegments, briefStops;
}
```

### Step 6: Filter Minimum Sessions
Removes insignificant activities based on duration and distance thresholds.

## ⚙️ Configuration

```dart
class ProcessingConfig {
  static const double maxAccuracy = 30.0;           // meters
  static const double radiusThreshold = 200.0;      // meters  
  static const Duration maxMergeThreshold = Duration(minutes: 1);
  static const Duration minSessionDuration = Duration(minutes: 2);
  static const double minDistanceKm = 0.01;          // 10 meters
  static const double minPointDistanceMeters = 5.0;
  static const double minWalkingSpeedKmh = 0.2;
  static const double maxWalkingSpeedKmh = 20.0;
}
```

## 🚀 Usage

### Basic Implementation

```dart
// Initialize service
final processor = LocationProcessingService();

// Process raw location data
List<WalkingSession> sessions = processor.processWalkingSessions(rawLocationData);

// Use results
for (final session in sessions) {
  print('Walking session: ${session.distanceKm}km in ${session.totalDuration}');
  print('Path: ${session.pathPoints.length} points');
  print('Mini map: ${session.miniMapUrl}');
}
```

### Integration with Guardian Bubble App

```dart
// In your location tracking cubit/service
class LocationTrackingCubit extends Cubit<LocationState> {
  final LocationProcessingService _processor = LocationProcessingService();
  
  Future<void> processChildLocationData(int childId) async {
    // Fetch raw data from API
    final rawData = await _childLocationRepository.getLocationHistory(childId);
    
    // Process into walking sessions
    final sessions = _processor.processWalkingSessions(rawData.data);
    
    // Emit processed results
    emit(LocationProcessed(walkingSessions: sessions));
  }
}
```

## 📊 Example Scenarios

### Scenario 1: Child at Home
```
Input:  Stationary → Walking(50m) → Walking(120m) → Stationary
Logic:  All walking within 200m radius of first stationary point
Output: Extended stationary session (walking absorbed as local movement)
```

### Scenario 2: Child Goes for Walk  
```
Input:  Stationary → Walking(300m) → Walking(500m) → Walking(800m)
Logic:  First walking point exceeds 200m radius
Output: Stationary session ends, new walking session begins
```

### Scenario 3: Walking with Brief Stop
```
Input:  Walking → Brief Stop(30sec) → Walking  
Logic:  Stop duration ≤ 1 minute threshold
Output: Single merged walking session with 1 brief stop
```

## 🎯 Benefits

### For Parents
- **Meaningful Insights**: See actual outdoor activities, not indoor movement
- **Accurate Distance**: Precise walking distance calculations
- **Visual Maps**: Mini-map URLs for route visualization
- **Time Tracking**: Active vs total duration metrics

### For Developers  
- **Clean Data**: Pre-processed, filtered location sessions
- **Performance**: Reduced data volume by filtering noise
- **Flexibility**: Configurable thresholds for different use cases
- **Integration Ready**: Easy to integrate with existing location tracking

## 🔧 API Reference

### Main Method
```dart
List<WalkingSession> processWalkingSessions(List<LocationDataEntity> rawData)
```

### Core Models

#### LocationDataEntity
```dart
class LocationDataEntity {
  final int id;
  final LocationDetailEntity location;
  final double accuracy;
  final DateTime capturedAt;  
  final String activityType;    // 'walking' | 'stationary'
  final int batteryLevel;
}
```

#### WalkingSession
```dart
class WalkingSession {
  final DateTime startTime, endTime;
  final Duration totalDuration, activeDuration;
  final double distanceKm, averageSpeedKmh;
  final List<LatLng> pathPoints;
  final LatLngBounds mapBounds;
  final LatLng startPoint, endPoint;
  final String miniMapUrl;
  final int walkingSegments, briefStops;
}
```

## 📈 Performance Considerations

- **Memory Efficient**: Processes data in single pass
- **Configurable**: Adjust thresholds based on device capabilities  
- **Scalable**: Handles large datasets with O(n) complexity
- **Error Resilient**: Graceful handling of corrupted/missing data

## 🧪 Testing

### Test Data Scenarios
- Local movement patterns (home, school, playground)
- Long-distance walking sessions
- Mixed activity patterns  
- Edge cases (GPS drift, poor accuracy)
- Performance with large datasets

### Quality Metrics
- Accuracy of local movement detection
- Proper session boundary identification
- Distance calculation precision
- Performance benchmarks

## 🤝 Contributing

1. Follow existing code patterns and naming conventions
2. Add comprehensive tests for new features
3. Update documentation for configuration changes
4. Test with real-world location data scenarios

## 📝 License

Part of the Guardian Bubble application. Internal use only.

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Maintainer**: Flutter Development Team
