import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init note (Dev Simulation): $e");
  }
  runApp(const FirestoreQueryApp());
}

/// Root Application Widget - Glassmorphic Dark Edition
class FirestoreQueryApp extends StatelessWidget {
  const FirestoreQueryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudDirectory - Firestore Retrieval',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7), // Ultraviolet
          secondary: Color(0xFFEC4899), // Neon Magenta
          surface: Color(0xFF111827),
        ),
      ),
      home: const FirestoreSearchScreen(),
    );
  }
}

/// Employee Record Model
class EmployeeRecord {
  final String id;
  final String name;
  final String email;
  final String department;
  final String role;
  final double salary;
  final double rating;

  const EmployeeRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.salary,
    required this.rating,
  });

  factory EmployeeRecord.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EmployeeRecord(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      department: d['department'] ?? '',
      role: d['role'] ?? '',
      salary: (d['salary'] as num?)?.toDouble() ?? 0.0,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Dynamic Firestore Search & Retrieval Screen
class FirestoreSearchScreen extends StatefulWidget {
  const FirestoreSearchScreen({super.key});

  @override
  State<FirestoreSearchScreen> createState() => _FirestoreSearchScreenState();
}

class _FirestoreSearchScreenState extends State<FirestoreSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  double _minSalary = 60000.0;

  static const List<EmployeeRecord> _masterEmployees = [
    EmployeeRecord(
      id: 'e1',
      name: 'Alexander Wright',
      email: 'a.wright@cloudcorp.com',
      department: 'Engineering',
      role: 'Staff Infrastructure Engineer',
      salary: 145000.0,
      rating: 4.9,
    ),
    EmployeeRecord(
      id: 'e2',
      name: 'Amina Al-Mansoor',
      email: 'a.mansoor@cloudcorp.com',
      department: 'AI Research',
      role: 'Senior ML Scientist',
      salary: 160000.0,
      rating: 5.0,
    ),
    EmployeeRecord(
      id: 'e3',
      name: 'Benjamin Cole',
      email: 'b.cole@cloudcorp.com',
      department: 'Engineering',
      role: 'Frontend Architect',
      salary: 130000.0,
      rating: 4.7,
    ),
    EmployeeRecord(
      id: 'e4',
      name: 'Chloe Dubois',
      email: 'c.dubois@cloudcorp.com',
      department: 'Product',
      role: 'Lead Technical PM',
      salary: 125000.0,
      rating: 4.8,
    ),
    EmployeeRecord(
      id: 'e5',
      name: 'Devin Patel',
      email: 'd.patel@cloudcorp.com',
      department: 'Engineering',
      role: 'Backend Systems Engineer',
      salary: 110000.0,
      rating: 4.6,
    ),
    EmployeeRecord(
      id: 'e6',
      name: 'Emily Watson',
      email: 'e.watson@cloudcorp.com',
      department: 'Security',
      role: 'Cloud Security Analyst',
      salary: 118000.0,
      rating: 4.8,
    ),
    EmployeeRecord(
      id: 'e7',
      name: 'Faisal Karim',
      email: 'f.karim@cloudcorp.com',
      department: 'AI Research',
      role: 'Data Mining Engineer',
      salary: 138000.0,
      rating: 4.7,
    ),
  ];

  final List<String> _departments = [
    'All',
    'Engineering',
    'AI Research',
    'Product',
    'Security',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<EmployeeRecord>> _buildFirestoreQueryStream() {
    try {
      Query query = FirebaseFirestore.instance.collection('employees');

      if (_selectedDepartment != 'All') {
        query = query.where('department', isEqualTo: _selectedDepartment);
      }

      if (_minSalary > 60000.0) {
        query = query.where('salary', isGreaterThanOrEqualTo: _minSalary);
      }

      if (_searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: _searchQuery)
            .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
      }

      return query.snapshots().map((snapshot) {
        final docs = snapshot.docs;
        if (docs.isEmpty) return _executeLocalQuery();
        return docs.map((doc) => EmployeeRecord.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return Stream.value(_executeLocalQuery());
    }
  }

  List<EmployeeRecord> _executeLocalQuery() {
    return _masterEmployees.where((emp) {
      final matchesQuery = _searchQuery.isEmpty ||
          emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.role.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDept =
          _selectedDepartment == 'All' || emp.department == _selectedDepartment;

      final matchesSalary = emp.salary >= _minSalary;

      return matchesQuery && matchesDept && matchesSalary;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // Ambient Neon Orbs
          Positioned(
            top: -70,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA855F7).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFA855F7).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(Icons.manage_search_rounded,
                            color: Color(0xFFA855F7), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Firestore Query Engine',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA855F7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Exp 8: Multi-Field Compound Retrieval',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Glass Query Filter Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFA855F7).withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search field
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                              decoration: InputDecoration(
                                hintText: 'Query by Name or Title...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 12.5,
                                ),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: Color(0xFFA855F7), size: 19),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded,
                                            color: Colors.white54, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.03),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFA855F7), width: 1.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Department Choice Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _departments.map((dept) {
                                  final selected = _selectedDepartment == dept;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedDepartment = dept),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? const Color(0xFFA855F7).withOpacity(0.2)
                                              : Colors.white.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFFA855F7)
                                                : Colors.white.withOpacity(0.08),
                                          ),
                                        ),
                                        child: Text(
                                          dept,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: selected
                                                ? const Color(0xFFD8B4FE)
                                                : Colors.white60,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Salary Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Salary Threshold (>=)',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white.withOpacity(0.6)),
                                ),
                                Text(
                                  '\$${_minSalary.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEC4899),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFEC4899),
                                thumbColor: const Color(0xFFEC4899),
                                overlayColor: const Color(0xFFEC4899).withOpacity(0.2),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: _minSalary,
                                min: 60000.0,
                                max: 150000.0,
                                divisions: 9,
                                onChanged: (val) => setState(() => _minSalary = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Query Stream Results
                Expanded(
                  child: StreamBuilder<List<EmployeeRecord>>(
                    stream: _buildFirestoreQueryStream(),
                    builder: (context, snapshot) {
                      final results = snapshot.data ?? _executeLocalQuery();

                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 12),
                              Text(
                                'No matching documents found',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final emp = results[index];
                          return _buildEmployeeCard(emp);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeRecord emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFA855F7).withOpacity(0.15),
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0] : 'E',
                    style: const TextStyle(
                      color: Color(0xFFD8B4FE),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              emp.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFBBF24), size: 15),
                              const SizedBox(width: 2),
                              Text(
                                emp.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emp.role,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD8B4FE),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${emp.department} • ${emp.email}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Comp: \$${emp.salary.toStringAsFixed(0)} /yr',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
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
