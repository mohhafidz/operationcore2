import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/repository/user_repository.dart';

class UserManagement extends ConsumerStatefulWidget {
  const UserManagement({super.key});

  @override
  ConsumerState<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends ConsumerState<UserManagement> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  final List<String> _roles = ["Mekanik", "SA", "Leader", "CS Service"];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddUserForm(),
              const SizedBox(width: 24),
              Expanded(child: _buildUserTable()),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildStatCards() {
  //   return Row(
  //     children: [
  //       _statCard("TOTAL USERS", "156", Icons.people_outline_rounded, const Color(0xff3B82F6)),
  //       const SizedBox(width: 20),
  //       _statCard("ACTIVE NOW", "42", Icons.bolt_rounded, const Color(0xff10B981)),
  //       const SizedBox(width: 20),
  //       _statCard("ADMIN ROLES", "8", Icons.shield_outlined, const Color(0xffec4899)),
  //       const SizedBox(width: 20),
  //       _statCard("NEW THIS MONTH", "12", Icons.person_add_alt_1_rounded, const Color(0xffEAB308)),
  //     ],
  //   );
  // }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: CardCustume(
        padding: 24,
        widget: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "USER MANAGEMENT",
          style: GoogleFonts.inter(
            color: AppColors.accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "System User Registry",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        Text(
          "Manage application users, roles, and access permissions",
          style: GoogleFonts.inter(color: AppColors.textGray, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAddUserForm() {
    return SizedBox(
      width: 380,
      child: CardCustume(
        padding: 24,
        widget: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CREATE NEW USER",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Fill in the details to add a new system user",
                style: GoogleFonts.inter(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: "FULL NAME",
                controller: _nameController,
                hint: "Enter full name",
                icon: Icons.person_outline_rounded,
              ),
              if (_selectedRole != "Mekanik" && _selectedRole != "Leader") ...[
                const SizedBox(height: 20),
                _buildInputField(
                  label: "EMAIL ADDRESS",
                  controller: _emailController,
                  hint: "name@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              const SizedBox(height: 20),
              _buildRoleDropdown(),
              if (_selectedRole != "Mekanik" && _selectedRole != "Leader") ...[
                const SizedBox(height: 20),
                _buildInputField(
                  label: "PASSWORD",
                  controller: _passwordController,
                  hint: "••••••••",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: "CONFIRM PASSWORD",
                  controller: _confirmPasswordController,
                  hint: "••••••••",
                  icon: Icons.lock_clock_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "CREATE USER",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textGray,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textGray.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppColors.textGray, size: 20),
            filled: true,
            fillColor: const Color(0xff0F172A),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Color(0xffF43F5E), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ASSIGN ROLE",
          style: GoogleFonts.inter(
            color: AppColors.textGray,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          items: _roles
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(
                    role,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select a role";
            }
            return null;
          },
          dropdownColor: const Color(0xff1E293B),
          decoration: InputDecoration(
            hintText: "Select role",
            hintStyle: TextStyle(
              color: AppColors.textGray.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.shield_outlined,
              color: AppColors.textGray,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xff0F172A),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final repo = ref.read(userRepositoryProvider);

        final bool isPassiveRole = _selectedRole == "Mekanik" || _selectedRole == "Leader";
        
        await repo.createUser(
          name: _nameController.text.trim(),
          email: isPassiveRole ? "" : _emailController.text.trim(),
          password: isPassiveRole ? "nopassword" : _passwordController.text,
          role: _selectedRole!,
        );

        // Close loading indicator
        if (mounted) Navigator.pop(context);

        // Success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _selectedRole = null;
        });
      } catch (e) {
        // Close loading indicator if open
        if (mounted) Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildUserTable() {
    final userListAsync = ref.watch(userListProvider);

    return CardCustume(
      padding: 0,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userListAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: AppColors.textGray),
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth:
                        MediaQuery.of(context).size.width -
                        400 -
                        48, // Responsive min width
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTableHeader(),
                        const Divider(height: 1, color: Colors.white10),
                        ...users.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return _buildUserRow(
                            index + 1,
                            user['name'] ?? '',
                            user['email'] ?? '',
                            user['role'] ?? '',
                            user['userId'] ?? '',
                            user['id'] ?? '',
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(
                child: Text(
                  "Error: $err",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget _buildFilterButton(String label) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: AppColors.primary,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.white10),
  //     ),
  //     child: Row(
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(color: Colors.white, fontSize: 13),
  //         ),
  //         const SizedBox(width: 8),
  //         const Icon(
  //           Icons.keyboard_arrow_down,
  //           color: AppColors.textGray,
  //           size: 18,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTableHeader() {
    return Container(
      constraints: const BoxConstraints(minWidth: 900),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _tableHeaderCell("#", width: 40),
          _tableHeaderCell("USER ID", width: 120),
          _tableHeaderCell("NAME", isExpanded: true),
          _tableHeaderCell("EMAIL ADDRESS", isExpanded: true),
          _tableHeaderCell("ROLE", width: 150, isCenter: true),
          _tableHeaderCell("ACTIONS", width: 100, isCenter: true),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String label, {
    double? width,
    bool isCenter = false,
    bool isExpanded = false,
  }) {
    Widget cell = Text(
      label,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: AppColors.textGray,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 1.0,
      ),
    );

    if (isExpanded) {
      return Expanded(
        child: Padding(padding: const EdgeInsets.only(right: 16), child: cell),
      );
    }
    return SizedBox(width: width, child: cell);
  }

  Widget _buildUserRow(
    int no,
    String name,
    String email,
    String role,
    String userID,
    String docId,
  ) {
    Color roleColor;
    switch (role.toLowerCase()) {
      case 'mekanik':
        roleColor = const Color(0xff10B981); // Emerald
        break;
      case 'sa':
        roleColor = const Color(0xff06B6D4); // Cyan
        break;
      case 'leader':
        roleColor = const Color(0xffec4899); // Pink
        break;
      case 'cs service':
        roleColor = const Color(0xffEAB308); // Yellow
        break;
      default:
        roleColor = AppColors.textGray;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 900),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(.05)),
        ),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  no.toString(),
                  style: GoogleFonts.inter(
                    color: AppColors.textGray.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  userID,
                  style: GoogleFonts.inter(
                    color: AppColors.accentBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              roleColor.withOpacity(0.2),
                              roleColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: roleColor.withOpacity(0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: GoogleFonts.inter(
                            color: roleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    email.isNotEmpty ? email : '-',
                    style: GoogleFonts.inter(
                      color: AppColors.textGray,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: roleColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconButton(
                      Icons.edit_rounded,
                      AppColors.accentBlue,
                      "Edit",
                    ),
                    const SizedBox(width: 8),
                    _iconButton(
                      Icons.delete_outline_rounded,
                      const Color(0xffF43F5E),
                      "Delete",
                      onTap: () => _confirmDelete(docId, name),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    Color color,
    String tooltip, {
    VoidCallback? onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }

  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1E293B),
        title: const Text("Delete User", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete user $name?",
          style: const TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(userRepositoryProvider).deleteUser(docId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User deleted"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xffF43F5E)),
            ),
          ),
        ],
      ),
    );
  }
}
