import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/ForgotPasswordRequestCubit.dart';
import '../../../../utils/ui_utils.dart';

class ForgotPasswordRequestBottomSheet extends StatefulWidget {
  const ForgotPasswordRequestBottomSheet({super.key});

  @override
  State<ForgotPasswordRequestBottomSheet> createState() =>
      _ForgotPasswordRequestBottomSheetState();
}

class _ForgotPasswordRequestBottomSheetState
    extends State<ForgotPasswordRequestBottomSheet> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ForgotPasswordRequestCubit>().state
            is ForgotPasswordRequestInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
            topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BottomSheetTopBarMenu(
              //   onTapCloseButton: () {
              //     if (context.read<ForgotPasswordRequestCubit>().state
              //         is ForgotPasswordRequestInProgress) {
              //       return;
              //     }
              //     Navigator.of(context).pop();
              //   },
              //   title: 'Forget Password',
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _emailTextEditingController,
                  style: TextStyle(
                    fontSize: UiUtils.screenSubTitleFontSize,
                  ),
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
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              const SizedBox(
                height: 10,
              ),
              BlocConsumer<ForgotPasswordRequestCubit,
                  ForgotPasswordRequestState>(
                listener: (context, state) {
                  if (state is ForgotPasswordRequestFailure) {
                    UiUtils.showSnackBar(
                      context,
                      state.errorMessage,
                      Theme.of(context).colorScheme.error,
                    );
                  } else if (state is ForgotPasswordRequestSuccess) {
                    Navigator.of(context).pop({
                      "error": false,
                      "email": _emailTextEditingController.text.trim()
                    });
                  }
                },
                builder: (context, state) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      onPressed: state is ForgotPasswordRequestInProgress
                          ? null
                          : () {
                        FocusScope.of(context).unfocus();
                        if (UiUtils.validateEmail(_emailTextEditingController.text.trim()) != null) {
                          UiUtils.showOverlay(
                            context,
                            UiUtils.validateEmail(_emailTextEditingController.text.trim())!,
                            Theme.of(context).colorScheme.error,
                          );
                          return;
                        }

                        context
                            .read<ForgotPasswordRequestCubit>()
                            .requestForgotPassword(
                              email: _emailTextEditingController.text.trim(),
                            );
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
                                ? 'Submitting...'
                                : 'Submit',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
