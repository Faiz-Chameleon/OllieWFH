import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:country_state_city_picker_2/model/select_status_model.dart' as status_model;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/common/common.dart';

class FilledSelectState extends StatefulWidget {
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final VoidCallback? onCountryTap;
  final VoidCallback? onStateTap;
  final VoidCallback? onCityTap;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final Color? dropdownColor;
  final InputDecoration decoration;
  final double spacing;
  final String? selectedCountryLabel;
  final String? selectedStateLabel;
  final String? selectedCityLabel;

  const FilledSelectState({
    super.key,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    this.decoration = const InputDecoration(),
    this.spacing = 0.0,
    this.style,
    this.selectedCountryLabel,
    this.selectedStateLabel,
    this.selectedCityLabel,
    this.labelStyle,
    this.dropdownColor,
    this.onCountryTap,
    this.onStateTap,
    this.onCityTap,
  });

  @override
  State<FilledSelectState> createState() => _FilledSelectStateState();
}

class _FilledSelectStateState extends State<FilledSelectState> {
  final List<status_model.StatusModel> _countryModels = [];
  final List<String> _countryItems = [];
  final List<String> _stateItems = [];
  final List<String> _cityItems = [];

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<List<dynamic>> _loadRawData() async {
    final res = await rootBundle.loadString('packages/country_state_city_picker_2/lib/assets/country.json');
    return jsonDecode(res) as List<dynamic>;
  }

  Future<void> _loadCountries() async {
    final data = await _loadRawData();
    final models = data.map((entry) => status_model.StatusModel.fromJson(entry as Map<String, dynamic>)).toList();

    if (!mounted) return;
    setState(() {
      _countryModels
        ..clear()
        ..addAll(models);
      _countryItems
        ..clear()
        ..addAll(models.map(_composeCountryLabel));
    });
  }

  status_model.StatusModel? _findCountryModel(String? countryValue) {
    if (countryValue == null) return null;
    for (final model in _countryModels) {
      if (_composeCountryLabel(model) == countryValue) {
        return model;
      }
    }
    return null;
  }

  status_model.State? _findStateModel(status_model.StatusModel? country, String? stateValue) {
    if (country == null || stateValue == null) return null;
    for (final state in country.state ?? <status_model.State>[]) {
      if (state.name == stateValue) {
        return state;
      }
    }
    return null;
  }

  List<String> _statesForCountry(String? countryValue) {
    final model = _findCountryModel(countryValue);
    if (model == null) return [];
    return (model.state ?? <status_model.State>[]).map((state) => state.name).whereType<String>().toSet().toList()..sort();
  }

  List<String> _citiesForState(String? countryValue, String? stateValue) {
    final country = _findCountryModel(countryValue);
    final state = _findStateModel(country, stateValue);
    if (state == null) return [];
    return (state.city ?? <status_model.City>[]).map((city) => city.name).whereType<String>().toSet().toList()..sort();
  }

  void _onCountrySelected(String? value) {
    widget.onCountryTap?.call();
    final normalized = value ?? "";

    if (!mounted) return;
    setState(() {
      _selectedCountry = value;
      _selectedState = null;
      _selectedCity = null;
      _stateItems
        ..clear()
        ..addAll(_statesForCountry(value));
      _cityItems.clear();
    });

    widget.onCountryChanged(normalized);
    widget.onStateChanged("");
    widget.onCityChanged("");
  }

  void _onStateSelected(String? value) {
    widget.onStateTap?.call();
    final normalized = value ?? "";

    if (!mounted) return;
    setState(() {
      _selectedState = value;
      _selectedCity = null;
      _cityItems
        ..clear()
        ..addAll(_citiesForState(_selectedCountry, value));
    });

    widget.onStateChanged(normalized);
    widget.onCityChanged("");
  }

  void _onCitySelected(String? value) {
    widget.onCityTap?.call();
    final normalized = value ?? "";

    if (!mounted) return;
    setState(() {
      _selectedCity = value;
    });

    widget.onCityChanged(normalized);
  }

  InputDecoration _buildDecoration(String hint) {
    final base = widget.decoration;
    final labelStyle = widget.labelStyle ?? base.labelStyle ?? prominentFieldTextStyle(color: Colors.grey);
    final hintStyle = base.hintStyle ?? prominentFieldHintStyle(color: const Color(0xFF6D6D6D));

    return base.copyWith(
      hintText: hint,
      hintStyle: hintStyle,
      errorStyle: base.errorStyle ?? prominentFieldErrorStyle(),
      floatingLabelBehavior: base.floatingLabelBehavior ?? FloatingLabelBehavior.never,
      labelStyle: labelStyle,
      filled: base.filled ?? true,
      fillColor: base.fillColor ?? Colors.white,
      contentPadding: base.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border:
          base.border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
      enabledBorder:
          base.enabledBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
      focusedBorder:
          base.focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
      disabledBorder:
          base.disabledBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
      errorBorder:
          base.errorBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
      focusedErrorBorder:
          base.focusedErrorBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff463C3380)),
          ),
    );
  }

  DropdownButtonFormField<String> _buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    final textStyle = widget.style ?? prominentFieldTextStyle(color: Colors.black);

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: textStyle),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      style: textStyle,
      menuMaxHeight: 300,
      dropdownColor: widget.dropdownColor ?? Colors.white,
      decoration: _buildDecoration(hint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryLabel = widget.selectedCountryLabel ?? "Select Country";
    final stateLabel = widget.selectedStateLabel ?? "Select State/Province";
    final cityLabel = widget.selectedCityLabel ?? "Select City";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDropdown(
          hint: countryLabel,
          items: _countryItems,
          value: _selectedCountry,
          onChanged: _onCountrySelected,
          enabled: _countryItems.isNotEmpty,
        ),
        SizedBox(height: widget.spacing),
        _buildDropdown(hint: stateLabel, items: _stateItems, value: _selectedState, onChanged: _onStateSelected, enabled: _stateItems.isNotEmpty),
        SizedBox(height: widget.spacing),
        _buildDropdown(hint: cityLabel, items: _cityItems, value: _selectedCity, onChanged: _onCitySelected, enabled: _cityItems.isNotEmpty),
      ],
    );
  }
}

String _composeCountryLabel(status_model.StatusModel model) {
  final emoji = model.emoji ?? "";
  final name = model.name ?? "";
  return "${emoji.isNotEmpty ? "$emoji    " : ""}$name";
}
