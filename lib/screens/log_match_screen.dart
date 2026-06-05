import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/match_provider.dart';
import '../providers/nav_provider.dart';
import '../models/match_record.dart';

class LogMatchScreen extends ConsumerStatefulWidget {
  const LogMatchScreen({super.key});

  @override
  ConsumerState<LogMatchScreen> createState() => _LogMatchScreenState();
}

class _LogMatchScreenState extends ConsumerState<LogMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _locationController = TextEditingController();
  final _partnerController = TextEditingController();
  
  ScoringFormat _selectedFormat = ScoringFormat.traditional;

  // Traditional Controllers
  final List<TextEditingController> _usSetControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _themSetControllers = List.generate(3, (_) => TextEditingController());

  // Points Controllers
  final _myPointsController = TextEditingController(text: '0');
  final _oppPointsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _locationController.dispose();
    _partnerController.dispose();
    for (var c in _usSetControllers) { c.dispose(); }
    for (var c in _themSetControllers) { c.dispose(); }
    _myPointsController.dispose();
    _oppPointsController.dispose();
    super.dispose();
  }

  void _saveMatch() {
    if (!_formKey.currentState!.validate()) return;
    
    String scoreData = '';

    if (_selectedFormat == ScoringFormat.traditional) {
      List<String> validSets = [];
      for (int i = 0; i < 3; i++) {
        final us = _usSetControllers[i].text.trim();
        final them = _themSetControllers[i].text.trim();
        if (us.isNotEmpty && them.isNotEmpty) {
          validSets.add('$us-$them');
        }
      }
      if (validSets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least one set score.')));
        return;
      }
      scoreData = validSets.join(', ');
    } else {
      final myPts = _myPointsController.text.trim();
      final oppPts = _oppPointsController.text.trim();
      if (myPts.isEmpty || oppPts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both scores.')));
        return;
      }
      scoreData = '$myPts-$oppPts';
    }

    final location = _locationController.text.trim();
    final partner = _partnerController.text.trim();

    // Save using provider
    ref.read(matchProvider.notifier).addMatch(
      date: DateTime.now(),
      location: location.isEmpty ? 'Unknown Court' : location,
      partnerName: partner.isEmpty ? null : partner,
      scoringFormat: _selectedFormat,
      scoreData: scoreData,
    );

    // Reset Form
    _locationController.clear();
    _partnerController.clear();
    for (var c in _usSetControllers) { c.clear(); }
    for (var c in _themSetControllers) { c.clear(); }
    _myPointsController.text = '0';
    _oppPointsController.text = '0';

    // Show success & Redirect
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match Logged Successfully!')));
    ref.read(bottomNavIndexProvider.notifier).setIndex(0);
  }

  void _adjustScore(TextEditingController controller, int delta) {
    int current = int.tryParse(controller.text) ?? 0;
    int next = current + delta;
    if (next < 0) next = 0;
    controller.text = next.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('LOG NEW MATCH', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Track your performance and climb the rankings.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
              const SizedBox(height: 32),
              
              _buildInputLabel('Location Name'),
              _buildTextField(_locationController, Icons.location_on, 'e.g. Padel Club Central'),
              const SizedBox(height: 24),
              
              _buildInputLabel('Partner Name (Optional)'),
              _buildTextField(_partnerController, Icons.group, 'Search recent partners...'),
              const SizedBox(height: 24),
              
              _buildFormatSwitcher(),
              const SizedBox(height: 32),
              
              if (_selectedFormat == ScoringFormat.traditional) _buildTraditionalInputs() else _buildPointsInputs(),
              
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAfx3EyoDjA79PbSoYpgZFqJS_652zL8GziUzoVGh3XNKIDwvUyB2JWHxXZZ1tiR7xme7BiU4jA4dSkpBjlBWvWRWvtSpW3vcYpGR9KIGQXMMpRcB_-tVNlricyCtnW7yYssJiEaBmftyV2mKGMg9qBUHRuVol5KN0tu3jT31gmuoiJnB97euGMesw7N1xS4qdJCw_MTOJH5maXMIPf58FIxx84rrTDYcRn6IdVTR80jSVljCJviDDXU10aDXda-1hfPLNECUFJl67Y'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'APEX PADEL',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.primary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.outline, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.outline),
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildFormatSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFormatButton('Sets (Traditional)', ScoringFormat.traditional)),
          Expanded(child: _buildFormatButton('Quick Match (Points)', ScoringFormat.points)),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String text, ScoringFormat format) {
    final isSelected = _selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 15)]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildTraditionalInputs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text('SET NO.', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      child: Center(child: Text('US', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.outline))),
                    ),
                    const SizedBox(width: 24),
                    Text('—', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.transparent)),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 64,
                      child: Center(child: Text('THEM', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.outline))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < 3; i++) _buildSetRow(i),
      ],
    );
  }

  Widget _buildSetRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('0${index + 1}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSquareInput(_usSetControllers[index]),
                const SizedBox(width: 24),
                Text('—', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
                const SizedBox(width: 24),
                _buildSquareInput(_themSetControllers[index]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSquareInput(TextEditingController controller) {
    return SizedBox(
      width: 64,
      height: 64,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsInputs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05), blurRadius: 60),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('MY SCORE', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary, 
                          letterSpacing: 2.0,
                          shadows: [Shadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), blurRadius: 8)],
                        )),
                        const SizedBox(height: 16),
                        _buildBigDigitalInput(_myPointsController, isPrimary: true),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(width: 2, height: 48, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Theme.of(context).colorScheme.outline]))),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('VS', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic)),
                      ),
                      Container(width: 2, height: 48, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Theme.of(context).colorScheme.outline, Colors.transparent]))),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('OPPONENT', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline, 
                          letterSpacing: 2.0,
                        )),
                        const SizedBox(height: 16),
                        _buildBigDigitalInput(_oppPointsController, isPrimary: false),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildAdjustmentControls(_myPointsController)),
              const SizedBox(width: 48), // Space for VS graphic
              Expanded(child: _buildAdjustmentControls(_oppPointsController)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBigDigitalInput(TextEditingController controller, {required bool isPrimary}) {
    final borderColor = isPrimary ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1);
    final textColor = isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline;
    
    return SizedBox(
      height: 100,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: textColor, fontSize: 64, height: 1.0),
        decoration: InputDecoration(
          filled: true,
          fillColor: isPrimary ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentControls(TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _adjustScore(controller, -1),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Icon(Icons.remove, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => _adjustScore(controller, 1),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))),
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _saveMatch,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SAVE & CALCULATE',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.trending_up, size: 28, color: Theme.of(context).colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
