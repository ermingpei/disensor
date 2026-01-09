import 'dart:io';

class AppStrings {
  // Override for manual language switching if needed in future
  static String? _manualLanguage;

  static String get languageCode {
    if (_manualLanguage != null) return _manualLanguage!;
    try {
      final locale = Platform.localeName.split('_')[0];
      // Simple logic: if 'zh', use 'zh'. Else default to 'en'.
      if (locale == 'zh') return 'zh';
      return 'en';
    } catch (e) {
      return 'en';
    }
  }

  // Define keys here to avoid typos
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // --- General ---
      'nodes': 'Nodes',
      'nodes_desc': 'Peers',
      'uptime': 'Uptime',
      'uptime_desc': 'Online code',
      'latency': 'Latency',
      'latency_desc': 'Ping',
      'network': 'Network',
      'hexes': 'Hexes',
      'estimated_earnings': 'ESTIMATED EARNINGS',
      'resume_mining': 'RESUME MINING',
      'pause_mining': 'PAUSE MINING',
      'checking_permissions': 'Checking permissions...',
      'mining_started': '✅ Mining started successfully!',
      'location_required': '📍 Location permission is required for mining.',
      'turn_on_gps': '📍 Please turn ON GPS/Location in device settings.',
      'perm_denied_forever':
          '⚠️ Location permanently denied. Tap SETTINGS to enable.',
      'allow_location': '📍 Please allow location access when prompted.',
      'settings': 'SETTINGS',
      'coverage_map': 'Coverage Map',
      'map_desc':
          'Explore high-yield hexagons\nand optimize your mining routes',
      'interactive': 'Interactive',
      'invite_earn': 'Join the Global Sensing Network',
      'invite_desc':
          '🏙 Turn your phone into a sensor. Earn QBit rewards automatically.',
      'share_subject':
          '📱 Join the DiSensor Network: Measuring the World\'s Pulse together',
      'share_body':
          'Did you know your phone is packed with sensors that sit idle 99% of the time?\n\nJoin DiSensor to transform these resources into scientific value and earn rewards:\n\n🔬 Build the global environmental map.\n⏰ Runs automatically in the background.\n💰 Earn QBit tokens and share the network growth.\n\n👉 Referral Code: *#CODE#*\nhttps://disensor.qubitrhythm.com/dashboard/start.html?ref=#CODE#',
      'share_link': 'Share & Join Together',
      'boost_active': 'BOOST ACTIVE',
      'referred_by': 'Referred by:',
      'mining_efficiency': '+20% Mining Efficiency',
      'have_invite': 'Have an invite code? Click here',
      'enter_code': 'Enter Referral Code',
      'settings_title': 'Settings & About',
      'device_sensors': 'Device Sensors',
      'about': 'About DiSensor',
      'version': 'Version',
      'powered_by': 'Support',
      'privacy_policy': 'Privacy Policy',
      'replay_tutorial': 'Show Onboarding',
      'sensor_accelerometer': 'Accelerometer',
      'sensor_gyroscope': 'Gyroscope',
      'sensor_magnetometer': 'Magnetometer',
      'sensor_orientation': 'Orientation',
      'sensor_light': 'Light',
      'sensor_pressure': 'Pressure', // Existing but grouped here for context
      'sensor_proximity': 'Proximity',
      'sensor_pedometer': 'Step Counter',
      'sensor_gps': 'GPS',
      'sensor_wifi': 'WiFi Scanner',
      'sensor_bluetooth': 'Bluetooth',
      'sensor_audio': 'Microphone',
      'pressure': 'Pressure',
      'pressure_desc': 'Atmospheric pressure helps in calculating altitude.',
      'noise': 'Noise Level',
      'noise_desc': 'Ambient noise level monitoring.',
      'bluetooth': 'Bluetooth Density',
      'bluetooth_desc': 'Active devices nearby. Indicates crowd density.',
      'cell_signal': 'Cell Signal',
      'cell_signal_desc': 'Cellular network strength for coverage mapping.',
      'jitter': 'Jitter',
      'jitter_desc': 'Network latency variation. Lower is better.',
      'packet_loss': 'Packet Loss',
      'packet_loss_desc': 'Data loss percentage. 0% is ideal.',
      'network_quality': 'Network Quality',
      'signal_excellent': 'Excellent',
      'signal_good': 'Good',
      'signal_fair': 'Fair',
      'signal_poor': 'Poor',
      'about_qbit': 'About QBit Rewards',
      'about_qbit_content':
          'QBit is the native incentive token of the DiSensor network.\n\nYou earn QBit by contributing valuable environmental data (Pressure, Noise, Signal Density, etc.). This data is essential for building a high-precision global environmental map. QBit represents your stake in the early growth of the network, with future value emerging as the data ecosystem and industry applications expand.\n\nEarning Rate: Base Contribution + Exploration Bonus.',
      'got_it': 'GOT IT',
      'onboard_1_title': 'Hyper-local Sensing',
      'onboard_1_body':
          'Join the new global sensing network. Turn your smartphone into a high-precision scientific instrument anytime, anywhere.',
      'onboard_2_title': 'Global Scientific Contribution',
      'onboard_2_body':
          'Map air pressure, noise, and network signals. Your data helps scientists forecast weather, study urban heat islands, and improve city safety.',
      'onboard_3_title': 'Potential Rewards',
      'onboard_3_body':
          'Turn your data into value. Every contribution earns 💰QBit tokens, which represent potential future rewards and network equity.',
      'enter_network': 'ENTER NETWORK',
      'next': 'NEXT',
      'slogan': 'Measuring the World\'s Pulse',
      'rewards_title': 'Rewards & Equity',
      'invite_activated': 'Invite Activated! Boost applied. 🚀',

      // --- Coverage Map ---
      'legend_my_mining': 'My Mining',
      'legend_my_mining_desc': 'You are actively contributing here.',
      'legend_covered': 'Covered',
      'legend_covered_desc': 'Already mapped by others. Low reward.',
      'legend_empty': 'Empty',
      'legend_empty_desc': 'Unexplored! High reward zone.',
      'mission_title': 'Mission: Expand Network',
      'tap_to_view': 'Tap to view',
      'mission_empty_hex': 'Empty Hex',
      'mission_high_yield': 'High Yield (10x Reward)',
      'mission_covered_hex': 'Covered Hex',
      'mission_low_yield': 'Low Yield (1x Reward)',
      'mission_action_desc':
          'Action: Go to an Empty Hex via walking/biking and stay for 5+ min.',
      'loc_access_needed': 'Location Access Needed',
      'loc_access_desc': 'We need location to show the coverage map.',
      'open_settings': 'Open Settings',
      'retry_permission': 'Retry Permission',

      // --- Rewards Page (Exchange Hub) ---
      'exchange_hub': 'EXCHANGE HUB',
      'available_balance': 'AVAILABLE BALANCE',
      'tier_free': 'Tier: FREE',
      'tier_info_title': 'Membership Tiers',
      'tier_info_desc': '''💎 **FREE Tier** (Current)
• Basic mining rate
• Standard redemption access

🚀 **PRIME Tier** (Coming Soon)
• +20% mining speed bonus
• Priority redemption queue
• Exclusive event access
• Future equity rewards

**How to Upgrade:**
Stake 1000+ QBit for 30 days to unlock PRIME status automatically.''',
      'currency_usd': 'USD',
      'currency_rmb': '人民币',
      'global_pool_title': 'GLOBAL REDEMPTION POOL (24H)',
      'claimed': 'CLAIMED',
      'reset_in': 'RESET IN',
      'lucky_draw_title': 'LUCKY DRAW',
      'lucky_draw_desc':
          'Burn 10 QBit for a chance to win a \$50 Gift Card immediately.',
      'try_luck_btn': 'TRY LUCK (-10 QBit)',
      'spinning': 'SPINNING...',
      'instant_redemption': 'INSTANT REDEMPTION',
      'become_prime': 'BECOME A DISENSOR PRIME PARTNER',
      'stake_desc':
          'Stake your current balance for 30 days. Get +20% mining speed and future equity in the DiSensor Network.',
      'enable_staking': 'ENABLE STAKING',
      'confirm_redemption': 'Confirm Redemption',
      'email_address': 'Email Address',
      'confirm': 'CONFIRM',
      'cancel': 'CANCEL',
      'daily_limit_reached':
          '⚠️ Daily Limit Reached. Please try tomorrow or use Lucky Draw!',
      'insufficient_qbit': '⚠️ Not enough QBit! Earn more by mapping areas.',
      'jackpot_win':
          '🎉 JACKPOT! You won a \$50 Gift Card!\n\nEmail us with code: ',
      'jackpot_lose':
          'So close! You won 0.1 QBit consolation prize.\n\nKeep trying, the jackpot is waiting!',
      'item': 'Item:',
      'cost': 'Cost:',
      'prime_status': 'DiSensor Prime',
      'lock_duration_30': '30 Days',
      'speed_boost_20': '+20% Speed',
      'stake_warning':
          'Tokens are locked and cannot be redeemed during this period.',
      'staking_activated': '✅ Staking Activated! Multiplier x1.2 applied.',
      'request_submitted': '✅ Request Submitted! Check email in 24h.',
      'lock_duration': 'Lock Duration',
      'stake_now': 'STAKE NOW',
      'redeem_btn': 'REDEEM',
      'ok': 'OK',
      'gift_card_amazon': '\$1 Amazon Gift Card',
      'gift_card_coffee': '\$5 Coffee Card',
      // --- New V1.1.0 Keys ---
      'app_name': 'DiSensor™',
      'company_name': 'Qubit Rhythm™',
      'status_idle': 'IDLE',
      'status_active': 'ACTIVE',
      'status_ready': 'READY',
      'status_live': 'LIVE VIEW',
      'status_on': 'ON',
      'status_off': 'OFF',
      'mining_rate_label': 'QBit/hr',
      'total_earnings': 'TOTAL EARNINGS',
      'mining_rules_title': 'Earning Rules',
      'mining_rules_desc': '''• **IDLE**: Base rate (Heartbeat only).
• **ACTIVE**: 1.0x Rate (Moving or High Value Data).
• **PRIME**: +20% Boost on top of any rate.''',
      'staking_explain_title': 'Early Pioneer Program',
      'staking_explain_desc':
          'This is more than a membership—it\'s a shareholder status in the DiSensor Network.\n\nWhen you choose to **Staking (Save)** your QBit, it means you believe in the long-term future of the network. To reward your trust, we grant you a **20% permanent speed boost**, just like earning higher interest on a fixed deposit.',

      // --- Authentication ---
      'auth_subtitle': 'Login to sync your earnings across devices',
      'email': 'Email',
      'password': 'Password',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_too_short': 'Password must be at least 6 characters',
      'forgot_password': 'Forgot Password?',
      'login_register': 'LOGIN / REGISTER',
      'reset_password_title': 'Reset Password',
      'reset_password_desc':
          'Enter your email and we\'ll send you a reset link.',
      'send_reset_email': 'SEND RESET EMAIL',
      'reset_email_sent': 'Reset email sent! Check your inbox.',
      'back_to_login': '← Back to Login',
      'or': 'OR',
      'continue_with_google': 'Continue with Google',
      'continue_with_apple': 'Continue with Apple',
      'continue_with_wechat': 'Continue with WeChat',
      'wechat_coming_soon': 'WeChat login coming soon!',
      'anonymous_warning':
          '⚠️ Anonymous mode: Your earnings are stored locally only and may be lost if you uninstall the app.',
      'continue_anonymous': 'Continue as Guest (Not Recommended)',
      'logout': 'Logout',
      'login_to_sync': 'Login to sync earnings',
    },
    'zh': {
      // --- General ---
      'nodes': '节点数量',
      'nodes_desc': '连接数',
      'uptime': '在线时长',
      'uptime_desc': '稳定性',
      'latency': '网络延迟',
      'latency_desc': '毫秒',
      'network': '网络类型',
      'hexes': '覆盖区域',
      'estimated_earnings': '预计收益',
      'resume_mining': '开始淘金',
      'pause_mining': '暂停淘金',
      'checking_permissions': '正在检查权限...',
      'mining_started': '✅ 淘金成功启动！',
      'location_required': '📍 需要位置权限。',
      'turn_on_gps': '📍 请在设备设置中打开 GPS/位置服务。',
      'perm_denied_forever': '⚠️ 位置权限被永久拒绝。点击设置以启用。',
      'allow_location': '📍 请允许位置访问权限。',
      'settings': '设置',
      'coverage_map': '覆盖地图',
      'map_desc': '探索高收益区域\n优化您的淘金路线',
      'interactive': '交互式',
      'invite_earn': '加入全球数据感知网络',
      'invite_desc': '🏙 充分利用手机空闲资源、随时随地探测环境数据。全自动运行，轻松赚取Q比特。',
      'share_subject': '📱 加入点索网络(DiSensor) 共建探测全球脉搏的数据感知网络',
      'share_body':
          '🌐 您是否知道，您的手机内置了多种传感器，但它们绝大部分时间都在闲置？\n\n加入点索网络(DiSensor Network)将这些沉睡的资源转化为科研价值，并为您回馈收益：\n\n🔬 贡献科研：协助构建全球环境图谱\n⏰ 零感参与：全自动运行，无需干预\n💰 获取收益：赚取Q比特代币，未来分享非凡收益\n\n👉 邀请码：*#CODE#*\nhttps://disensor.qubitrhythm.com/dashboard/start.html?ref=#CODE#',
      'share_link': '邀请好友加入',
      'boost_active': '邀请码已激活',
      'referred_by': '推荐人：',
      'mining_efficiency': '+20% 淘金效率',
      'have_invite': '有邀请码？点击这里',
      'enter_code': '输入邀请码',
      'settings_title': '设置与关于',
      'device_sensors': '设备传感器',
      'about': '关于点索 (DiSensor)',
      'version': '版本',
      'powered_by': '技术支持：量子律动',
      'privacy_policy': '隐私政策',
      'replay_tutorial': '重现引导页面',
      'sensor_accelerometer': '加速度计',
      'sensor_gyroscope': '陀螺仪',
      'sensor_magnetometer': '磁力计',
      'sensor_orientation': '方向传感器',
      'sensor_light': '光照传感器',
      'sensor_pressure': '气压计',
      'sensor_proximity': '距离传感器',
      'sensor_pedometer': '计步器',
      'sensor_gps': 'GPS 定位',
      'sensor_wifi': 'WiFi 扫描',
      'sensor_bluetooth': '蓝牙扫描',
      'sensor_audio': '麦克风',
      'pressure': '气压',
      'pressure_desc': '大气压有助于计算海拔和预测局部天气变化。',
      'noise': '噪音',
      'noise_desc': '环境噪音监测有助于城市噪音污染地图绘制。',
      'bluetooth': '蓝牙密度',
      'bluetooth_desc': '附近的蓝牙设备数量。用于估算人群密度。',
      'cell_signal': '蜂窝信号',
      'cell_signal_desc': '蜂窝网络强度，用于覆盖地图绘制。',
      'jitter': '抖动',
      'jitter_desc': '网络延迟波动。数值越低越好。',
      'packet_loss': '丢包率',
      'packet_loss_desc': '数据丢失百分比。0%为最佳。',
      'network_quality': '网络质量',
      'signal_excellent': '优秀',
      'signal_good': '良好',
      'signal_fair': '一般',
      'signal_poor': '较差',
      'about_qbit': '关于QBit奖励',
      'about_qbit_content':
          'Q比特(QBit)是点索网络(DiSensor Network)的原生激励代币。\n\n您通过贡献宝贵的环境感知数据（如气压、噪音、信号密度等）来获得Q比特。这些数据是构建全球精细化环境图谱的核心。Q比特代表了您在网络早期建设中的贡献权益，其未来价值将随着数据生态的丰富和行业应用而不断体现和增值。\n\n如何赢取：基础贡献 + 实时探索加成。',
      'got_it': '知道了',
      'onboard_1_title': '个体化精细感知',
      'onboard_1_body': '加入新型全球分布式数据感知网络。让您的手机变身一台随时随地的科学探测仪器，充分利用空闲资源。',
      'onboard_2_title': '每人参与科研贡献',
      'onboard_2_body':
          '随时随地探测本地气压、噪音、网络等信号，用超精细本地数据帮助科学家预测天气、研究城市热岛效应或优化公共交通。',
      'onboard_3_title': '获取潜在非凡收益',
      'onboard_3_body': '将您的数据充分转化为潜在价值。每一份数据都在为您赚取QBit币，并在将来可能转化为实际收益。',
      'enter_network': '进入网络',
      'next': '下一步',
      'slogan': '测量世界的脉动',
      'rewards_title': '奖励与权益',
      'invite_activated': '邀请激活！加成已生效 🚀',

      // --- Coverage Map ---
      'legend_my_mining': '我的地盘',
      'legend_my_mining_desc': '您正在此处贡献算力。',
      'legend_covered': '已覆盖',
      'legend_covered_desc': '他人已探索。收益较低。',
      'legend_empty': '空闲区域',
      'legend_empty_desc': '未探索！高收益区域。',
      'mission_title': '任务：扩展网络边界',
      'tap_to_view': '点击查看详情',
      'mission_empty_hex': '空闲区块',
      'mission_high_yield': '高收益 (10倍奖励)',
      'mission_covered_hex': '已覆盖区块',
      'mission_low_yield': '低收益 (1倍奖励)',
      'mission_action_desc': '任务：前往空闲区块（步行/骑行）并停留5分钟以上。',
      'loc_access_needed': '需要位置权限',
      'loc_access_desc': '我们需要位置信息来显示覆盖地图。',
      'open_settings': '打开设置',
      'retry_permission': '重试权限',

      // --- Rewards Page (Exchange Hub) ---
      'exchange_hub': '兑换中心',
      'available_balance': '可用余额',
      'tier_free': '等级: 免费',
      'tier_info_title': '会员等级说明',
      'tier_info_desc': '''💎 **免费用户** (当前等级)
• 基础挖矿速率
• 标准兑换权限

🚀 **先驱合伙人** (即将开放)
• +20% 挖矿加速
• 优先兑换通道
• 专属活动参与权
• 未来网络股权分配

**如何升级：**
质押(留存)1000个Q比特满30天，自动升级为先驱合伙人。''',
      'currency_usd': 'USD',
      'currency_rmb': '人民币',
      'global_pool_title': '全网日兑换池 (24H)',
      'claimed': '已抢光',
      'reset_in': '重置倒计时',
      'lucky_draw_title': '幸运抽奖',
      'lucky_draw_desc': '消耗 10 QBit 试手气，有机会立赢 \$50 礼品卡。',
      'try_luck_btn': '试手气 (-10 QBit)',
      'spinning': '抽奖中...',
      'instant_redemption': '即时兑换',
      'become_prime': '成为先驱合伙人 (Pioneer)',
      'stake_desc': '留存当前余额 30 天。获得 +20% 淘金加速及点索网络未来股权。',
      'enable_staking': '开启留存',
      'confirm_redemption': '确认兑换',
      'email_address': '接收邮箱',
      'confirm': '确认',
      'cancel': '取消',
      'daily_limit_reached': '⚠️ 今日额度已抢完。请明天更早来，或尝试手气！',
      'insufficient_qbit': '⚠️ 余额不足！去地图上探索更多区域吧。',
      'jackpot_win': '🎉 中大奖啦！你赢得了 \$50 礼品卡！\n\n请将以下代码发送至我们的邮箱: ',
      'jackpot_lose': '差一点点！获得0.1Q比特安慰奖。\n\n别灰心，大奖还在等你！',
      'item': '商品:',
      'cost': '消耗:',
      'prime_status': '先驱合伙人 (Prime)',
      'lock_duration_30': '留存 30 天',
      'speed_boost_20': '+20% 加速',
      'stake_warning': '代币在留存期内无法兑换。',
      'staking_activated': '✅ 留存已激活！1.2x 倍率生效。',
      'request_submitted': '✅ 请求已提交！请在 24 小时内查收邮件。',
      'lock_duration': '留存期限',
      'stake_now': '立即留存',
      'redeem_btn': '兑换',
      'ok': '好的',
      'gift_card_amazon': '\$1 亚马逊礼品卡',
      'gift_card_coffee': '\$5 咖啡卡',
      // --- New V1.1.0 Keys ---
      'app_name': '点索(DiSensor)™',
      'company_name': '量子律动(Qubit Rhythm)™',
      'status_idle': '空闲',
      'status_active': '活跃',
      'status_ready': '就绪',
      'status_live': '实时显示',
      'status_on': '开启',
      'status_off': '关闭',
      'mining_rate_label': 'Q比特/小时',
      'total_earnings': '累计收益',
      'mining_rules_title': '收益计算法则',
      'mining_rules_desc': '''• **空闲 (IDLE)**: 基础心跳收益 (低费率)。
• **活跃 (ACTIVE)**: 1.0x 全额收益 (移动中或采集高价值数据)。
• **先驱 (PRIME)**: 在任意费率基础上额外 +20% 加速。''',
      'staking_explain_title': '先驱合伙人计划',
      'staking_explain_desc':
          '这不仅是一个会员身份，更是点索 (DiSensor) 网络的股东。\n\n当您选择**留存**您的Q比特时，意味着您看好网络的长期未来。为了回报您的信任，我们赋予您 **20% 的永久加速权**，就像您往存钱罐里多放了一笔定期存款，我们要给您更高的利息。',

      // --- Authentication ---
      'auth_subtitle': '登录以跨设备同步您的收益',
      'email': '邮箱',
      'password': '密码',
      'email_required': '请输入邮箱',
      'email_invalid': '请输入有效的邮箱地址',
      'password_required': '请输入密码',
      'password_too_short': '密码至少需要6位',
      'forgot_password': '忘记密码？',
      'login_register': '登录 / 注册',
      'reset_password_title': '重置密码',
      'reset_password_desc': '输入您的邮箱，我们将发送重置链接。',
      'send_reset_email': '发送重置邮件',
      'reset_email_sent': '重置邮件已发送！请查收邮箱。',
      'back_to_login': '← 返回登录',
      'or': '或',
      'continue_with_google': '使用 Google 登录',
      'continue_with_apple': '使用 Apple 登录',
      'continue_with_wechat': '使用微信登录',
      'wechat_coming_soon': '微信登录即将上线！',
      'anonymous_warning': '⚠️ 匿名模式下，您的收益仅保存在本地设备。卸载App将导致数据丢失。',
      'continue_anonymous': '以访客身份继续（不推荐）',
      'logout': '退出登录',
      'login_to_sync': '登录以同步收益',
    },
  };

  static String t(String key) {
    String lang = languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']![key] ?? key;
  }
}
