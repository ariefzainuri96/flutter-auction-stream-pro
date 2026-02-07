import 'dart:io';

import 'package:flutter/material.dart';

double get iosBottomOffsetHeight => Platform.isIOS ? 16 : 0;

Widget get iosBottomOffset => SizedBox(height: iosBottomOffsetHeight);
