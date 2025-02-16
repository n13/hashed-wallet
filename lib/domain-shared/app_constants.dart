import 'dart:math';

/// Firebase Dynamic Link Parameters
const String domainAppUriPrefix = 'https://hashedwallet.page.link';
const String guardianTargetLink = 'https://app.hashed.io/vouch/?placeholder=&lostAccount=&rescuer=';
const String androidPacakageName = 'io.hashed.wallet';
const String iosBundleId = 'io.hashed.wallet';
const String iosAppStoreId = '1639248612';

int inappLocalHostPort = Random().nextInt(9999) + 10000;

const String hashedNetworkId = 'hashed';

/// Actions
const String transferAction = 'transfer';
