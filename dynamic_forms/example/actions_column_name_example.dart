import 'package:flutter/material.dart';

/// Ejemplo de uso del parámetro actionsColumnName en SfGenericDataGrid
/// 
/// Este ejemplo muestra cómo personalizar el nombre de la columna de acciones
/// para dar contexto específico según el tipo de datos que se estén mostrando.
class ActionsColumnNameExample extends StatelessWidget {
  const ActionsColumnNameExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo: Nombre de Columna de Acciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ejemplos de uso del parámetro actionsColumnName:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Ejemplo 1: Tabla de usuarios con "Gestionar"
            const Text('1. Tabla de Usuarios - Columna "Gestionar":'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'SfGenericDataGrid<UserFieldsConfig, UserModel>(\n'
                  '  configuration: userConfig,\n'
                  '  items: users,\n'
                  '  columnCount: 4,\n'
                  '  actionsColumnName: "Gestionar",\n'
                  '  onEditItemTap: (user) => editUser(user),\n'
                  '  onRemoveItemTap: (user) => deleteUser(user),\n'
                  '  rowMenuActions: [\n'
                  '    RowMenuAction(\n'
                  '      icon: Icons.person_add,\n'
                  '      label: "Asignar rol",\n'
                  '      onTap: (user) => assignRole(user),\n'
                  '    ),\n'
                  '  ],\n'
                  ')',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ejemplo 2: Tabla de productos con "Opciones"
            const Text('2. Tabla de Productos - Columna "Opciones":'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'SfGenericDataGrid<ProductFieldsConfig, ProductModel>(\n'
                  '  configuration: productConfig,\n'
                  '  items: products,\n'
                  '  columnCount: 5,\n'
                  '  actionsColumnName: "Opciones",\n'
                  '  onEditItemTap: (product) => editProduct(product),\n'
                  '  onRemoveItemTap: (product) => deleteProduct(product),\n'
                  '  rowMenuActions: [\n'
                  '    RowMenuAction(\n'
                  '      icon: Icons.inventory,\n'
                  '      label: "Actualizar stock",\n'
                  '      onTap: (product) => updateStock(product),\n'
                  '    ),\n'
                  '    RowMenuAction(\n'
                  '      icon: Icons.copy,\n'
                  '      label: "Duplicar",\n'
                  '      onTap: (product) => duplicateProduct(product),\n'
                  '    ),\n'
                  '  ],\n'
                  ')',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ejemplo 3: Sin nombre (comportamiento por defecto)
            const Text('3. Sin nombre (comportamiento por defecto):'),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'SfGenericDataGrid<OrderFieldsConfig, OrderModel>(\n'
                  '  configuration: orderConfig,\n'
                  '  items: orders,\n'
                  '  columnCount: 6,\n'
                  '  // actionsColumnName: null, // Por defecto\n'
                  '  onEditItemTap: (order) => editOrder(order),\n'
                  '  onRemoveItemTap: (order) => cancelOrder(order),\n'
                  ')',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Beneficios
            const Text(
              'Beneficios del parámetro actionsColumnName:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Proporciona contexto claro sobre las acciones disponibles\n'
              '• Mejora la experiencia de usuario con etiquetas descriptivas\n'
              '• Permite personalización según el dominio de la aplicación\n'
              '• Mantiene consistencia visual en toda la interfaz\n'
              '• Es opcional, no rompe código existente',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
