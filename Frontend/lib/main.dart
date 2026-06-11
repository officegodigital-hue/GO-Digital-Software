import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/employee_dashboard.dart';
import 'screens/client_onboarding_screen.dart';
import 'screens/Package_Quotation_admin.dart';
import 'screens/create_quotation_screen.dart';
import 'screens/invoice_admin_screen.dart';
import 'screens/add_invoice_screen.dart';
import 'screens/tasks_assign_screen.dart';
import 'screens/employee_status_screen.dart';
import 'screens/manager_review_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/admin_panel_screen.dart'; 
import 'screens/time_management_screen.dart';
import 'screens/performance_page.dart';
  
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GoDigital Portal",

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/employee': (context) => const EmployeeDashboard(),
        '/client': (context) => const ClientOnboardingScreen(),
        '/quotation': (context) => const PackageQuotationAdmin(),
        '/create-quotation': (context) => const CreateQuotationScreen(),
        '/invoice': (context) => const InvoiceAdminScreen(),
        '/add-invoice': (context) => const AddInvoiceScreen(),
        '/tasks': (context) => const TasksAssignScreen(),
        '/employee-status': (context) => const EmployeeStatusScreen(),
        '/manager-review': (context) => const ManagerReviewScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/admin-panel': (context) => const AdminPanelScreen(),
        '/time-manager': (context) => const TimeManagerScreen(),
        '/performance': (context) => const PerformanceScreen(),
      },
    );
  }
}