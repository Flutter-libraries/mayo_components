## dynamic_forms

Componentes para construir formularios dinámicos y tablas de datos sobre Flutter.

Este paquete incluye un widget de tabla genérica basado en Syncfusion que estandariza paginación, ordenación, búsqueda, selección y theming: `SfGenericDataGrid`.

---

## SfGenericDataGrid

Tabla genérica con integración directa con los modelos de formularios (`FormConfiguration2` y `FormFieldDefinition`). Construye columnas automáticamente a partir de los campos listables e incluye selección con checkbox, paginación, ordenación, buscador local y acciones por fila.

### Principales características

- Columnas autogeneradas a partir de `configuration.fields.where((f) => f.isListable)`.
- Buscador local (filtra usando `ListableModel.contains(String query)`).
- Paginación con selector de filas por página y pager sincronizado.
- Selección múltiple con checkbox por fila y checkbox tri‐estado en el header.
- Acciones de fila: editar, eliminar y acción personalizada (`customRowAction`).
- Ordenación segura (clona la lista para evitar errores con listas inmutables).
- Theming neutral: colores de cabecera, líneas, selección, hover, tipografía y footer.
- Layout flexible: expansión opcional (`expanded`) y límite de altura (`maxHeight`).
- Personalización por celda según `FormFieldDefinition` y `DropdownOption`: `prefixIcon`, `color`, `backgroundColor`.

### Importación

```dart
import 'package:dynamic_forms/dynamic_forms.dart';
```

### API (parámetros principales)

- required `configuration`: FormConfiguration2<S> con los campos y reglas.
- required `items`: List<S> elementos a mostrar.
- required `columnCount`: número de columnas visibles (para layout responsive/mediciones).
- `columns`: List<GridColumn>? (avanzado). Si no se define, se generan desde `configuration`.
- Acciones por fila:
	- `onEditItemTap(S item)`
	- `onRemoveItemTap(S item)`
	- `customRowAction(S item) => Widget` (se renderiza en la misma columna de acciones).
- `rowBuilder(S data) => List<Widget>`: personalización completa por fila, uno por columna listable.
- `toolbarActions`: List<Widget> para mostrar acciones en la barra superior.
- `setSelectedItems(List<S>)`: callback con la selección acumulada a través de páginas/filtros.
- Búsqueda/ordenación/selección:
	- `showSearchField` (bool, por defecto true)
	- `allowSorting` (bool, por defecto true)
	- `allowMultiSelection` (bool, por defecto true)
- Paginación:
	- `rowsPerPage` (int, por defecto 10)
	- `availableRowsPerPage` (List<int>, por defecto [10, 25, 50, 100])
- Anchos de columnas:
	- `columnWidthMode` (ColumnWidthMode, por defecto fill)
	- `columnWidths` (Map<String,double>): permite fijar anchos específicos por `columnName`.
		- Especialmente útil para `__actions__`.
- Theming neutro (opcional):
	- `headerBackgroundColor`, `headerTextStyle`, `rowTextStyle`
	- `gridLineColor`, `selectionColor`, `rowHoverColor`
	- `pagerItemColor`, `pagerSelectedItemColor`
	- `footerBackgroundColor`
- Layout:
	- `expanded` (bool, por defecto true): envuelve el grid en `Expanded`.
	- `maxHeight` (double?): si se define, no se usa `Expanded` para respetar la altura máxima.

### Conexión con FormFieldDefinition

Cada `FormFieldDefinition` puede definir:

- `isListable`: si la columna debe mostrarse.
- `fieldType`: text, number, toggle, checkbox, dropdown, dropdownMultiple, date, etc.
- `formatter`: para formatear números/fechas/texto.
- Enriquecimiento visual por celda:
	- `prefixIcon`: icono al inicio de la celda.
	- `color`: color del texto en la celda.
	- `backgroundColor`: color de fondo de la celda.

Para `FieldType.dropdown`, también se pueden definir colores por opción a través de `DropdownOption` (propiedades `label`, `value`, `color`, `backgroundColor`). Si la opción seleccionada define color/fondo, tiene prioridad sobre los valores del campo.

### Selección de filas

- Checkbox en la primera columna cuando `setSelectedItems` no es null.
- Checkbox de cabecera tri‐estado (desmarcado, indeterminado, marcado) para seleccionar/deseleccionar todos en la página/filtrado actual.
- La selección se acumula a través de páginas y filtros y se sincroniza visualmente con el highlight del grid.

### Acciones por fila y ancho de la columna de acciones

- La columna de acciones se crea automáticamente cuando se define alguna de `onEditItemTap`, `onRemoveItemTap` o `customRowAction`.
- Por defecto la columna mide 80 px; si hay `customRowAction`, 120 px.
- Se puede forzar con `columnWidths: {'__actions__': 136}`.

### Paginación y footer

- Selector “Filas por página” y `SfDataPager` integrados.
- Divider superior y color de fondo del footer configurables vía `footerBackgroundColor`.
- Colores de pager configurables (`pagerItemColor`, `pagerSelectedItemColor`).

### Búsqueda y ordenación

- Búsqueda local sobre `items` aplicando `contains(query)` del modelo `S`.
- Ordenación habilitable con `allowSorting`. Las columnas de selección (`__select__`) y acciones (`__actions__`) no son ordenables.

### Convenciones internas de columnas

- `__index__`: columna oculta que guarda el item real de la fila.
- `__select__`: columna de checkbox de selección.
- `__actions__`: columna de acciones (editar, eliminar, acción personalizada).

### Ejemplos

Ejemplo básico:

```dart
final config = MyEntityFieldsConfig(context: context);

SfGenericDataGrid(
	configuration: config,
	items: state.items,
	columnCount: config.columnsCount,
	onEditItemTap: (item) => _edit(item),
	onRemoveItemTap: (item) => _remove(item),
	toolbarActions: [
		IconButton(icon: const Icon(Icons.add), onPressed: _create),
	],
	setSelectedItems: (selected) => context.read<Cubit>().setSelected(selected),
);
```

Acción personalizada y control de ancho de columna de acciones:

```dart
SfGenericDataGrid(
	configuration: config,
	items: state.lineItems,
	columnCount: config.columnsCount,
	showSearchField: false,
	columnWidths: const {
		'__actions__': 136, // asegura que la acción extra no desborde
	},
	expanded: false,      // no ocupar todo el alto
	maxHeight: 320,       // limitar altura del grid si procede
	customRowAction: (item) => IconButton(
		icon: const Icon(Icons.payments_outlined),
		tooltip: 'Añadir pago',
		onPressed: () => _openPaymentDialog(item),
	),
);
```

Colores e iconos por celda desde `FormFieldDefinition` y `DropdownOption`:

```dart
final fields = [
	FormFieldDefinition(
		fieldName: 'status',
		label: 'Estado',
		isListable: true,
		fieldType: FieldType.dropdown,
		prefixIcon: Icons.info_outline,
		options: [
			DropdownOption(label: 'Pendiente', value: 'pending', color: Colors.orange),
			DropdownOption(label: 'Pagado', value: 'paid', color: Colors.green,
				backgroundColor: Colors.green.withValues(alpha: 0.08)),
			DropdownOption(label: 'Cancelado', value: 'cancelled', color: Colors.red,
				backgroundColor: Colors.red.withValues(alpha: 0.08)),
		],
	),
];
```

### Buenas prácticas

- Si `expanded` es false, asegúrate de proporcionar constraints externas (p. ej., `SizedBox`, `ConstrainedBox` o `maxHeight`).
- Usa `columnWidths` para ajustar columnas con contenido variable, sobre todo `__actions__`.
- Implementa `contains(String)` en tus modelos listables para que la búsqueda local sea útil y performante.
- Emplea `formatter` en campos numéricos/fechas para un output consistente.

### Requisitos

- Syncfusion DataGrid/DataPager (`syncfusion_flutter_datagrid` y `syncfusion_flutter_core`).
- Modelos que extiendan `ListableModel<S>` y definan correctamente `getValue`, `getListValue` y `contains`.

---

¿Sugerencias o mejoras? Abre un issue o PR en el repositorio interno.
