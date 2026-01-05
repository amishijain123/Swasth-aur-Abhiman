# Chat Functionality Troubleshooting Guide

## Overview
This guide helps troubleshoot issues with the real-time chat system in Swastha Aur Abhiman. The chat system should work between all user roles: Doctor-Patient, Teacher-Student, Trainer-Trainee, and User-User.

## Common Issues & Solutions

### Issue 1: Chat Window Doesn't Appear After Selecting Contact

**Symptoms:**
- User clicks on a contact to start chat
- No chat window appears
- No error message shown

**Root Causes & Solutions:**

1. **API Connection Issue**
   - Check that backend is running: `npm run start:dev` in backend folder
   - Verify API URL in mobile app `lib/core/constants/app_constants.dart`
   - Ensure `REACT_APP_API_URL` matches backend URL
   
   ```dart
   // For local development
   static const String baseUrl = 'http://localhost:3000/api';
   
   // For Android Emulator
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   
   // For physical device (replace with your IP)
   static const String baseUrl = 'http://192.168.1.100:3000/api';
   ```

2. **Chat Room Creation Failure**
   - Check backend logs for errors:
     ```bash
     # In backend directory
     npm run start:dev
     # Look for error messages related to chat/rooms
     ```
   - Verify both users are active in the database
   - Check that JWT token is valid

3. **Missing Error Messages**
   - Enable verbose logging in Flutter:
     ```bash
     flutter run -v
     ```
   - Check device logs for network errors
   - Verify internet connection is active

### Issue 2: Contact List is Empty

**Symptoms:**
- "No contacts available" message appears
- Contact loading shows but doesn't populate

**Solutions:**

1. **Check User Role Filter**
   - Make sure "All" filter is selected, not a specific role
   - Verify there are actually users with different roles in the system
   
2. **Backend Database Check**
   - Verify users exist in database:
     ```bash
     # In backend container/psql
     SELECT id, fullName, role, isActive FROM "user" LIMIT 10;
     ```
   - Check that `isActive = true` for the user
   
3. **API Response Issue**
   - Check `/chat/contacts` endpoint is working:
     ```bash
     curl http://localhost:3000/api/chat/contacts \
       -H "Authorization: Bearer YOUR_JWT_TOKEN"
     ```
   - Should return array of available contacts
   - If empty, create test users with different roles

### Issue 3: Messages Not Being Sent/Received

**Symptoms:**
- Message input allows text but doesn't send
- Messages disappear after sending
- WebSocket connection issues

**Solutions:**

1. **WebSocket Connection**
   - Verify WebSocket is connecting:
     ```bash
     # Check in browser console or Flutter logs
     # Should see: "Socket connected" message
     ```
   - Check CORS configuration in backend:
     ```typescript
     @WebSocketGateway({
       cors: {
         origin: '*', // For development only
       },
     })
     ```

2. **Message Validation**
   - Verify message content is not empty
   - Check message type is valid: TEXT, IMAGE, AUDIO, FILE
   - Verify roomId is valid

3. **Backend Logs**
   - Check for message errors:
     ```bash
     npm run start:dev
     # Look for "sendMessage" error logs
     ```

### Issue 4: Chat Works Only for Doctor-Patient

**Symptoms:**
- Can chat with doctor as patient
- Cannot chat with teacher/trainer
- Other roles don't have chat windows

**Solutions:**

1. **Verify All Screens Have Chat Integration**
   - Doctor Screen: ✅ Implemented (`patients_screen.dart`)
   - Teacher Screen: ❌ Not yet implemented
   - Trainer Screen: ❌ Not yet implemented
   - User Screen: ✅ Chat from main chat list

2. **Add Chat to Missing Screens**
   
   For Teacher to Student chat:
   ```dart
   // In teacher_dashboard_screen.dart
   // Add similar button to create chat with student
   ElevatedButton.icon(
     onPressed: () async {
       final room = await ref.read(chatProvider.notifier)
           .createDirectChat(studentId, studentName);
       if (room != null && mounted) {
         Navigator.push(context,
           MaterialPageRoute(builder: (_) => ChatRoomScreen(room: room)));
       }
     },
     icon: const Icon(Icons.message),
     label: const Text('Message Student'),
   )
   ```

3. **Check Role-Based Access**
   - Ensure all roles can access `/chat` route
   - Verify JWT includes user role
   - Check that no role-specific restrictions block chat

### Issue 5: Old Chat Messages Not Showing

**Symptoms:**
- Chat opens but no previous messages visible
- Only new messages appear
- Message history is lost

**Solutions:**

1. **Chat Room Not Loading Previous Messages**
   - Verify `loadMessages` is called:
     ```dart
     @override
     void initState() {
       super.initState();
       WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(chatProvider.notifier).loadMessages(widget.room.id);
       });
     }
     ```

2. **Database Query Issue**
   - Check if messages are being saved:
     ```bash
     # In psql
     SELECT * FROM message WHERE "roomId" = 'ROOM_ID' ORDER BY "createdAt";
     ```
   - If empty, messages weren't saved properly

3. **Pagination Issue**
   - Messages are loaded page by page
   - Scroll to bottom to load more messages
   - Check `getRoomMessages` API response

### Issue 6: Real-Time Updates Not Working

**Symptoms:**
- Messages sent by other user don't appear immediately
- Must refresh to see new messages
- WebSocket events not triggering

**Solutions:**

1. **WebSocket Registration**
   - Ensure user registers with socket:
     ```dart
     // In chat_room_screen.dart
     // Should emit 'register' event with userId
     ```
   - Check socket is joining room:
     ```dart
     // Should emit 'joinRoom' with roomId
     ```

2. **Event Handling**
   - Verify `onNewMessage` is called in provider
   - Check that UI listens to state changes
   - Ensure Riverpod watchers are active

3. **Network Issues**
   - Check firewall allows WebSocket
   - Verify no proxy blocks WebSocket upgrade
   - Test on different network

## Testing Checklist

Before reporting issues, verify:

- [ ] Backend is running (`npm run start:dev`)
- [ ] PostgreSQL database is accessible
- [ ] Redis is running (for caching)
- [ ] API URLs are correctly configured
- [ ] Users exist with different roles
- [ ] JWT token is valid and includes user data
- [ ] Network allows WebSocket connections
- [ ] Test with multiple devices/simulators

## Debugging Commands

### Backend Debugging

```bash
# Start backend with verbose logging
npm run start:dev

# Test chat endpoints
curl http://localhost:3000/api/chat/rooms \
  -H "Authorization: Bearer YOUR_TOKEN"

# Check database
docker-compose exec postgres psql -U postgres -d swastha_aur_abhiman
SELECT COUNT(*) FROM "chat_room";
SELECT COUNT(*) FROM message;
```

### Mobile Debugging

```bash
# Run with verbose output
flutter run -v

# Check device logs
adb logcat | grep flutter

# For iOS
tail -f ~/Library/Logs/com.apple.CoreSimulator.CoreSimulatorService.log
```

### Frontend (Admin) Debugging

```bash
# Open browser console (F12)
# Check Network tab for API calls
# Verify WebSocket connection in WS tab

# Test API
fetch('http://localhost:3000/api/chat/contacts', {
  headers: { 'Authorization': 'Bearer TOKEN' }
}).then(r => r.json()).then(console.log)
```

## Role-Based Chat Matrix

| From Role | To Role | Status | Notes |
|-----------|---------|--------|-------|
| USER | DOCTOR | ✅ Works | User initiates via chat list |
| DOCTOR | USER | ✅ Works | Doctor initiates from patients screen |
| USER | TEACHER | ✅ Works | User initiates via chat list |
| TEACHER | USER | ⚠️ Partial | Need to implement in teacher screen |
| USER | TRAINER | ✅ Works | User initiates via chat list |
| TRAINER | USER | ⚠️ Partial | Need to implement in trainer screen |
| USER | USER | ✅ Works | User initiates via chat list |
| DOCTOR | DOCTOR | ✅ Works | Inter-doctor consultation |
| TEACHER | TEACHER | ✅ Works | Inter-teacher collaboration |

## Implementation Status

### Completed ✅
- Backend chat service (all roles supported)
- Chat list screen for users
- Chat room screen with messages
- WebSocket integration
- Message persistence
- Chat from doctor screen

### In Progress 🔄
- Chat UI improvements
- Message search functionality
- File/image sharing in chat
- Voice messages

### Planned 📋
- Video calling
- Message reactions
- Chat groups
- Chat notifications customization
- Chat message encryption

## Getting Help

If issues persist after trying these solutions:

1. **Collect Logs**
   ```bash
   # Collect backend logs
   npm run start:dev > backend.log 2>&1
   
   # Collect mobile logs
   flutter run -v > mobile.log 2>&1
   ```

2. **Check API Response**
   - Use Postman or curl to test endpoints
   - Verify response format matches expected DTOs
   - Check status codes (200, 201, 400, 401, 404, 500)

3. **Verify Database State**
   - Check users, chat_room, and message tables
   - Verify foreign key relationships
   - Check for orphaned data

4. **Report Issue**
   - Include relevant logs from all components
   - Specify which roles are having issues
   - Note exact steps to reproduce
   - Include error messages and stack traces

## Performance Optimization

For better chat performance:

1. **Limit Message Loading**
   ```dart
   // Load only latest 50 messages
   final messages = await _repository.getMessages(roomId, limit: 50);
   ```

2. **Pagination**
   - Implement infinite scroll with pagination
   - Load older messages when scrolling up

3. **Caching**
   - Cache contact list locally
   - Use Redis for message caching
   - Reduce API calls

4. **WebSocket Optimization**
   - Reconnect on network change
   - Queue messages during offline
   - Batch message delivery

## Conclusion

The chat system is designed to work across all user roles. If experiencing issues, start with the API connection verification and work through the troubleshooting steps systematically. Enable verbose logging at each layer (backend, mobile, database) to identify the exact failure point.

For persistent issues, ensure all services (PostgreSQL, Redis, NestJS backend) are running and properly configured.
