import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';

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

  // 🔹 Đăng nhập Google
  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _loading = true);
      final googleSignIn = GoogleSignIn(
          scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() => _user = userCredential.user);
      _showSnack('✅ Đăng nhập thành công!');
    } catch (e) {
      _showSnack('❌ Lỗi đăng nhập: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
    setState(() => _user = null);
    _showSnack('👋 Đã đăng xuất.');
  }

  Future<void> _syncProgressToCloud() async {
    if (_user == null) {
      _showSnack('⚠️ Vui lòng đăng nhập!');
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
      _showSnack('☁️ Đồng bộ thành công!');
    } catch (e) {
      _showSnack('❌ Lỗi: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched', false);
    _showSnack('🎈 Đã đặt lại màn chào mừng!');
  }

  Future<void> _resetProgress() async {
    setState(() => _loading = true);
    await ProgressService.resetAll();
    setState(() => _loading = false);
    _showSnack('🧹 Đã đặt lại tiến độ học!');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF5E2CED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(rect),
          child: const Text(
            "Cài đặt",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌈 Gradient Fintech background
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          // 📋 Main content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildSettingCard(
                    Icons.cloud_upload_rounded,
                    "Đồng bộ lên Firebase",
                    "Lưu tiến độ học hiện tại ☁️",
                    _syncProgressToCloud),
                const SizedBox(height: 16),
                _buildSettingCard(Icons.delete_outline_rounded,
                    "Đặt lại tiến độ học", "Xoá toàn bộ dữ liệu 🔄", _resetProgress,
                    color: Colors.redAccent.withOpacity(0.25)),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child:
                      CircularProgressIndicator(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👤 Hồ sơ người dùng
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E2CED), Color(0xFFA58CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8B00), Color(0xFF5E2CED)],
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : const AssetImage('assets/images/mascot/mascot_10.png')
              as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _user?.displayName ?? "Chưa đăng nhập",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
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
    );
  }

  // 🪄 Card chức năng
  Widget _buildSettingCard(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {Color? color}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.95, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: _loading ? null : onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color ?? Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
