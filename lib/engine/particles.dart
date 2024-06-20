import 'atoms.dart';

class Particles {
  Particles({required this.atoms});

  final GraphicAtoms atoms;
  final List<int> generators=[];
  final Map<String, int> particles = {};
}
