# Actualización de Colores para Modo Oscuro - Matchscreen

## Cambios Realizados

### 1. Nuevos Colores Agregados (`lib/core/utils/colors.dart`)

Se agregaron colores específicos para el modo oscuro:

```dart
// Colores específicos para modo oscuro
static const Color darkCardBackground = Color(0xFF2A2A2A);    // Fondo de tarjetas
static const Color darkCardSurface = Color(0xFF1E1E1E);       // Superficie secundaria
static const Color darkTextPrimary = Color(0xFFFFFFFF);       // Texto principal (blanco)
static const Color darkTextSecondary = Color(0xFFB0B0B0);     // Texto secundario (gris claro)
static const Color darkBorder = Color(0xFF404040);            // Bordes
```

### 2. Archivos Actualizados

#### `lib/features/matching/widgets/matching_loader.dart`
- **Fondo de tarjetas**: Cambia de blanco fijo a `darkCardBackground` en modo oscuro
- **Texto del título**: Cambia de negro fijo a `darkTextPrimary` (blanco) en modo oscuro
- **Texto secundario**: Cambia de gris fijo a `darkTextSecondary` en modo oscuro
- **Iconos**: Adaptan su color según el tema
- **Sombras**: Más pronunciadas en modo oscuro para mejor contraste
- **Mensajes de carga y error**: Adaptan sus colores al tema

#### `lib/features/events/presentation/widgets/eventCard.dart`
- **Fondo de tarjetas**: Cambia de blanco fijo a `darkCardBackground` en modo oscuro
- **Textos**: Adaptan sus colores al tema (título, subtítulo, fecha, asistentes)
- **Botones**: Adaptan colores de texto y bordes al tema

### 3. Paleta de Colores Recomendada

#### Modo Claro (sin cambios)
- Fondo de tarjetas: `#FFFFFF` (blanco)
- Texto principal: `#000000` (negro)
- Texto secundario: `#757575` (gris)

#### Modo Oscuro (nuevo)
- Fondo de tarjetas: `#2A2A2A` (gris oscuro suave)
- Texto principal: `#FFFFFF` (blanco)
- Texto secundario: `#B0B0B0` (gris claro)
- Bordes: `#404040` (gris medio)

### 4. Beneficios

1. **Mejor legibilidad**: El contraste entre texto y fondo es óptimo en ambos modos
2. **Menos fatiga visual**: Los colores oscuros reducen la fatiga en ambientes con poca luz
3. **Consistencia**: Todas las tarjetas de eventos ahora siguen el mismo patrón de colores
4. **Accesibilidad**: Cumple con estándares de contraste para mejor accesibilidad

### 5. Implementación

Los cambios utilizan `Theme.of(context).brightness` para detectar automáticamente el modo actual y aplicar los colores correspondientes. Esto significa que:

- No requiere reinicio de la app
- Cambia automáticamente al cambiar el tema del sistema
- Es consistente con el resto de la aplicación
