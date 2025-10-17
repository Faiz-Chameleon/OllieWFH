import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class CommentsOnPostRepository {
  Future<Map<String, dynamic>> commentsOnPost(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.commentsOnPost, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> getCommentsOnPost(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.getCommentsOnPost, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> likeAndReplyOnPost(String commentId, Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.likeAndReplyOnPostComment, data, token: requiredToken);
  }
}

// var headers = {
//   'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE2OWZlMjJlLTU5YTktNDg3OS1iMjhiLTQzZTBlOGYyNDU1NSIsInVzZXJUeXBlIjoiVVNFUiIsImlhdCI6MTc1NjQxNzU1MiwiZXhwIjoxNzU2NTAzOTUyfQ.Qm8JMBLlBBFfQnayZYX1bePqoDToFsIQcCMzcYJydeQ',
//   'Content-Type': 'application/json'
// };
// var request = http.Request('POST', Uri.parse('http://3.96.202.108/api/v1/user/post/likeAndReplyOnComment'));
// request.body = json.encode({
//   "reply": "second reply on post comment",
//   "commentId": "b83ed8e6-4b7b-4eea-9a00-6b488ad0c597"
// });
// request.headers.addAll(headers);

// http.StreamedResponse response = await request.send();

// if (response.statusCode == 200) {
//   print(await response.stream.bytesToString());
// }
// else {
//   print(response.reasonPhrase);
// }
