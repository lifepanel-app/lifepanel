import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

/// Initialize all dependencies via get_it.
///
/// Registers data sources, repositories, and use cases.
/// Riverpod providers bridge to these via `sl<T>()`.
Future<void> initDependencies() async {
  // ── Database ──────────────────────────────────────────────
  // TODO: Register Isar instance
  // final isar = await Isar.open([...schemas]);
  // sl.registerSingleton<Isar>(isar);

  // ── Shared Layer ──────────────────────────────────────────
  // TODO: Register shared data sources
  // TODO: Register shared repositories
  // TODO: Register shared use cases

  // ── Money ─────────────────────────────────────────────────
  // TODO: Register money data sources, repositories, use cases

  // ── Fuel ──────────────────────────────────────────────────
  // TODO: Register fuel data sources, repositories, use cases

  // ── Work ──────────────────────────────────────────────────
  // TODO: Register work data sources, repositories, use cases

  // ── Mind ──────────────────────────────────────────────────
  // TODO: Register mind data sources, repositories, use cases

  // ── Body ──────────────────────────────────────────────────
  // TODO: Register body data sources, repositories, use cases

  // ── Home ──────────────────────────────────────────────────
  // TODO: Register home data sources, repositories, use cases
}
