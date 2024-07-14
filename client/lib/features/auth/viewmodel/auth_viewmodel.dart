import 'package:client/core/models/user_model.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

//Why authviewmodel
// Determine what state is going to be displaced with ui , So it's going to communicate with the repository so ui and repository don't communicate directly

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;
  @override
  //Tracking of dependecies and updating them;
  AsyncValue<UserModel>? build() {
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.signUp(
      name: name,
      email: email,
      password: password,
    );
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
      Right(value: final r) => state = AsyncValue.data(r),
    };

    print(val);
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> loginUser(
      {required String email, required String password}) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
      Right(value: final r) =>
        _loginSuccess(r), //Getting Data of user in UserModel format
    };
    print(val);
  }

  AsyncValue<UserModel> _loginSuccess(UserModel user) {
    print("Printing user from _loginSuccess $user");
    _authLocalRepository.setToken(user
        .token); // Extracting the user token {format of UserModel} and setting to local repo
    _currentUserNotifier.addUser(
        user); // Global currentuser is updated whenever user login and main function works as it watches the currentUser regularly
    return state = AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    //Getting userdata on bases of the token present in local auth repo if uer available
    // Setting state as loading
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);

      final val = switch (res) {
        Left(value: final l) => state = AsyncValue.error(
            l.message,
            StackTrace.current,
          ),
        Right(value: final r) => _getDataSuccess(r),
      };

      return val.value;
    }
    return null;
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user) {
    print("Printing user from _getDataSuccess $user");
    _currentUserNotifier.addUser(user);
    // Change of currentUserNotifier is important to add user to notifier because the main function watches the current user regularly
    return state = AsyncValue.data(user);
  }
}
