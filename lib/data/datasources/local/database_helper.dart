import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestao_manutencao.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
  
    print("Iniciando banco de dados em: $path");
    
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    print("Criando tabelas do banco de dados...");
    final batch = db.batch();
    
    batch.execute('''CREATE TABLE ativos (
      id TEXT PRIMARY KEY, 
      nome TEXT, 
      patrimonio TEXT, 
      localizacao TEXT, 
      estadoConservacao TEXT, 
      dataAquisicao TEXT
    )''');
    
    batch.execute('''CREATE TABLE chamados (
      id TEXT PRIMARY KEY, 
      titulo TEXT, 
      descricao TEXT, 
      status TEXT, 
      prioridade TEXT, 
      ativoId TEXT, 
      dataCriacao TEXT
    )''');
    
    batch.execute('''CREATE TABLE estoque (
      id TEXT PRIMARY KEY, 
      nome TEXT, 
      quantidade INTEGER, 
      nivelMinimo INTEGER, 
      unidadeMedida TEXT, 
      forcedor TEXT, 
      precoUnitario REAL
    )''');
    
    batch.execute('''CREATE TABLE usuarios (
      id TEXT PRIMARY KEY, 
      nome TEXT, 
      email TEXT, 
      perfil INTEGER, 
      senha TEXT
    )''');

    batch.execute('''CREATE TABLE ordens_servico (
      id TEXT PRIMARY KEY, 
      ativoId TEXT, 
      solicitanteId TEXT, 
      descricaoProblema TEXT, 
      dataAbertura TEXT, 
      prioridade TEXT, 
      tecnicoResponsavelId TEXT, 
      status INTEGER, 
      relatotecnico TEXT, 
      dataInicio TEXT, 
      dataFim TEXT, 
      custoPecas REAL, 
      custoMaoDeObra REAL
    )''');
    
    batch.execute('''CREATE TABLE ambientes (
      id TEXT PRIMARY KEY,
      nome TEXT,
      predio TEXT,
      andar TEXT,
      observacoes TEXT
    )''');  

    batch.execute('''CREATE TABLE notificacoes (
      id TEXT PRIMARY KEY,
      titulo TEXT,
      mensagem TEXT,
      dataCriacao TEXT,
      lida INTEGER,
      usuarioId TEXT
    )''');

    await batch.commit();
    print("Todas as tabelas foram criadas com sucesso!");
  }
}