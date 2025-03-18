// lib/src/presentation/screens/payment/payment_successful_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';
import 'package:intl/intl.dart';

class PaymentSuccessfulScreen extends StatelessWidget {
  final Payment payment;
  final Subscription subscription;

  const PaymentSuccessfulScreen({
    Key? key,
    required this.payment,
    required this.subscription,
  }) : super(key: key);

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.paymentSuccessful,
      hasBackButton: false,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSpacing.vLg,
                  // Success icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 60,
                    ),
                  ),
                  AppSpacing.vLg,
                  
                  // Success message
                  Text(
                    StringConstants.paymentSuccessful,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vMd,
                  Text(
                    StringConstants.paymentSuccessMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vXl,
                  
                  // Payment details
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction ID',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              payment.transactionId ?? 'N/A',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatDateTime(payment.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Method',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatPaymentMethod(payment.paymentMethod),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppSpacing.vMd,
                        const Divider(),
                        AppSpacing.vMd,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subscription',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${_getDurationName(subscription.duration)} Plan',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duration',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${subscription.durationInDays} days',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Validity',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppSpacing.vMd,
                        const Divider(),
                        AppSpacing.vMd,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount Paid',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '₹${payment.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom action
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppButton(
              label: StringConstants.goToHome,
              onPressed: () => _navigateToHome(context),
              buttonType: AppButtonType.primary,
              buttonSize: AppButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dateTime);
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      default:
        return method.toString().split('.').last;
    }
  }

  String _getDurationName(SubscriptionDuration duration) {
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        return 'Weekly';
      case SubscriptionDuration.fourteenDays:
        return 'Bi-Weekly';
      case SubscriptionDuration.twentyEightDays:
        return 'Monthly';
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.quarterly:
        return 'Quarterly';
      case SubscriptionDuration.halfYearly:
        return 'Half Yearly';
      case SubscriptionDuration.yearly:
        return 'Yearly';
      default:
        return duration.toString().split('.').last;
    }
  }
}