# Swastha Aur Abhiman

A comprehensive digital ecosystem for health, education, and training services built for government outreach programs.

## 🎯 Project Overview

**Swastha Aur Abhiman** is a full-stack application designed to bridge the gap between citizens and essential services including medical advice, educational resources, and vocational training. The platform emphasizes Post-COVID recovery strategies and traditional knowledge of herbal remedies.

## 🏗️ System Architecture

### Technology Stack

#### Backend
- **Framework**: NestJS (Node.js + TypeScript)
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT (JSON Web Tokens)
- **Real-time**: Socket.io for WebSockets
- **Storage**: AWS S3 / MinIO

#### Frontend
- **Mobile**: Flutter (Dart)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive

## 📁 Project Structure

```
swasth-aur-abhiman/
├── backend/                    # NestJS Backend API
│   ├── src/
│   │   ├── auth/              # Authentication module
│   │   ├── users/             # User management
│   │   ├── admin/             # ✨ Admin dashboard & content management
│   │   ├── doctor/            # ✨ Doctor dashboard & patient management
│   │   ├── education/         # ✨ Teacher dashboard & NCERT content
│   │   ├── health/            # ✨ Health metrics tracking & analysis
│   │   ├── media/             # Media content & file upload services
│   │   ├── notifications/     # ✨ Real-time notification system
│   │   ├── nutrition/         # Nutrition & diet plans
│   │   ├── skills/            # ✨ Skills training & certification
│   │   ├── events/            # Events management
│   │   ├── prescriptions/     # Medical prescriptions
│   │   ├── chat/              # Real-time chat
│   │   └── common/            # Shared utilities
│   ├── docker-compose.yml     # Docker services
│   └── package.json
│
├── admin-dashboard/            # ✨ React Admin Web App
│   ├── src/
│   │   ├── components/        # UI components
│   │   ├── pages/             # Dashboard & login pages
│   │   ├── lib/               # API client
│   │   └── store/             # State management
│   ├── package.json
│   └── README.md
│
├── mobile-app/                 # Flutter Mobile App
│   ├── lib/
│   │   ├── core/              # Core functionality
│   │   ├── features/          # Feature modules
│   │   └── widgets/           # ✨ Reusable UI components
│   ├── pubspec.yaml
│   └── README.md
│
└── docs/                       # Documentation
    ├── plan.md
    ├── product_requirements_document.md
    ├── structure.md
    ├── system_architecture.md
    ├── API_INTEGRATION_GUIDE.md         # ✨ Complete API documentation
    ├── FILE_UPLOAD_API.md               # ✨ File upload & storage guide
    ├── IMPLEMENTATION_SUMMARY.md        # ✨ Feature implementation details
    └── PROJECT_STATUS.md                # ✨ Current project status

✨ = Recently implemented
```

## 👥 User Roles

1. **ADMIN** - System administration and content management
2. **USER** - Citizens/applicants accessing services
3. **DOCTOR** - Medical professionals providing consultations
4. **TEACHER** - Educators providing learning resources
5. **TRAINER** - Skill development experts

## 🎉 Recent Accomplishments

### Backend Implementation (100% Complete)
- ✅ **Admin Module**: Complete CRUD operations for all content types
- ✅ **Doctor Module**: Patient management, prescription reviews, health monitoring
- ✅ **Teacher Module**: Dashboard with analytics, lesson planning, student progress
- ✅ **Health Module**: Comprehensive health metrics tracking with AI analysis
- ✅ **Skills Module**: Enrollment system with certification automation
- ✅ **Notifications Module**: Real-time notification system with WebSocket support
- ✅ **File Upload**: Dual storage system (local + AWS S3/MinIO)
- ✅ **Cloud Storage**: Complete S3/MinIO integration with CDN support

### Frontend Implementation
- ✅ **Admin Dashboard**: Full-featured React web application
- ✅ **Authentication**: Login with JWT and session management
- ✅ **Content Management**: Upload, edit, delete media content
- ✅ **User Management**: Admin controls for user activation/deactivation
- ✅ **Analytics Dashboard**: Charts and statistics for content performance
- ✅ **File Upload UI**: Drag-and-drop with progress indicators
- ✅ **Storage Settings**: Toggle between local and cloud storage

### Mobile App Screens
- ✅ **Video Player Screen**: Full-featured video playback with controls
- ✅ **Health Metrics Screen**: Track and visualize health data
- ✅ **Notifications Screen**: View and manage notifications
- ✅ **Nutrition Screen**: Browse diet plans and recipes
- ✅ **Skills Hub Screen**: Enroll and track skill training progress

### Database & Architecture
- ✅ **32+ Entity Models**: Complete database schema implementation
- ✅ **TypeORM Integration**: Full ORM setup with migrations
- ✅ **Indexing & Optimization**: Performance-optimized queries
- ✅ **Relationship Mapping**: Complex many-to-many and one-to-many relations

### DevOps & Infrastructure
- ✅ **Docker Setup**: Multi-container orchestration
- ✅ **Environment Configuration**: Comprehensive .env setup
- ✅ **Storage Flexibility**: Easy switching between storage backends
- ✅ **Error Handling**: Robust error handling and validation
- ✅ **API Documentation**: Complete endpoint documentation

### Code Quality
- ✅ **TypeScript**: 100% TypeScript for type safety
- ✅ **DTOs & Validation**: Input validation with class-validator
- ✅ **Guards & Decorators**: Custom authentication guards
- ✅ **Service Architecture**: Clean separation of concerns
- ✅ **Modular Design**: Feature-based module organization

## ✨ Key Features

### 🏥 Medical Services
- ✅ **Health Metrics Tracking**: Complete system for BP, Blood Sugar, BMI, Weight, Temperature, Pulse
- ✅ **Health Sessions**: Record complete health check sessions with all vitals
- ✅ **Health Analysis**: Automatic condition evaluation (normal, elevated, high, critical)
- ✅ **Health Recommendations**: AI-powered health advice based on metrics
- ✅ **Doctor Dashboard**: Patient management, prescription review, activity feeds
- ✅ **Prescription Management**: Upload, review, and track prescriptions
- ✅ **Patient-Doctor Chat**: Real-time communication between patients and doctors
- Post-COVID recovery guidance (in progress)
- Herbal remedies information (in progress)

### 📚 Education Hub
- ✅ **NCERT Content**: Complete integration for Class 1-12 books and resources
- ✅ **Teacher Dashboard**: Content management, analytics, and student progress tracking
- ✅ **Subject & Chapter Organization**: Structured content by class, subject, and chapter
- ✅ **Content Analytics**: View counts, ratings, and engagement metrics
- ✅ **Lesson Plans**: Create and manage comprehensive lesson plans
- Educational videos (in progress)
- Interactive learning resources (planned)

### 🛠️ Skills Training
- ✅ **Skill Categories**: Bamboo work, Honeybee farming, Jute work, Macrame, Artisan training
- ✅ **Course Enrollment**: Track student enrollments and progress
- ✅ **Skill Progress Tracking**: Monitor completion percentage and milestones
- ✅ **Certification System**: Automatic certificate issuance upon completion
- ✅ **Trainer Dashboard**: Manage trainees, track progress, view analytics
- ✅ **Skill Assessments**: Quiz and evaluation system
- Video tutorials (in progress)

### 🥗 Nutrition
- ✅ **Nutrition Content Management**: Diet plans, recipes, wellness guides
- ✅ **Post-COVID Nutrition**: Specialized dietary guidance for recovery
- ✅ **Nutrition Entities**: Complete database schema for nutrition content
- Traditional food wisdom (in progress)

### 📅 Events
- ✅ **Event Management**: Create, update, and delete events
- ✅ **Event Types**: Health camps, training workshops, education programs
- ✅ **Event Registration**: Track participants and attendance
- ✅ **Assignment Notifications**: Automatic alerts for new assignments
- Community event listings (in progress)

### 💬 Communication
- ✅ **Real-time Chat**: Socket.io powered instant messaging
- ✅ **Multi-Role Chat**: User ↔ Doctor/Teacher/Trainer messaging
- ✅ **Chat Rooms**: Group discussions and private conversations
- ✅ **Message Notifications**: Real-time alerts for new messages
- ✅ **Media Sharing**: Share images and files in chat
- Video calls (planned)

### 🔔 Notifications
- ✅ **Real-time Notifications**: WebSocket-based instant alerts
- ✅ **Notification Types**: Health alerts, prescriptions, messages, assignments, certifications
- ✅ **Notification History**: 30-day retention with search and filtering
- ✅ **Read/Unread Tracking**: Mark notifications as read
- ✅ **Broadcast Notifications**: System-wide announcements
- Push notifications (planned)

### 🎛️ Admin Dashboard
- ✅ **Web-based Admin Panel**: React application for administrators
- ✅ **Media Management**: Upload, edit, delete, and organize content
- ✅ **User Management**: Activate/deactivate users, role management
- ✅ **Content Analytics**: Views, ratings, engagement statistics
- ✅ **File Upload System**: Support for videos, images, documents
- ✅ **Cloud Storage Integration**: AWS S3/MinIO support with local fallback
- ✅ **Bulk Operations**: Batch upload and CSV export
- ✅ **Storage Backend Switching**: Toggle between local and cloud storage

### 📤 File Management
- ✅ **Local File Storage**: Upload files to local server storage
- ✅ **Cloud Storage**: AWS S3 and MinIO-compatible storage
- ✅ **Dual Storage Mode**: Seamlessly switch between local and cloud
- ✅ **Thumbnail Generation**: Automatic thumbnail creation for media
- ✅ **File Type Validation**: Support for videos, images, PDFs
- ✅ **Size Limits**: Configurable file size restrictions (500MB for videos)
- ✅ **CDN Support**: CloudFront distribution integration

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- Flutter SDK 3.0+
- Docker & Docker Compose
- PostgreSQL 15+

### Quick Start

#### 1. Setup Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
docker-compose up -d
npm run start:dev
```

Backend will run at: `http://localhost:3000/api`

#### 2. Setup Admin Dashboard
```bash
cd admin-dashboard
npm install
cp .env.example .env
# Edit .env with API URL
npm start
```

Admin dashboard will run at: `http://localhost:3001`

#### 3. Setup Mobile App
```bash
cd mobile-app
flutter pub get
# Update API URL in lib/core/constants/app_constants.dart
flutter run
```

### Development Workflow

1. **Database Setup**
   ```bash
   cd backend
   docker-compose up -d
   ```

2. **Backend Development**
   ```bash
   cd backend
   npm run start:dev
   ```

3. **Admin Dashboard Development**
   ```bash
   cd admin-dashboard
   npm start
   ```

4. **Mobile Development**
   ```bash
   cd mobile-app
   flutter run --debug
   ```

## 📖 Documentation

Detailed documentation is available in the `docs/` directory and root:

### Core Documentation
- [Product Requirements Document](docs/product_requirements_document.md) - Complete product specification
- [System Architecture](docs/system_architecture.md) - Technical architecture details
- [Sprint Plan](docs/plan.md) - Development sprint planning
- [Project Structure](docs/structure.md) - Codebase organization

### Implementation Guides
- [API Integration Guide](API_INTEGRATION_GUIDE.md) - Complete API endpoint documentation
- [File Upload API](FILE_UPLOAD_API.md) - File upload and storage implementation
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Feature-by-feature implementation details
- [Backend Compilation Fixes](BACKEND_COMPILATION_FIXES.md) - TypeScript compilation troubleshooting
- [Notification Integration](backend/src/notifications/NOTIFICATION_INTEGRATION_GUIDE.md) - Notification system integration

### Project Status
- [Project Status](PROJECT_STATUS.md) - Current development status and progress
- [Remaining Tasks](REMAINING_TASKS_IMPLEMENTATION.md) - Pending features and enhancements

## 🔒 Security

- JWT-based authentication
- Role-based access control (RBAC)
- Secure file storage (S3)
- Encrypted API communication
- Password hashing with bcrypt

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm run test
npm run test:e2e
```

### Mobile Tests
```bash
cd mobile-app
flutter test
```

## 📊 Database Schema

### Core Entities
- **Users**: Authentication and profile management
- **User Profiles**: Detailed user information and preferences
- **Doctor Profiles**: Medical credentials and specializations
- **Teacher Profiles**: Educational background and subjects
- **Trainer Profiles**: Expertise areas and certifications

### Health & Medical
- **Health Metrics**: BP, blood sugar, BMI, weight, temperature, pulse tracking
- **Health Metric Sessions**: Complete health check records
- **Prescriptions**: Medical prescriptions with status tracking

### Education & Training
- **Media Content**: Videos, documents, and educational materials
- **Skill Enrollments**: Student skill course enrollments
- **Skill Progress**: Course completion tracking
- **Lesson Plans**: Teacher-created lesson plans

### Communication
- **Chat Rooms**: One-on-one and group chat rooms
- **Messages**: Real-time chat messages with media support
- **Notifications**: System-wide notification tracking

### Events & Nutrition
- **Events**: Community events, assignments, and activities
- **Nutrition**: Diet plans, recipes, and wellness content

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get current user profile

### Admin Endpoints
- `POST /admin/media/upload` - Upload media content
- `POST /admin/media/upload-file` - Upload with file
- `POST /admin/media/bulk-upload` - Bulk media upload
- `GET /admin/media` - Get all media with filters
- `PUT /admin/media/:id` - Update media content
- `DELETE /admin/media/:id` - Soft delete media
- `GET /admin/analytics` - Dashboard analytics
- `GET /admin/users` - User management
- `POST /admin/events` - Create events

### Doctor Endpoints
- `GET /doctor/patients` - Get patient list
- `GET /doctor/patients/:id` - Patient details with health records
- `GET /doctor/patients/:id/health-summary` - Patient health summary
- `GET /doctor/patients/:id/metrics` - Patient metrics history
- `GET /doctor/prescriptions` - Get all prescriptions
- `POST /doctor/prescriptions/:id/notes` - Add prescription notes
- `PUT /doctor/prescriptions/:id/status` - Update prescription status
- `GET /doctor/dashboard` - Doctor dashboard overview

### Teacher Endpoints
- `GET /teacher/dashboard` - Teacher dashboard overview
- `GET /teacher/classes` - Get all classes
- `GET /teacher/classes/:classLevel/subjects` - Subjects for a class
- `GET /teacher/classes/:classLevel/subjects/:subject/chapters` - Chapter content
- `POST /teacher/lesson-plans` - Create lesson plan
- `GET /teacher/content/:contentId/progress` - Student progress
- `GET /teacher/analytics` - Teaching analytics
- `GET /teacher/export/csv` - Export content data

### Health Endpoints
- `POST /health/metrics` - Record health metric
- `GET /health/metrics` - Get user's health metrics
- `GET /health/metrics/latest` - Latest metrics for all types
- `GET /health/summary` - Health summary with trends
- `GET /health/metrics/range` - Metrics for date range
- `GET /health/recommendations` - Health recommendations
- `POST /health/sessions` - Record complete health session
- `GET /health/sessions` - Get health sessions
- `POST /health/analyze/bp` - Analyze blood pressure
- `POST /health/analyze/blood-sugar` - Analyze blood sugar
- `POST /health/analyze/bmi` - Analyze BMI

### Skills & Training Endpoints
- `POST /skills/enroll` - Enroll in skill training
- `GET /skills/my-enrollments` - User's enrollments
- `GET /skills/enrollment/:id/progress` - Enrollment progress
- `POST /skills/progress/:id/complete` - Mark course complete
- `GET /skills/certificates` - User's certificates
- `GET /trainer/trainees` - Get all trainees
- `GET /trainer/dashboard` - Trainer dashboard
- `GET /trainer/analytics` - Training analytics

### Notifications Endpoints
- `GET /notifications` - Get user notifications
- `GET /notifications/unread` - Get unread notifications
- `PATCH /notifications/:id/read` - Mark notification as read
- `PATCH /notifications/mark-all-read` - Mark all as read
- `DELETE /notifications/:id` - Delete notification

### Media & Content
- `GET /media` - Get all media content
- `GET /media/:id` - Get media by ID
- `POST /media` - Create media content (Admin)
- `PATCH /media/:id` - Update media content
- `DELETE /media/:id` - Delete media content

### Prescriptions
- `POST /prescriptions` - Upload prescription
- `GET /prescriptions` - Get user's prescriptions
- `PATCH /prescriptions/:id/review` - Review prescription (Doctor)

### Chat
- `POST /chat/rooms` - Create chat room
- `GET /chat/rooms` - Get user's chat rooms
- `GET /chat/rooms/:id/messages` - Get messages
- `POST /chat/rooms/:id/messages` - Send message
- `WebSocket /chat` - Real-time chat connection

### Events
- `GET /events` - Get all events
- `GET /events/:id` - Get event details
- `POST /events` - Create event (Admin/Teacher)
- `PUT /events/:id` - Update event
- `DELETE /events/:id` - Delete event

## 🔄 Development Roadmap

### ✅ Sprint 1: Foundation (COMPLETED)
- [x] Database setup with PostgreSQL & TypeORM
- [x] Authentication system with JWT
- [x] User management with role-based access
- [x] Basic Flutter UI screens
- [x] Docker configuration

### ✅ Sprint 2: Core Features (COMPLETED)
- [x] Admin dashboard (React web app)
- [x] Media upload functionality (local & cloud)
- [x] Event management system
- [x] Content tagging and organization
- [x] Health metrics tracking system
- [x] Prescription management
- [x] Real-time notification system

### ✅ Sprint 3: Role-Specific Dashboards (COMPLETED)
- [x] Doctor dashboard with patient management
- [x] Teacher dashboard with content analytics
- [x] Trainer dashboard for skill training
- [x] Health analysis and recommendations
- [x] Skills enrollment and progress tracking
- [x] Certificate generation system

### ✅ Sprint 4: Advanced Features (COMPLETED)
- [x] Real-time chat with Socket.io
- [x] File upload with S3/MinIO integration
- [x] Storage backend switching (local/cloud)
- [x] Bulk upload operations
- [x] Analytics and reporting
- [x] CSV export functionality
- [x] Notification integration across modules

### 🚧 Sprint 5: Mobile App Enhancement (IN PROGRESS)
- [ ] Video player screen implementation
- [ ] Health metrics visualization
- [ ] Skills hub with progress tracking
- [ ] Nutrition recommendation engine
- [ ] Enhanced chat UI with media preview
- [ ] Offline data caching
- [ ] Push notifications (FCM)

### 📋 Sprint 6: Polish & Production (PLANNED)
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Load testing and scaling
- [ ] Comprehensive testing suite
- [ ] Production deployment setup
- [ ] User documentation
- [ ] Admin training materials
- [ ] API rate limiting
- [ ] Monitoring and logging

### 🎯 Future Enhancements
- [ ] Video calling for doctor consultations
- [ ] AI-powered health recommendations
- [ ] Multilingual support (Hindi, regional languages)
- [ ] Mobile app for doctors and teachers
- [ ] Advanced analytics dashboard
- [ ] Integration with government health systems
- [ ] SMS notifications for low-bandwidth users
- [ ] Offline-first mobile app capabilities

## 🤝 Contributing

1. Follow the existing code style
2. Write tests for new features
3. Update documentation
4. Create meaningful commit messages
5. Submit pull requests for review

## 📝 Environment Variables

### Backend (.env)
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=swastha_aur_abhiman

# JWT Authentication
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# AWS S3 / Cloud Storage (Optional)
ENABLE_CLOUD_STORAGE=false
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name
CLOUDFRONT_DOMAIN=your-cdn-domain.cloudfront.net

# MinIO Configuration (Alternative to AWS S3)
USE_MINIO=false
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin

# Server Configuration
PORT=3000
NODE_ENV=development

# File Upload Limits
MAX_FILE_SIZE=524288000  # 500MB in bytes
MAX_FILES_PER_UPLOAD=10

# CORS Configuration
CORS_ORIGIN=http://localhost:3001,http://localhost:8080
```

### Admin Dashboard (.env)
```env
REACT_APP_API_URL=http://localhost:3000/api
REACT_APP_WS_URL=http://localhost:3000
```

### Mobile App (app_constants.dart)
```dart
static const String baseUrl = 'http://localhost:3000/api';
static const String wsUrl = 'http://localhost:3000';

// For Android Emulator, use:
// static const String baseUrl = 'http://10.0.2.2:3000/api';

// For iOS Simulator, use:
// static const String baseUrl = 'http://localhost:3000/api';

// For Physical Device, use your computer's IP:
// static const String baseUrl = 'http://192.168.x.x:3000/api';
```

## 🐛 Troubleshooting

### Backend Issues
- **Port 3000 in use**: Change PORT in .env or kill existing process
  ```bash
  # Windows
  netstat -ano | findstr :3000
  taskkill /PID <PID> /F
  
  # Linux/Mac
  lsof -ti:3000 | xargs kill -9
  ```
- **Database connection**: Verify PostgreSQL is running
  ```bash
  docker ps  # Check if postgres container is running
  docker-compose up -d  # Start services
  ```
- **Module not found**: Run `npm install` and restart server
- **TypeScript errors**: Check `tsconfig.json` and run `npm run build`
- **File upload errors**: Verify `uploads/` directory exists and has write permissions
- **Cloud storage errors**: Check AWS/MinIO credentials in .env

### Admin Dashboard Issues
- **API connection failed**: Verify `REACT_APP_API_URL` in .env matches backend URL
- **CORS errors**: Add frontend URL to backend CORS configuration
- **Build errors**: Clear cache with `rm -rf node_modules package-lock.json && npm install`
- **Login issues**: Check JWT_SECRET matches between frontend and backend

### Mobile Issues
- **Build errors**: Run `flutter clean && flutter pub get`
- **API connection**: Check baseUrl in constants
  - Android Emulator: `http://10.0.2.2:3000/api`
  - iOS Simulator: `http://localhost:3000/api`
  - Physical Device: `http://<YOUR_IP>:3000/api`
- **Emulator issues**: Use correct IP address for your platform
- **WebSocket connection**: Ensure firewall allows WebSocket connections
- **Hot reload not working**: Restart Flutter app or run `flutter clean`

### Database Issues
- **Migration errors**: Run `npm run migration:run` in backend
- **Connection refused**: Check PostgreSQL is running on correct port
- **Data inconsistency**: Clear database and run migrations from scratch
  ```bash
  docker-compose down -v  # Remove volumes
  docker-compose up -d    # Recreate database
  npm run migration:run   # Run migrations
  ```

### Storage Issues
- **Local storage full**: Check disk space and clean old uploads
- **Cloud upload timeout**: Increase timeout in cloud-storage.service.ts
- **Permission denied**: Check file/directory permissions for uploads folder
- **S3 access denied**: Verify IAM permissions and bucket policy

## 📄 License

This project is licensed under UNLICENSED.

## 👨‍💻 Development Team

Built with ❤️ for government health and education initiatives.

## 📧 Contact & Support

For questions, issues, or contributions, please contact the development team.

---

**Note**: This is a government project aimed at improving access to healthcare, education, and vocational training services for underserved communities.