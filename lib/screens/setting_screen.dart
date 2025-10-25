import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/progress_service.dart';

/// ⚙️ Wonder Kids Math — Firebase Login + Cloud Sync (fix for google_sign_in 7.2.0)
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _loading = false;
  String? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final time = await ProgressService.getLastSyncTime();
    setState(() => _lastSyncTime = time);
  }

  /// 🔹 Đăng nhập Google (chuẩn mới Flutter 3.24)
  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      // 🔹 googleAuth.accessToken vẫn tồn tại trong 7.2.0
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      setState(() => _user = userCredential.user);

      _showSnack('✅ Đăng nhập thành công với Google!');
    } catch (e) {
      _showSnack('❌ Lỗi đăng nhập: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 🔹 Đăng xuất
  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
    setState(() => _user = null);
    _showSnack('👋 Đã đăng xuất khỏi tài khoản.');
  }

  /// 🔹 Xoá dữ liệu Firebase & đăng xuất
  Future<void> _signOutAndDeleteFirebase() async {
    if (_user == null) {
      _showSnack('⚠️ Bạn chưa đăng nhập!');
      return;
    }

    final confirm = await _showConfirmDialog(
      "Xoá dữ liệu trên Cloud?",
      "Toàn bộ tiến độ học của bé trên Firebase sẽ bị xoá vĩnh viễn.",
      confirmText: "Xoá",
      confirmColor: Colors.redAccent,
    );

    if (!confirm) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('wonderkids_progress')
          .doc(_user!.uid)
          .delete();

      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await _auth.signOut();
      setState(() => _user = null);

      _showSnack('🧨 Đã xoá dữ liệu học khỏi Firebase & đăng xuất!');
    } catch (e) {
      _showSnack('❌ Lỗi khi xoá dữ liệu: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// ☁️ Đồng bộ tiến độ học lên Firebase
  Future<void> _syncProgressToCloud() async {
    if (_user == null) {
      _showSnack('⚠️ Vui lòng đăng nhập để đồng bộ!');
      return;
    }

    setState(() => _loading = true);
    try {
      final levels = await ProgressService.ensureDefaultLevels(() => []);
      final data = levels.map((e) => e.toJson()).toList();

      await FirebaseFirestore.instance
          .collection('wonderkids_progress')
          .doc(_user!.uid)
          .set({'levels': data, 'updated': DateTime.now().toIso8601String()});

      await _loadLastSyncTime();
      _showSnack('☁️ Đã đồng bộ tiến độ học lên Firebase!');
    } catch (e) {
      _showSnack('❌ Lỗi khi đồng bộ: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 📥 Tải tiến độ học từ Firebase (có xác nhận)
  Future<void> _restoreProgressFromCloud() async {
    if (_user == null) {
      _showSnack('⚠️ Vui lòng đăng nhập để tải dữ liệu!');
      return;
    }

    final confirm = await _showConfirmDialog(
      "Ghi đè dữ liệu local?",
      "Tiến độ học hiện tại của bé sẽ được thay thế bằng dữ liệu trên Cloud.",
      confirmText: "Khôi phục",
      confirmColor: Colors.greenAccent,
    );

    if (!confirm) return;

    setState(() => _loading = true);
    try {
      final ok = await ProgressService.restoreFromFirebase();
      if (ok) {
        await _loadLastSyncTime();
        _showSnack('📥 Đã tải tiến độ học từ Firebase về máy!');
      } else {
        _showSnack('📭 Không tìm thấy dữ liệu trên Cloud!');
      }
    } catch (e) {
      _showSnack('❌ Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 🎈 Reset màn chào mừng
  Future<void> _resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched', false);
    _showSnack('🎈 Đã đặt lại màn chào mừng. Lần sau sẽ hiển thị lại!');
  }

  /// 🔄 Xoá toàn bộ tiến độ local + reset flag hoàn thành
  Future<void> _resetProgress() async {
    final confirm = await _showConfirmDialog(
      "Đặt lại toàn bộ tiến độ học?",
      "Tất cả cấp độ, sao và trạng thái hoàn thành sẽ bị xoá. Bé sẽ bắt đầu lại từ đầu.",
      confirmText: "Đặt lại",
      confirmColor: Colors.orangeAccent,
    );

    if (!confirm) return;

    setState(() => _loading = true);

    // 🧹 Gọi service xoá toàn bộ tiến độ
    await ProgressService.resetAll();

    // 🔹 Xoá các flag hoàn thành level (isFinalRewardShown_xxx)
    final prefs = await SharedPreferences.getInstance();
    for (var key in prefs.getKeys()) {
      if (key.startsWith('isFinalRewardShown_')) {
        await prefs.remove(key);
        debugPrint("🧹 Reset flag hoàn thành: $key");
      }
    }

    setState(() => _loading = false);
    _showSnack('🧹 Đã xoá tiến độ học local và reset trạng thái hoàn thành!');
  }

  /// 🪄 SnackBar
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
      ),
    );
  }

  /// 💬 Dialog xác nhận
  Future<bool> _showConfirmDialog(
    String title,
    String message, {
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withOpacity(0.95),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Huỷ"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return "Chưa có dữ liệu";
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return "Không xác định";
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Cài đặt"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.05),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E2E), const Color(0xFF5E2CED)]
                : [
                    const Color(0xFF5E2CED),
                    const Color(0xFFA58CFF),
                    const Color(0xFFFF8B00),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            _buildProfileCard(),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.cloud_upload_rounded,
              title: "Đồng bộ lên Firebase",
              subtitle: "Lưu tiến độ học hiện tại của bé ☁️",
              onTap: _syncProgressToCloud,
            ),
            const SizedBox(height: 6),
            if (_lastSyncTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 56.0),
                child: Text(
                  "🕓 Cập nhật gần nhất: ${_formatTime(_lastSyncTime)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.cloud_download_rounded,
              title: "Tải tiến độ từ Firebase",
              subtitle: "Khôi phục dữ liệu học khi cài lại app 📥",
              onTap: _restoreProgressFromCloud,
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.refresh_rounded,
              title: "Phát lại màn chào mừng",
              subtitle:
                  "Lần mở app kế tiếp sẽ hiển thị lại màn 'Bắt đầu thôi!' 🎉",
              onTap: _resetWelcome,
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.delete_outline_rounded,
              title: "Xoá tiến độ học local",
              subtitle: "Đặt lại toàn bộ level về trạng thái ban đầu 🔄",
              onTap: _resetProgress,
              color: Colors.redAccent.withOpacity(0.25),
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.dangerous_rounded,
              title: "Đăng xuất & Xoá dữ liệu Firebase",
              subtitle: "Xoá bản sao tiến độ của bé trên Cloud ☁️",
              onTap: _signOutAndDeleteFirebase,
              color: Colors.red.withOpacity(0.35),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Wonder Kids Math © 2025\nTPBank Fintech Style ✨",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white.withOpacity(0.08),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : const AssetImage('assets/images/mascot/mascot_10.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _user?.displayName ?? "Chưa đăng nhập",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : _user != null
                    ? _signOut
                    : _signInWithGoogle,
                child: Text(
                  _user != null ? "Đăng xuất" : "Đăng nhập",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: _loading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
