import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../datasources/supabase_adoption_repository.dart';
import '../models/adoption_application.dart';
import '../models/app_user.dart';
import '../models/dog.dart';
import '../models/swipe_decision.dart';
import '../models/user_profile.dart';
import '../repositories/dog_repository.dart';
import '../repositories/interaction_repository.dart';
import '../services/compatibility_service.dart';
import '../widgets/dog_card.dart';

import 'admin_screen.dart';
import 'adoption_application_screen.dart';
import 'dog_detail_screen.dart';
import 'donations_screen.dart';
import 'events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.dogRepository,
    required this.interactionRepository,
    required this.user,
    required this.profile,
    required this.isAdmin,
    required this.onEditProfile,
    required this.onSignOut,
  });

  final DogRepository dogRepository;
  final InteractionRepository interactionRepository;
  final AppUser user;
  final UserProfile profile;
  final bool isAdmin;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseAdoptionRepository _adoptionRepository =
      SupabaseAdoptionRepository();

  final List<Dog> _dogs = [];

  final Set<String> _interestedDogIds =
  <String>{};

  final List<AdoptionApplication>
  _applications = [];

  final CompatibilityService _compatibility =
  const CompatibilityService();

  int _index = 0;
  int _tab = 0;

  double _dragX = 0;

  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    _loadDogs();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      final applications =
          await _adoptionRepository.getMyApplications();

      if (!mounted) {
        return;
      }

      setState(() {
        _applications
          ..clear()
          ..addAll(applications);
      });
    } catch (_) {}
  }

  Future<void> _loadDogs() async {
    try {
      final dogs = List<Dog>.of(
        await widget.dogRepository
            .getAvailableDogs(),
      );

      final interestedIds =
      await widget.interactionRepository
          .getInterestedDogIds();

      dogs.sort(
            (a, b) => _compatibility
            .score(
          widget.profile,
          b,
        )
            .compareTo(
          _compatibility.score(
            widget.profile,
            a,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _dogs
          ..clear()
          ..addAll(dogs);

        _interestedDogIds
          ..clear()
          ..addAll(interestedIds);

        if (_index >= _dogs.length) {
          _index = 0;
        }

        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError =
            error.toString();

        _loading = false;
      });
    }
  }

  Future<void> _refreshDogs() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _index = 0;
    });

    await _loadDogs();
  }

  Future<void> _decide(
      SwipeDecision decision,
      ) async {
    if (_index >= _dogs.length) {
      return;
    }

    final dog =
    _dogs[_index];

    try {
      await widget.interactionRepository
          .saveSwipe(
        DogSwipe(
          dogId: dog.id,
          decision: decision,
          createdAt:
          DateTime.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (decision ==
            SwipeDecision.interested) {
          _interestedDogIds.add(
            dog.id,
          );
        } else {
          _interestedDogIds.remove(
            dog.id,
          );
        }

        _index++;
        _dragX = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar la acción: $error',
          ),
        ),
      );
    }
  }

  Future<void> _syncInterests() async {
    try {
      final interestedIds =
      await widget.interactionRepository
          .getInterestedDogIds();

      if (!mounted) {
        return;
      }

      setState(() {
        _interestedDogIds
          ..clear()
          ..addAll(
            interestedIds,
          );
      });
    } catch (_) {}
  }

  void _dragEnd(
      DragEndDetails details,
      ) {
    if (_dragX > 90) {
      _decide(
        SwipeDecision.interested,
      );
      return;
    }

    if (_dragX < -90) {
      _decide(
        SwipeDecision.rejected,
      );
      return;
    }

    setState(() {
      _dragX = 0;
    });
  }

  Future<void> _markInterested(
      Dog dog, {
        bool advanceCard = false,
      }) async {
    try {
      await widget.interactionRepository
          .saveSwipe(
        DogSwipe(
          dogId: dog.id,
          decision:
          SwipeDecision.interested,
          createdAt:
          DateTime.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _interestedDogIds.add(
          dog.id,
        );

        if (advanceCard &&
            _index <
                _dogs.length &&
            _dogs[_index].id ==
                dog.id) {
          _index++;
          _dragX = 0;
        }
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${dog.name} se agregó a Intereses.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el interés: $error',
          ),
        ),
      );
    }
  }

  void _openDog(
      Dog dog, {
        bool allowAdopt = false,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DogDetailScreen(
              dog: dog,
              profile:
              widget.profile,
              isInterested:
              _interestedDogIds
                  .contains(
                dog.id,
              ),
              onInterest:
              _interestedDogIds
                  .contains(
                dog.id,
              )
                  ? null
                  : () async {
                await _markInterested(
                  dog,
                );

                if (context
                    .mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              },
              onAdopt:
              allowAdopt
                  ? () {
                Navigator.pop(
                  context,
                );

                _application(
                  dog,
                );
              }
                  : null,
            ),
      ),
    );
  }

  Future<void> _application(
    Dog dog,
  ) async {
    final submitted =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdoptionApplicationScreen(
          dog: dog,
        ),
      ),
    );

    if (submitted == true) {
      await _loadApplications();
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logos/ada_azul_logo.png',
              width: 36,
              height: 36,
            ),
            const SizedBox(
              width: 8,
            ),
            const Text(
              'Ada Azul',
              style: TextStyle(
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          if (_tab == 0)
            IconButton(
              tooltip:
              'Actualizar perritos',
              onPressed:
              _refreshDogs,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _loadError != null
          ? _errorView()
          : IndexedStack(
        index: _tab,
        children: [
          _explore(),
          _interests(),
          const DonationsScreen(),
          const EventsScreen(),
          _profileView(),
        ],
      ),
      bottomNavigationBar:
      NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected:
            (index) {
          setState(() {
            _tab = index;
          });

          if (index == 1) {
            _syncInterests();
            _loadApplications();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.pets_outlined,
            ),
            selectedIcon: Icon(
              Icons.pets,
            ),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),
            selectedIcon: Icon(
              Icons.favorite,
            ),
            label: 'Intereses',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .volunteer_activism_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .volunteer_activism,
            ),
            label: 'Donar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.event_outlined,
            ),
            selectedIcon: Icon(
              Icons.event,
            ),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
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
              'No fue posible cargar los perritos.',
              style: TextStyle(
                fontWeight:
                FontWeight.w800,
                fontSize: 18,
              ),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _loadError!,
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            FilledButton.icon(
              onPressed:
              _refreshDogs,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _explore() {
    if (_dogs.isEmpty) {
      return const Center(
        child: Padding(
          padding:
          EdgeInsets.all(30),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.pets,
                size: 64,
                color:
                AppColors.primary,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'Todavía no hay perritos disponibles.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Cuando el administrador agregue un perrito disponible aparecerá aquí.',
                textAlign:
                TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_index >=
        _dogs.length) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            30,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .check_circle_outline,
                size: 64,
                color:
                AppColors.primary,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Ya viste a todos los perritos disponibles por ahora.',
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _index = 0;
                  });
                },
                icon: const Icon(
                  Icons.replay,
                ),
                label: const Text(
                  'Ver otra vez',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dog =
    _dogs[_index];

    final score =
    _compatibility.score(
      widget.profile,
      dog,
    );

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        14,
      ),
      child: Column(
        children: [
          Expanded(
            child:
            GestureDetector(
              onHorizontalDragUpdate:
                  (details) {
                setState(() {
                  _dragX +=
                      details
                          .delta.dx;
                });
              },
              onHorizontalDragEnd:
              _dragEnd,
              child:
              Transform.translate(
                offset: Offset(
                  _dragX,
                  0,
                ),
                child:
                Transform.rotate(
                  angle:
                  (_dragX /
                      1000)
                      .clamp(
                    -0.15,
                    0.15,
                  ),
                  child: DogCard(
                    dog: dog,
                    compatibility:
                    score,
                    onTap: () =>
                        _openDog(
                          dog,
                        ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              FloatingActionButton(
                heroTag:
                'reject',
                backgroundColor:
                Colors.white,
                foregroundColor:
                Colors
                    .redAccent,
                onPressed: () =>
                    _decide(
                      SwipeDecision
                          .rejected,
                    ),
                child: const Icon(
                  Icons.close,
                ),
              ),
              const SizedBox(
                width: 32,
              ),
              FloatingActionButton(
                heroTag:
                'interest',
                onPressed: () =>
                    _decide(
                      SwipeDecision
                          .interested,
                    ),
                child: const Icon(
                  Icons.favorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Dog> get _favoriteDogs {
    return _dogs
        .where(
          (dog) =>
          _interestedDogIds
              .contains(
            dog.id,
          ),
    )
        .toList();
  }

  Widget _interests() {
    final favorites =
        _favoriteDogs;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                text:
                'Perritos guardados',
              ),
              Tab(
                text:
                'Mis solicitudes',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                favorites.isEmpty
                    ? _emptyFavorites()
                    : ListView.separated(
                  padding:
                  const EdgeInsets
                      .all(
                    16,
                  ),
                  itemCount:
                  favorites
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
                    final dog =
                    favorites[
                    index];

                    return Card(
                      child:
                      Padding(
                        padding:
                        const EdgeInsets
                            .all(
                          8,
                        ),
                        child:
                        Column(
                          children: [
                            ListTile(
                              leading:
                              _FavoriteDogImage(
                                imageUrl:
                                dog.imageUrl,
                              ),
                              title:
                              Text(
                                dog.name,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                              subtitle:
                              Text(
                                '${_compatibility.score(widget.profile, dog)}% compatible · ${dog.location}',
                                maxLines:
                                2,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                              trailing:
                              const Icon(
                                Icons
                                    .chevron_right,
                              ),
                              onTap:
                                  () {
                                _openDog(
                                  dog,
                                  allowAdopt:
                                  true,
                                );
                              },
                            ),
                            Padding(
                              padding:
                              const EdgeInsets
                                  .fromLTRB(
                                12,
                                0,
                                12,
                                8,
                              ),
                              child:
                              SizedBox(
                                width:
                                double.infinity,
                                child:
                                FilledButton.icon(
                                  onPressed:
                                      () {
                                    _application(
                                      dog,
                                    );
                                  },
                                  icon:
                                  const Icon(
                                    Icons
                                        .description_outlined,
                                  ),
                                  label:
                                  const Text(
                                    'Llenar solicitud de adopción',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _applications.isEmpty
                    ? const Center(
                  child:
                  Padding(
                    padding:
                    EdgeInsets.all(
                      28,
                    ),
                    child:
                    Text(
                      'Aún no has enviado solicitudes.',
                    ),
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets
                      .all(
                    16,
                  ),
                  itemCount:
                  _applications
                      .length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final application =
                    _applications[
                    index];

                    return Card(
                      child:
                      ListTile(
                        leading:
                        const Icon(
                          Icons
                              .description_outlined,
                          color:
                          AppColors
                              .primary,
                        ),
                        title: Text(
                          application
                              .dogName,
                        ),
                        subtitle:
                        Text(
                          '${application.statusLabel} · '
                              '${application.createdAt.day}/'
                              '${application.createdAt.month}/'
                              '${application.createdAt.year}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFavorites() {
    return const Center(
      child: Padding(
        padding:
        EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .favorite_border,
              size: 56,
              color:
              AppColors.primary,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              'Aún no guardas ningún perrito.',
              textAlign:
              TextAlign.center,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'Da ❤️ en Explorar y aparecerá aquí.',
              textAlign:
              TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileView() {
    return ListView(
      padding:
      const EdgeInsets.all(
        20,
      ),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor:
          AppColors.primarySoft,
          child: Icon(
            Icons.person,
            size: 42,
            color:
            AppColors.primary,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          widget.user.displayName,
          textAlign:
          TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w900,
          ),
        ),
        Text(
          widget.user.email,
          textAlign:
          TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(
              Icons.tune,
              color:
              AppColors.primary,
            ),
            title: const Text(
              'Mi cuestionario',
            ),
            subtitle:
            const Text(
              'Actualizar vivienda, tiempo y estilo de vida',
            ),
            trailing:
            const Icon(
              Icons.chevron_right,
            ),
            onTap: widget
                .onEditProfile,
          ),
        ),
        if (widget.isAdmin)
          Card(
            child: ListTile(
              leading:
              const Icon(
                Icons
                    .admin_panel_settings,
                color:
                AppColors
                    .primary,
              ),
              title:
              const Text(
                'Panel de administración',
              ),
              subtitle:
              const Text(
                'Gestionar perros, eventos, donaciones y solicitudes',
              ),
              trailing:
              const Icon(
                Icons
                    .chevron_right,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                    const AdminScreen(),
                  ),
                );

                if (mounted) {
                  _refreshDogs();
                }
              },
            ),
          ),
        Card(
          child: ListTile(
            leading:
            const Icon(
              Icons.logout,
            ),
            title:
            const Text(
              'Cerrar sesión',
            ),
            onTap:
            widget.onSignOut,
          ),
        ),
      ],
    );
  }
}

class _FavoriteDogImage
    extends StatelessWidget {
  const _FavoriteDogImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(
      BuildContext context,
      ) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        10,
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
          imageUrl,
          fit:
          BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return _placeholder();
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color:
      AppColors.primarySoft,
      child: const Icon(
        Icons.pets,
        color:
        AppColors.primary,
      ),
    );
  }
}