#!/usr/bin/env dart

/// Example script demonstrating Gemini AI integration
/// This script shows how the GeminiAiService would work with a real API key

import 'dart:io';

void main() {
  print('🧠 Chaos Clinic - Gemini AI Integration Demo\n');
  
  // Check for API key
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ No GEMINI_API_KEY found in environment variables.');
    print('   Please set your API key:');
    print('   export GEMINI_API_KEY="your_api_key_here"');
    print('   dart run scripts/demo_gemini.dart\n');
    print('📖 See GEMINI_SETUP.md for detailed setup instructions.');
    exit(1);
  }
  
  print('✅ API key found! Running demo...\n');
  
  // Simulate the integration
  demonstrateFeatures();
}

void demonstrateFeatures() {
  print('🎯 Key Features of Gemini Integration:\n');
  
  print('1. 💬 Mental Health Grounded Responses');
  print('   - Input: "I\'m feeling really anxious about work"');
  print('   - Expected: Empathetic response with breathing techniques\n');
  
  print('2. 🧠 Context-Aware Conversations');
  print('   - Maintains conversation history for context');
  print('   - Provides relevant follow-up questions\n');
  
  print('3. 🛡️ Safety & Fallback System');
  print('   - Built-in content filtering');
  print('   - Graceful degradation if API fails');
  print('   - Crisis intervention awareness\n');
  
  print('4. 📱 App Integration');
  print('   - Suggests relevant app features (breathing, journaling)');
  print('   - Connects to user\'s mood tracking data');
  print('   - Persistent chat history in Firestore\n');
  
  print('5. 🎨 Conversation Starters');
  print('   - AI-generated personalized prompts');
  print('   - Contextually appropriate for mental health\n');
  
  print('🚀 To test the actual integration:');
  print('   1. Set your GEMINI_API_KEY environment variable');
  print('   2. Run the Flutter app: flutter run --dart-define=GEMINI_API_KEY=\$GEMINI_API_KEY');
  print('   3. Navigate to the Kanha Chat screen');
  print('   4. Send a message and receive AI-powered responses!\n');
  
  print('📚 For more details, see GEMINI_SETUP.md');
}