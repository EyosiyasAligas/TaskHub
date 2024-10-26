import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lottie/lottie.dart';
import 'package:task_hub/ui/screens/auth_screen/widgets/forget_password.dart';

import '../../../app/app.dart';
import '../../../app/routes.dart';
import '../../../cubits/ForgotPasswordRequestCubit.dart';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/signin_cubit.dart';
import '../../../cubits/signup_cubit.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../utils/local_storage_keys.dart';
import '../../../utils/ui_utils.dart';
import '../../styles/colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SignInCubit>(
            create: (_) => SignInCubit(AuthRepository()),
          ),
          BlocProvider<SignUpCubit>(
            create: (_) => SignUpCubit(AuthRepository()),
          ),
        ],
        child: const LoginScreen(),
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController nameController= = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();

  String email = '';
  String password = '';

  bool isPasswordVisible = true;
  bool isLoginScreen = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // nameController.dispose();
    // emailController.dispose();
    // passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     if (MyApp.themeNotifier.value == ThemeMode.dark) {
        //       MyApp.themeNotifier.value = ThemeMode.light;
        //       var box = Hive.box(settingsKey);
        //       box.put(darkModeKey, false);
        //     } else {
        //       MyApp.themeNotifier.value = ThemeMode.dark;
        //       var box = Hive.box(settingsKey);
        //       box.put(darkModeKey, true);
        //     }
        //     setState(() {});
        //   },
        //   child: Icon(
        //     MyApp.themeNotifier.value == ThemeMode.light
        //         ? Icons.dark_mode
        //         : Icons.light_mode,
        //   ),
        // ),
        body: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildLargeScreen(size);
              } else {
                return _buildSmallScreen(size);
              }
            },
          ),
        ),
      ),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
    Size size,
  ) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      children: [
        if (isLandscape)
          Expanded(
            flex: 4,
            child: RotatedBox(
              quarterTurns: 0,
              child: Lottie.asset(
                'assets/task.json',
                height: size.height,
                width: size.width * 0.50,
                // fit: BoxFit.fitHeight,
              ),
            ),
          ),
        // if (isLandscape) SizedBox(width: size.width * 0.10),
        Expanded(
          flex: 4,
          child: _buildMainBody(
            size,
          ),
        ),
        SizedBox(width: size.width * 0.05),
      ],
    );
  }

  /// For Small screens
  Widget _buildSmallScreen(
    Size size,
  ) {
    return Center(
      child: _buildMainBody(
        size,
      ),
    );
  }

  /// Main Body
  Widget _buildMainBody(
    Size size,
  ) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: !isLandscape && size.width > 600 ? 100 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: size.width > 600
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (!isLandscape) SizedBox(height: size.height * 0.25),
          size.width > 600
              ? Container()
              : SizedBox(
                  // height: size.height * 0.25,
                ),
          // Lottie.asset(
          //   'assets/wave.json',
          //   height: size.height * 0.2,
          //   width: size.width,
          //   fit: BoxFit.fill,
          // ),
          SizedBox(
            height: size.height * 0.03,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                isLoginScreen ? 'Login' : 'Signup',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              isLoginScreen ? 'Welcome Back!!!' : 'Create an Account',
              style: TextStyle(
                fontSize: UiUtils.screenTitleFontSize,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// username or Gmail
                  TextFormField(
                    // controller: emailController,
                    style: TextStyle(
                      fontSize: UiUtils.screenSubTitleFontSize,
                    ),
                    onChanged: (val) {
                      email = val;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) => UiUtils.validateEmail(value!),
                  ),

                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  /// password
                  TextFormField(
                    // controller: passwordController,
                    style: TextStyle(
                      fontSize: UiUtils.screenSubTitleFontSize,
                    ),
                    onChanged: (val) {
                      password = val;
                    },
                    obscureText: isPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_open),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          isPasswordVisible = !isPasswordVisible;
                          setState(() {});
                        },
                      ),
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else if (value.length < 7) {
                        return 'at least enter 6 characters';
                      } else if (value.length > 13) {
                        return 'maximum character is 13';
                      }
                      return null;
                    },
                  ),
                  if (isLoginScreen)
                    BlocBuilder<SignInCubit, SignInState>(
                      builder: (context, state) {
                        return Container(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: state is SignInInProgress
                                ? null
                                : () {
                                    UiUtils.showBottomSheet(
                                      child: BlocProvider(
                                        create: (_) =>
                                            ForgotPasswordRequestCubit(
                                                AuthRepository()),
                                        child:
                                            const ForgotPasswordRequestBottomSheet(),
                                      ),
                                      context: context,
                                    ).then((value) {
                                      if (value != null && !value['error']) {
                                        UiUtils.showSnackBar(
                                          context,
                                          "an email with password reset link has been sent to ${value['email']}",
                                          successColor,
                                        );
                                      }
                                    });
                                  },
                            child: Text(
                              'Forget Password?',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        );
                      },
                    ),
                  if (!isLoginScreen)
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                  if (!isLoginScreen)
                    Text(
                      'Creating an account means you\'re okay with our Terms of Services and our Privacy Policy',
                      style: TextStyle(
                        // color: Theme.of(context).colorScheme.onBackground,
                        fontSize: UiUtils.screenSubTitleFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (!isLoginScreen)
                    SizedBox(
                      height: size.height * 0.02,
                    ),

                  /// Login/signup Button
                  if (isLoginScreen) loginButton(),
                  if (!isLoginScreen) signupButton(),
                  SizedBox(
                    height: size.height * 0.03,
                  ),

                  /// change between login and signup
                  BlocBuilder<SignInCubit, SignInState>(
                    builder: (context, signInState) {
                      return BlocBuilder<SignUpCubit, SignUpState>(
                        builder: (context, signUpState) {
                          return GestureDetector(
                            onTap: signInState is SignInInProgress
                                ? null
                                : signUpState is SignInInProgress
                                    ? null
                                    : () {
                                        setState(() {
                                          _formKey.currentState?.reset();
                                          isLoginScreen = !isLoginScreen;
                                          print('emailController');
                                          print(email);
                                          print('passwordController');
                                          print(password);
                                        });
                                      },
                            child: RichText(
                              text: TextSpan(
                                text: isLoginScreen
                                    ? 'Don\'t have an account?'
                                    : 'Already have an account?',
                                // style: kHaveAnAccountStyle(size),
                                style: Theme.of(context).textTheme.bodyMedium,

                                children: [
                                  TextSpan(
                                    text: isLoginScreen ? ' Sign up' : ' Login',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: UiUtils.screenSubTitleFontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Login Button
  Widget loginButton() {
    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          context.read<AuthCubit>().authenticateUser(
              jwtToken: state.jwtToken ?? '', user: state.user);
          Navigator.of(context).pushReplacementNamed(Routes.home);
        } else if (state is SignInFailure) {
          UiUtils.showSnackBar(
            context,
            state.errorMessage,
            Theme.of(context).colorScheme.error,
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                context.read<SignInCubit>().signIn(
                      email: email.trim(),
                      password: password.trim(),
                    );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is SignInInProgress)
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  state is SignInInProgress ? 'Logging In...' : 'Login',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget signupButton() {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          context
              .read<AuthCubit>()
              .authenticateUser(jwtToken: state.jwtToken, user: state.user);
          Navigator.of(context).pushReplacementNamed(Routes.home);
        } else if (state is SignUpFailure) {
          UiUtils.showSnackBar(
            context,
            state.errorMessage ?? 'fff',
            Theme.of(context).colorScheme.error,
          );
        }
      },
      builder: (context, state) {
        if (state is SignUpInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                context.read<SignUpCubit>().signUp(
                      email: email.trim(),
                      password: password.trim(),
                    );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is ForgotPasswordRequestInProgress)
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  state is ForgotPasswordRequestInProgress
                      ? 'Signing Up...'
                      : 'Signup',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
