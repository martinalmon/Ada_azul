import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../datasources/supabase_adoption_repository.dart';
import '../models/adoption_application.dart';

class AdminAdoptionApplicationsScreen
    extends StatefulWidget {
  const AdminAdoptionApplicationsScreen({
    super.key,
  });

  @override
  State<AdminAdoptionApplicationsScreen>
  createState() =>
      _AdminAdoptionApplicationsScreenState();
}

class _AdminAdoptionApplicationsScreenState
    extends State<
        AdminAdoptionApplicationsScreen> {
  final SupabaseAdoptionRepository
  _repository =
  SupabaseAdoptionRepository();

  List<AdoptionApplication>
  _applications = [];

  bool _loading = true;
  String? _error;

  String _filter = 'all';

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    try {
      final applications =
      await _repository
          .getAllApplications();

      if (!mounted) {
        return;
      }

      setState(() {
        _applications =
            applications;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _load();
  }

  List<AdoptionApplication>
  get _filteredApplications {
    if (_filter == 'all') {
      return _applications;
    }

    return _applications
        .where(
          (application) =>
      application.status ==
          _filter,
    )
        .toList();
  }

  Future<void> _changeStatus(
      AdoptionApplication application,
      String status,
      ) async {
    try {
      await _repository
          .updateStatus(
        application.id,
        status,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Solicitud actualizada a ${_statusLabel(status)}.',
          ),
        ),
      );

      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar la solicitud: $error',
          ),
        ),
      );
    }
  }

  Future<void> _openApplication(
      AdoptionApplication application,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _ApplicationDetailScreen(
              application:
              application,
              onStatusChanged:
                  (status) async {
                await _changeStatus(
                  application,
                  status,
                );
              },
            ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitudes de adopción',
          style: TextStyle(
            fontWeight:
            FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
            _reload,
            tooltip:
            'Actualizar',
            icon:
            const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body:
      _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color:
                Colors.redAccent,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'No se pudieron cargar las solicitudes.',
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                _error!,
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton.icon(
                onPressed:
                _reload,
                icon:
                const Icon(
                  Icons.refresh,
                ),
                label:
                const Text(
                  'Reintentar',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final applications =
        _filteredApplications;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection:
          Axis.horizontal,
          padding:
          const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            8,
          ),
          child: Row(
            children: [
              _filterChip(
                'all',
                'Todas',
              ),
              _filterChip(
                'pending',
                'Pendientes',
              ),
              _filterChip(
                'reviewing',
                'En revisión',
              ),
              _filterChip(
                'approved',
                'Aprobadas',
              ),
              _filterChip(
                'rejected',
                'Rechazadas',
              ),
            ],
          ),
        ),

        Expanded(
          child:
          applications.isEmpty
              ? const Center(
            child:
            Padding(
              padding:
              EdgeInsets.all(
                30,
              ),
              child:
              Column(
                mainAxisSize:
                MainAxisSize
                    .min,
                children: [
                  Icon(
                    Icons
                        .description_outlined,
                    size: 64,
                    color:
                    AppColors
                        .primary,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    'No hay solicitudes en esta categoría.',
                    textAlign:
                    TextAlign
                        .center,
                  ),
                ],
              ),
            ),
          )
              : RefreshIndicator(
            onRefresh:
            _load,
            child:
            ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ),
              itemCount:
              applications
                  .length,
              separatorBuilder:
                  (
                  context,
                  index,
                  ) =>
              const SizedBox(
                height: 10,
              ),
              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final application =
                applications[
                index];

                return Card(
                  child:
                  ListTile(
                    contentPadding:
                    const EdgeInsets
                        .all(
                      14,
                    ),
                    leading:
                    CircleAvatar(
                      backgroundColor:
                      AppColors
                          .primarySoft,
                      child:
                      const Icon(
                        Icons
                            .pets,
                        color:
                        AppColors
                            .primary,
                      ),
                    ),
                    title:
                    Text(
                      application
                          .dogName,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                    subtitle:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const SizedBox(
                          height:
                          4,
                        ),
                        Text(
                          application
                              .fullName,
                        ),
                        Text(
                          _date(
                            application
                                .createdAt,
                          ),
                        ),
                        const SizedBox(
                          height:
                          6,
                        ),
                        _StatusLabel(
                          status:
                          application
                              .status,
                        ),
                      ],
                    ),
                    trailing:
                    const Icon(
                      Icons
                          .chevron_right,
                    ),
                    onTap: () =>
                        _openApplication(
                          application,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(
      String value,
      String label,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label:
        Text(label),
        selected:
        _filter == value,
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  String _date(
      DateTime value,
      ) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _statusLabel(
      String status,
      ) {
    return switch (status) {
      'pending' =>
      'Pendiente',
      'reviewing' =>
      'En revisión',
      'approved' =>
      'Aprobada',
      'rejected' =>
      'Rechazada',
      'cancelled' =>
      'Cancelada',
      _ => status,
    };
  }
}

class _ApplicationDetailScreen
    extends StatelessWidget {
  const _ApplicationDetailScreen({
    required this.application,
    required this.onStatusChanged,
  });

  final AdoptionApplication
  application;

  final ValueChanged<String>
  onStatusChanged;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Solicitud',
          style: TextStyle(
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(
          20,
        ),
        children: [
          Text(
            application.dogName,
            style:
            Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _StatusLabel(
            status:
            application.status,
          ),

          const SizedBox(
            height: 22,
          ),

          _InfoCard(
            title:
            'Solicitante',
            children: [
              _InfoRow(
                icon:
                Icons.person_outline,
                label:
                'Nombre',
                value:
                application.fullName,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Número de contacto',
                value: application.contactPhone.isEmpty
                    ? 'No proporcionado'
                    : application.contactPhone,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          _TextCard(
            title:
            'Motivación',
            value:
            application.reason,
          ),

          const SizedBox(
            height: 12,
          ),

          _TextCard(
            title:
            'Vivienda',
            value:
            application
                .housingDetails,
          ),

          const SizedBox(
            height: 12,
          ),

          _TextCard(
            title:
            'Experiencia con mascotas',
            value:
            application
                .experience,
          ),

          if (application
              .comments
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            _TextCard(
              title:
              'Comentarios adicionales',
              value:
              application.comments,
            ),
          ],

          const SizedBox(
            height: 24,
          ),

          Text(
            'Cambiar estado',
            style:
            Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          FilledButton.tonalIcon(
            onPressed: () {
              onStatusChanged(
                'reviewing',
              );

              Navigator.pop(
                context,
              );
            },
            icon:
            const Icon(
              Icons
                  .visibility_outlined,
            ),
            label:
            const Text(
              'Marcar en revisión',
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          FilledButton.icon(
            onPressed: () {
              onStatusChanged(
                'approved',
              );

              Navigator.pop(
                context,
              );
            },
            icon:
            const Icon(
              Icons.check,
            ),
            label:
            const Text(
              'Aprobar solicitud',
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          OutlinedButton.icon(
            onPressed: () {
              onStatusChanged(
                'rejected',
              );

              Navigator.pop(
                context,
              );
            },
            icon:
            const Icon(
              Icons.close,
            ),
            label:
            const Text(
              'Rechazar solicitud',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              const TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color:
            AppColors.primary,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              '$label: $value',
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard
    extends StatelessWidget {
  const _TextCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              value.isEmpty
                  ? 'Sin información'
                  : value,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel
    extends StatelessWidget {
  const _StatusLabel({
    required this.status,
  });

  final String status;

  @override
  Widget build(
      BuildContext context,
      ) {
    final label =
    switch (status) {
      'pending' =>
      'Pendiente',
      'reviewing' =>
      'En revisión',
      'approved' =>
      'Aprobada',
      'rejected' =>
      'Rechazada',
      'cancelled' =>
      'Cancelada',
      _ => status,
    };

    return Chip(
      avatar:
      Icon(
        _icon(status),
        size: 17,
      ),
      label:
      Text(label),
    );
  }

  IconData _icon(
      String status,
      ) {
    return switch (status) {
      'pending' =>
      Icons.schedule,
      'reviewing' =>
      Icons.visibility_outlined,
      'approved' =>
      Icons.check_circle_outline,
      'rejected' =>
      Icons.cancel_outlined,
      'cancelled' =>
      Icons.block,
      _ =>
      Icons.info_outline,
    };
  }
}