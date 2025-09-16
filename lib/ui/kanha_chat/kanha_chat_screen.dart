import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import '../../domain/models/chat_message.dart';
import 'kanha_chat_view_model.dart';

/// Chat screen for conversing with Kanha AI assistant
class KanhaChatScreen extends StatefulWidget {
  const KanhaChatScreen({super.key});

  @override
  State<KanhaChatScreen> createState() => _KanhaChatScreenState();
}

class _KanhaChatScreenState extends State<KanhaChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KanhaChatViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(viewModel),
          body: Column(
            children: [
              Expanded(
                child: _buildChatArea(viewModel),
              ),
              _buildMessageInput(viewModel),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(KanhaChatViewModel viewModel) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kanha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                viewModel.isAiTyping ? 'Typing...' : 'AI Companion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: viewModel.refresh,
        ),
      ],
    );
  }

  Widget _buildChatArea(KanhaChatViewModel viewModel) {
    if (viewModel.state == KanhaChatState.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.state == KanhaChatState.error && !viewModel.hasMessages) {
      return EmptyState(
        title: 'Failed to load chat',
        message: viewModel.errorMessage ?? 'Something went wrong',
        icon: Icons.error_outline,
        actionText: 'Try Again',
        onActionPressed: viewModel.refresh,
      );
    }

    if (!viewModel.hasMessages) {
      return _buildWelcomeScreen(viewModel);
    }

    return _buildMessagesList(viewModel);
  }

  Widget _buildWelcomeScreen(KanhaChatViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingXL),
          
          // Kanha Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 50,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Welcome Message
          Text(
            'Meet Kanha',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            viewModel.getWelcomeMessage(),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Conversation Starters
          if (viewModel.shouldShowStarters) ...[
            Text(
              'Quick Starters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...viewModel.conversationStarters.map((starter) {
              return _buildStarterCard(starter, viewModel);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStarterCard(String starter, KanhaChatViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: AppTheme.primaryColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: () => viewModel.sendStarterMessage(starter),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    starter,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(KanhaChatViewModel viewModel) {
    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: viewModel.messages.length + (viewModel.isAiTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.messages.length && viewModel.isAiTyping) {
          return _buildTypingIndicator();
        }
        
        final message = viewModel.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser),
            const SizedBox(width: AppTheme.spacingS),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppTheme.primaryColor 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppTheme.radiusL).copyWith(
                  bottomLeft: isUser 
                      ? const Radius.circular(AppTheme.radiusL)
                      : const Radius.circular(AppTheme.radiusS),
                  bottomRight: isUser
                      ? const Radius.circular(AppTheme.radiusS)
                      : const Radius.circular(AppTheme.radiusL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    message.timeDisplay,
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: AppTheme.spacingS),
            _buildAvatar(isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.secondaryColor : AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: AppTheme.spacingS),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.radiusL).copyWith(
                bottomLeft: const Radius.circular(AppTheme.radiusS),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(
                      right: index < 2 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(KanhaChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                ),
                onSubmitted: (message) => _sendMessage(viewModel),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: viewModel.isAiTyping 
                    ? null 
                    : () => _sendMessage(viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(KanhaChatViewModel viewModel) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      viewModel.sendMessage(message);
      _messageController.clear();
    }
  }
}