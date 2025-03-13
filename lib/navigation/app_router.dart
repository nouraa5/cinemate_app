import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:cinema_app/views/home/home_screen.dart';
import 'package:cinema_app/views/auth/login_screen.dart';
import 'package:cinema_app/views/auth/signup_screen.dart';
import 'package:cinema_app/views/auth/forgot_password_screen.dart';
import 'package:cinema_app/views/booking/select_showtime_screen.dart';
import 'package:cinema_app/views/booking/select_seat_screen.dart';
import 'package:cinema_app/views/booking/checkout_screen.dart';
import 'package:cinema_app/views/profile/profile_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(),
      ),
      // GoRoute(
      //   path: '/forgot-password',
      //   builder: (context, state) => ForgotPasswordScreen(),
      // ),
      // GoRoute(
      //   path: '/select-showtime',
      //   builder: (context, state) => SelectShowtimeScreen(),
      // ),
      // GoRoute(
      //   path: '/select-seat',
      //   builder: (context, state) => SelectSeatScreen(),
      // ),
      // GoRoute(
      //   path: '/checkout',
      //   builder: (context, state) => CheckoutScreen(),
      // ),
      // GoRoute(
      //   path: '/profile',
      //   builder: (context, state) => ProfileScreen(),
      // ),
    ],
  );
}
