# Ada Azul

Aplicación móvil para la gestión y promoción de adopciones del albergue Ada Azul.

El proyecto centraliza en una sola plataforma la consulta de perros disponibles, el registro de personas interesadas, las solicitudes de adopción, la publicación de eventos y la información de donaciones. Además, incorpora un panel administrativo que permite al personal del albergue mantener actualizada la información sin necesidad de publicar una nueva versión de la aplicación.

## Problemática

Los procesos de adopción de animales suelen depender de publicaciones dispersas en redes sociales, mensajes privados y registros manuales. Esto dificulta mantener información actualizada sobre los perros disponibles, conocer qué personas están interesadas, dar seguimiento a las solicitudes de adopción y comunicar eventos o métodos de apoyo al albergue.

Esta fragmentación puede generar varios problemas:

- Información desactualizada sobre perros disponibles o ya adoptados.
- Falta de un registro centralizado de personas interesadas.
- Seguimiento manual de solicitudes de adopción.
- Dificultad para presentar información relevante de cada perro de forma estructurada.
- Dependencia de múltiples canales para comunicar eventos y formas de donación.
- Necesidad de modificar o redistribuir la aplicación cuando cambia información operativa.

## Solución propuesta

Ada Azul fue desarrollada como una aplicación móvil conectada a una base de datos centralizada en Supabase.

La aplicación permite que una persona consulte perros disponibles, indique cuáles le interesan, revise información detallada y envíe una solicitud de adopción. El sistema utiliza un cuestionario de compatibilidad para considerar aspectos como vivienda, tiempo disponible, nivel de actividad y características del perro.

El personal autorizado del albergue dispone de funciones administrativas para gestionar perros, fotografías, eventos, métodos de donación y solicitudes de adopción. Los cambios se almacenan en la base de datos y pueden reflejarse en la aplicación sin necesidad de generar un APK nuevo para cada actualización de contenido.

## Objetivo del proyecto

El objetivo principal de Ada Azul es digitalizar y centralizar parte del proceso de adopción del albergue mediante una aplicación móvil que facilite la interacción entre personas interesadas y personal administrativo. La solución busca reducir tareas manuales, mejorar la disponibilidad de información y proporcionar una herramienta que pueda mantenerse actualizada desde una base de datos central sin depender de modificaciones constantes en el cliente móvil.

## Alcance del sistema

El sistema cubre el flujo principal de consulta, interés y solicitud de adopción, además de funciones complementarias para eventos y donaciones. Incluye autenticación de usuarios, cuestionario de compatibilidad, consulta de perros, registro de intereses, solicitudes de adopción, panel administrativo y persistencia de información en la nube.

El proyecto fue diseñado para Android como plataforma principal. La arquitectura utilizada permite extender la solución a otras plataformas compatibles con Flutter y continuar agregando módulos sin modificar la base del sistema.

## Enfoque de desarrollo

La aplicación fue construida con una separación clara entre presentación, modelos de dominio, repositorios, fuentes de datos y servicios. Esto permite aislar responsabilidades, reducir el acoplamiento entre componentes y facilitar futuras modificaciones.

La información dinámica se obtiene desde Supabase en lugar de permanecer hardcodeada en la aplicación. De esta forma, perros, fotografías, eventos, métodos de donación y estados de solicitudes pueden actualizarse desde el backend sin volver a distribuir el APK.

## Funcionalidades principales

### Usuarios

- Registro e inicio de sesión mediante correo electrónico y contraseña.
- Recuperación de contraseña mediante Supabase Auth.
- Cuestionario inicial de compatibilidad.
- Consulta de perros disponibles.
- Visualización de información detallada de cada perro.
- Sistema de interés inspirado en una interfaz de tarjetas deslizables.
- Sección de perros guardados como interesados.
- Formulario de solicitud de adopción.
- Registro de número telefónico de contacto dentro de la solicitud.
- Consulta del estado de las solicitudes enviadas.
- Calendario mensual de eventos del albergue.
- Consulta de métodos de donación activos.
- Actualización del cuestionario de usuario.

### Administración

El acceso administrativo depende del rol asignado al usuario dentro de la base de datos.

Los administradores pueden:

- Registrar nuevos perros.
- Editar información de perros existentes.
- Cambiar su estado entre disponible, en proceso, adoptado u oculto.
- Cargar y reemplazar fotografías.
- Crear, modificar, cancelar, finalizar y eliminar eventos.
- Administrar métodos de donación.
- Activar o desactivar cuentas de donación.
- Consultar solicitudes de adopción.
- Revisar la información proporcionada por cada solicitante.
- Cambiar el estado de una solicitud a pendiente, en revisión, aprobada o rechazada.

## Compatibilidad de adopción

El sistema considera información proporcionada por el usuario durante el cuestionario inicial y características registradas para cada perro.

Entre los criterios utilizados se encuentran:

- Tipo de vivienda.
- Disponibilidad de patio.
- Tiempo diario disponible.
- Frecuencia de paseos.
- Nivel de actividad del usuario.
- Tamaño del perro.
- Nivel de energía del perro.
- Tiempo mínimo de atención requerido.

El resultado se utiliza para ordenar y presentar los perros de acuerdo con su compatibilidad estimada con el perfil del usuario. Esta puntuación funciona como apoyo para la exploración y no sustituye el proceso de evaluación realizado por el albergue.

## Arquitectura

La aplicación utiliza una arquitectura modular en Flutter separando modelos, repositorios, fuentes de datos, servicios, pantallas y componentes reutilizables.

```text
mobile/
├── assets/
├── config/
├── lib/
│   ├── core/
│   │   └── theme/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   ├── screens/
│   ├── services/
│   └── widgets/
├── pubspec.yaml
└── analysis_options.yaml

supabase/
└── schema.sql

scripts/
└── check-secrets.ps1
```

### Flujo general

```text
Flutter
   |
   | HTTPS
   v
Supabase
   ├── Authentication
   ├── PostgreSQL
   ├── Row Level Security
   └── Storage
```

La aplicación cliente utiliza únicamente credenciales publicables destinadas a aplicaciones móviles. Las autorizaciones sobre datos se controlan mediante autenticación, privilegios de PostgreSQL y políticas Row Level Security.

## Tecnologías utilizadas

- Flutter 3.47.5
- Dart 3.13.4
- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- Row Level Security
- Android SDK
- Git
- GitHub

La aplicación utiliza `supabase_flutter` para establecer la comunicación entre el cliente Flutter y los servicios de autenticación, base de datos y almacenamiento de Supabase. Las credenciales del entorno se proporcionan mediante `--dart-define-from-file`, evitando mantener valores reales directamente en el código fuente versionado.

## Decisiones técnicas relevantes

- La autenticación se realiza con correo electrónico y contraseña mediante Supabase Auth.
- Los perfiles de usuario se relacionan con `auth.users` mediante UUID.
- Los permisos administrativos se determinan por el campo `role` del perfil.
- Las operaciones sensibles están protegidas por Row Level Security y políticas específicas por tabla.
- Las fotografías de perros se gestionan mediante Supabase Storage.
- Los intereses de usuarios se almacenan de forma persistente y se relacionan con el usuario autenticado.
- Las solicitudes de adopción incluyen estado de seguimiento y número de contacto.
- Los eventos se almacenan con fecha y hora de inicio y término.
- Los métodos de donación se administran desde base de datos y pueden activarse o desactivarse sin modificar el código de la aplicación.
- La información de configuración del entorno se mantiene fuera del repositorio mediante archivos ignorados por Git.

## Base de datos

La solución utiliza PostgreSQL mediante Supabase.

Entre las entidades principales se encuentran:

- `profiles`
- `user_preferences`
- `dogs`
- `dog_photos`
- `interests`
- `adoption_applications`
- `events`
- `donation_methods`
- `shelter_settings`

El archivo `supabase/schema.sql` contiene una versión sanitizada del esquema utilizado por el proyecto. No incluye credenciales, usuarios administradores ni información bancaria real.

## Seguridad

La seguridad del proyecto no depende de ocultar claves dentro del código cliente. Una aplicación móvil puede ser inspeccionada, por lo que cualquier credencial incluida en el APK debe considerarse accesible para el usuario final.

Por esta razón, el proyecto utiliza las siguientes medidas:

- Autenticación mediante Supabase Auth.
- Row Level Security en las tablas que contienen información protegida.
- Separación entre usuarios normales y administradores mediante roles.
- Restricción de operaciones administrativas mediante políticas de base de datos.
- Uso exclusivo de la clave publicable de Supabase en el cliente.
- Exclusión de claves secretas, `service_role` y contraseñas de PostgreSQL.
- Exclusión de archivos de configuración local mediante `.gitignore`.
- Exclusión de archivos de firma de Android y certificados privados.
- Almacenamiento de imágenes mediante Supabase Storage.
- Uso de URLs firmadas para recursos almacenados en buckets privados cuando corresponde.
- Script local para detectar patrones comunes de secretos antes de realizar un commit.

Nunca debe utilizarse una clave `service_role`, `sb_secret_...` o una contraseña de PostgreSQL directamente dentro de la aplicación Flutter.

## Configuración del proyecto

### Requisitos

- Flutter SDK compatible con Dart 3.
- Android Studio o Android SDK configurado.
- Proyecto de Supabase con el esquema correspondiente.
- Git para control de versiones.

### Instalar dependencias

Desde la carpeta `mobile`:

```powershell
flutter pub get
```

### Configuración de Supabase

El repositorio no contiene las credenciales reales del proyecto.

Copia el archivo de ejemplo:

```powershell
Copy-Item .\config\example.json .\config\prod.json
```

Después configura `config/prod.json` con los valores del entorno correspondiente:

```json
{
  "SUPABASE_URL": "https://TU_PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_REEMPLAZAR"
}
```

`config/prod.json` está excluido mediante `.gitignore` y no debe añadirse al repositorio.

## Ejecutar la aplicación

Desde `mobile`:

```powershell
flutter run --dart-define-from-file=config/prod.json
```

## Análisis estático

```powershell
flutter analyze
```

## Generar APK de producción

```powershell
flutter build apk --release --dart-define-from-file=config/prod.json
```

El APK generado se encuentra normalmente en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Verificación previa a un commit

Desde la raíz del repositorio puede ejecutarse:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-secrets.ps1
```

El script busca patrones asociados con credenciales que no deberían formar parte del repositorio.

También es recomendable revisar manualmente los archivos preparados antes de cada commit:

```powershell
git status
```

El archivo `mobile/config/prod.json` no debe aparecer entre los archivos rastreados por Git.

## Estado del proyecto

La aplicación fue desarrollada inicialmente para Android y cuenta con los principales flujos funcionales de usuario y administración conectados a Supabase.

El proyecto contempla una arquitectura que permite continuar incorporando funcionalidades sin modificar la estructura principal de autenticación, persistencia y administración de contenido.

## Alcance

Ada Azul funciona como una herramienta de apoyo para facilitar el contacto entre personas interesadas en adoptar y el albergue. La compatibilidad calculada por la aplicación es orientativa. La decisión final sobre una adopción corresponde al proceso de evaluación y seguimiento definido por el albergue.

## Licencia y uso

El código fuente se publica como referencia del desarrollo del proyecto. El nombre, logotipo, información institucional y demás recursos gráficos asociados a Ada Azul pueden estar sujetos a derechos de sus respectivos propietarios y no se consideran automáticamente cubiertos por una licencia de software del repositorio.
