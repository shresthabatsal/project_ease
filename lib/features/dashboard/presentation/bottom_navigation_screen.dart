import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/services/storage/app_settings.dart';
import 'package:project_ease/core/services/websocket/socket_service.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/core/utils/proximity_service.dart';
import 'package:project_ease/core/utils/shake_detector.dart';
import 'package:project_ease/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:project_ease/features/profile/presentation/pages/account_screen.dart';
import 'package:project_ease/features/cart/presentation/pages/cart_screen.dart';
import 'package:project_ease/features/dashboard/presentation/home_screen.dart';
import 'package:project_ease/features/order/presentation/pages/my_orders_screen.dart';
import 'package:project_ease/features/order/presentation/pages/order_detail_screen.dart';
import 'package:project_ease/features/product/presentation/pages/search_screen.dart';
import 'package:project_ease/features/notification/data/models/notification_api_model.dart';
import 'package:project_ease/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';
import 'package:project_ease/features/support/data/models/message_api_model.dart';
import 'package:project_ease/features/support/presentation/view_model/chat_view_model.dart';

class BottomNavigationScreen extends ConsumerStatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends ConsumerState<BottomNavigationScreen> {
  int _selectedIndex = 0;
  bool _isNearSensor = false;

  late final ShakeDetector _shakeDetector;
  late final ProximityService _proximityService;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector(onShake: _onShake);
    _proximityService = ProximityService(
      onNear: () => setState(() => _isNearSensor = true),
      onFar: () => setState(() => _isNearSensor = false),
    );
    _socketService = ref.read(socketServiceProvider);

    Future.microtask(() {
      if (ref.read(appSettingsProvider).shakeEnabled) _shakeDetector.start();

      // Proximity is always active — no setting toggle needed
      _proximityService.start();

      ref.read(orderViewModelProvider.notifier).loadOrders();
      ref.read(notificationViewModelProvider.notifier).loadUnreadCount();

      _socketService.connect(
        onNotification: _onRealtimeNotification,
        onUnreadCount: _onUnreadCount,
        onTicketMessage: _onRealtimeTicketMessage,
      );
    });
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    _proximityService.stop();
    _socketService.disconnect();
    super.dispose();
  }

  void _onSettingsChanged(AppSettings? prev, AppSettings next) {
    if (next.shakeEnabled != prev?.shakeEnabled) {
      next.shakeEnabled ? _shakeDetector.start() : _shakeDetector.stop();
    }
  }

  // WebSocket handlers

  void _onRealtimeNotification(Map<String, dynamic> payload) {
    if (!mounted) return;
    try {
      final model = NotificationApiModel.fromJson({
        ...payload,
        'isRead': false,
        'createdAt': payload['createdAt'] ?? DateTime.now().toIso8601String(),
      });
      final entity = model.toEntity();
      ref
          .read(notificationViewModelProvider.notifier)
          .addRealtimeNotification(entity);
    } catch (_) {
      final current = ref.read(notificationViewModelProvider).unreadCount;
      ref
          .read(notificationViewModelProvider.notifier)
          .setUnreadCount(current + 1);
    }
  }

  void _onUnreadCount(int count) {
    if (!mounted) return;
    ref.read(notificationViewModelProvider.notifier).setUnreadCount(count);
  }

  void _onRealtimeTicketMessage(Map<String, dynamic> payload) {
    if (!mounted) return;
    try {
      final model = MessageApiModel.fromJson(payload);
      ref
          .read(chatViewModelProvider.notifier)
          .addRealtimeMessage(model.toEntity());
    } catch (_) {}
  }

  // ── Shake handler ─────────────────────────────────────────────────────────

  Future<void> _onShake() async {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    final orders = ref.read(orderViewModelProvider).orders;
    if (orders.isEmpty) {
      await ref.read(orderViewModelProvider.notifier).loadOrders();
    }
    if (!mounted) return;

    final ready = ref
        .read(orderViewModelProvider)
        .orders
        .where((o) => o.status == 'READY_FOR_COLLECTION')
        .toList();

    if (ready.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: ready.first.orderId),
        ),
      );
    } else if (ready.length > 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const MyOrdersScreen(initialFilter: 'READY_FOR_COLLECTION'),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
    }
  }

  void _switchToSearch() => setState(() => _selectedIndex = 1);

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    ref.listen(appSettingsProvider, _onSettingsChanged);

    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final cartCount = ref.watch(
      cartViewModelProvider.select((s) => s.totalItems),
    );

    final screens = [
      HomeScreen(onNavigateToSearch: _switchToSearch),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: isTablet ? 26 : 24,
            selectedFontSize: isTablet ? 13 : 11,
            unselectedFontSize: isTablet ? 12 : 10,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 12,
            backgroundColor: Colors.white,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        ),

        if (_isNearSensor)
          const Positioned.fill(
            child: IgnorePointer(child: ColoredBox(color: Colors.black)),
          ),
      ],
    );
  }
}
