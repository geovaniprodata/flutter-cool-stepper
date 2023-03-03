library cool_stepper;

export 'package:cool_stepper/src/models/cool_step.dart';
export 'package:cool_stepper/src/models/cool_stepper_config.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:cool_stepper/src/models/cool_step.dart';
import 'package:cool_stepper/src/models/cool_stepper_config.dart';
import 'package:cool_stepper/src/widgets/cool_stepper_view.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TabIndex {
  String name;
  int index;

  TabIndex({required this.name, required this.index});
}

/// CoolStepper
class CoolStepper extends StatefulWidget {
  /// The steps of the stepper whose titles, subtitles, content always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CoolStep> steps;

  /// Actions to take when the final stepper is passed
  final VoidCallback onCompleted;

  /// Padding for the content inside the stepper
  final EdgeInsetsGeometry contentPadding;

  /// CoolStepper config
  final CoolStepperConfig config;

  /// This determines if or not a snackbar displays your error message if validation fails
  ///
  /// default is false
  final bool showErrorSnackbar;

  /// This determines if you want a TabBar of Required fields and non-required fields
  ///
  /// default is false
  final bool tabRequired;

  const CoolStepper({
    Key? key,
    required this.steps,
    required this.onCompleted,
    this.tabRequired = false,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.config = const CoolStepperConfig(),
    this.showErrorSnackbar = false,
  }) : super(key: key);

  @override
  _CoolStepperState createState() => _CoolStepperState();
}

class _CoolStepperState extends State<CoolStepper>
    with SingleTickerProviderStateMixin {
  PageController? _controller = PageController();
  late TabController? _tabController;

  int currentStep = 0;
  int indexStack = 0;

  List<TabIndex> tabs = [];

  bool onlyRequired = false;

  List<CoolStep> stepsNoRequired = [];
  List<CoolStep> stepsRequired = [];

  final translator = GoogleTranslator();

  @override
  void initState() {
    _setSteps();
    _setTabs();
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  void _setTabs() async {
    var tabRequired = 'REQUIRED';
    var tabNonRequired = 'NON-REQUIRED';

    var sgCountry = widget.config.localeName!.substring(0, 2);

    if (!widget.config.localeName!.contains('en')) {
      final translationreq =
          await translator.translate(tabRequired, from: 'en', to: sgCountry);
      tabRequired = translationreq.text;

      final translationNreq =
          await translator.translate(tabNonRequired, from: 'en', to: sgCountry);
      tabRequired = translationNreq.text;
    }

    tabs.add(TabIndex(name: tabRequired, index: 0));
    tabs.add(TabIndex(name: tabNonRequired, index: 1));
  }

  void _setSteps() {
    for (var element in widget.steps) {
      if (element.validation != null) {
        stepsRequired.add(element);
      } else {
        stepsNoRequired.add(element);
      }
    }
  }

  Future<void>? switchToPage(int page) {
    _controller!.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    return null;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  Widget _buildItem(BuildContext context, String title, Widget widget) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => widget));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Text(title),
      ),
    );
  }

  // _setIndex(int index) {
  //   if (index > 0 && index < widget.steps.length) {
  //     switchToPage(index);
  //   } else {
  //     throw Exception(
  //         'int Index must be above 0 and below or equal the steps count. Index : $index');
  //   }
  // }

  void onStepNext() {
    final validation = widget.steps[currentStep].validation!();

    /// [validation] is null, no validation rule
    if (validation == null) {
      if (!_isLast(currentStep)) {
        setState(() {
          currentStep++;
        });
        FocusScope.of(context).unfocus();
        switchToPage(currentStep);
      } else {
        widget.onCompleted();
      }
    } else {
      /// [showErrorSnackbar] is true, Show error snackbar rule
      if (widget.showErrorSnackbar) {
        final flush = Flushbar(
          message: validation,
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: EdgeInsets.all(8.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          icon: Icon(
            Icons.info_outline,
            size: 28.0,
            color: Theme.of(context).primaryColor,
          ),
          duration: Duration(seconds: 2),
          leftBarIndicatorColor: Theme.of(context).primaryColor,
        );
        flush.show(context);

        // final snackBar = SnackBar(content: Text(validation));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void onStepBack() {
    if (!_isFirst(currentStep)) {
      setState(() {
        currentStep--;
      });
      switchToPage(currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listPages = <Widget>[
      Expanded(
        child: PageView(
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          children: stepsRequired.map((step) {
            return CoolStepperView(
              step: step,
              contentPadding: widget.contentPadding,
              config: widget.config,
            );
          }).toList(),
        ),
      ),
      Expanded(
        child: PageView(
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          children: stepsNoRequired.map((step) {
            return CoolStepperView(
              step: step,
              contentPadding: widget.contentPadding,
              config: widget.config,
            );
          }).toList(),
        ),
      ),
    ];

    final content = Expanded(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: widget.steps.map((step) {
          return CoolStepperView(
            step: step,
            contentPadding: widget.contentPadding,
            config: widget.config,
          );
        }).toList(),
      ),
    );

    final counter = Container(
      child: Text(
        "${widget.config.stepText ?? 'STEP'} ${currentStep + 1} ${widget.config.ofText ?? 'OF'} ${widget.steps.length}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.config.stepColor ?? Colors.black,
        ),
      ),
    );

    String getNextLabel() {
      String nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = widget.config.finalText ?? 'FINISH';
      } else {
        if (widget.config.nextTextList != null) {
          nextLabel = widget.config.nextTextList![currentStep];
        } else {
          nextLabel = widget.config.nextText ?? 'NEXT';
        }
      }
      return nextLabel;
    }

    String getPrevLabel() {
      String backLabel;
      if (_isFirst(currentStep)) {
        backLabel = '';
      } else {
        if (widget.config.backTextList != null) {
          backLabel = widget.config.backTextList![currentStep - 1];
        } else {
          backLabel = widget.config.backText ?? 'PREV';
        }
      }
      return backLabel;
    }

    final buttons = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: onStepBack,
            child: Text(
              getPrevLabel(),
              style: TextStyle(color: widget.config.backColor ?? Colors.grey),
            ),
          ),
          counter,
          TextButton(
            onPressed: onStepNext,
            child: Text(
              getNextLabel(),
              style: TextStyle(
                color: widget.config.nextColor ?? Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    final allf = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.info,
                headerAnimationLoop: false,
                animType: AnimType.bottomSlide,
                btnOkColor: Theme.of(context).primaryColor,
                body: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.64,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 6,
                        runSpacing: 8,
                        children: List.generate(widget.steps.length, (index) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              currentStep = index;
                              FocusScope.of(context).unfocus();
                              switchToPage(currentStep);
                            },
                            icon: Icon(
                              widget.steps.elementAt(index).validation != null
                                  ? Icons.text_fields_rounded
                                  : Icons.text_fields,
                              color: widget.steps.elementAt(index).validation !=
                                      null
                                  ? Colors.red.shade400
                                  : Colors.black,
                            ),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Campo',
                                  style: TextStyle(
                                      color: widget.steps
                                                  .elementAt(index)
                                                  .validation !=
                                              null
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                                Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                      color: widget.steps
                                                  .elementAt(index)
                                                  .validation !=
                                              null
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                              elevation: MaterialStatePropertyAll(4),
                              backgroundColor: MaterialStatePropertyAll(
                                  widget.steps.elementAt(index).validation !=
                                          null
                                      ? Colors.red.shade900
                                      : Colors.white),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide.none,
                              )),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                btnOkOnPress: () {},
                btnOkText: 'OK',
              ).show();
            },
            style: ButtonStyle(
              elevation: MaterialStatePropertyAll(4),
              backgroundColor: MaterialStatePropertyAll(Colors.white),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              )),
            ),
            child: Text(widget.config.allFieldsText ?? 'ALL FIELDS  '),
          ),
        ],
      ),
    );

    return Container(
      child: Column(
          children: widget.tabRequired
              ? <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: tabs.map((tab) {
                      return _buildItem(
                          context, tab.name, listPages[tab.index]);
                    }).toList(),
                  ),
                  allf,
                  buttons
                ]
              : <Widget>[content, allf, buttons]),
    );
  }
}
