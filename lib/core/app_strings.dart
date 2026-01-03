import 'dart:io';
import 'package:flutter/material.dart';

class AppStrings {
  static String get languageCode {
    try {
      final locale = Platform.localeName.split('_')[0];
      if (locale == 'zh') return 'zh';
      return 'en';
    } catch (e) {
      return 'en';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
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
      'invite_earn': 'Invite & Earn 💰',
      'invite_desc': 'Get 20% constant bonus\nfrom every friend!',
      'share_link': 'Share Link Now',
      'boost_active': 'BOOST ACTIVE',
      'referred_by': 'Referred by:',
      'mining_efficiency': '+20% Mining Efficiency',
      'have_invite': 'Have an invite code? Click here',
      'enter_code': 'Enter Referral Code',
      'settings_title': 'Settings & About',
      'version': 'Version',
      'powered_by': 'Powered by',
      'privacy_policy': 'Privacy Policy',
      'replay_tutorial': 'Replay Tutorial',
      'pressure': 'Pressure',
      'pressure_desc': 'Atmospheric pressure helps in calculating altitude.',
      'noise': 'Noise Level',
      'noise_desc': 'Ambient noise level monitoring.',
      'about_qbit': 'About QBIT Rewards',
      'about_qbit_content':
          'QBIT is the native reward token of the DiSensor network.\n\nYou earn QBIT by contributing valid sensor data (Pressure, Noise, Location). Future value will be determined by network usage and data demand.\n\nMining Rate: Base + Movement Bonus.',
      'got_it': 'GOT IT',
      'onboard_1_title': 'Decentralized Sensing',
      'onboard_1_body':
          'Join the world\'s first distributed environmental network. Your phone is now a scientific instrument.',
      'onboard_2_title': 'Proof of Coverage',
      'onboard_2_body':
          'Map air pressure and noise levels in your city. Help scientists predict weather patterns with hyper-local data.',
      'onboard_3_title': 'Earn QBIT Rewards',
      'onboard_3_body':
          'Turn your data into value. Earn QBIT tokens for every valid contribution to the network.',
      'enter_network': 'ENTER NETWORK',
      'next': 'NEXT',
      'slogan': 'Measuring the World\'s Pulse',
    },
    'zh': {
      'nodes': '节点数量',
      'nodes_desc': '连接数',
      'uptime': '在线时长',
      'uptime_desc': '稳定性',
      'latency': '网络延迟',
      'latency_desc': '毫秒',
      'network': '网络类型',
      'hexes': '覆盖区域',
      'estimated_earnings': '预计收益',
      'resume_mining': '开始挖矿',
      'pause_mining': '暂停挖矿',
      'checking_permissions': '正在检查权限...',
      'mining_started': '✅ 挖矿已成功启动！',
      'location_required': '📍 挖矿需要位置权限。',
      'turn_on_gps': '📍 请在设备设置中打开 GPS/位置服务。',
      'perm_denied_forever': '⚠️ 位置权限被永久拒绝。点击设置以启用。',
      'allow_location': '📍 请允许位置访问权限。',
      'settings': '设置',
      'coverage_map': '覆盖地图',
      'map_desc': '探索高收益区域\n优化您的挖矿路线',
      'interactive': '交互式',
      'invite_earn': '邀请赚钱 💰',
      'invite_desc': '每邀请一位好友\n获得 20% 永久加成！',
      'share_link': '立即分享链接',
      'boost_active': '加成已激活',
      'referred_by': '推荐人：',
      'mining_efficiency': '+20% 挖矿效率',
      'have_invite': '有邀请码？点击这里',
      'enter_code': '输入邀请码',
      'settings_title': '设置与关于',
      'version': '版本',
      'powered_by': '技术支持',
      'privacy_policy': '隐私政策',
      'replay_tutorial': '重播教程',
      'pressure': '气压',
      'pressure_desc': '大气压有助于计算海拔和预测局部天气变化。',
      'noise': '噪音',
      'noise_desc': '环境噪音监测有助于城市噪音污染地图绘制。',
      'about_qbit': '关于 QBIT 奖励',
      'about_qbit_content':
          'QBIT 是 DiSensor 网络的原生奖励代币。\n\n您通过贡献有效的传感器数据（气压、噪音、位置）获得 QBIT。未来价值将由网络使用量和数据需求决定。\n\n挖矿速率：基础 + 移动加成。',
      'got_it': '知道了',
      'onboard_1_title': '去中心化感知',
      'onboard_1_body': '加入全球首个分布式环境网络。您的手机现在就是一台科学仪器。',
      'onboard_2_title': '覆盖证明',
      'onboard_2_body': '绘制您所在城市的气压和噪音水平地图。用超本地化数据帮助科学家预测天气模式。',
      'onboard_3_title': '赚取 QBIT 奖励',
      'onboard_3_body': '将您的数据转化为价值。为网络做出的每一份有效贡献都能赚取 QBIT 代币。',
      'enter_network': '进入网络',
      'next': '下一步',
      'slogan': '测量世界的脉搏',
    },
  };

  static String t(String key) {
    String lang = languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']![key] ?? key;
  }
}
