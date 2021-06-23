import 'package:country_codes/country_codes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/my_certs/my_certs.dart';
import 'package:greenpass_app/pub_certs/pub_certs.dart';
import 'package:greenpass_app/views/add_my_pass_page.dart';
import 'package:greenpass_app/views/my_passes_page.dart';
import 'package:greenpass_app/views/scan_others_pass.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CountryCodes.init();
  await PubCerts.initAppStart();
  await MyCerts.initAppStart();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('de')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: App()
    )
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'GreenPass',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: GPColors.createMaterialColor(GPColors.blue),
        fontFamily: 'Inter',
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  int _currentPageIdx = 0;
  static const int _pageCount = 2;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pageCount, vsync: this);
    _tabController.addListener(() {
      setState(() { _currentPageIdx = _tabController.index; });
    });

    _tabController.animation!.addListener(() {
      int roundedIdx = _tabController.animation!.value.round();
      if (_currentPageIdx != roundedIdx) {
        setState(() { _currentPageIdx = roundedIdx; });

        if (_currentPageIdx == 0) {
          FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        } else {
          FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _tabPages = [
      MyPassesPage(),
      ScanOthersPassView(context: context),
    ];

    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(Theme.of(context).brightness == Brightness.dark);
    FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'GreenPass',
          style: TextStyle(
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          /*IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Information',
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            onPressed: () async {
              //var encodedCert = Uri.encodeFull("NCFTW2H:7*I06R3W/J:O6:P4QB3+7RKFVJWV66UBCE//UXDT:*ML-4D.NBXR+SRHMNIY6EB8I595+6UY9-+0DPIO6C5%0SBHN-OWKCJ6BLC2M.M/NPKZ4F3WNHEIE6IO26LB8:F4:JVUGVY8*EKCLQ..QCSTS+F\$:0PON:.MND4Z0I9:GU.LBJQ7/2IJPR:PAJFO80NN0TRO1IB:44:N2336-:KC6M*2N*41C42CA5KCD555O/A46F6ST1JJ9D0:.MMLH2/G9A7ZX4DCL*010LGDFI\$MUD82QXSVH6R.CLIL:T4Q3129HXB8WZI8RASDE1LL9:9NQDC/O3X3G+A:2U5VP:IE+EMG40R53CG9J3JE1KB KJA5*\$4GW54%LJBIWKE*HBX+4MNEIAD\$3NR E228Z9SS4E R3HUMH3J%-B6DRO3T7GJBU6O URY858P0TR8MDJ\$6VL8+7B5\$G CIKIPS2CPVDK%K6+N0GUG+TG+RB5JGOU55HXDR.TL-N75Y0NHQTZ3XNQMTF/ZHYBQ\$8IR9MIQHOSV%9K5-7%ZQ/.15I0*-J8AVD0N0/0USH.3");
              var cert = "NCFTW2H%3A7*I06R3W%2FJ%3AO6%3AP4QB3%2B7RKFVJWV66UBCE%2F%2FUXDT%3A*ML-4D.NBXR%2BSRHMNIY6EB8I595%2B6UY9-%2B0DPIO6C5%250SBHN-OWKCJ6BLC2M.M%2FNPKZ4F3WNHEIE6IO26LB8%3AF4%3AJVUGVY8*EKCLQ..QCSTS%2BF%24%3A0PON%3A.MND4Z0I9%3AGU.LBJQ7%2F2IJPR%3APAJFO80NN0TRO1IB%3A44%3AN2336-%3AKC6M*2N*41C42CA5KCD555O%2FA46F6ST1JJ9D0%3A.MMLH2%2FG9A7ZX4DCL*010LGDFI%24MUD82QXSVH6R.CLIL%3AT4Q3129HXB8WZI8RASDE1LL9%3A9NQDC%2FO3X3G%2BA%3A2U5VP%3AIE%2BEMG40R53CG9J3JE1KB%20KJA5*%244GW54%25LJBIWKE*HBX%2B4MNEIAD%243NR%20E228Z9SS4E%20R3HUMH3J%25-B6DRO3T7GJBU6O%20URY858P0TR8MDJ%246VL8%2B7B5%24G%20CIKIPS2CPVDK%25K6%2BN0GUG%2BTG%2BRB5JGOU55HXDR.TL-N75Y0NHQTZ3XNQMTF%2FZHYBQ%248IR9MIQHOSV%259K5-7%25ZQ%2F.15I0*-J8AVD0N0%2F0USH.3";
              await _pkPassDownload(url:"http://localhost:8081/api/user/pass?cert=$cert");
              //_addPassIntoWallet();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hello there!')));
            },
          ),*/

          if (_currentPageIdx == 0) ...[
            IconButton(
              icon: const Icon(FontAwesome5Solid.plus),
              color: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddMyPassPage()
              )).then((data) => FlutterStatusbarcolor.setStatusBarWhiteForeground(false)),
            ),
            PopupMenuButton(
              icon: const Icon(
                FontAwesome5Solid.ellipsis_v,
                color: Colors.black,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Privacy'.tr()),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('Impress'.tr()),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('Open Source Licenses'.tr()),
                  value: 3,
                ),
              ],
              onSelected: (val) {
                // TODO refactor
                if (val == 1)
                  launch('https://greenpassapp.eu/privacy');
                if (val == 2)
                  launch('https://greenpassapp.eu/imprint');
                if (val == 3)
                  launch('https://greenpassapp.eu/legal/opensource');
              },
            ),
          ] else if (_currentPageIdx == 1) ...[
            /*
            TODO add flashlight
            IconButton(
              icon: const Icon(Icons.flashlight_on),
              color: Colors.white,
              onPressed: () {}
            ),
           */
          ],
        ],
      ),
      extendBodyBehindAppBar: true,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIdx,
        onTap: (newIdx) {
          _tabController.animateTo(newIdx);
        },
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(FontAwesome5Solid.file_alt),
            ),
            label: 'My Pass'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(FontAwesome5Solid.qrcode),
            ),
            label: 'Scan Pass'.tr(),
          ),
        ],
      ),
    );
  }
}
