import 'dart:convert';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

//Riverpod analyze provider don't have to determine what provider has to use
@riverpod
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ServerConstants.serverUrl}/auth/signup",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': name,
            'email': email,
            'password': password,
          },
        ),
      );
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        //Handling the error
        return Left(AppFailure(responseBody['detail']));
      }
      return Right(UserModel.fromMap(responseBody));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login(
      {required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ServerConstants.serverUrl}/auth/login",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(responseBody['detail']));
      }
      //Because the response in in format of { 'user': {... User Data...} , 'token': ...Token... }
      return Right(UserModel.fromMap(responseBody['user'])
          .copyWith(token: responseBody['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ServerConstants.serverUrl}/auth/",
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(responseBody['detail']));
      }

      return Right(
        UserModel.fromMap(responseBody).copyWith(token: token),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
