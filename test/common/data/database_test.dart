import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'database_test.mocks.dart';

late DataBaseManagerImpl dbManager;
late MockDatabase db;

@GenerateMocks([
  Database
])
void main(){
  setUp((){
    db = MockDatabase();
    dbManager = DataBaseManagerImpl(db: db);
  });

  group('query inner join', _testQueryInnerJoin);
  group('query count', _testQueryCount);
  group('remove where', _testRemoveWhere);
}

void _testQueryInnerJoin(){
  late String tableName1;
  late String table1JoinedColumn;
  late String tableName2;
  late String table2JoinedColumn;
  late String whereStatement;
  late List whereVariables;
  late List<Map<String, dynamic>> tQueryResult;
  setUp((){
    tableName1 = 'table_1';
    table1JoinedColumn = 'table_1_joined_column';
    tableName2 = 'table_2';
    table2JoinedColumn = 'table_2_joined_column';
    whereStatement = 'where statement';
    whereVariables = [1, '2'];
    tQueryResult = [
      {
        'key1': 'value1',
        'key2': 1
      },
      {
        'key1': 'value2',
        'key2': 2
      }
    ];
    when(db.rawQuery(any, any))
        .thenAnswer((_) async => tQueryResult);
  });

  test('Debe llamar los métodos esperados', ()async{
    await dbManager.queryInnerJoin(
      tableName1,
      table1JoinedColumn,
      tableName2,
      table2JoinedColumn,
      whereStatement,
      whereVariables
    );
    verify(db.rawQuery(
'''
SELECT * FROM $tableName1
INNER JOIN $tableName2
ON $tableName1.$table1JoinedColumn = $tableName2.$table2JoinedColumn
WHERE $whereStatement
''',
      whereVariables
    ));
  });

  test('Debe retornar el resultado esperado', ()async{
    final result = await dbManager.queryInnerJoin(
      tableName1,
      table1JoinedColumn,
      tableName2,
      table2JoinedColumn,
      whereStatement,
      whereVariables
    );
    expect(result, tQueryResult);
  });
}

void _testQueryCount(){
  late String tableName;
  late String whereStatement;
  late List whereVariables;
  late List<Map<String, Object>> dbResponse;
  setUp((){
    tableName = 'table_name';
    whereStatement = 'where_statement';
    whereVariables = [
      1,
      'a'
    ];
    dbResponse = [
      {
        'response': 2
      }
    ];
    when(db.rawQuery(any, any))
        .thenAnswer((_) async => dbResponse);
  });

  test('Debe llamar los métodos esperados', ()async{
    await dbManager.queryCount(tableName, whereStatement, whereVariables);
    verify(db.rawQuery(
'''
SELECT COUNT($idKey)
FROM $tableName
WHERE $whereStatement
''',
    whereVariables
    ));
  });
}

void _testRemoveWhere(){
  late String tableName;
  late String whereStatement;
  late List whereVariables;
  setUp((){
    tableName = 'table_name';
    whereStatement = 'where_statement';
    whereVariables = [
      1,
      'b'
    ];
    when(db.delete(
      any,
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs')
    )).thenAnswer((_) async => 1);
  });

  test('Debe llamar los métodos esperados', ()async{
    await dbManager.removeWhere(
      tableName,
      whereStatement,
      whereVariables
    );
    verify(db.delete(
      tableName,
      where: whereStatement,
      whereArgs: whereVariables
    ));
  });
}