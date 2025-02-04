import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/connectivity/apple_wallet.dart';
import 'package:greenpass_app/connectivity/share_certificate.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/vaccine_type.dart';
import 'package:greenpass_app/local_storage/my_certs/my_cert_share.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs.dart';
import 'package:greenpass_app/views/share_info_page.dart';
import 'package:greenpass_app/views/share_page.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PassDetails extends StatefulWidget {
  final GreenCertificate cert;

  const PassDetails({Key? key, required this.cert}) : super(key: key);

  @override
  _PassDetailsState createState() => _PassDetailsState(cert: cert);
}

class _PassDetailsState extends State<PassDetails> {
  final GreenCertificate cert;

  _PassDetailsState({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Certificate details'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            FontAwesome5Solid.arrow_left,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesome5Solid.trash_alt,
              color: Colors.black,
            ),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PassInfo.getSmallPassCard(cert),
            if (Platform.isIOS) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 40.0,
                            width: 40.0,
                            image: AssetImage('assets/images/AppleWallet.png'),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                          Text('Add to Apple Wallet'.tr()),
                        ],
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        overlayColor: MaterialStateProperty.all(GPColors.dark_grey),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
                      ),
                      onPressed: () {
                        PlatformAlertDialog.showAlertDialog(
                          context: context,
                          title: 'Notice'.tr(),
                          text: 'The certificate is sent to us for technical reasons in order to generate an Apple Wallet pass. This certificate is not stored longer than necessary for generation, which normally takes a few seconds.'.tr(),
                          dismissButtonText: 'Cancel'.tr(),
                          actionButtonText: 'Create pass'.tr(),
                          action: () => AppleWallet.getAppleWalletPass(rawCert: cert.rawData, serialNumber: cert.personInfo.pseudoIdentifier),
                        );
                      }
                    ),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 7.0)),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesome5Solid.share),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                        if (MyCerts.getShareInfo(cert.rawData) == null) ...[
                          Text('Share certificate'.tr()),
                        ] else ...[
                          Text('Shared certificate'.tr()),
                        ],
                      ],
                    ),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      overlayColor: MaterialStateProperty.all(GPColors.dark_grey),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        if (MyCerts.getShareInfo(cert.rawData) == null)
                          return SharePage(cert: cert);
                        return ShareInfoPage(cert: cert);
                      }
                    )).then((_) => setState(() {})),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 14.0)),
            ListElements.listPadding(ListElements.groupText('Person info'.tr())),
            ListElements.horizontalLine(),
            ListElements.entryText('Full name'.tr(), cert.personInfo.fullName),
            ListElements.horizontalLine(),
            ListElements.entryText('Date of birth'.tr(), DateFormat('dd.MM.yyyy').format(cert.personInfo.dateOfBirth)),
            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),

            if (cert.certificateType == CertificateType.test) ...[
              ListElements.listPadding(ListElements.groupText('Test'.tr())),
              ListElements.horizontalLine(),
              ListElements.entryText('Test type'.tr(), PassInfo.testType((cert.entryList[0] as CertEntryTest).testType)),
              ListElements.horizontalLine(),
              ListElements.entryText('Test result'.tr(), _testResult((cert.entryList[0] as CertEntryTest).testResult)),
              ListElements.horizontalLine(),
              ListElements.entryText('Testing centre'.tr(), (cert.entryList[0] as CertEntryTest).testingCentreName),
              ListElements.horizontalLine(),
              ListElements.entryText('Time of sample collection'.tr(), DateFormat('HH:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeSampleCollection)),
              if ((cert.entryList[0] as CertEntryTest).timeTestResult != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText('Time of test result'.tr(), DateFormat('HH:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeTestResult!)),
              ],
              if ((cert.entryList[0] as CertEntryTest).testName != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText('Test name'.tr(), (cert.entryList[0] as CertEntryTest).testName!),
              ],
              if ((cert.entryList[0] as CertEntryTest).manufacturerName != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText('Test manufacturer'.tr(), (cert.entryList[0] as CertEntryTest).manufacturerName!),
              ],
            ],

            if (cert.certificateType == CertificateType.recovery) ...[
              ListElements.listPadding(ListElements.groupText('Recovery'.tr())),
              ListElements.horizontalLine(),
              ListElements.entryText('First positive test result'.tr(), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).firstPositiveTestResult)),
              ListElements.horizontalLine(),
              ListElements.entryText('Certificate valid from'.tr(), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validFrom)),
              ListElements.horizontalLine(),
              ListElements.entryText('Certificate valid until'.tr(), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validUntil)),
            ],

            if (cert.certificateType == CertificateType.vaccination) ...[
              for (CertEntryVaccination vac in cert.entryList.map((e) => e as CertEntryVaccination)) ...[
                ListElements.listPadding(ListElements.groupText('Vaccination ({}/{})'.tr(args: [vac.doseNumber.toString(), vac.dosesNeeded.toString()]))),
                ListElements.horizontalLine(),
                ListElements.entryText('Vaccine type'.tr(), _vaccineType(vac.vaccine)),
                ListElements.horizontalLine(),
                ListElements.entryText('Vaccine'.tr(), vac.medicalProduct),
                ListElements.horizontalLine(),
                ListElements.entryText('Manufacturer'.tr(), vac.manufacturer),
              ],
            ],

            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            ListElements.listPadding(ListElements.groupText('Certificate info'.tr())),
            ListElements.horizontalLine(),
            ListElements.entryText('Issuer'.tr(), cert.entryList[0].certificateIssuer),
            ListElements.horizontalLine(),
            ListElements.entryText('Issuing country'.tr(), cert.entryList[0].country.localizedName!),
            ListElements.horizontalLine(),
            ListElements.entryText('Certificate identifier'.tr(), cert.entryList[0].certificateIdentifier),
            Padding(padding: const EdgeInsets.symmetric(vertical: 15.0)),
            AspectRatio(
              aspectRatio: 1,
              child: FittedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(const Radius.circular(4.0))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: PrettyQr(
                            data: cert.rawData,
                            errorCorrectLevel: QrErrorCorrectLevel.L,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(FontAwesome5Solid.trash_alt, size: 18.0),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(GPColors.red),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0))
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Delete certificate'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      onPressed: () => _delete(context),
                    ),
                  ],
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Delete pass?'.tr(),
      text: 'Are you sure you want to delete this pass? The restoration of the pass will not be possible.'.tr(),
      dismissButtonText: 'Cancel'.tr(),
      actionButtonText: 'Delete'.tr(),
      action: () async {
        MyCertShare? share = MyCerts.getShareInfo(cert.rawData);
        if (share != null) {
          if (!await ShareCertificate.delete(share.token)) {
            PlatformAlertDialog.showAlertDialog(
              context: context,
              title: 'Error'.tr(),
              text: 'An error occurred while deleting the share link associated to this pass. You need an internet connection in order to delete your share link first.'.tr(),
              dismissButtonText: 'Ok'.tr()
            );
            return;
          }
        }
        await MyCerts.removeCert(cert.rawData);
        Navigator.of(context).pop();
      },
    );
  }

  String _vaccineType(VaccineType vaccineType) {
    if (vaccineType == VaccineType.antigen) return 'Antigen'.tr();
    if (vaccineType == VaccineType.mRna) return 'mRNA'.tr();
    return 'Other'.tr();
  }

  String _testResult(TestResult testResult) {
    if (testResult == TestResult.negative) return 'Negative'.tr();
    if (testResult == TestResult.positive) return 'Positive'.tr();
    return 'Unknown'.tr();
  }
}