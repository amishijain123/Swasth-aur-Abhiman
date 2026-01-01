import 'package:dio/dio.dart';
import '../../features/chat/models/chat_models.dart';

class MockChatInterceptor extends Interceptor {
  // Store mock data
  static final Map<String, List<Message>> _mockMessages = {};
  static final Map<String, ChatRoom> _mockRooms = {};

  MockChatInterceptor() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Create mock chat room
    final mockRoom = ChatRoom(
      id: '1',
      name: 'Dr. Smith',
      type: 'DIRECT',
      participants: [
        ChatParticipant(
          id: '2',
          name: 'Dr. Smith',
          role: 'DOCTOR',
          isOnline: true,
        ),
      ],
      createdAt: DateTime.now(),
    );
    _mockRooms['1'] = mockRoom;

    // Create mock messages
    _mockMessages['1'] = [
      Message(
        id: '1',
        roomId: '1',
        senderId: 'current_user',
        senderName: 'You',
        content: 'Hello Dr. Smith, how are you?',
        type: 'TEXT',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Message(
        id: '2',
        roomId: '1',
        senderId: '2',
        senderName: 'Dr. Smith',
        content: 'I am doing well, thank you for asking!',
        type: 'TEXT',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If we get a connection error, try to handle it with mock data
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      
      final path = err.requestOptions.path;
      
      // Handle chat/rooms GET
      if (path.contains('/chat/rooms') && err.requestOptions.method == 'GET') {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: _mockRooms.values.map((r) => r.toJson()).toList(),
          ),
        );
      }
      
      // Handle chat/rooms/:roomId/messages GET
      if (path.contains('/chat/rooms/') && 
          path.contains('/messages') && 
          err.requestOptions.method == 'GET') {
        final roomId = path.split('/')[3]; // Extract roomId from path
        final messages = _mockMessages[roomId] ?? [];
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: messages.map((m) => m.toJson()).toList(),
          ),
        );
      }

      // Handle chat/contacts GET
      if (path.contains('/chat/contacts') && err.requestOptions.method == 'GET') {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: [
              {
                'id': '2',
                'name': 'Dr. Smith',
                'role': 'DOCTOR',
                'avatarUrl': null,
                'isOnline': true,
              },
              {
                'id': '3',
                'name': 'Mrs. Johnson',
                'role': 'TEACHER',
                'avatarUrl': null,
                'isOnline': false,
              },
            ],
          ),
        );
      }

      // Handle file upload POST
      if (path.contains('/chat/upload') && err.requestOptions.method == 'POST') {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: {
              'url': '/uploads/mock/${DateTime.now().millisecondsSinceEpoch}',
              'originalName': 'mock-file',
              'size': 0,
              'mimeType': 'application/octet-stream',
              'type': 'document',
            },
          ),
        );
      }
    }
    
    return handler.next(err);
  }
}
