# API Integration Quick Start

This guide helps you quickly integrate the backend APIs with the Flutter frontend.

## Backend API Base URL

Update this in your Flutter app:

```dart
// lib/core/constants/api_constants.dart

const String API_BASE_URL = 'http://localhost:3000/api';
// For production: const String API_BASE_URL = 'https://api.swastha.com/api';
```

## 1. Health Metrics Integration

### Backend Endpoints

```
POST   /health/metrics                    - Record metric
GET    /health/metrics/:type              - Get metrics by type
GET    /health/summary                    - Get latest metrics + trends
GET    /health/trends?days=30             - Get trend data for chart
GET    /health/recommendations            - Get health advice
```

### Flutter Integration

```dart
// lib/features/medical/providers/health_provider.dart

final healthMetricsProvider = FutureProvider<List<HealthMetric>>((ref) async {
  final response = await Dio().get(
    '$API_BASE_URL/health/metrics?type=BP_SYSTOLIC&limit=30'
  );
  return (response.data['data'] as List)
    .map((item) => HealthMetric.fromJson(item))
    .toList();
});

// Recording a metric
ref.read(authProvider).then((auth) async {
  await Dio().post(
    '$API_BASE_URL/health/metrics',
    data: {
      'metricType': 'BP_SYSTOLIC',
      'value': 120,
      'unit': 'mmHg',
    },
    options: Options(
      headers: {'Authorization': 'Bearer ${auth.token}'},
    ),
  );
});
```

## 2. Skills Module Integration

### Backend Endpoints

```
GET    /skills/categories                 - Get all skill categories
GET    /skills/:categoryId/content        - Get courses (page, limit)
POST   /skills/enroll/:skillCategory      - Enroll in skill
GET    /skills/my-enrollments             - Get user's enrollments
POST   /skills/enrollment/:id/record-progress  - Log video watch
GET    /skills/:skillCategory/leaderboard  - Get top performers
```

### Flutter Integration

```dart
// lib/features/skills/providers/skills_provider.dart

final skillCategoriesProvider = FutureProvider((ref) async {
  final response = await Dio().get('$API_BASE_URL/skills/categories');
  return (response.data as List)
    .map((item) => SkillCategory.fromJson(item))
    .toList();
});

// Record video progress
await Dio().post(
  '$API_BASE_URL/skills/enrollment/$enrollmentId/record-progress',
  data: {
    'courseId': courseId,
    'courseTitle': title,
    'videoUrl': url,
    'watchedDurationSeconds': currentPosition.inSeconds,
    'totalDurationSeconds': duration.inSeconds,
  },
);
```

## 3. Nutrition Module Integration

### Backend Endpoints

```
POST   /nutrition/plans                   - Create nutrition plan
GET    /nutrition/plans/active            - Get current plan
POST   /nutrition/logs/meal               - Log a meal
GET    /nutrition/logs/today              - Get today's meals + totals
GET    /nutrition/summary?days=7          - Get 7-day stats
GET    /nutrition/recipes/popular         - Get popular recipes
GET    /nutrition/post-covid/tips         - Get recovery tips
```

### Flutter Integration

```dart
// lib/features/nutrition/providers/nutrition_provider.dart

final nutritionPlanProvider = FutureProvider((ref) async {
  final response = await Dio().get(
    '$API_BASE_URL/nutrition/plans/active'
  );
  return NutritionPlan.fromJson(response.data);
});

// Log meal
await Dio().post(
  '$API_BASE_URL/nutrition/logs/meal',
  data: {
    'mealType': 'BREAKFAST',
    'foodItem': 'Oatmeal with milk',
    'estimatedCalories': 350,
    'proteinGrams': 10,
  },
);
```

## 4. Doctor Module Integration

### Backend Endpoints

```
GET    /doctor/patients                   - Get patient list
GET    /doctor/patients/:id               - Get patient details
GET    /doctor/patients/:id/prescriptions - Get patient's prescriptions
POST   /doctor/prescriptions/:id/notes    - Add notes to prescription
GET    /doctor/patients/:id/activity-feed - Get patient activity
```

### Flutter Integration

```dart
// For doctor app - lib/features/doctor/providers/doctor_provider.dart

final doctorPatientsProvider = FutureProvider((ref) async {
  final response = await Dio().get('$API_BASE_URL/doctor/patients');
  return (response.data['data'] as List)
    .map((item) => Patient.fromJson(item))
    .toList();
});
```

## 5. Notifications Integration

### Backend Endpoints

```
GET    /notifications                     - Get notifications
GET    /notifications/unread-count        - Get unread count
POST   /notifications/:id/read            - Mark as read
DELETE /notifications/:id                 - Delete notification
SSE    /notifications/stream              - Real-time SSE stream
```

### Flutter Integration - WebSocket/SSE

```dart
// lib/features/notifications/providers/notification_provider.dart

final notificationStreamProvider = StreamProvider<NotificationItem>((ref) async* {
  final token = ref.watch(authTokenProvider).value;
  final uri = Uri.parse('http://localhost:3000/notifications/stream');
  
  try {
    final client = http.Client();
    final request = http.Request('GET', uri)
      ..headers['Authorization'] = 'Bearer $token';
    
    final response = await client.send(request);
    await for (String line in response.stream.transform(utf8.decoder).transform(LineSplitter())) {
      if (line.startsWith('data: ')) {
        final json = jsonDecode(line.substring(6));
        yield NotificationItem.fromJson(json);
      }
    }
  } catch (e) {
    print('Error: $e');
  }
});

// Listen to notifications in UI
ref.listen(notificationStreamProvider, (previous, next) {
  next.whenData((notification) {
    showNotificationToast(context, notification);
  });
});
```

## 6. Authentication Headers

All authenticated endpoints require Bearer token:

```dart
// lib/core/interceptors/auth_interceptor.dart

Dio dio = Dio();

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = ref.read(authTokenProvider);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

## 7. Common Response Format

All API responses follow this format:

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

Or for paginated responses:

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

## 8. Testing Endpoints

### Using cURL

```bash
# Record a health metric
curl -X POST http://localhost:3000/health/metrics \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "metricType": "BP_SYSTOLIC",
    "value": 120,
    "unit": "mmHg"
  }'

# Get notifications
curl -X GET http://localhost:3000/notifications \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Using Postman

1. Create Bearer token in Authorization tab
2. Set `{{API_BASE_URL}}` as environment variable
3. Import endpoints for testing
4. Use form-data for file uploads (admin media)

## 9. Common Issues & Solutions

### CORS Error
```
Solution: Add to NestJS main.ts:
app.enableCors({
  origin: 'http://localhost:3000',
  credentials: true,
});
```

### 401 Unauthorized
- Check token expiration
- Verify Bearer token format
- Confirm JWT secret matches

### 404 Not Found
- Verify API_BASE_URL is correct
- Check endpoint path matches exactly
- Ensure module is registered in app.module.ts

### Network Timeout
- Increase Dio timeout: `Dio().connectTimeout = Duration(seconds: 30)`
- Check backend is running
- Verify network connectivity

## 10. Next Steps

1. ✅ Copy `API_BASE_URL` and update in constants
2. ✅ Create Dio instance with interceptors
3. ✅ Update each provider with API calls
4. ✅ Test each endpoint with sample data
5. ✅ Setup error handling and retry logic
6. ✅ Configure real-time notifications (SSE/WebSocket)
7. ✅ Add loading and error states to UI
8. ✅ Setup caching strategy for offline support

---

## Environment Variables

Create `.env` file in backend root:

```
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=swastha_db
JWT_SECRET=your_jwt_secret_key
REDIS_URL=redis://localhost:6379
S3_BUCKET=swastha-media
S3_REGION=us-east-1
NODE_ENV=development
```

---

For detailed API documentation, see backend/README.md
