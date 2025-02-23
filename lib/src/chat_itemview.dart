import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

class MsgStreamEv<T> {
  final String msgId;
  final T value;

  MsgStreamEv({required this.msgId, required this.value});
}

typedef CustomItemBuilder = Widget? Function(
  BuildContext context,
  int index,
  Message message,
);

typedef ItemVisibilityChange = void Function(
  BuildContext context,
  int index,
  Message message,
  bool visible,
);

/// MessageType.custom
typedef CustomMessageBuilder = Widget? Function(
  BuildContext context,
  bool isReceivedMsg,
  int index,
  Message message,
  Map<String, String> allAtMap,
  double textScaleFactor,
  List<MatchPattern> patterns,
  Subject<MsgStreamEv<int>> msgSendProgressSubject,
  Subject<int> clickSubject,
);

///  chat item
///
class ChatItemView extends StatefulWidget {
  /// if current is group chat : false
  /// if current is single chat : true
  /// true 单聊，false 群聊
  final bool isSingleChat;

  /// When you need to customize the message style,
  /// Whether to use a bubble container
  /// 自定义消息item view时，是否使用默认的起泡背景
  final bool isBubbleMsg;

  /// Customize the display style of messages,
  /// such as system messages or status messages such as withdrawal
  /// 自定义消息item view
  final CustomItemBuilder? customItemBuilder;

  /// OpenIM [Message]
  final Message message;

  /// listview index
  final int index;

  /// Message background on the left side of the chat window
  /// 收到的消息的气泡的背景色
  final Color leftBubbleColor;

  /// Message background on the right side of the chat window
  /// 发送的消息的气泡背景色
  final Color rightBubbleColor;

  /// Click on the message to process voice playback, video playback, picture preview, etc.
  final Subject<int> clickSubject;

  /// The status of message sending,
  /// there are two kinds of success or failure, true success, false failure
  /// 消息发送状态：成功，失败，发送中
  final Subject<MsgStreamEv<bool>> msgSendStatusSubject;

  /// The progress of sending messages, such as the progress of uploading pictures, videos, and files
  /// 消息的发送进度
  final Subject<MsgStreamEv<int>> msgSendProgressSubject;

  /// Download progress of pictures, videos, and files
  // final Subject<MsgStreamEv<int>> downloadProgressSubject;


  final Subject<MsgStreamEv<bool>> voicePlaySubject;

  /// Style of text content
  /// 文字消息的样式，只针对文本消息，其他消息默认采用rightTextStyle
  final TextStyle? rightTextStyle;
  final TextStyle? leftTextStyle;

  final double textScaleFactor;

  /// @ message style
  /// @消息的文字样式
  final TextStyle? atTextStyle;

  /// 消息时间的样式
  final TextStyle? timeStyle;

  /// hint message style
  /// 提示消息的样式，如：时间，xx撤回了一条消息等
  final TextStyle? hintTextStyle;

  /// Click on the avatar event on the left side of the chat window
  final Function()? onTapLeftAvatar;

  // LongPress on the avatar event on the left side of the chat window
  final Function()? onLongPressLeftAvatar;

  /// Click on the avatar event on the right side of the chat window
  final Function()? onTapRightAvatar;

  // LongPress on the avatar event on the right side of the chat window
  final Function()? onLongPressRightAvatar;

  /// Click the @ content
  final ValueChanged<String>? onClickAtText;

  /// Whether the current message item is visible,
  /// used to process whether the message has been read event
  /// 当前消息是否处于界面可见位置
  final ItemVisibilityChange? visibilityChange;

  /// all user info
  /// key:userid，value:username
  /// @信息列表，key：用户id，value：用户名
  final Map<String, String> allAtMap;

  // final double width;

  /// long press menu list
  /// 长按消息起泡弹出的菜单列表
  final List<ChatMenuInfo>? menus;

  /// menu list style
  /// 菜单样式
  final ChatMenuStyle? menuStyle;

  ///
  final EdgeInsetsGeometry? padding;

  ///
  final EdgeInsetsGeometry? margin;

  /// 头像大小
  final double? avatarSize;

  ///
  // final bool showTime;
  final String? timeStr;

  /// Click the copy button event on the menu
  final Function()? onTapCopyMenu;

  /// Click the delete button event on the menu
  final Function()? onTapDelMenu;

  /// Click the forward button event on the menu
  final Function()? onTapForwardMenu;

  /// Click the reply button event on the menu
  final Function()? onTapReplyMenu;

  /// Click the revoke button event on the menu
  final Function()? onTapRevokeMenu;

  ///
  final Function()? onTapMultiMenu;

  ///
  final Function()? onTapTranslationMenu;

  ///
  final Function()? onTapAddEmojiMenu;

  /// Click the copy button event on the menu
  final bool enabledCopyMenu;

  /// Click the delete button event on the menu
  final bool enabledDelMenu;

  /// Click the forward button event on the menu
  final bool enabledForwardMenu;

  /// Click the reply button event on the menu
  final bool enabledReplyMenu;

  /// Click the revoke button event on the menu
  final bool enabledRevokeMenu;

  ///
  final bool enabledMultiMenu;

  ///
  final bool enabledTranslationMenu;

  ///
  final bool enabledAddEmojiMenu;

  /// 当前是否是多选模式
  final bool multiSelMode;

  ///
  final Function(bool checked)? onMultiSelChanged;

  /// 被选择的消息
  final List<Message> multiList;

  ///
  final Function()? onTapQuoteMsg;

  final List<MatchPattern> patterns;

  /// 是否在发送消息时，延迟显示消息发送中状态，既延迟显示加载框
  final bool delaySendingStatus;

  /// 显示消息已读
  final bool enabledReadStatus;

  /// 是否开启阅后即焚
  final bool isPrivateChat;

  /// 阅后即焚回调
  final Function()? onDestroyMessage;

  /// 阅读时长s
  final int readingDuration;

  /// 预览群消息已读状态
  final Function()? onViewMessageReadStatus;

  /// 失败重发
  final Function()? onFailedResend;

  /// MessageType.custom
  final CustomMessageBuilder? customMessageBuilder;

  /// 自定义头像
  final CustomAvatarBuilder? customLeftAvatarBuilder;
  final CustomAvatarBuilder? customRightAvatarBuilder;
  final Color? highlightColor;

  /// 当前播放的语音消息
  final bool isPlayingSound;

  final Function(bool show)? onPopMenuShowChanged;

  final String? leftName;
  final String? leftAvatarUrl;
  final String? rightName;
  final String? rightAvatarUrl;

  /// 将公告消息做普通消息显示
  final bool showNoticeMessage;

  /// 显示长按菜单
  final bool showLongPressMenu;

  /// 时间装饰
  final BoxDecoration? timeDecoration;

  /// 上下间距
  final EdgeInsetsGeometry? timePadding;

  /// 点击系统软键盘返回键关闭菜单
  final Subject<bool>? popPageCloseMenuSubject;

  const ChatItemView({
    Key? key,
    required this.index,
    required this.isSingleChat,
    required this.message,
    this.customItemBuilder,
    required this.clickSubject,
    required this.msgSendStatusSubject,
    required this.msgSendProgressSubject,
    required this.voicePlaySubject,
    this.isBubbleMsg = true,
    this.leftBubbleColor = const Color(0xFFF0F0F0),
    this.rightBubbleColor = const Color(0xFFDCEBFE),
    this.onLongPressRightAvatar,
    this.onTapRightAvatar,
    this.onLongPressLeftAvatar,
    this.onTapLeftAvatar,
    this.visibilityChange,
    this.allAtMap = const {},
    this.onClickAtText,
    this.menus,
    this.menuStyle,
    this.padding,
    this.margin,
    this.rightTextStyle,
    this.leftTextStyle,
    this.atTextStyle,
    this.timeStyle,
    this.hintTextStyle,
    this.textScaleFactor = 1.0,
    this.avatarSize,
    this.timeStr,
    this.onTapCopyMenu,
    this.onTapDelMenu,
    this.onTapForwardMenu,
    this.onTapReplyMenu,
    this.onTapRevokeMenu,
    this.onTapMultiMenu,
    this.onTapTranslationMenu,
    this.onTapAddEmojiMenu,
    this.enabledCopyMenu = true,
    this.enabledMultiMenu = true,
    this.enabledDelMenu = true,
    this.enabledForwardMenu = true,
    this.enabledReplyMenu = true,
    this.enabledRevokeMenu = true,
    this.enabledTranslationMenu = true,
    this.enabledAddEmojiMenu = true,
    this.multiSelMode = false,
    this.onMultiSelChanged,
    this.multiList = const [],
    this.onTapQuoteMsg,
    this.patterns = const [],
    this.delaySendingStatus = false,
    this.enabledReadStatus = true,
    this.readingDuration = 30,
    this.isPrivateChat = false,
    this.onDestroyMessage,
    this.onViewMessageReadStatus,
    this.onFailedResend,
    this.customMessageBuilder,
    this.customLeftAvatarBuilder,
    this.customRightAvatarBuilder,
    this.highlightColor,
    this.isPlayingSound = false,
    this.onPopMenuShowChanged,
    this.leftName,
    this.rightName,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    this.showNoticeMessage = false,
    this.showLongPressMenu = true,
    this.timeDecoration,
    this.timePadding,
    this.popPageCloseMenuSubject,
  }) : super(key: key);

  @override
  _ChatItemViewState createState() => _ChatItemViewState();
}

class _ChatItemViewState extends State<ChatItemView> {
  final _popupCtrl = CustomPopupMenuController();

  bool get _isFromMsg => widget.message.sendID != OpenIM.iMManager.uid;

  bool get _checked => widget.multiList.contains(widget.message);
  late StreamSubscription<bool> _keyboardSubs;
  StreamSubscription<bool>? _closeMenuSubs;

  /// 提示信息样式
  var _isHintMsg = false;

  var _hintTextStyle = TextStyle(
    color: Color(0xFF999999),
    fontSize: 12.sp,
  );

  @override
  void dispose() {
    _popupCtrl.dispose();
    _keyboardSubs.cancel();
    _closeMenuSubs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    var keyboardVisibilityCtrl = KeyboardVisibilityController();
    // Query
    print('Keyboard visibility direct query: ${keyboardVisibilityCtrl.isVisible}');

    // Subscribe
    _keyboardSubs = keyboardVisibilityCtrl.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      _popupCtrl.hideMenu();
    });

    _popupCtrl.addListener(() {
      widget.onPopMenuShowChanged?.call(_popupCtrl.menuIsShowing);
    });

    _closeMenuSubs = widget.popPageCloseMenuSubject?.listen((value) {
      if (value == true) {
        _popupCtrl.hideMenu();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? child;
    // custom view
    var view = _customItemView();
    if (null != view) {
      if (widget.isBubbleMsg) {
        child = _buildCommonItemView(child: view);
      } else {
        child = view;
      }
    } else {
      child = _buildItemView();
    }

    return FocusDetector(
      child: Container(
        padding: widget.padding ??
            EdgeInsets.fromLTRB(
              widget.multiSelMode && !_isHintMsg ? 0 : 22.w,
              0,
              22.w,
              _isHintMsg ? 5.h : 15.h,
            ),
        margin: widget.margin,
        child: child,
        color: widget.highlightColor,
      ),
      onVisibilityLost: () {
        if (widget.visibilityChange != null) {
          widget.visibilityChange!(
            context,
            widget.index,
            widget.message,
            false,
          );
        }
      },
      onVisibilityGained: () {
        if (widget.visibilityChange != null) {
          widget.visibilityChange!(
            context,
            widget.index,
            widget.message,
            true,
          );
        }
      },
    );
  }

  Widget? _buildItemView() {
    Widget? child;
    try {
      // 公告消息
      if (widget.showNoticeMessage && null != _noticeView) {
        return _noticeView;
      }
      switch (widget.message.contentType) {
        case MessageType.text:
          {
            child = _buildCommonItemView(
              child: ChatAtText(
                text: widget.message.content!,
                textStyle: _isFromMsg ? widget.leftTextStyle : widget.rightTextStyle,
                textScaleFactor: widget.textScaleFactor,
                patterns: widget.patterns,
              ),
            );
          }
          break;
        case MessageType.at_text:
          {
            Map map = json.decode(widget.message.content!);
            var text = map['text'];
            child = _buildCommonItemView(
              child: ChatAtText(
                text: text,
                allAtMap: widget.allAtMap,
                textStyle: _isFromMsg ? widget.leftTextStyle : widget.rightTextStyle,
                textScaleFactor: widget.textScaleFactor,
                patterns: widget.patterns,
              ),
            );
          }
          break;
        case MessageType.picture:
          {
            var picture = widget.message.pictureElem;
            child = _buildCommonItemView(
              isBubbleBg: false,
              child: ChatPictureView(
                msgId: widget.message.clientMsgID!,
                isReceived: _isFromMsg,
                snapshotPath: null,
                snapshotUrl: picture?.snapshotPicture?.url,
                sourcePath: picture?.sourcePath,
                sourceUrl: picture?.sourcePicture?.url,
                width: picture?.sourcePicture?.width?.toDouble(),
                height: picture?.sourcePicture?.height?.toDouble(),
                widgetWidth: 100.w,
                msgSenProgressStream: widget.msgSendProgressSubject.stream,
                initMsgSendProgress: 100,
                index: widget.index,
                clickStream: widget.clickSubject.stream,
              ),
            );
          }
          break;
        case MessageType.voice:
          {
            var sound = widget.message.soundElem;
            child = _buildCommonItemView(
              child: ChatVoiceView(
                msgId: widget.message.clientMsgID!,
                index: widget.index,
                clickStream: widget.clickSubject.stream,
                voicePlayStream: widget.voicePlaySubject.stream,
                isReceived: _isFromMsg,
                soundPath: sound?.soundPath,
                soundUrl: sound?.sourceUrl,
                duration: sound?.duration,
                isPlaying: widget.isPlayingSound,
              ),
            );
          }
          break;
        case MessageType.video:
          {
            var video = widget.message.videoElem;
            child = _buildCommonItemView(
              isBubbleBg: false,
              child: ChatVideoView(
                msgId: widget.message.clientMsgID!,
                isReceived: _isFromMsg,
                snapshotPath: video?.snapshotPath,
                snapshotUrl: video?.snapshotUrl,
                videoPath: video?.videoPath,
                videoUrl: video?.videoUrl,
                width: video?.snapshotWidth?.toDouble(),
                height: video?.snapshotHeight?.toDouble(),
                widgetWidth: 100.w,
                msgSenProgressStream: widget.msgSendProgressSubject.stream,
                initMsgSendProgress: 100,
                index: widget.index,
                clickStream: widget.clickSubject.stream,
              ),
            );
          }
          break;
        case MessageType.file:
          {
            var file = widget.message.fileElem;
            child = _buildCommonItemView(
              child: ChatFileView(
                msgId: widget.message.clientMsgID!,
                fileName: file!.fileName!,
                bytes: file.fileSize ?? 0,
                width: 158.w,
                initProgress: 100,
                uploadStream: widget.msgSendProgressSubject.stream,
                index: widget.index,
                clickStream: widget.clickSubject.stream,
              ),
            );
          }
          break;
        case MessageType.location:
          {
            var location = widget.message.locationElem;
            child = _buildCommonItemView(
              isBubbleBg: false,
              child: ChatLocationView(
                description: location!.description!,
                latitude: location.latitude!,
                longitude: location.longitude!,
              ),
            );
          }
          break;
        case MessageType.quote:
          {
            child = _buildCommonItemView(
              child: ChatAtText(
                text: widget.message.quoteElem?.text ?? '',
                allAtMap: widget.allAtMap,
                textStyle: _isFromMsg ? widget.leftTextStyle : widget.rightTextStyle,
                textScaleFactor: widget.textScaleFactor,
                patterns: widget.patterns,
              ),
            );
          }
          break;
        case MessageType.merger:
          {
            child = _buildCommonItemView(
              child: ChatMergeMsgView(
                title: widget.message.mergeElem?.title ?? '',
                summaryList: widget.message.mergeElem?.abstractList ?? [],
              ),
            );
          }
          break;
        case MessageType.card:
          {
            var data = json.decode(widget.message.content!);
            child = _buildCommonItemView(
              isBubbleBg: false,
              child: ChatCarteView(
                name: data['nickname'],
                url: data['faceURL'],
              ),
            );
          }
          break;
        case MessageType.custom_face:
          {
            var face = widget.message.faceElem;
            child = _buildCommonItemView(
              isBubbleBg: false,
              child: ChatCustomEmojiView(
                index: face?.index,
                data: face?.data,
                widgetWidth: 100.w,
              ),
            );
          }
          break;
        case MessageType.custom:
          {
            child = _buildCommonItemView(
              isBubbleBg: widget.isBubbleMsg,
              child: widget.customMessageBuilder?.call(
                    context,
                    _isFromMsg,
                    widget.index,
                    widget.message,
                    widget.allAtMap,
                    widget.textScaleFactor,
                    widget.patterns,
                    widget.msgSendProgressSubject,
                    widget.clickSubject,
                  ) ??
                  ChatAtText(
                    text: UILocalizations.unsupportedMessage,
                    textStyle: widget.rightTextStyle,
                    textScaleFactor: widget.textScaleFactor,
                  ),
            );
          }
          break;
        default:
          {
            _isHintMsg = true;
            var text = _parseHintText();
            if (null == text) _isHintMsg = false;
            child = _buildCommonItemView(
              isBubbleBg: null == text,
              isHintMsg: null != text,
              child: ChatAtText(
                text: text ?? UILocalizations.unsupportedMessage,
                textAlign: null != text ? TextAlign.center : TextAlign.left,
                textStyle: null != text ? widget.hintTextStyle ?? _hintTextStyle : widget.rightTextStyle,
                textScaleFactor: null != text ? 1.0 : widget.textScaleFactor,
              ),
            );
          }
          break;
      }
    } catch (e) {
      print('--------message parse error----->e:$e');
      child = _buildCommonItemView(
        child: ChatAtText(
          text: UILocalizations.unsupportedMessage,
          textStyle: widget.rightTextStyle,
          textScaleFactor: widget.textScaleFactor,
        ),
      );
    }
    return child;
  }

  Widget _buildCommonItemView({
    required Widget child,
    bool isBubbleBg = true,
    bool isHintMsg = false,
  }) =>
      ChatSingleLayout(
        child: child,
        msgId: widget.message.clientMsgID!,
        index: widget.index,
        menuBuilder: _menuBuilder,
        haveUsableMenu: _haveUsableMenu,
        clickSink: widget.clickSubject.sink,
        sendStatusStream: widget.msgSendStatusSubject.stream,
        popupCtrl: _popupCtrl,
        isReceivedMsg: _isFromMsg,
        isSingleChat: widget.isSingleChat,
        avatarSize: widget.avatarSize ?? 42.h,
        rightAvatar: widget.rightAvatarUrl ?? OpenIM.iMManager.uInfo.faceURL,
        leftAvatar: widget.leftAvatarUrl ?? widget.message.senderFaceUrl,
        leftName: widget.leftName ?? widget.message.senderNickname ?? '',
        isUnread: !widget.message.isRead!,
        leftBubbleColor: widget.leftBubbleColor,
        rightBubbleColor: widget.rightBubbleColor,
        onLongPressRightAvatar: widget.onLongPressRightAvatar,
        onTapRightAvatar: widget.onTapRightAvatar,
        onLongPressLeftAvatar: widget.onLongPressLeftAvatar,
        onTapLeftAvatar: widget.onTapLeftAvatar,
        isSendFailed: widget.message.status == MessageStatus.failed,
        isSending: widget.message.status == MessageStatus.sending,
        timeView: widget.timeStr == null ? null : _buildTimeView(),
        isBubbleBg: isBubbleBg,
        isHintMsg: isHintMsg,
        quoteView: _quoteView,
        showRadio: widget.multiSelMode,
        checked: _checked,
        onRadioChanged: widget.onMultiSelChanged,
        delaySendingStatus: widget.delaySendingStatus,
        enabledReadStatus: widget.enabledReadStatus,
        isPrivateChat: widget.isPrivateChat,
        onStartDestroy: widget.onDestroyMessage,
        readingDuration: widget.readingDuration,
        needReadCount: _needReadCount,
        haveReadCount: _haveReadCount,
        viewMessageReadStatus: widget.onViewMessageReadStatus,
        failedResend: widget.onFailedResend,
        customLeftAvatarBuilder: widget.customLeftAvatarBuilder,
        customRightAvatarBuilder: widget.customRightAvatarBuilder,
        showLongPressMenu: widget.showLongPressMenu,
        isVoiceMessage: widget.message.contentType == MessageType.voice,
      );

  Widget _menuBuilder() => ChatLongPressMenu(
        controller: _popupCtrl,
        menus: widget.menus ?? _menusItem(),
        menuStyle: widget.menuStyle ??
            ChatMenuStyle(
                crossAxisCount: 5,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                radius: 8,
                background: const Color(0xFF333333),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
      );

  Widget? _customItemView() => widget.customItemBuilder?.call(
        context,
        widget.index,
        widget.message,
      );

  Widget _buildTimeView() => Container(
        padding: widget.timePadding ??
            EdgeInsets.symmetric(
              vertical: 4.h,
              horizontal: 2.h,
            ),
        // height: 20.h,
        decoration: widget.timeDecoration,
        child: Text(
          widget.timeStr!,
          style: widget.timeStyle ?? _hintTextStyle,
        ),
      );

  List<ChatMenuInfo> _menusItem() => [
        ChatMenuInfo(
          icon: ImageUtil.menuCopy(),
          text: UILocalizations.copy,
          enabled: widget.enabledCopyMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapCopyMenu,
        ),
        ChatMenuInfo(
          icon: ImageUtil.menuDel(),
          text: UILocalizations.delete,
          enabled: widget.enabledDelMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapDelMenu,
        ),
        ChatMenuInfo(
          icon: ImageUtil.menuForward(),
          text: UILocalizations.forward,
          enabled: widget.enabledForwardMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapForwardMenu,
        ),
        ChatMenuInfo(
          icon: ImageUtil.menuReply(),
          text: UILocalizations.reply,
          enabled: widget.enabledReplyMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapReplyMenu,
        ),
        ChatMenuInfo(
            icon: ImageUtil.menuRevoke(),
            text: UILocalizations.revoke,
            enabled: widget.enabledRevokeMenu,
            textStyle: menuTextStyle,
            onTap: widget.onTapRevokeMenu),
        ChatMenuInfo(
          icon: ImageUtil.menuMultiChoice(),
          text: UILocalizations.multiChoice,
          enabled: widget.enabledMultiMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapMultiMenu,
        ),
        ChatMenuInfo(
          icon: ImageUtil.menuTranslation(),
          text: UILocalizations.translation,
          enabled: widget.enabledTranslationMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapTranslationMenu,
        ),
        ChatMenuInfo(
          icon: ImageUtil.menuAddEmoji(),
          text: UILocalizations.add,
          enabled: widget.enabledAddEmojiMenu,
          textStyle: menuTextStyle,
          onTap: widget.onTapAddEmojiMenu,
        ),
      ];

  static var menuTextStyle = TextStyle(
    fontSize: 13.sp,
    color: Color(0xFFFFFFFF),
  );

  // Widget? get _quoteView => widget.message.contentType == MessageType.quote
  //     ? ChatQuoteView(
  //         message: widget.message,
  //         onTap: widget.onTapQuoteMsg,
  //       )
  //     : null;

  Widget? get _quoteView {
    if (widget.message.contentType == MessageType.quote) {
      return ChatQuoteView(
        message: widget.message.quoteElem!.quoteMessage!,
        onTap: widget.onTapQuoteMsg,
      );
    } else if (widget.message.contentType == MessageType.at_text) {
      var message = widget.message.atElem!.quoteMessage;
      if (message != null) {
        return ChatQuoteView(
          message: message,
          onTap: widget.onTapQuoteMsg,
        );
      }
    }
    return null;
  }

  /// 公告消息
  Widget? get _noticeView {
    // 公告消息
    if (widget.message.contentType! == MessageType.groupInfoSetNotification) {
      final elem = widget.message.notificationElem!;
      final map = json.decode(elem.detail!);
      final notification = GroupNotification.fromJson(map);
      if (notification.group?.notification != null && notification.group!.notification!.trim().isNotEmpty) {
        return _buildCommonItemView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatAtText(
                text: UILocalizations.groupNotice,
                textStyle: widget.rightTextStyle,
                textScaleFactor: widget.textScaleFactor,
                patterns: widget.patterns,
              ),
              ChatAtText(
                text: notification.group!.notification!,
                textStyle: widget.rightTextStyle,
                textScaleFactor: widget.textScaleFactor,
                patterns: widget.patterns,
              )
            ],
          ),
        );
      }
    }
    return null;
  }

  String get _who => _isFromMsg ? widget.message.senderNickname ?? '' : UILocalizations.you;

  int get _haveReadCount => widget.message.attachedInfoElem?.groupHasReadInfo?.hasReadUserIDList?.length ?? 0;

  int get _needReadCount => widget.message.attachedInfoElem?.groupHasReadInfo?.groupMemberCount ?? 0;

  bool get _haveUsableMenu =>
      widget.enabledCopyMenu ||
      widget.enabledDelMenu ||
      widget.enabledForwardMenu ||
      widget.enabledReplyMenu ||
      widget.enabledRevokeMenu ||
      widget.enabledMultiMenu ||
      widget.enabledTranslationMenu ||
      widget.enabledAddEmojiMenu;

  // bool get _isNotification => widget.message.contentType! > 1000;

  String? _parseHintText() {
    String? text;
    if (MessageType.revoke == widget.message.contentType) {
      text = '$_who ${UILocalizations.revokeAMsg}';
    } else if (MessageType.advancedRevoke == widget.message.contentType) {
      if (widget.message.isSingleChat) {
        // 单聊
        text = '$_who ${UILocalizations.revokeAMsg}';
      } else {
        // 群聊撤回包含：撤回自己消息，群组或管理员撤回其他人消息
        var map = json.decode(widget.message.content!);
        var info = RevokedInfo.fromJson(map);
        if (info.revokerID == info.sourceMessageSendID) {
          text = '$_who ${UILocalizations.revokeAMsg}';
        } else {
          late String revoker;
          late String sender;
          if (info.revokerID == OpenIM.iMManager.uid) {
            revoker = UILocalizations.you;
          } else {
            revoker = info.revokerNickname!;
          }
          if (info.sourceMessageSendID == OpenIM.iMManager.uid) {
            sender = UILocalizations.you;
          } else {
            sender = info.sourceMessageSenderNickname!;
          }

          text = sprintf(
            UILocalizations.groupOwnerOrAdminRevokeAMsg,
            [revoker, sender],
          );
        }
      }
    } else {
      try {
        var content = json.decode(widget.message.content!);
        text = content['defaultTips'];
      } catch (e) {
        print('--------message content parse error----->e:$e');
        text = json.encode(widget.message);
      }
    }
    return text;
  }
}
