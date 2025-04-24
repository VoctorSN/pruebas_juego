import 'package:flutter/material.dart';

class TextStyleSingleton {
  // Instancia única del singleton
  static final TextStyleSingleton _instance = TextStyleSingleton._internal();

  // Constructor privado
  TextStyleSingleton._internal();

  // Método para acceder a la instancia
  factory TextStyleSingleton() {
    return _instance;
  }

  // Método para obtener el estilo de texto
  TextStyle get style {
    return const TextStyle(
      fontFamily: 'ArcadeClassic',
      color: Colors.white,
    );
  }
}