import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencia_form_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IncidenciaFormDialog extends StatelessWidget {
 const IncidenciaFormDialog({super.key});

 @override
 Widget build(BuildContext context) {
   final controller = context.watch<IncidenciaFormController>();

   return Dialog(
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
     child: Container(
       width: MediaQuery.of(context).size.width * 0.9,
       padding: const EdgeInsets.all(20),
       child: Form(
         key: controller.formKey,
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             _buildHeader(),
             const SizedBox(height: 20),
             Expanded(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildSection(
                       'Información Básica',
                       Icons.info_outline,
                       children: [
                         _FormField(
                           label: 'Nombre de la Práctica',
                           icon: Icons.science,
                           onChanged: (value) => controller.updateFormField('nombrePractica', value),
                           validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                           required: true,
                         ),
                         _FormField(
                           label: 'Lugar',
                           icon: Icons.location_on,
                           onChanged: (value) => controller.updateFormField('lugar', value),
                         ),
                         _FormField(
                           label: 'Curso',
                           icon: Icons.school,
                           onChanged: (value) => controller.updateFormField('curso', value),
                         ),
                       ],
                     ),
                     _buildSection(
                       'Detalles del Incidente',
                       Icons.warning_amber,
                       children: [
                         _FormField(
                           label: 'Observador',
                           icon: Icons.person,
                           onChanged: (value) => controller.updateFormField('observador', value),
                         ),
                         _FormField(
                           label: 'Incidente',
                           icon: Icons.report_problem,
                           onChanged: (value) => controller.updateFormField('incidente', value),
                           maxLines: 3,
                           helperText: 'Describe detalladamente el incidente ocurrido',
                         ),
                       ],
                     ),
                     _buildSection(
                       'Seguimiento',
                       Icons.timeline,
                       children: [
                         _FormField(
                           label: 'Tratamiento',
                           icon: Icons.healing,
                           onChanged: (value) => controller.updateFormField('tratamiento', value),
                           maxLines: 2,
                         ),
                         _FormField(
                           label: 'Derivación',
                           icon: Icons.alt_route,
                           onChanged: (value) => controller.updateFormField('derivacion', value),
                         ),
                         _FormField(
                           label: 'Compromiso',
                           icon: Icons.handshake,
                           onChanged: (value) => controller.updateFormField('compromiso', value),
                           maxLines: 2,
                         ),
                       ],
                     ),
                     _buildSection(
                       'Estado y Fecha',
                       Icons.date_range,
                       children: [
                         _DateTimeField(
                           initialValue: controller.formState.fecha,
                           onChanged: (value) => controller.updateFormField('fecha', value),
                         ),
                         _StatusDropdown(
                           value: controller.formState.estado,
                           onChanged: (value) => controller.updateFormField('estado', value ?? 'Pendiente'),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
             ),
             const SizedBox(height: 20),
             _buildButtons(context, controller),
           ],
         ),
       ),
     ),
   );
 }

 Widget _buildHeader() {
   return Row(
     children: [
       Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: Colors.blue.shade100,
           borderRadius: BorderRadius.circular(8),
         ),
         child: Icon(Icons.note_add, color: Colors.blue.shade700),
       ),
       const SizedBox(width: 12),
       const Text(
         'Registrar Nueva Incidencia',
         style: TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
         ),
       ),
     ],
   );
 }

 Widget _buildSection(String title, IconData icon, {required List<Widget> children}) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Padding(
         padding: const EdgeInsets.only(bottom: 16),
         child: Row(
           children: [
             Icon(icon, size: 20, color: Colors.blue),
             const SizedBox(width: 8),
             Text(
               title,
               style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold,
                 color: Colors.blue,
               ),
             ),
           ],
         ),
       ),
       ...children,
       const SizedBox(height: 20),
     ],
   );
 }

 Widget _buildButtons(BuildContext context, IncidenciaFormController controller) {
   return Row(
     mainAxisAlignment: MainAxisAlignment.end,
     children: [
       TextButton.icon(
         icon: const Icon(Icons.close),
         label: const Text('Cancelar'),
         onPressed: () => Navigator.pop(context),
         style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
       ),
       const SizedBox(width: 12),
       ElevatedButton.icon(
         icon: const Icon(Icons.save),
         label: const Text('Guardar Incidencia'),
         onPressed: () => controller.submitForm(context),
         style: ElevatedButton.styleFrom(
           backgroundColor: Colors.blue,
           foregroundColor: Colors.white,
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
         ),
       ),
     ],
   );
 }
}

class _FormField extends StatelessWidget {
 final String label;
 final IconData icon;
 final Function(String) onChanged;
 final String? Function(String?)? validator;
 final int maxLines;
 final String? helperText;
 final bool required;

 const _FormField({
   required this.label,
   required this.icon,
   required this.onChanged,
   this.validator,
   this.maxLines = 1,
   this.helperText,
   this.required = false,
 });

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.only(bottom: 16),
     child: TextFormField(
       onChanged: onChanged,
       validator: validator,
       maxLines: maxLines,
       decoration: InputDecoration(
         labelText: label + (required ? ' *' : ''),
         helperText: helperText,
         prefixIcon: Icon(icon),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: Colors.blue, width: 2),
         ),
         filled: true,
         fillColor: Colors.grey.shade50,
       ),
     ),
   );
 }
}

class _DateTimeField extends StatelessWidget {
 final DateTime initialValue;
 final Function(DateTime) onChanged;

 const _DateTimeField({
   required this.initialValue,
   required this.onChanged,
 });

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.only(bottom: 16),
     child: TextFormField(
       controller: TextEditingController(
         text: DateFormat('yyyy-MM-dd HH:mm').format(initialValue),
       ),
       decoration: InputDecoration(
         labelText: 'Fecha y Hora',
         prefixIcon: const Icon(Icons.calendar_today),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: Colors.blue, width: 2),
         ),
         filled: true,
         fillColor: Colors.grey.shade50,
       ),
       readOnly: true,
       onTap: () => _selectDateTime(context),
     ),
   );
 }

 Future<void> _selectDateTime(BuildContext context) async {
   final DateTime? date = await showDatePicker(
     context: context,
     initialDate: initialValue,
     firstDate: DateTime(2000),
     lastDate: DateTime(2101),
     builder: (context, child) => Theme(
       data: Theme.of(context).copyWith(
         colorScheme: const ColorScheme.light(
           primary: Colors.blue,
           onPrimary: Colors.white,
           surface: Colors.white,
           onSurface: Colors.black,
         ),
       ),
       child: child!,
     ),
   );

   if (date != null) {
     // ignore: use_build_context_synchronously
     final TimeOfDay? time = await showTimePicker(
       context: context,
       initialTime: TimeOfDay.fromDateTime(initialValue),
       builder: (context, child) => Theme(
         data: Theme.of(context).copyWith(
           colorScheme: const ColorScheme.light(
             primary: Colors.blue,
             surface: Colors.white,
             onSurface: Colors.black,
           ),
         ),
         child: child!,
       ),
     );

     if (time != null) {
       onChanged(DateTime(
         date.year,
         date.month,
         date.day,
         time.hour,
         time.minute,
       ));
     }
   }
 }
}

class _StatusDropdown extends StatelessWidget {
 final String value;
 final Function(String?) onChanged;

 const _StatusDropdown({
   required this.value,
   required this.onChanged,
 });

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.only(bottom: 16),
     child: DropdownButtonFormField<String>(
       decoration: InputDecoration(
         labelText: 'Estado',
         prefixIcon: const Icon(Icons.flag),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: Colors.blue, width: 2),
         ),
         filled: true,
         fillColor: Colors.grey.shade50,
       ),
       value: value,
       items: ['Pendiente', 'Devuelto'].map((String value) {
         return DropdownMenuItem<String>(
           value: value,
           child: Text(value),
         );
       }).toList(),
       onChanged: onChanged,
     ),
   );
 }
}