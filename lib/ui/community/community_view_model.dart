import 'package:flutter/material.dart';

/// Article model
class Article {
  final String title;
  final int duration;
  final String image;
  final String emotionalAttribute;
  final List<String> tags;
  final String description;
  final List<String> content;
  final String? imageURL;

  Article({
    required this.title,
    required this.duration,
    required this.image,
    required this.emotionalAttribute,
    required this.tags,
    required this.description,
    required this.content,
    this.imageURL,
  });
}

/// Featured article model
class FeaturedArticle {
  final Article article;

  FeaturedArticle({required this.article});
}

/// Story model
class Story {
  final String username;
  final String image;
  final DateTime timestamp;
  final String content;

  Story({
    required this.username,
    required this.image,
    required this.timestamp,
    required this.content,
  });
}

/// Community user model
class CommunityUser {
  final String username;
  final String avatar;
  final bool isFollowed;

  CommunityUser({
    required this.username,
    required this.avatar,
    required this.isFollowed,
  });

  CommunityUser copyWith({bool? isFollowed}) {
    return CommunityUser(
      username: username,
      avatar: avatar,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

/// View model for community screen
class CommunityViewModel extends ChangeNotifier {
  List<Article> _articles = [];
  List<Story> _stories = [];
  List<CommunityUser> _users = [];
  FeaturedArticle? _featuredArticle;
  bool _showNewStorySheet = false;

  // Getters
  List<Article> get articles => _articles;
  List<Story> get stories => _stories;
  List<CommunityUser> get users => _users;
  FeaturedArticle? get featuredArticle => _featuredArticle;
  bool get showNewStorySheet => _showNewStorySheet;

  CommunityViewModel() {
    _initializeData();
  }

  void _initializeData() {
    // Initialize articles with the provided blog data
    _articles = [
      Article(
        title: "Hear how Kavya broke stereotypes with confidence and courage",
        duration: 8,
        image: "kavya",
        emotionalAttribute: "Courage",
        tags: ["Stereotype"],
        description: "An inspiring story on how a young adult overcame her struggle through her anxious thoughts reminiscing about her career.",
        content: [
          "Hey everyone, Kavya here! I'm in my 3rd year of B.Tech, and let me tell you, it's been a wild ride so far. I always knew I wanted to be in tech, but sometimes it felt like I didn't quite fit the \"mold.\" You know, the image of the stereotypical programmer who's been coding since they were 10 and lives and breathes algorithms? That was never me.",
          "For a long time, I let those thoughts define me, until I realized I don't have to be someone to someone, I just have to be *me*.",
          "Being a woman in tech, especially in a field that's still largely male-dominated, comes with its own set of pressures. I constantly felt like I had to prove myself, work twice as hard, and always be on top of my game. It was exhausting! Then the overthinking would kick in:\n\nAm I smart enough?\n\nDo I belong here?\n\nAm I ever going to be taken seriously?\n\nCan I really become a great software engineer with this skill set that i am having?\n\nThose thoughts would leave me paralyzed with fear.",
          "The turning point for me was realizing that success isn't about fitting into a mold or meeting someone else's expectations. It's about defining your own path, embracing your unique strengths, and pursuing what genuinely excites you. It's like playing a video game, but you define what victory is.",
          "These are different weapons I've made to make this world better.",
          "Embrace My Strengths: I realized that I didn't have to be a coding whiz to be valuable in tech. I was able to be more empathetic than some of the people with great technical skills, making me a great team worker and more importantly a team leader.",
          "Find My Tribe: Surrounding myself with other supportive and like-minded individuals made a world of difference. I also realized that everyone felt the same at some point of time, making me realize these pressures were there just for a very short time to pass. And to be the best, you need to fail at it.",
          "Challenge the Status Quo: I started speaking up and advocating for more diversity and inclusion in tech. I joined organizations that support women and underrepresented groups in STEM, and I used my voice to challenge stereotypes and promote equality.",
          "Knowing when to stop: Its just that my anxiety comes from my career but its not that serious that its making me really depressed or anything. I know my goals and everything, and my actions are always driven towards it. I know if I am going the right way or not, and even it is not, it is fine, because I will find something along the way. And I cannot keep going forever. We all need to switch to youtube at some point of time.",
          "My Takeaway: Breaking stereotypes and conquering career anxieties takes courage, confidence, and a willingness to embrace your unique self. Don't be afraid to challenge the status quo, find your tribe, and define success on your own terms. You've got this! ✨"
        ],
        imageURL: null,
      ),
      Article(
        title: "Hear how Manas overpowered his overthinking with help from his friends",
        duration: 8,
        image: "manas",
        emotionalAttribute: "Anxious",
        tags: ["Social Interaction"],
        description: "An inspiring story on how a young adult overcame his struggle through his anxious thoughts reminiscing about his social interactions.",
        content: [
          "What's up, everyone? Manas here, trying to survive the chaos. Tech is hard, but honestly, sometimes my biggest challenges happen *outside* the code editor. I'm talking about social interactions, group chats, and that constant *what are they thinking about me* spiral.",
          "I was just the \"it\" guy at the wrong time.",
          "Anyone else get crazy anxious after sending a text? Like, you analyze every word, every emoji, and then spend the next hour refreshing your phone, waiting for a reply? That was me, times a million. My brain would go into overdrive:\n\nDid I say something wrong?\n\nAre they mad at me?\n\nDid I bore them to death with that story about the algorithm I was working on?\n\nAnd if someone didn't reply right away, forget about it! My brain would be like, \"Okay, they clearly hate you now. Time to pack your bags and move to a remote island.\" Okay that was a bit to far.",
          "That feeling when people change how they talk to you, probably due to their time crunching schedule.",
          "Thankfully, I have some amazing friends who helped me see the light, especially Kavya. Seriously, she deserves a medal for putting up with my overthinking tendencies. I had a friend named Kavya, it wasn't anything serious but she was a real help.",
          "Kavya taught me these following toolkits that actually made myself better!",
          "The \"It's Not Always About You\" Reminder: Kavya would constantly remind me that people have their own lives, their own problems, and their own schedules. If someone doesn't reply right away, it's probably not because they hate you, but because they're busy, tired, or maybe just forgot to charge their phone (we've all been there!).",
          "The Straight-Up Truth: One of the best things about Kavya is that she's not afraid to give me a reality check. If I was spiraling out of control, she'd be like, \"Manas, chill! You're being ridiculous. They probably just haven't seen your message yet.\" Sometimes, you need that dose of tough love. XD",
          "Embracing Imperfection: I learned to let go of the need to be perfect in every social interaction. It's okay to say the wrong thing sometimes, to be a little awkward, or to not have all the answers. People are much more forgiving than my brain makes them out to be.",
          "Reaffirming my Actions: Making me understand that my actions are driven towards helping improve myself. I was already on the right path!",
          "Overcoming social anxieties and overthinking is a process. I learned how to manage my thoughts. And, most importantly, is be true to myself!",
          "And with that all we know, always love what others do and do what you love 💖😃! Now let's keep on building cool and awesome applications! ✨"
        ],
        imageURL: null,
      ),
      Article(
        title: "Swapna solves stress with ease",
        duration: 4,
        image: "swapna",
        emotionalAttribute: "Empowering",
        tags: ["Upskilling"],
        description: "A girl with dreams overcame her struggle through her anxious thoughts reminiscing about her career.",
        content: [
          "Hey everyone! I'm Swapna Dande, a recent grad and super excited to be a Women Techmakers Ambassador for Google Developer Groups Vizag! For a while, I thought that I had it easy, however my dreams were big, but the stress to succeed, even bigger.",
          "The \"easy\" life was never really easy. It was just all a facade. I had to come up with a way to feel, ok.",
          "I was also struggling for:\n\nImpostor syndrome\n\nWhere am I really going?\n\nAll the success stories in the Google Developer Groups were also becoming a negative form of encouragement for me. Until I was able to come across several things that I needed to keep going, I would often remind myself.",
          "Embrace Lifelong Learning: Tech is constantly evolving, so there's always something new to learn! Upskilling wasn't just about building my resume, it was more about building myself. Having a broader set of tools allows me to think bigger, to not feel that only I'm the bottleneck in the world.",
          "Find Your Voice: Being a Women Techmakers Ambassador has given me a platform to share my knowledge and passion with others. Helping women be more in STEM, and use the skills, and connections Google has to offer! We really can do this together.",
          "Celebrate Small Wins: Don't get caught up in the big picture! I would literally note them down! Each success story allows me to pat myself on the back and say everything I have accomplished has lead to some better point. All of these small things were making me stronger and stronger.",
          "Takeaway: You're capable of amazing things, and the journey is just as important as the destination. Keep learning, keep connecting, and keep empowering yourself and others, and you'll find your own path to success. ✨",
          "Also, remember to smile on the go, its something really fun! 😃"
        ],
        imageURL: null,
      ),
    ];

    // Initialize featured article
    _featuredArticle = FeaturedArticle(
      article: Article(
        title: "Tune into how Värshita conquered her overthinking career",
        duration: 4,
        image: "varshita",
        emotionalAttribute: "Anxious",
        tags: ["Career"],
        description: "An inspiring story on how a young adult overcame his struggle through his anxious thoughts reminiscing about his career.",
        content: [
          "Hey everyone! I'm Varshita, and like many of you, I'm a student trying to navigate the crazy world of tech. I'm currently in my 3rd year, and if I'm being honest, the pressure to \"succeed\" in my career has often felt overwhelming. That feeling of constantly needing to keep up to avoid career suicide. Impostor syndrome became my best friend.",
          "I soon learned this was only in my head.",
          "It wasn't pretty. I'd spend hours comparing myself to other students, worrying about internships, and panicking about the future. It was exhausting, and it started to affect my studies, my relationships, and my overall well-being. I'd catch myself thinking:\n\nAm I good enough?\n\nAm I ready for what is to come?\n\nThe mind could always come up with something I wasn't. I became a perfectionist with my grades, since if it slipped it meant my death. All the fun and freedom I had were gone. I decided I've had enough.",
          "Then a small spark of recognition came by, which made me know I'm not crazy, that everyone goes through what I'm going through, and everyone has a unique way to managing it. There were a lot of different ways I found, but the best was doing art!",
          "Art gave me a way to express those hard emotions.",
          "I learned different toolkits to make myself understand the mind that is causing me pain.",
          "Mindfulness Moments: I started practicing mindfulness, even if it was just for a few minutes each day. Focusing on my breath or the sensations in my body helped me ground myself in the present moment and quiet the mental chatter.",
          "Cognitive Reframing: Whenever I noticed myself having negative thoughts, I challenged them. I asked myself, \"Is this thought really true? Is there another way to look at this situation?\"",
          "Seeking Support: I had to reach out to friends and a professional for help. Talking to others who understood what I was going through made me feel less alone.",
          "The big challenge was the negative talk, but it soon came to an end!",
          "Conquering career overthink is a journey, not a destination. There will be good days and bad days, but the important thing is to keep moving forward. Be kind to yourself, celebrate your successes, and don't be afraid to ask for help when you need it. 💖",
          "You can do it! 😄"
        ],
        imageURL: null,
      ),
    );

    // Initialize stories
    _stories = [
      Story(
        username: "Kavya",
        image: "https://github.com/manasmalla.png",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        content: "Just completed my first tech interview today! It was nerve-wracking but I remembered to be myself and embrace my unique strengths. The preparation really paid off. 💪 #TechCareer #Confidence",
      ),
      Story(
        username: "Manas",
        image: "https://github.com/manasmalla.png",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        content: "Had a great conversation with a friend today without overthinking every word! It's amazing how much more enjoyable social interactions become when you stop worrying about every little detail. Progress! 🎉",
      ),
    ];

    // Initialize users
    _users = [
      CommunityUser(username: "Kavya", avatar: "kavya", isFollowed: false),
      CommunityUser(username: "Manas", avatar: "manas", isFollowed: true),
      CommunityUser(username: "Swapna", avatar: "swapna", isFollowed: false),
      CommunityUser(username: "Varshita", avatar: "varshita", isFollowed: false),
      CommunityUser(username: "CurrentUser", avatar: "manasmalla", isFollowed: false),
    ];

    notifyListeners();
  }

  /// Toggle follow status for a user
  void toggleFollow(CommunityUser user) {
    final index = _users.indexWhere((u) => u.username == user.username);
    if (index != -1) {
      _users[index] = user.copyWith(isFollowed: !user.isFollowed);
      notifyListeners();
    }
  }

  /// Show new story sheet
  void showNewStorySheet() {
    _showNewStorySheet = true;
    notifyListeners();
    // TODO: Implement story creation dialog/sheet
  }

  /// Add a new story
  void addStory(String content) {
    final newStory = Story(
      username: "You",
      image: "user_avatar",
      timestamp: DateTime.now(),
      content: content,
    );
    _stories.insert(0, newStory);
    _showNewStorySheet = false;
    notifyListeners();
  }
}