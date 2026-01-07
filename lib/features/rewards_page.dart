import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensor_sentinel/core/app_strings.dart';
import '../core/sensor_manager.dart';
import 'dart:async';
import 'dart:math' as math;

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Timer? _countdownTimer;
  String _timeLeftStr = "00:00:00";

  bool _isSpinning = false;
  double _globalPoolUsed = 0.82; // Mock start
  final int _luckDrawCost = 10;

  @override
  void initState() {
    super.initState();
    _spinController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // Start Countdown Timer
    _startCountdown();
  }

  void _startCountdown() {
    _updateTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    // Calculate time until next midnight UTC
    final now = DateTime.now().toUtc();
    final tomorrow = DateTime.utc(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);

    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    setState(() {
      _timeLeftStr = "$h:$m:$s";
      // Simulate pool slowly filling up over time
      if (_globalPoolUsed < 1.0) {
        _globalPoolUsed += 0.00001;
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium Web3 Palette (Slate Blue / Gold / Cyan)
    final bgColor = const Color(0xFF0F172A); // Dark Slate Blue (Cleaner dark)
    final cardColor =
        const Color(0xFF1E293B).withValues(alpha: 0.9); // Lighter Slate
    final accentCyan = const Color(0xFF22D3EE); // Bright Cyan (Tech)
    final accentGold = const Color(0xFFFFD700); // Gold (Wealth)
    final accentPurple = const Color(0xFF8B5CF6); // Violet (Premium)

    // Text Colors
    final textMuted = Colors.blueGrey[200];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.t('exchange_hub'),
            style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<SensorManager>(
        builder: (context, manager, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ASSET HEADER
                _buildAssetHeader(manager.totalEarnings, accentCyan, textMuted),

                const SizedBox(height: 30),

                // 2. DAILY MELTDOWN BAR (FOMO)
                Text(
                  AppStrings.t('global_pool_title'),
                  style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _buildGlobalPoolBar(
                    accentPurple), // Use Purple for a stable look

                const SizedBox(height: 30),

                // 3. LUCKY DRAW (Burn Mechanism)
                _buildLuckyDrawCard(manager, cardColor, accentGold),

                const SizedBox(height: 30),

                // 4. CASH OUT (Limited)
                Text(
                  AppStrings.t('instant_redemption'),
                  style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildRedeemOption(
                  context,
                  manager,
                  AppStrings.t('gift_card_amazon'),
                  2000,
                  Icons.shopping_cart,
                  Colors.white, // Clean white icon
                  cardColor,
                ),
                _buildRedeemOption(
                  context,
                  manager,
                  AppStrings.t('gift_card_coffee'),
                  10000,
                  Icons.coffee,
                  Colors.white,
                  cardColor,
                ),

                const SizedBox(height: 30),

                // 5. STAKING (Lock-up)
                _buildStakingCard(cardColor, accentPurple),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetHeader(double balance, Color accent, Color? textMuted) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF334155), Color(0xFF1E293B)], // Lighter gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t('available_balance'),
                  style: TextStyle(
                      color: textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.token, color: accent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    balance.toStringAsFixed(2),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: "monospace",
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("≈ \$${(balance * 0.0005).toStringAsFixed(4)} USD",
                  style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10)),
            child: Text(AppStrings.t('tier_free'),
                style: TextStyle(color: Colors.white, fontSize: 10)),
          )
        ],
      ),
    );
  }

  Widget _buildGlobalPoolBar(Color color) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _globalPoolUsed > 1.0 ? 1.0 : _globalPoolUsed,
            minHeight: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "${(_globalPoolUsed * 100).toInt()}% ${AppStrings.t('claimed')}",
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            // Dynamic Timer
            Text("${AppStrings.t('reset_in')} $_timeLeftStr",
                style: TextStyle(color: Colors.blueGrey[300], fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildLuckyDrawCard(SensorManager manager, Color bg, Color accent) {
    return Container(
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24), // Smoother corners
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.05))), // Subtle border
      child: Stack(
        children: [
          // Background Icon
          Positioned(
              right: -20,
              top: -20,
              child: Icon(Icons.casino,
                  size: 100, color: Colors.white.withValues(alpha: 0.03))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Animated Icon
                  RotationTransition(
                    turns: _spinController,
                    child: Icon(Icons.auto_awesome, color: accent, size: 28),
                  ),
                  SizedBox(width: 12),
                  Text(AppStrings.t('lucky_draw_title'),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))
                ]),
                const SizedBox(height: 12),
                Text(AppStrings.t('lucky_draw_desc'),
                    style: TextStyle(
                        color: Colors.blueGrey[100],
                        fontSize: 13,
                        height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSpinning ? null : () => _handleSpin(manager, accent),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor:
                            Colors.black, // High contrast text on Gold
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 16)),
                    child: Text(
                        _isSpinning
                            ? AppStrings.t('spinning')
                            : AppStrings.t('try_luck_btn'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSpin(SensorManager manager, Color color) async {
    // 1. Deduct cost
    bool paid = manager.deductEarnings(_luckDrawCost.toDouble());
    if (!paid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.t('insufficient_qbit')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // 2. Start Animation
    setState(() => _isSpinning = true);
    _spinController.repeat(); // Start rotating

    // Simulate API/RNG delay
    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    // 3. Stop Animation
    _spinController.stop();
    _spinController.reset(); // Reset position
    setState(() => _isSpinning = false);

    // 4. Result Logic (99% LOSE)
    // Add randomness to make it feel real
    final rng = math.Random().nextInt(100);
    bool isWinner = rng > 98; // 1% chance

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Color(0xFF1E293B),
              title: Icon(
                  isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 40,
                  color: isWinner ? Colors.amber : Colors.blueGrey),
              content: Text(
                isWinner
                    ? AppStrings.t('jackpot_win') +
                        "WIN50-${DateTime.now().millisecondsSinceEpoch}"
                    : AppStrings.t('jackpot_lose'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(_),
                    child: Text(AppStrings.t('ok'),
                        style: TextStyle(color: color)))
              ],
            ));
  }

  // --- Redeem Option Builder ---
  Widget _buildRedeemOption(BuildContext ctx, SensorManager manager,
      String title, int cost, IconData icon, Color iconColor, Color bg) {
    bool canAfford = manager.totalEarnings >= cost;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                SizedBox(height: 4),
                Text("$cost QBIT",
                    style:
                        TextStyle(color: Colors.blueGrey[300], fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    _showRedeemDialog(ctx, manager, title, cost);
                  }
                : null, // Disabled if not enough funds
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size(0, 36)),
            child: Text(AppStrings.t('redeem_btn'),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- Staking Card ---
  Widget _buildStakingCard(Color bg, Color accent) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.rocket_launch, color: accent, size: 40),
          const SizedBox(height: 16),
          Text(AppStrings.t('become_prime'),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            AppStrings.t('stake_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueGrey[200], fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              _showStakingDialog(); // Now hooked up!
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: accent),
                foregroundColor: accent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(AppStrings.t('enable_staking')),
          )
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showRedeemDialog(
      BuildContext ctx, SensorManager manager, String item, int cost) {
    if (_globalPoolUsed >= 1.0) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(AppStrings.t('daily_limit_reached')),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }

    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E293B),
        title: Text(AppStrings.t('confirm_redemption'),
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${AppStrings.t('item')} $item\n${AppStrings.t('cost')} $cost QBIT",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppStrings.t('email_address'),
                labelStyle: TextStyle(color: Colors.blueGrey),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber)),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('cancel'),
                  style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (emailController.text.isEmpty) return;

              bool success = await manager.submitRedemptionRequest(
                  item: item, cost: cost, email: emailController.text);

              if (success) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(AppStrings.t('request_submitted')),
                  backgroundColor: Colors.green,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(AppStrings.t('confirm'),
                style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  void _showStakingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(AppStrings.t('prime_status'),
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: Icon(Icons.lock_clock,
                    size: 48, color: Colors.purpleAccent)),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('lock_duration'),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.t('lock_duration_30'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    Text(AppStrings.t('speed_boost_20'),
                        style: const TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                )),
            const SizedBox(height: 10),
            Text(
              AppStrings.t('stake_warning'),
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.t('cancel'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppStrings.t('staking_activated')),
                  backgroundColor: Colors.purpleAccent));
              // TODO: Update manager mining multiplier
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            child: Text(AppStrings.t('stake_now'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
