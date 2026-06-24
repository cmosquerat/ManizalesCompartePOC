// Pruebas de serialización de los modelos del catálogo (Supabase ↔ modelos).
// No requieren inicializar Supabase ni levantar la UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:manizales_comparte_app/models/models.dart';

void main() {
  test('BusinessProduct.fromMap / toMap conserva los campos', () {
    final p = BusinessProduct.fromMap({
      'id': 'prod_x',
      'business_id': 'biz_x',
      'nombre': 'Cappuccino',
      'descripcion': 'rico',
      'precio_cop': 8000,
      'precio_fermines': 8,
      'stock': 10,
      'destacado': true,
      'activo': true,
    });
    expect(p.nombre, 'Cappuccino');
    expect(p.precioCOP, 8000);
    expect(p.precioFermines, 8);
    expect(p.destacado, isTrue);

    final m = p.toMap();
    expect(m['precio_cop'], 8000);
    expect(m['business_id'], 'biz_x');
    expect(m.containsKey('id'), isFalse); // el id lo genera la DB
  });

  test('Business.fromMap mapea el enum de tipo', () {
    final b = Business.fromMap({
      'id': 'biz_x',
      'nombre': 'Hotel X',
      'tipo': 'hotel',
      'activo': true,
    });
    expect(b.tipo, BusinessType.hotel);
    expect(b.toMap()['tipo'], 'hotel');
  });

  test('Promotion.copyWith alterna el estado activo', () {
    final p = Promotion.fromMap({
      'id': 'promo_x',
      'business_id': 'biz_x',
      'titulo': '2x1',
      'activa': true,
    });
    expect(p.copyWith(activa: false).activa, isFalse);
  });
}
