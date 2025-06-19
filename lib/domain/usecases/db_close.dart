
import 'package:object_tree/domain/repositories/i_node_repository.dart';

Future<void> closeDbUseCase(INodeRepository nodeRepository) async{
  await nodeRepository.db.close();
}