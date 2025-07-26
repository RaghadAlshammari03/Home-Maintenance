import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static String firebaseMessagingScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "baligny-6cec8",
        "private_key_id": "0f4d2ae4be6b80fbd595063f00b31e880e313d1c",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCk/ok5fuxkr9EX\njnB0onwG1Zy03FY3HNdZSK94eEUV38jtgsvTlyywtqF+mGJxIgcYLt085N0bs6i9\nVftT7GS8Ub8GaErsYwGF1GJd8u0C57RYBrFs7lx2Z4NdexPPoQjSHc8U0JqJUpG8\n3ddP1iCfcxkbp0yMdBqfwYN/WEZfv/lgqFXiDopbB6ch1kq02lFwleWCF0eKMM3R\nRiGa4wirR+zYAw//budjaoVVaCnXSXcoLiMdWAx2Vp2wxy0+7G0SXMDqETq6h1iI\nyyC0lYFmtAIwq2QId6AJOF4AomcAkoxg5IHSBu3+VVgUhsNb0lLLdtz2o97zkkpj\n0rfJenKVAgMBAAECggEAEP5554GisIuJXO9EtvFba/V0Mrlfv0UfCykDkG7MKCtz\nYxSYkN5zxxnF0Ce65U3XbuQOJoJTdycjPKkj/f9jBXXirTLFxiDmccCFMd8JDsZg\ncBFJv19dB6xevpykLDu5EFyV994Kj2qr7HOUWeVDWUOoyjffmGHcXNMONmoYXtku\nlss/hCMILGmxQpVnDXHB/rCbO+S4NPtU8bF74AamTg3iPUNk6BODBrEyo2QCqHN+\no5OCOzFaZJ/d9ttke3U9J4Edyvm8LFS3zt9bXOmGVoOfilpWp8wEZI1caovdxbyt\nfdXaLnWugQbfU3MHPeg/ImTL8GAB2jSdFe1IZTzGKwKBgQDPfZtk1WoeJ/SpANFJ\nPZmQpI5U1rjKle/3KHHzScJhBNEZr0lGu0KiHpe6ux/vxPWN5m/SD0gLEMzv3UY0\nXWGvWSBXY/uh0r6RHVfWwEqOdMf+3iXZiFO6LmMYFwFBaJNrUaqfjwXf6p1PtDAj\ntFcsN753bnV9jWmVsXu3Gf7h5wKBgQDLkYFfSGDt//gScKML8F4FV5IaBwQ/g6pH\ndCqYxAH64A8JzazneyK6gzU09b7I6uLlyLNBkuq40LxONXNU5Ik1C5ro9fzAMxNq\nmeiU+oki8aUxO0DAR4SbEGlW+3zdpwXqVU4FeDY1TxBDtD8ib0bTRPv8O6gq/nEX\n9rk90D/wIwKBgCLcZLZdUPX+GpImjAM1MU7nBu7kIKoQ5P9usS6CDwGD8KnTFImo\nvrpET5PVCrmbKvKLa/AsFxuc2AHY+ImlwtrWK6PjLYzzvobdGjv/lMc4gb2lj1Bs\nIj0evBF5FAHsUxBt6S/jtMX5QjL5ADmPfDH2r66bRWwxzTKUXkfWO0ezAoGBAMXx\ncKkkCgyjL6dOm1yKmAH9yvVACWNxNexRCvKM9ZfqsvTHZ++Wjohp+RzMMH3R2Fuz\nsop6v36CifhKhSDxMHHCHRmVx/VkNOcdTUk/7IVsD0M16JqPcGQPqz6HQD2PoXLh\nDALJh3yCqsAKzrE/HtFkbNoxcC6OR44TvMBcdS+dAoGAOkZq/nh6C0OLk7gZeCju\nFjqy4Ht+TybVGdXDZYlXpvNqjcE+jrUB8uhfczdgXP+Vx6qb2cx8CuH7SCPh6iJ1\n25pRBGNbxBH16LH2JAnE3fZsJ3JiLO03Y0nT8tycS+3OAjEL3/G79fA67TB3jlof\n0UgpcsOjUXCNn4R00Bqob24=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@baligny-6cec8.iam.gserviceaccount.com",
        "client_id": "111249367188971560955",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40baligny-6cec8.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      [firebaseMessagingScope],
    );

    // Extract the access token from the credentials
    final accessToken = client.credentials.accessToken.data;

    //return the access token
    return accessToken;
  }
}
