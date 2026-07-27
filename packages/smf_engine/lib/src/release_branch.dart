import 'package:smf_engine/src/model.dart';

/// Returns the internal release branch used for [platform].
String releaseBranchName(Platform platform) => 'smf/${platform.value}';
