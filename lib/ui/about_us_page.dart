import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/image_constants.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/network/api_base_helper.dart';
import 'package:arumbu/network/request_type.dart';
import 'package:arumbu/providers/language_provider.dart';
import 'package:arumbu/utility/snackbar.dart';
import 'package:provider/provider.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    final bannerHeight = MediaQuery.of(context).size.height * 0.22;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openFeedbackModal(context);
        },
        icon: const Icon(Icons.feedback_outlined),
        label: Text(localization.translate('Feedback')),
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Stack(
                  children: [
                    Container(
                      height: bannerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(ImageConstants.banner),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  localization.translate('About Us'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  localization.translate(
                                    'Learn more about our mission and values',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      iconSize: 30,
                      tooltip: "Back",
                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(ImageConstants.sipcotLogo, height: 50),
                        Image.asset(ImageConstants.governmentLogo, height: 50),
                      ],
                    ),
                    Text(
                      localization.translate('SIPCOT'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        height: 0.61,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      localization.translate('about sipcot'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.31,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      localization.translate("About Us for Herbal Garden"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.31,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      localization.translate("about sipcot herbal garden"),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.31,
                      ),
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

  void _openFeedbackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: const _FeedbackFormSheet(),
        );
      },
    );
  }
}

class _FeedbackFormSheet extends StatefulWidget {
  const _FeedbackFormSheet();

  @override
  State<_FeedbackFormSheet> createState() => _FeedbackFormSheetState();
}

class _FeedbackFormSheetState extends State<_FeedbackFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentsController = TextEditingController();
  int? _rating;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LanguageProvider>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback_outlined, color: Color(0xFF166534)),
                const SizedBox(width: 8),
                Text(
                  localization.translate('Feedback'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localization.translate('Your Name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? localization.translate('Please enter a value')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: localization.translate('Phone'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) {
                        return localization.translate('Please enter a value');
                      }
                      if (!RegExp(r'^[+0-9\- ()]{7,}$').hasMatch(value)) {
                        return localization.translate('Enter a valid phone');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: localization.translate('Email'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) {
                        return localization.translate('Please enter a value');
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value)) {
                        return localization.translate('Enter a valid email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _rating,
                    items: List.generate(5, (i) => i + 1)
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e,
                            child: Text('$e'),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: localization.translate('Rating'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => v == null
                        ? localization.translate('Please select a value')
                        : null,
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: localization.translate('Comments'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF166534),
                            side: const BorderSide(color: Color(0xFF166534)),
                          ),
                          child: Text(localization.translate('Cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(localization.translate('Submit')),
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
    );
  }

  void _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'ratings': _rating ?? 0,
      'comments': _commentsController.text.trim(),
    };

    // For now, just log and show a confirmation.
    debugPrint('Feedback payload: ' + payload.toString());

    ApiBaseHelper helper = ApiBaseHelper(context);
    final responseData = await helper.callAPI(
      URLs.postFeedback,
      RequestType.POST,
      body: payload,
    );
    log("responseData: $responseData");
    if (responseData['success'] == true && mounted) {
      final localization = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(localization.translate('Thank you for your feedback!')),
      //   ),
      // );
      showSnackBar(
        context,
        localization.translate('Thank you for your feedback!'),
      );
      Navigator.of(context).pop();
    }
  }
}
