import 'package:geosprint/database/database_provider.dart';
import 'package:geosprint/models/corrida.dart';

class CorridaDao {
  final dbProvider = DatabaseProvider.instance;

 
  Future<bool> salvar(Corrida corrida) async {
    final db = await dbProvider.database;
    final valores = corrida.toMap();

    try {
      if (corrida.id == null) {

        int idInserido = await db.insert(Corrida.nomeTabela, valores);
        corrida.id = idInserido;
        print("Corrida salva com sucesso! ID: $idInserido");
        return true;
      } else {

        final atualizados = await db.update(
          Corrida.nomeTabela,
          valores,
          where: '${Corrida.CAMPO_ID} = ?',
          whereArgs: [corrida.id],
        );
        print("Corrida atualizada, registros modificados: $atualizados");
        return atualizados > 0;
      }
    } catch (e) {
      print("Erro ao salvar a corrida: $e");
      return false;
    }
  }

  Future<List<Corrida>> listar() async {
    final db = await dbProvider.database;
    final resultado = await db.query(
      Corrida.nomeTabela,
      orderBy: '${Corrida.CAMPO_ID} DESC',
    );
    print("Resultados da consulta: $resultado");
    return resultado.map((m) => Corrida.fromMap(m)).toList();
  }
}
