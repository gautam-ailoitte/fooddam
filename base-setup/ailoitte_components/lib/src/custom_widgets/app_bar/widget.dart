import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';

const EdgeInsets defaultTitlePadding = EdgeInsets.only(top: 2);
const EdgeInsets defaultLeadingPadding = EdgeInsets.only(right: 20);
const double defaultElevation = 0;
const bool defaultCenterTitle = false;
const bool defaultShowBackButton = true;

class AiloitteAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const AiloitteAppBarWidget({
    Key? key,
    this.titlePadding,
    this.leadingPadding,
    this.title,
    this.titleStyle,
    this.callBack,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.gradient,
    this.toolbarHeight,
    this.showBackButton,
    this.centerTitle,
    this.elevation,
  }) : super(key: key);

  final EdgeInsets? titlePadding;
  final EdgeInsets? leadingPadding;
  final String? title;
  final TextStyle? titleStyle;
  final Function? callBack;
  final Widget? leading;
  final List<Widget>? actions;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double? toolbarHeight;
  final bool? showBackButton;
  final bool? centerTitle;
  final double? elevation;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? defaultElevation,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor,
        ),
      ),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: (centerTitle ?? defaultCenterTitle)
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          leading ??
              Visibility(
                visible: showBackButton ?? defaultShowBackButton,
                child: GestureDetector(
                  child: Padding(
                    padding: leadingPadding ?? defaultLeadingPadding,
                    child: const Icon(
                      Icons.arrow_back,
                    ),
                  ),
                  onTap: () {
                    callBack ??
                        AiloitteNavigation.back(context,);
                  },
                ),
              ),
          Padding(
            padding: titlePadding ?? defaultTitlePadding,
            child: AiloitteTextWidget(
              title,
              style: titleStyle,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
