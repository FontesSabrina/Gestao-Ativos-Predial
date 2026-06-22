abstract class RepositoryMemoryBase<T> {
  List<T> dataMemory = [];
  List<T> get fakeData;

  Future<void> connect() async {
    if (dataMemory.isEmpty) {
      dataMemory = List<T>.from(fakeData);
    }
  }

  void reset() {
    dataMemory.clear();
  }
}