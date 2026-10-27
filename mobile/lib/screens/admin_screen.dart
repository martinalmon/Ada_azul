import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'admin_adoption_applications_screen.dart';
import 'admin_dogs_screen.dart';
import 'admin_donations_screen.dart';
import 'admin_events_screen.dart';

class AdminScreen
    extends StatelessWidget {
  const AdminScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administración',
          style: TextStyle(
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(
          16,
        ),
        children: [
          const _AdminHeader(),

          const SizedBox(
            height: 18,
          ),

          _AdminOption(
            icon:
            Icons.pets,
            title:
            'Perritos',
            subtitle:
            'Agregar, editar, ocultar o cambiar el estado de los perros.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const AdminDogsScreen(),
                ),
              );
            },
          ),

          _AdminOption(
            icon:
            Icons.event,
            title:
            'Eventos',
            subtitle:
            'Crear, modificar, cancelar o finalizar eventos del albergue.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const AdminEventsScreen(),
                ),
              );
            },
          ),

          _AdminOption(
            icon:
            Icons.account_balance,
            title:
            'Donaciones',
            subtitle:
            'Administrar cuentas bancarias oficiales del albergue.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const AdminDonationsScreen(),
                ),
              );
            },
          ),

          _AdminOption(
            icon:
            Icons.description_outlined,
            title:
            'Solicitudes de adopción',
            subtitle:
            'Revisar, aprobar o rechazar solicitudes.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const AdminAdoptionApplicationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminHeader
    extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor:
              AppColors.primarySoft,
              child: Icon(
                Icons
                    .admin_panel_settings,
                color:
                AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    'Panel de administración',
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
                    height: 4,
                  ),
                  const Text(
                    'Gestiona el contenido de Ada Azul desde la aplicación.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption
    extends StatelessWidget {
  const _AdminOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          color:
          AppColors.primary,
        ),
        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
        subtitle:
        Text(subtitle),
        trailing:
        const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}