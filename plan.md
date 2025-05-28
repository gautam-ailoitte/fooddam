Complete Location Processing Flow & Logic
Overall Processing Pipeline
Raw Location Data 
    ↓
Step 1: Filter & Validate
    ↓
Step 2: Group Consecutive Activities  
    ↓
Step 3: Smart Grouping Enhancement (NEW)
    ↓
Step 4: Apply Smart Merging
    ↓
Step 5: Create Walking Sessions
    ↓
Step 6: Filter Minimum Sessions
    ↓
Final Walking Sessions

Step 1: Filter & Validate Data
Purpose
Clean raw GPS data and remove noise
Process Logic
FOR each location point:
    IF accuracy > 30 meters → REMOVE
    IF activityType NOT IN ['walking', 'stationary'] → REMOVE
    IF coordinates are (0,0) → REMOVE
    ELSE → KEEP

SORT remaining points by timestamp
Output
Clean, chronologically ordered location points

Step 2: Group Consecutive Activities
Purpose
Group adjacent points with same activity type
Process Logic
Initialize: currentGroup = [], currentActivity = null, allGroups = []

FOR each location point:
    IF point.activityType != currentActivity:
        IF currentGroup is not empty:
            CREATE ActivityGroup from currentGroup
            ADD to allGroups
        
        START new currentGroup with this point
        SET currentActivity = point.activityType
    ELSE:
        ADD point to currentGroup

AFTER loop: ADD final currentGroup to allGroups
Output
List of ActivityGroups with:

activityType ('walking' or 'stationary')
points array
startTime, endTime, duration


Step 3: Smart Grouping Enhancement (CORE NEW LOGIC)
Purpose
Eliminate local movement noise using radius-based filtering
State Management
Global Variables:
- currentSessionState: 'STATIONARY' | 'WALKING'
- firstStationaryPoint: LatLng | null
- currentSession: List<ActivityGroup>
Processing Logic
Initialize: currentSessionState = 'STATIONARY', firstStationaryPoint = null

FOR each ActivityGroup:
    
    IF ActivityGroup.type == 'stationary':
        IF currentSessionState == 'STATIONARY':
            IF firstStationaryPoint == null:
                SET firstStationaryPoint = first point of this group
            EXTEND current stationary session
        ELSE: // currentSessionState == 'WALKING'
            APPLY normal merge logic (check duration)
    
    ELSE IF ActivityGroup.type == 'walking':
        IF currentSessionState == 'STATIONARY':
            CHECK if walking points are within 200m of firstStationaryPoint
            
            FOR each walking point in group:
                distance = calculateDistance(point, firstStationaryPoint)
                IF distance > 200m:
                    TRIGGER: Start new walking session
                    SET currentSessionState = 'WALKING'
                    BREAK out of check
            
            IF all walking points within 200m:
                ABSORB walking points into current stationary session
                IGNORE as local movement
        
        ELSE: // currentSessionState == 'WALKING'
            CONTINUE walking session (no radius check needed)
Key Decision Points
Stationary → Walking Transition:
IF currentSessionState == 'STATIONARY' AND new walking detected:
    maxDistance = MAX(distance from each walking point to firstStationaryPoint)
    
    IF maxDistance <= 200m:
        ACTION: Absorb walking into stationary session
        REASON: Local movement (pacing, yard walking, etc.)
    
    IF maxDistance > 200m:
        ACTION: End stationary session, start walking session
        REASON: Significant movement detected
        UPDATE: currentSessionState = 'WALKING'
Walking State Behavior:
IF currentSessionState == 'WALKING':
    PROCESS all subsequent events normally
    NO radius checking required
    REASON: Once walking, track all movement patterns

Step 4: Apply Smart Merging
Purpose
Merge walking sessions separated by brief stops
Process Logic
Initialize: mergedSessions = [], currentWalkingSession = []

FOR each processed ActivityGroup:
    
    IF group.type == 'walking':
        ADD group to currentWalkingSession
        
        LOOK AHEAD for merge opportunity:
        IF next group is 'stationary' AND nextNext group is 'walking':
            stationaryDuration = next group duration
            
            IF stationaryDuration <= 1 minute:
                ADD stationary group to currentWalkingSession
                ADD nextNext walking group to currentWalkingSession
                SKIP next two groups in main loop
            ELSE:
                FINALIZE currentWalkingSession
                ADD to mergedSessions
                RESET currentWalkingSession = []
    
    ELSE: // group.type == 'stationary'
        IF currentWalkingSession is not empty:
            FINALIZE currentWalkingSession
            ADD to mergedSessions  
            RESET currentWalkingSession = []
Merge Criteria

Brief stops: ≤ 1 minute duration
Pattern: Walking → Brief Stop → Walking = Single Session
Pattern: Walking → Long Stop → Walking = Separate Sessions


Step 5: Create Walking Sessions
Purpose
Convert merged activity groups into final walking session objects
Process Logic
FOR each merged session:
    
    EXTRACT walking points (ignore stationary points for distance calculation)
    EXTRACT all points (for timeline)
    
    CALCULATE metrics:
    - startTime = first point timestamp
    - endTime = last point timestamp  
    - totalDuration = endTime - startTime
    - activeDuration = sum of walking group durations only
    
    FILTER path points:
    - Remove consecutive points < 5m apart
    - Keep start and end points always
    
    CALCULATE distance:
    - Use Haversine formula between filtered points
    - Sum all point-to-point distances
    
    CALCULATE speed:
    - averageSpeed = distance / (totalDuration in hours)
    
    GENERATE map data:
    - pathPoints = filtered LatLng array
    - mapBounds = calculate bounding rectangle
    - miniMapUrl = generate static map URL
    
    COUNT segments:
    - walkingSegments = number of walking groups
    - briefStops = number of stationary groups
    
    CREATE WalkingSession object
Distance Calculation
Haversine Formula:
a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
c = 2 ⋅ atan2( √a, √(1−a) )
distance = R ⋅ c

Where:
- φ = latitude in radians
- λ = longitude in radians  
- R = Earth's radius (6371 km)
- Δφ = lat2 - lat1
- Δλ = lng2 - lng1

Step 6: Filter Minimum Sessions
Purpose
Remove insignificant walking sessions
Filter Criteria
FOR each walking session:
    IF session.totalDuration < 2 minutes → REMOVE
    IF session.distanceKm < 0.01 km (10 meters) → REMOVE
    IF session.averageSpeed < 0.2 kmh OR > 20 kmh → REMOVE (invalid speeds)
    ELSE → KEEP
Quality Thresholds

Minimum Duration: 2 minutes
Minimum Distance: 10 meters
Speed Range: 0.2 - 20 km/h (human walking speeds)


Core Algorithm Behaviors
Scenario Handling
Local Movement Pattern:
State: STATIONARY → Walking (within 200m) → STATIONARY
Result: Extended stationary session
Reason: Pacing, yard movement, room-to-room walking
Significant Movement Pattern:
State: STATIONARY → Walking (beyond 200m) → Continues
Result: New walking session starts
Reason: Actual outdoor walking/travel
Walking Session Pattern:
State: WALKING → Any movement → Continues processing
Result: All movement tracked normally
Reason: Once mobile, track complete journey
State Transitions
Initial State: STATIONARY

STATIONARY → WALKING:
Triggered by: Walking points beyond 200m radius

WALKING → STATIONARY:  
Triggered by: Long stationary period (>1 minute) or session end

WALKING → WALKING:
Triggered by: Brief stops (≤1 minute) get merged

Configuration Constants
MAX_ACCURACY_THRESHOLD = 30.0 meters
RADIUS_THRESHOLD = 200.0 meters  
MAX_MERGE_DURATION = 1 minute
MIN_SESSION_DURATION = 2 minutes
MIN_DISTANCE = 10 meters
MIN_POINT_DISTANCE = 5 meters
MIN_WALKING_SPEED = 0.2 kmh
MAX_WALKING_SPEED = 20.0 kmh
Expected Outcomes
Input: Raw GPS tracking data with noise
Output: Clean, meaningful walking sessions representing actual outdoor movement
Filtered Out: Local movement, GPS drift, brief indoor walking
Captured: Genuine walking sessions with proper start/stop detection
This system provides parents with meaningful movement insights rather than noisy location data!
