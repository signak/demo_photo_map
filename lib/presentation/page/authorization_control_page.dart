import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/exception/exception_util.dart';
import '../../core/util/logger.dart';
import '../../domain/auth/authorization_info.dart';
import '../service/auth/auth_state_service.dart';
import '../service/auth/authorization_service.dart';
import '../theme/dimension_info.dart';
import '../widget/loading_progress_indicator.dart';
import '../widget/util/dialog_util.dart';

class AuthorizationControlPage extends HookConsumerWidget {
  const AuthorizationControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dimens = DimensionUtil.getInfo(context, ref);

    final appBarForegroundColor = theme.colorScheme.onSecondaryContainer;
    final appBarBackgroundColor = theme.colorScheme.secondaryContainer;

    const title = Text('Authorization Control');
    final appBar = AppBar(
      title: title,
      titleTextStyle: theme.appBarTheme.titleTextStyle!.copyWith(
        color: appBarForegroundColor,
        fontWeight: FontWeight.bold,
        fontSize: dimens.appBarFontSize,
      ),
      foregroundColor: appBarForegroundColor,
      backgroundColor: appBarBackgroundColor.withOpacity(0.5),
      iconTheme: IconThemeData(
        color: appBarForegroundColor,
        size: dimens.appBarIconSize,
      ),
    );

    final appBarHeight = appBar.preferredSize.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        alignment: Alignment.topLeft,
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.all(dimens.largeGap)
                .copyWith(top: 0, bottom: dimens.smallGap),
            child: _UserListViewWidget(
              appBarHeight: appBarHeight,
              dimens: dimens,
            ),
          ),
          _MessageWidget(dimens: dimens),
        ],
      ),
    );
  }
}

final _messageProvider = StateProvider.autoDispose<_Message>(
  (ref) => _Message.empty(),
);

class _Message {
  _Message(this.text, {this.isError = false});
  factory _Message.empty() {
    return _Message('');
  }

  final String text;
  final bool isError;

  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return text;
  }
}

class _MessageWidget extends HookConsumerWidget {
  const _MessageWidget({required this.dimens});

  final DimensionInfo dimens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final message = ref.watch(_messageProvider);
    late final Color borderColor;
    late final Color containerColor;
    late final Color textColor;

    if (message.isError) {
      borderColor = theme.colorScheme.error;
      containerColor = theme.colorScheme.errorContainer;
      textColor = borderColor;
    } else {
      borderColor = theme.colorScheme.onBackground;
      containerColor = theme.colorScheme.background;
      textColor = borderColor;
    }

    void clearMessage() {
      final message = ref.read(_messageProvider.notifier);
      message.update((state) => _Message.empty());
    }

    final contents = Container(
      padding: EdgeInsets.all(dimens.largeGap),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        color: containerColor,
        borderRadius: BorderRadius.circular(dimens.smallGap),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: dimens.authEditUI.messageFontSize,
            ),
          ),
          Gap(dimens.largeGap),
          ElevatedButton(
            onPressed: clearMessage,
            child: Text(
              'OK',
              style: TextStyle(fontSize: dimens.normalFontSize),
            ),
          ),
        ],
      ),
    );

    return Visibility(
      visible: message.isNotEmpty,
      maintainSize: false,
      child: GestureDetector(
        onTap: clearMessage,
        child: ColoredBox(
          color: theme.colorScheme.onBackground.withOpacity(0.5),
          child: SizedBox.expand(
            child: Center(
              child: contents,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserListViewWidget extends HookConsumerWidget {
  const _UserListViewWidget({
    required this.appBarHeight,
    required this.dimens,
  });

  final double appBarHeight;
  final DimensionInfo dimens;
  static const int _fixedItemCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selfAuthState = ref.watch(authStateNotifierProvider)!;
    final adminUid = selfAuthState.uid!;
    final auth = ref.watch(authorizationServiceProvider);

    final messageNotifier = ref.read(_messageProvider.notifier);

    late Stream<List<AuthorizationInfo>> stream;
    if (selfAuthState.isSystemAdmin) {
      stream = auth.getUsersStream(excludeUid: selfAuthState.uid);
    } else {
      stream = auth.getUsersStream(excludesAuthorizationAdmins: true);
    }

    return StreamBuilder(
      stream: stream,
      initialData: const <AuthorizationInfo>[],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!;
          return ListView.builder(
            padding:
                EdgeInsets.zero.copyWith(top: appBarHeight + dimens.largeGap),
            physics: const BouncingScrollPhysics(),
            itemCount: users.length + 2,
            itemBuilder: (context, index) {
              late final AuthorizationInfo user;
              switch (index) {
                case 0:
                  return _HintCard(dimens: dimens);
                case 1:
                  user = selfAuthState.authorizationInfo!;
                  break;
                default:
                  user = users[index - _fixedItemCount];
                  break;
              }
              return _UserCard(
                key: Key(
                    'User${user.uid}_${user.updatedAt!.millisecondsSinceEpoch}'),
                messageNotifier: messageNotifier,
                service: auth,
                adminUid: adminUid,
                user: user,
                isSelfCard: (user.uid == selfAuthState.uid),
                dimens: dimens,
              );
            },
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error!;
          final stackTrace = snapshot.stackTrace;
          logger.e(
              'error on _UserListViewWidget#build. ${error.runtimeType}: $error',
              error);
          return _ErrorDisplayWidget(
            error: error,
            stackTrace: stackTrace,
          );
        }
        return const Expanded(child: Center(child: LoadingProgressIndicator()));
      },
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.dimens});

  final DimensionInfo dimens;
  static const hintMessage = 'ユーザーをタップすると利用権限のON/OFFを行うことができます。';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = theme.colorScheme.background;
    final fgColor = theme.colorScheme.onBackground;
    final key = Key('authorization_control_page_hint_card'
        '_fg${fgColor.value}_bg${bgColor.value}');

    return Card(
      key: key,
      margin: EdgeInsets.all(dimens.smallGap).copyWith(top: dimens.largeGap),
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimens.normalGap),
        side: BorderSide(
          color: fgColor,
          strokeAlign: BorderSide.strokeAlignCenter,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Center(
          child: Text(
            hintMessage,
            style: TextStyle(
              fontSize: dimens.authEditUI.hintFontSize,
              color: fgColor,
              overflow: TextOverflow.visible,
            ),
            softWrap: true,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    super.key,
    required this.messageNotifier,
    required this.service,
    required this.adminUid,
    required this.user,
    this.isSelfCard = false,
    required this.dimens,
  });

  final StateController<_Message> messageNotifier;
  final AuthorizationService service;
  final AuthorizationInfo user;
  final String adminUid;
  final bool isSelfCard;
  final DimensionInfo dimens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userIcon = (isSelfCard) ? Icons.account_circle : Icons.person;

    final iconSize = dimens.authEditUI.stateIconSize;
    final double cardHeight = dimens.authEditUI.cardHeight;

    final colorScheme = theme.colorScheme;
    late final List<Widget> userAuthorityState;
    late final Color cardColor;
    if (isSelfCard) {
      userAuthorityState = [Gap(dimens.largeGap + iconSize)];
      cardColor = colorScheme.surfaceVariant;
    } else if (user.canRead && user.canWrite) {
      userAuthorityState = [
        Gap(dimens.largeGap),
        Icon(
          Icons.check_circle_outlined,
          color: colorScheme.onTertiaryContainer,
          size: iconSize,
        ),
      ];
      cardColor = colorScheme.tertiaryContainer;
    } else {
      userAuthorityState = [
        Gap(dimens.largeGap),
        Icon(
          Icons.hide_source,
          color: colorScheme.error,
          size: iconSize,
        ),
      ];
      cardColor = colorScheme.surface;
    }
    final f = DateFormat('yyyy年 MM月 dd日').format;
    final registeredDateText = '登録日： ${f(user.createdAt!)}';

    Future<bool> confirmAuthorityUpdating(
        {required String email, required bool updateToEnabled}) async {
      final buttonSize = Size(
        dimens.authEditUI.dialogButtonWidth,
        dimens.authEditUI.dialogButtonHeight,
      );
      final ret = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogContextWidth = MediaQuery.of(dialogContext).size.width;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.question_mark_rounded),
                Gap(dimens.normalGap),
                const Text('利用権限'),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                (updateToEnabled)
                    ? const Text('このユーザーにシステムを利用を許可しますか？')
                    : const Text('このユーザーのシステム利用を停止しますか？'),
                const Gap(12),
                Text('User: $email'),
              ],
            ),
            actions: DialogUtil.layoutActionButtons(
              containerWidth: dialogContextWidth * 0.8,
              buttonWidth: buttonSize.width,
              buttonSpacing: dimens.normalGap,
              buttons: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(context, true),
                  child: (updateToEnabled)
                      ? const Text('利用を許可する')
                      : const Text('利用を停止する'),
                ),
              ],
            ),
          );
        },
      );
      return ret ?? false;
    }

    Future<void> showUpdatedDialog({
      required String targetUserEmail,
      required bool updateToEnabled,
    }) async {
      final buf = <String>[];
      if (updateToEnabled) {
        buf.add('下記ユーザーのシステム利用を許可しました。');
      } else {
        buf.add('下記ユーザーのシステム利用を停止しました。');
      }
      buf.add('User: $targetUserEmail');

      final String messageText = buf.join('\n');
      if (!context.mounted) {
        // logger.w(
        //     'context unmounted on showUpdatedDialog as update succeed information.');
        messageNotifier.update((state) => _Message(messageText));
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.info_outline_rounded),
                  Gap(8),
                  Text('利用権限'),
                ],
              ),
              content: Text(messageText),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ]);
        },
      );
    }

    Future<void> showErrorDialog({
      required String targetUserEmail,
      required bool updateToEnabled,
      required dynamic error,
    }) async {
      final buf = <String>[];
      if (updateToEnabled) {
        buf.add('エラーが発生したため、下記ユーザーのシステム利用を許可できませんでした。');
      } else {
        buf.add('エラーが発生したため、下記ユーザーのシステム利用を停止できませんでした。');
      }
      buf.add('User: $targetUserEmail');
      buf.add('\n');
      buf.add(ExceptionUtil.getString(error));

      if (!context.mounted) {
        // logger.w(
        //     'context unmounted on showErrorDialog as update failed information.');
        messageNotifier
            .update((state) => _Message(buf.join('\n'), isError: true));
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: theme.colorScheme.error),
                  Gap(dimens.normalGap),
                  const Text('利用権限'),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: buf.map<Widget>((e) {
                  return (e.trim().isEmpty) ? Gap(dimens.normalGap) : Text(e);
                }).toList(),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ]);
        },
      );
    }

    Future<void> toggleAuthorityState() async {
      final targetUserEmail = user.id!;
      final targetUid = user.uid;
      final newAuthority = !user.canRead;

      final confirm = await confirmAuthorityUpdating(
          email: targetUserEmail, updateToEnabled: newAuthority);
      if (!confirm) {
        return;
      }

      await service
          .updateUserLicense(
              adminUid: adminUid, targetUid: targetUid, canUse: newAuthority)
          .then(
        (ret) async {
          return await ret.when(
            ok: (value) async {
              await showUpdatedDialog(
                  targetUserEmail: targetUserEmail,
                  updateToEnabled: newAuthority);
            },
            err: (error) async {
              logger.e('failed user authority updating. user: $targetUserEmail',
                  error);
              await showErrorDialog(
                  targetUserEmail: targetUserEmail,
                  updateToEnabled: newAuthority,
                  error: error);
            },
          );
        },
      );
    }

    return Card(
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(dimens.normalGap),
        onTap: () async {
          if (isSelfCard) {
            return;
          }
          return await toggleAuthorityState();
        },
        child: ListTile(
          leading: Icon(userIcon, size: iconSize),
          title: SizedBox(
            height: cardHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          user.id!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: dimens.authEditUI.userIdFontSize,
                          ),
                        ),
                      ),
                      Gap(dimens.largeGap),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(registeredDateText,
                            style: TextStyle(
                              fontSize: dimens.authEditUI.regDateFontSize,
                              decoration: TextDecoration.underline,
                            )),
                      ),
                    ],
                  ),
                ),
                ...userAuthorityState,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorDisplayWidget extends StatelessWidget {
  const _ErrorDisplayWidget({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

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
              const Gap(8),
              Text((kDebugMode) ? '$stackTrace' : ''),
            ],
          ),
        ),
      ),
    );
  }
}
