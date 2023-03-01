import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// class Traslator {
//   final
// }

class CoolStepperConfig {
  /// The text that should be displayed for the back button
  ///
  /// default is 'BACK'
  final String? backText;

  /// The text that should be displayed for the next button
  ///
  /// default is 'NEXT'
  final String? nextText;

  /// The text that describes the progress
  ///
  /// default is 'STEP'
  final String? stepText;

  /// The text that describes the progress
  ///
  /// default is 'OF'
  final String? ofText;

  /// This is the background color of the header
  final Color? headerColor;

  /// This is the color of the icon
  ///
  /// [This does not apply when icon is set]
  final Color? iconColor;

  /// This icon replaces the default icon
  final Icon? icon;

  /// This is the textStyle for the title text
  final TextStyle? titleTextStyle;

  /// This is the textStyle for the subtitle text
  final TextStyle? subtitleTextStyle;

  /// A List of string that when supplied will override 'backText'
  ///
  /// Must be one less than the number of steps since for the first step, the backText won't be visible
  final List<String>? backTextList;

  /// A List of string that when supplied will override 'nextText'
  ///
  /// Must be one less than the number of steps since the 'finalText' attribute is able to set the value for the final step's next button
  final List<String>? nextTextList;

  /// The text that should be displayed for the next button on the final step
  ///
  /// default is 'FINISH'
  final String? finalText;

  /// The color of next button
  ///
  /// If the color is not specified it will assume Green
  final Color? nextColor;

  /// The color of back button
  ///
  /// If the color is not specified it will assume Grey
  final Color? backColor;

  /// The color of back button
  ///
  /// If the color is not specified it will assume Black
  final Color? stepColor;

  final bool isHeaderEnabled;

  /// The locale sign of your location for translate the default texts
  ///
  /// If not specified will assume the device language
  final String? localeName;

  const CoolStepperConfig({
    this.backText = 'PRE',
    this.nextText = 'NEXT',
    this.stepText = 'STEP',
    this.ofText = 'OF',
    this.headerColor,
    this.iconColor,
    this.icon,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.backTextList,
    this.nextTextList,
    this.finalText = 'FINISH',
    this.isHeaderEnabled = true,
    this.nextColor = Colors.green,
    this.backColor = Colors.grey,
    this.stepColor = Colors.black,
    this.localeName = 'pt_BR',
  });
}
