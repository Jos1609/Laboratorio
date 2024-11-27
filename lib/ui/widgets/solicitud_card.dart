import 'package:flutter/material.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;

  const SolicitudCard({
    Key? key,
    required this.solicitud,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile
          ? ExpansionTile(
              title: Text(
                solicitud.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          solicitud.date ?? 'Sin fecha',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${solicitud.startTime ?? 'N/A'} - ${solicitud.endTime ?? 'N/A'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight:
                        200, // Limitar la altura máxima del contenido expandido
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Curso', solicitud.course),
                        _buildInfoRow('Docente', solicitud.docente ?? ''),
                        _buildInfoRow('Estudiantes', solicitud.studentCount),
                        _buildInfoRow('Turno', solicitud.turn),
                        const SizedBox(height: 12),
                        const Text(
                          'Materiales requeridos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...solicitud.materials.map((material) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 4),
                              child: Text(
                                  '• ${material.name} - ${material.quantity} unidades'),
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solicitud.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          solicitud.date ?? 'Sin fecha',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${solicitud.startTime ?? 'N/A'} - ${solicitud.endTime ?? 'N/A'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Curso', solicitud.course),
                  _buildInfoRow('Docente', solicitud.docente ?? ''),
                  _buildInfoRow('Estudiantes', solicitud.studentCount),
                  _buildInfoRow('Turno', solicitud.turn),
                  const SizedBox(height: 12),
                  const Text(
                    'Materiales requeridos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...solicitud.materials.map((material) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text(
                            '• ${material.name} - ${material.quantity} unidades'),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}