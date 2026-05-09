import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.locale = 'en',
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final String locale;

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    onChanged(
      DateTime(
        initial.year,
        initial.month,
        initial.day,
        time.hour,
        time.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.Hm(locale);
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          value == null ? '' : fmt.format(value!),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
