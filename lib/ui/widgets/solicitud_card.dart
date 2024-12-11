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
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile
          ? ExpansionTile(
              backgroundColor: theme.colorScheme.surface,
              collapsedBackgroundColor: theme.colorScheme.surface,
              title: Text(
                solicitud.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildIconText(
                    icon: Icons.calendar_today,
                    text: solicitud.date ?? 'Sin fecha',
                    theme: theme,
                  ),
                  const SizedBox(height: 4),
                  _buildIconText(
                    icon: Icons.access_time,
                    text: '${solicitud.startTime ?? 'N/A'} - ${solicitud.endTime ?? 'N/A'}',
                    theme: theme,
                  ),
                ],
              ),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.surface,
                          theme.colorScheme.surface.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(
                            title: 'Información del Laboratorio',
                            content: [
                              _buildInfoRow('Laboratorio', solicitud.laboratorio ?? '', theme),
                              _buildInfoRow('Curso', solicitud.course, theme),
                              _buildInfoRow('Docente', solicitud.docente ?? '', theme),
                              _buildInfoRow('Estudiantes', solicitud.studentCount, theme),
                              _buildInfoRow('Turno', solicitud.turn, theme),
                            ],
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoSection(
                            title: 'Materiales Requeridos',
                            content: [
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...solicitud.materials.map((material) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.science_outlined,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${material.name} - ${material.quantity} unidades',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitud.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _buildIconText(
                      icon: Icons.calendar_today,
                      text: solicitud.date ?? 'Sin fecha',
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    _buildIconText(
                      icon: Icons.access_time,
                      text: '${solicitud.startTime ?? 'N/A'} - ${solicitud.endTime ?? 'N/A'}',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      title: 'Información General',
                      content: [
                        _buildInfoRow('Laboratorio', solicitud.laboratorio ?? '', theme),
                        _buildInfoRow('Curso', solicitud.course, theme),
                        _buildInfoRow('Docente', solicitud.docente ?? '', theme),
                        _buildInfoRow('Estudiantes', solicitud.studentCount, theme),
                        _buildInfoRow('Turno', solicitud.turn, theme),
                      ],
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      title: 'Materiales Requeridos',
                      content: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...solicitud.materials.map((material) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.science_outlined,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${material.name} - ${material.quantity} unidades',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildIconText({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> content,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title.contains('Materiales') ? Icons.inventory_2 : Icons.science,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}