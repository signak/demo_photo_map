import 'dart:math' as math;

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pwa_update_listener/pwa_update_listener.dart';

import '../../core/util/logger.dart';
import '../../core/util/result.dart';
import '../../core/util/version_util.dart';
import '../../domain/auth/auth_exception.dart';
import '../../domain/auth/auth_state.dart';
import '../service/auth/auth_state_service.dart';
import '../service/auth/authentication_service.dart';
import '../theme/custom_color.g.dart';
import '../theme/dimension_info.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final dimens = DimensionUtil.getInfo(context, ref);
    final theme = Theme.of(context);

    final currentUser = ref.watch(authStateStreamProvider);
    final authServiceStatus = ref.watch(authServiceStatusNotifierProvider);
    final versionInfo = ref.watch(versionInfoProvider);
    final String versionText = (kDebugMode)
        ? 'Ver.${versionInfo.version}+${versionInfo.buildNumber}'
        : 'Ver.${versionInfo.version}';

    final appBarForegroundColor = theme.colorScheme.onSecondaryContainer;
    final appBarBackgroundColor = theme.colorScheme.onSurfaceVariant;
    final surfaceColor = theme.colorScheme.surfaceVariant;
    final containerBackgroundColor =
        theme.colorScheme.onSurfaceVariant.withAlpha(128);
    final versionTextColor = theme.colorScheme.onSurface.withOpacity(0.5);

    TextStyle getAppBarTextStyle() {
      final customTextStyle = TextStyle(
        color: appBarForegroundColor.withOpacity(0.5),
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
        fontSize: dimens.appBarFontSize,
      );
      return theme.appBarTheme.titleTextStyle?.merge(customTextStyle) ??
          customTextStyle;
    }

    final appBar = AppBar(
      title: const Text('Sign In'),
      titleTextStyle: getAppBarTextStyle(),
      elevation: 8,
      backgroundColor: appBarBackgroundColor.withOpacity(0.8),
    );

    final appBarHeight = appBar.preferredSize.height;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final mailTextController = ref.read(_mailTextControllerProvider(''));
    final passwordTextController =
        ref.read(_passwordTextControllerProvider(''));

    final containerWidth =
        math.min(dimens.loginUI.maxContainerWidth, screenSize.width);
    final containerPadding = (screenSize.width - containerWidth) / 2;

    return SafeArea(
      child: Scaffold(
        // キーボード表示切替でリビルドされるのでfalse指定
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          // 背景コンテナ
          color: surfaceColor,
          width: 1.sw,
          height: 1.sh,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(dimens.largeGap)
                  .copyWith(top: appBarHeight + dimens.largeGap),
              child: Container(
                // UIコンテナ
                margin: EdgeInsets.symmetric(
                  vertical: dimens.loginUI.containerVerticalMargin,
                  horizontal: containerPadding,
                ),
                // height: 0.9.sh,
                width: containerWidth,
                decoration: BoxDecoration(
                  color: containerBackgroundColor,
                  borderRadius: BorderRadius.circular(dimens.normalGap),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    currentUser.when(
                      data: (authState) {
                        if (authServiceStatus.isNotReady()) {
                          logger.d(
                              '[LoginPage] show auth service initializing information.');
                          return const _InitializingInfoWidget();
                        } else if (authState!.isSignedOut) {
                          return _SignInFormWidget(
                            formKey: formKey,
                            dimens: dimens,
                            mailTextController: mailTextController,
                            passwordTextController: passwordTextController,
                          );
                        } else if (authState.provider ==
                                AuthProviderType.password &&
                            !authState.emailVerified!) {
                          return _EmailConfirmWidget(
                              authState, dimens, containerWidth);
                        }
                        return _SignOutFormWidget(authState, dimens);
                      },
                      error: (error, stackTrace) {
                        logger.e('auth.state is error.', error, stackTrace);
                        return _ErrorDisplayWidget(
                          error: error,
                          stackTrace: stackTrace,
                        );
                      },
                      loading: () {
                        return const _LoadingProgressIndicator();
                      },
                    ),
                    Gap(dimens.largeGap),
                    Padding(
                      padding: EdgeInsets.all(dimens.largeGap),
                      child: Text(
                        versionText,
                        style: TextStyle(
                          color: versionTextColor,
                          fontSize: dimens.loginUI.versionFontSize,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final _mailTextControllerProvider =
    Provider.autoDispose.family<TextEditingController, String>(
  (ref, initialValue) => useTextEditingController(text: initialValue),
);

final _passwordTextControllerProvider =
    Provider.autoDispose.family<TextEditingController, String>(
  (ref, initialValue) => useTextEditingController(text: initialValue),
);

final _errorMessageProvider = StateProvider<String>((ref) => '');

enum _TextFieldType {
  email,
  password,
}

class _TextFormBuilder {
  static const int _passwordMinLength = 8;

  static const int _passwordMaxLength = 30;

  static const String _warnEmptyPassword =
      '$_passwordMinLength～$_passwordMaxLength文字でパスワードを入力してください。';

  static const String _warnPasswordLength =
      'パスワードは$_passwordMinLength～$_passwordMaxLength文字の範囲で入力してください。';

  static String? _validateEmailAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください。';
    } else if (!EmailValidator.validate(value)) {
      return '有効な形式のメールアドレスを入力してください。';
    }
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _warnEmptyPassword;
    } else if (value.length < 8 || value.length > _passwordMaxLength) {
      return _warnPasswordLength;
    }
    return null;
  }

  static Widget build({
    required _TextFieldType fieldType,
    required DimensionInfo dimens,
    required TextEditingController controller,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    late final FormFieldValidator<String> validator;
    late final bool obscureText;
    late final String hintText;
    late final String labelText;
    late final TextInputType? keyboardType;
    late final Iterable<String> autofillHints;
    late int? maxLength;
    late MaxLengthEnforcement? maxLengthEnforcement;

    if (fieldType == _TextFieldType.email) {
      validator = _validateEmailAddress;
      obscureText = false;
      hintText = 'メールアドレス';
      labelText = 'Email';
      keyboardType = TextInputType.emailAddress;
      autofillHints = [AutofillHints.email];
      maxLength = null;
      maxLengthEnforcement = null;
    } else {
      validator = _validatePassword;
      obscureText = true;
      hintText = 'パスワード ($_passwordMinLength～$_passwordMaxLength文字)';
      labelText = 'password';
      keyboardType = null;
      autofillHints = [AutofillHints.password];
      maxLength = _passwordMaxLength;
      maxLengthEnforcement = MaxLengthEnforcement.enforced;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dimens.largeGap,
        vertical: dimens.normalGap,
      ),
      child: TextFormField(
        controller: controller,
        textInputAction: textInputAction,
        decoration: InputDecoration(hintText: hintText, labelText: labelText),
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}

// TODO Androidの戻るボタンとブラウザbackの挙動制御
//      GoRouterでWillPopScopeによるBackボタンの制御と同等のことができるようになったら修正する。
class _SignInFormWidget extends HookConsumerWidget {
  const _SignInFormWidget({
    required this.formKey,
    required this.dimens,
    required this.mailTextController,
    required this.passwordTextController,
  });

  final GlobalKey<FormState> formKey;
  final DimensionInfo dimens;
  final TextEditingController mailTextController;
  final TextEditingController passwordTextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    final authService = ref.read(authenticationServiceProvider);
    final errorMessage = ref.watch(_errorMessageProvider.notifier);
    final errorMessageText = ref.watch(_errorMessageProvider);

    Future<void> signIn() async {
      errorMessage.state = '';
      formKey.currentState!.save();
      if (!formKey.currentState!.validate()) return;
      try {
        await authService.signIn(
            email: mailTextController.text,
            password: passwordTextController.text);
      } catch (e, st) {
        logger.e('failed sign in with email', e, st);
        errorMessage.state =
            '認証に失敗しました: ${(e is AuthException) ? e.code : e.toString()}';
      }
    }

    final List<Widget> errorMessageWidget = (errorMessageText.isEmpty)
        ? [Gap(dimens.normalGap)]
        : [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(dimens.smallGap),
              ),
              margin: EdgeInsets.symmetric(vertical: dimens.normalGap),
              padding: EdgeInsets.symmetric(
                vertical: dimens.normalGap,
                horizontal: dimens.largeGap,
              ),
              child: Text(
                errorMessageText,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(dimens.normalGap),
          ];

    final divider =
        Divider(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.3));

    Widget buildFixedButton({
      required IconData iconData,
      required String label,
      required VoidCallback onPressed,
      Color? color,
      Color? backgroundColor,
    }) {
      return Padding(
        padding: EdgeInsets.all(dimens.normalGap),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(
              dimens.loginUI.buttonWidth,
              dimens.loginUI.buttonHeight,
            ),
            elevation: dimens.smallGap,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(dimens.smallestGap)),
            ),
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: color ?? theme.colorScheme.onPrimary,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color ?? theme.colorScheme.onPrimary,
                      fontSize: dimens.normalFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> getButtons() {
      final registrationButton = buildFixedButton(
        iconData: Icons.person_add,
        label: '新規登録',
        onPressed: () async {
          errorMessage.state = '';
          formKey.currentState!.save();
          if (!formKey.currentState!.validate()) return;
          try {
            await authService.createNewAccount(
                mailTextController.text, passwordTextController.text);
          } catch (e, st) {
            logger.e('failed create new account with email', e, st);
            errorMessage.state =
                'アカウントの作成に失敗しました: ${(e is AuthException) ? e.code : e.toString()}';
          }
        },
      );

      final signInButton = buildFixedButton(
        iconData: Icons.login,
        label: 'サインイン',
        onPressed: () async {
          await signIn();
        },
      );

      final googleAuthButton = buildFixedButton(
        iconData: FontAwesomeIcons.google,
        label: 'Google 認証',
        color: theme.colorScheme.onTertiary,
        backgroundColor: theme.colorScheme.tertiary,
        onPressed: () async {
          await authService.signIn();
        },
      );

      if (screenSize.width <= dimens.loginUI.buttonWidth * 3) {
        return [
          registrationButton,
          signInButton,
          divider,
          googleAuthButton,
        ];
      } else {
        return [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  registrationButton,
                  Gap(dimens.normalGap * 2),
                  signInButton,
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  googleAuthButton,
                ],
              ),
            ],
          ),
        ];
      }
    }

    Widget buildPasswordResetLink() {
      return _PasswordResetLinkText(
        authService: authService,
        dimens: dimens,
        initialEmail: mailTextController,
      );
    }

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          ...errorMessageWidget,
          // メールアドレスの入力フォーム
          _TextFormBuilder.build(
            fieldType: _TextFieldType.email,
            dimens: dimens,
            controller: mailTextController,
            textInputAction: TextInputAction.next,
          ),
          // パスワードの入力フォーム
          _TextFormBuilder.build(
            fieldType: _TextFieldType.password,
            dimens: dimens,
            controller: passwordTextController,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) async => await signIn(),
          ),
          buildPasswordResetLink(),
          Gap(dimens.largeGap * 2),
          ...getButtons(),
          divider,
        ],
      ),
    );
  }
}

class _PasswordResetLinkText extends HookConsumerWidget {
  const _PasswordResetLinkText({
    required this.authService,
    required this.dimens,
    required this.initialEmail,
  });

  final DimensionInfo dimens;
  final TextEditingController initialEmail;
  final AuthenticationService authService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final linkedTextStyle = TextStyle(
      color: theme.extension<CustomColors>()!.linkedText,
      fontSize: dimens.loginUI.passwdResetFontSize,
    );

    final controller = useTextEditingController(text: initialEmail.text);

    Future<void> sendPasswordResetMail(BuildContext context) async {
      final email = controller.text;
      if (email.isEmpty || !EmailValidator.validate(email)) {
        return;
      }
      Future<Result<void, Exception>> send() async {
        logger.d('[LoginPage] send passwd reset mail to "$email"');

        return await authService
            .resetPassword(email)
            .then<Result<void, Exception>>((_) {
          return Result.ok(null);
        }).catchError((error) {
          if (error is Exception) {
            return Result.err(error);
          }
          return Result.err(Exception('unknown error: $error'));
        });
      }

      SnackBar buildSnackBar(String message, Result<void, Exception> result) {
        final icon = Icon(
          (result.isErr) ? FontAwesomeIcons.triangleExclamation : Icons.mail,
          size: dimens.loginUI.snackbarIconSize,
        );

        final backgroundColor = (result.isErr)
            ? theme.colorScheme.error
            : theme.colorScheme.tertiary;

        final textColor = (result.isErr)
            ? theme.colorScheme.onError
            : theme.colorScheme.onTertiary;

        final textStyle = TextStyle(
          color: textColor,
          fontSize: dimens.normalFontSize,
          fontWeight: FontWeight.normal,
        );

        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimens.normalGap),
        );

        return SnackBar(
          duration: const Duration(seconds: 10),
          elevation: 8,
          backgroundColor: backgroundColor,
          shape: shape,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(dimens.normalGap),
          padding: EdgeInsets.all(dimens.normalGap),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              Gap(dimens.largeGap),
              Expanded(
                child: Text(message,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 12,
                    style: textStyle),
              ),
            ],
          ),
        );
      }

      await send().then(
        (result) async {
          late final String message;
          result.when(
            ok: (_) {
              message = "パスワードの再設定リンクを、'$email' 宛てにメール送信しました。\n"
                  'メールを確認してパスワードを再設定してください。';
            },
            err: (e) {
              if (e is AuthException) {
                logger.e(
                    '[LoginPage] error raised on password reset mail sending. '
                    'code=${e.code}',
                    e,
                    e.stackTrace);
                message = 'パスワード再設定メールの送信中にエラーが発生しました。\n'
                    'メールアドレスが正しいか確認してから再度送信を行うか、'
                    'システム管理者にご連絡ください。\n'
                    'code: ${e.code}';
              } else {
                logger.e(
                    '[LoginPage] error raised on password reset mail sending. '
                    'type=${e.runtimeType}',
                    e);
                message = 'パスワード再設定メール送信中に予期しないエラーが発生しました。';
              }
            },
          );
          logger.d(
              '[LoginPage] result: ok is ${result.isOk}, err is ${result.isErr}');
          final snackBar = buildSnackBar(message, result);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      );
    }

    Future<void> showMailSendDialog(String initialFieldValue) async {
      final titleTextStyle = theme.dialogTheme.titleTextStyle?.copyWith(
            fontSize: dimens.largeFontSize,
          ) ??
          TextStyle(
            fontSize: dimens.largeFontSize,
          );
      final contentTextStyle = theme.dialogTheme.contentTextStyle?.copyWith(
            fontSize: dimens.normalFontSize,
          ) ??
          TextStyle(
            fontSize: dimens.normalFontSize,
          );
      controller.text = initialFieldValue;
      await showDialog<void>(
        context: context,
        builder: (_) {
          return ScaffoldMessenger(
            child: Builder(builder: (dialogContext) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext);
                },
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: AlertDialog(
                    titleTextStyle: titleTextStyle,
                    contentTextStyle: contentTextStyle,
                    title: Row(
                      children: [
                        Icon(Icons.info, size: dimens.appBarIconSize),
                        Gap(dimens.normalGap),
                        const Text('再設定'),
                      ],
                    ),
                    content: Form(
                      key: GlobalKey(debugLabel: 'passwordResetForm'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: dimens.largeGap,
                              vertical: dimens.normalGap,
                            ),
                            child: const Text('パスワードを再設定する場合は、'
                                '登録済みのメールアドレスを入力してから再設定ボタンを押してください。'),
                          ),
                          _TextFormBuilder.build(
                            fieldType: _TextFieldType.email,
                            dimens: dimens,
                            controller: controller,
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (_) async =>
                                await sendPasswordResetMail(dialogContext),
                          ),
                          Gap(dimens.normalGap),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                            dimens.loginUI.buttonWidth,
                            dimens.loginUI.buttonHeight,
                          ),
                        ),
                        onPressed: () => sendPasswordResetMail(dialogContext),
                        child: Text('再設定',
                            style: TextStyle(fontSize: dimens.normalFontSize)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.largeGap)
          .copyWith(top: dimens.normalGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await showMailSendDialog(initialEmail.text);
            },
            child: Text('ログインでお困りですか？', style: linkedTextStyle),
          ),
        ],
      ),
    );
  }
}

class _EmailConfirmWidget extends HookConsumerWidget {
  const _EmailConfirmWidget(
    this.authState,
    this.dimens,
    this.containerWidth,
  );

  final AuthState authState;
  final DimensionInfo dimens;
  final double containerWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authenticationServiceProvider);
    final errorMessage = ref.watch(_errorMessageProvider.notifier);

    ElevatedButton buildButton({
      required VoidCallback onPressed,
      required String label,
    }) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize:
              Size(dimens.loginUI.buttonWidth, dimens.loginUI.buttonHeight),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: dimens.normalFontSize),
          ),
        ),
      );
    }

    Widget getButtons() {
      final resendButton = buildButton(
        onPressed: () {
          errorMessage.state = '';
          try {
            authService.sendEmailVerification(authState);
          } catch (e) {
            errorMessage.state =
                '認証に失敗しました: ${(e is AuthException) ? e.code : e.toString()}';
          }
        },
        label: '認証メール再送信',
      );

      final reloadButton = buildButton(
        onPressed: reloadPwa,
        label: 'リロード',
      );

      final signOutButton = buildButton(
        onPressed: () => authService.signOut(authState),
        label: 'サインアウト',
      );

      if (containerWidth <= dimens.loginUI.buttonWidth * 2.5) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            reloadButton,
            Gap(dimens.normalGap),
            resendButton,
            Gap(dimens.largeGap * 2),
            signOutButton
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                signOutButton,
                Gap(dimens.largeGap * 2),
                reloadButton,
              ],
            ),
            Gap(dimens.largeGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                resendButton,
              ],
            ),
          ],
        );
      }
    }

    final textStyle = Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(
              fontSize: dimens.normalFontSize,
            ) ??
        TextStyle(fontSize: dimens.normalFontSize);

    return Padding(
      padding: EdgeInsets.all(dimens.largeGap),
      child: DefaultTextStyle(
        style: textStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              ref.watch(_errorMessageProvider),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(dimens.largeGap),
            const Text('アカウントに使用したメールの認証(*)が完了していません。'),
            Gap(dimens.smallestGap),
            Text(' * 利用可能なメールアドレスかどうかの確認',
                style: textStyle.copyWith(
                  fontSize: dimens.smallFontSize,
                  color: textStyle.color?.withOpacity(0.5) ??
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                )),
            Gap(dimens.largeGap),
            Text("'${authState.email}' のメールを確認し、"),
            const Text("'noreply@photo-share-capp.firebaseapp.com' から届いた"
                "確認メールのリンクをクリックしてアカウント認証を完了してください。"),
            Gap(dimens.largeGap),
            const Text('メールのリンクをクリックして認証完了のメッセージが表示されたあとも利用が開始できない場合は、'
                'リロードボタンを押してアプリをリロードしてください。'),
            Gap(dimens.largeGap),
            const Text('リロードしても利用が開始できない場合は、確認メールのリンクの認証期限がきれていた可能性があります。'
                'その場合は認証メール再送信ボタンを押し、送られてきたメールで再度認証を行ってください。'),
            Gap(dimens.largeGap * 2),
            Center(
              child: getButtons(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignOutFormWidget extends HookConsumerWidget {
  const _SignOutFormWidget(this.authState, this.dimens);

  final AuthState authState;
  final DimensionInfo dimens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authenticationServiceProvider);

    ElevatedButton buildButton({
      required VoidCallback onPressed,
      required String label,
    }) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize:
              Size(dimens.loginUI.buttonWidth, dimens.loginUI.buttonHeight),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: dimens.normalFontSize),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(dimens.largeGap),
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(
                    fontSize: dimens.normalFontSize,
                  ) ??
              TextStyle(fontSize: dimens.normalFontSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(dimens.normalGap),
              // (authState.isSignedIn)
              //     ? Text('Signed In by ${authState.provider!.name}')
              //     : const Text('Signed Out.'),
              // const Gap(8),
              // Text('UID: ${authState.uid}'),
              // const Gap(8),
              // Text('Name: ${authState.displayName}'),
              // const Gap(8),
              // Text('Email: ${authState.email}'),
              // const Gap(8),
              // Text('EmailVerified: ${authState.emailVerified}'),
              // const Gap(16),
              // Text('isAdmin: ${authState.authorizationInfo?.isSystemAdmin}'),
              // const Gap(8),
              // Text('canRead: ${authState.authorizationInfo?.canRead}'),
              // const Gap(8),
              // Text('canWrite: ${authState.authorizationInfo?.canWrite}'),
              // const Gap(8),
              // Text('updatedAt: ${authState.authorizationInfo?.updatedAt}'),
              const Text('システムの利用権が設定されていません。'),
              const Text('利用を開始する場合はシステム管理者に連絡してください。'),
              Gap(dimens.largeGap * 4),
              Center(
                child: buildButton(
                  onPressed: () {
                    authService.signOut(authState);
                  },
                  label: 'サインアウト',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorDisplayWidget extends StatelessWidget {
  const _ErrorDisplayWidget({required this.error, required this.stackTrace});

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 0.8.sw,
          height: 0.7.sh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(8),
              const Text('Error initializing Firebase.'),
              Text(error.toString()),
              // const Gap(8),
              // Text(stackTrace.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingProgressIndicator extends StatelessWidget {
  const _LoadingProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        Colors.orange,
      ),
    ));
  }
}

class _InitializingInfoWidget extends StatelessWidget {
  const _InitializingInfoWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Gap(8),
          Text('認証サービスの初期化中です。'),
          Text('初期化が完了するまでしばらくお待ちください。'),
        ],
      ),
    );
  }
}
