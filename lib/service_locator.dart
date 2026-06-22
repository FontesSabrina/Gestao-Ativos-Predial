import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import 'core/theme/theme_controller.dart';

import 'data/memory/usuario_repository_memory.dart';
import 'data/memory/ativo_repository_memory.dart';
import 'data/memory/chamado_repository_memory.dart';
import 'data/memory/ordem_servico_repository_memory.dart';
import 'data/memory/estoque_repository_memory.dart';
import 'data/memory/ambiente_repository_memory.dart';
import 'data/memory/notificacao_repository_memory.dart'; 

import 'data/datasources/local/ordem_servico_local_datasource.dart';
import 'data/datasources/local/ativo_local_datasource.dart';
import 'data/datasources/local/chamado_local_datasource.dart';
import 'data/datasources/local/usuario_local_datasource.dart';
import 'data/datasources/local/ambiente_local_datasource.dart';
import 'data/datasources/local/notificacao_local_datasource.dart';
import 'data/datasources/local/estoque_local_datasource.dart';

import 'data/repositories/ativo_repository_impl.dart';
import 'data/repositories/chamado_repository_impl.dart';
import 'data/repositories/usuario_repository_impl.dart';
import 'data/repositories/ambiente_repository_impl.dart';
import 'data/repositories/ordem_servico_repository_impl.dart';
import 'data/repositories/notificacao_repository_impl.dart';
import 'data/repositories/estoque_repository_impl.dart';

import 'domain/repositories/usuario_repository.dart';
import 'domain/repositories/ativo_repository.dart';
import 'domain/repositories/estoque_repository.dart';
import 'domain/repositories/ordem_servico_repository.dart';
import 'domain/repositories/chamado_repository.dart';
import 'domain/repositories/ambiente_repository.dart';
import 'domain/repositories/notificacao_repository.dart'; 
import 'domain/services/chamado_domain_services.dart';
import 'domain/services/estoque_domain_services.dart';
import 'domain/services/ordem_servico_domain_services.dart';

class ServiceLocator {
  ServiceLocator._internal();
  static final ServiceLocator _instance = ServiceLocator._internal();
  static ServiceLocator get instance => _instance;

  void setupRepository({Database? database}) {
    final sl = GetIt.instance;

    if (sl.isRegistered<ThemeController>()) {
      return;
    }

    sl.registerSingleton<ThemeController>(ThemeController());

    // --- LÓGICA DE REGISTRO SQL (Desktop) ---
    if (!kIsWeb && database != null) {
      // 1. Registra os DataSources locais recebendo o banco
      sl.registerLazySingleton(() => NotificacaoLocalDataSource(database));
      sl.registerLazySingleton(() => ChamadoLocalDataSource(database));
      sl.registerLazySingleton(() => AtivoLocalDataSource(database));
      sl.registerLazySingleton(() => UsuarioLocalDataSource(database));
      sl.registerLazySingleton(() => AmbienteLocalDataSource(database));
      sl.registerLazySingleton(() => OrdemServicoLocalDataSource(database)); 
      sl.registerLazySingleton(() => EstoqueLocalDataSource(database)); 

      // 2. Registra as Implementações dos Repositórios usando os DataSources correspondentes
      sl.registerLazySingleton<NotificacaoRepository>(() => NotificacaoRepositoryImpl(sl<NotificacaoLocalDataSource>()));
      sl.registerLazySingleton<ChamadoRepository>(() => ChamadoRepositoryImpl(sl<ChamadoLocalDataSource>()));
      sl.registerLazySingleton<AtivoRepository>(() => AtivoRepositoryImpl(sl<AtivoLocalDataSource>()));
      sl.registerLazySingleton<UsuarioRepository>(() => UsuarioRepositoryImpl(sl<UsuarioLocalDataSource>()));
      sl.registerLazySingleton<AmbienteRepository>(() => AmbienteRepositoryImpl(sl<AmbienteLocalDataSource>()));
      sl.registerLazySingleton<OrdemServicoRepository>(() => OrdemServicoRepositoryImpl(sl<OrdemServicoLocalDataSource>()));
      sl.registerLazySingleton<EstoqueRepository>(() => EstoqueRepositoryImpl(sl<EstoqueLocalDataSource>()));
    } 
    // --- LÓGICA DE REGISTRO MEMÓRIA (Web ou Fallback) ---
    else {
      sl.registerLazySingleton<NotificacaoRepository>(() => NotificacaoRepositoryMemory());
      sl.registerLazySingleton<UsuarioRepository>(() => UsuarioRepositoryMemory());
      sl.registerLazySingleton<AtivoRepository>(() => AtivoRepositoryMemory());
      sl.registerLazySingleton<ChamadoRepository>(() => ChamadoRepositoryMemory());
      sl.registerLazySingleton<AmbienteRepository>(() => AmbienteRepositoryMemory());
      sl.registerLazySingleton<OrdemServicoRepository>(() => OrdemServicoRepositoryMemory());
      sl.registerLazySingleton<EstoqueRepository>(() => EstoqueRepositoryMemory());
    }

    // --- Domain Services ---
    sl.registerLazySingleton(() => OrdemServicoDomainServices(sl<OrdemServicoRepository>()));
    
    sl.registerLazySingleton(() => ChamadoDomainServices(
      sl<OrdemServicoRepository>(), 
      sl<ChamadoRepository>(),
      sl<NotificacaoRepository>()
    ));
    
    sl.registerLazySingleton(() => EstoqueDomainServices(sl<EstoqueRepository>()));
  }
}