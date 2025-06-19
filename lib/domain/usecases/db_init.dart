
import 'package:object_tree/domain/repositories/i_node_repository.dart';

Future<bool> initDbUseCase(INodeRepository nodeRepository) async{
  return await nodeRepository.initDb();
}