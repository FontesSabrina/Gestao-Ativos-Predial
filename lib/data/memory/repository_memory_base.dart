abstract class RepositoryMemoryBase<T> {
  // Variável que armazena os dados em memória
  List<T> dataMemory = [];
  
  // Exige que cada repositório defina seus dados iniciais
  List<T> get fakeData;

  // Método 'connect' garantindo que a lista não seja recriada à toa
  Future<void> connect() async {
    // Se a lista já tiver conteúdo, não fazemos nada.
    // Isso evita perder alterações que você tenha feito durante o uso do app!
    if (dataMemory.isEmpty) {
      dataMemory = List<T>.from(fakeData);
    }
  }
  
  // Dica: Se precisar limpar os dados para testes, você pode adicionar isso:
  void reset() {
    dataMemory.clear();
  }
}