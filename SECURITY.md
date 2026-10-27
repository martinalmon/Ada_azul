# Seguridad del repositorio

## Nunca publicar

- `sb_secret_...`
- Supabase `service_role`
- contraseñas de PostgreSQL
- `DATABASE_URL` real
- archivos `key.properties`, `.jks` o `.keystore`
- tokens de CI/CD, GitHub PAT, claves privadas o certificados
- credenciales de correo, banco o servicios externos

## Aplicación móvil

La app solo debe utilizar la URL de Supabase y una clave **publishable**. Esos valores se inyectan en compilación mediante `--dart-define-from-file=config/prod.json`. El archivo `prod.json` está ignorado por Git.

La seguridad de datos depende de RLS y privilegios mínimos en Supabase. Nunca uses una secret/service-role key dentro de Flutter.

## Antes de cada push

Ejecuta desde la raíz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-secrets.ps1
```

Si el script encuentra un patrón peligroso, no hagas commit hasta revisarlo.
