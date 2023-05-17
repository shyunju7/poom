import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:poom/services/nft_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class MetamaskUtil {
  static const apiUrl =
      "https://sepolia.infura.io/v3/0be8b78f1cad416a80f5d523b264e437";

  static final WalletConnect _connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'POOM',
      description: 'An app for converting pictures to NFT',
      url: 'https://walletconnect.org',
      icons: [
        'https://velog.velcdn.com/images/taebong1012/profile/64d88125-3ac8-461d-8537-40dad38b0097/image.png'
      ],
    ),
  );
  static late final SessionStatus _session;
  static late final String _senderAddress, _uri;

  static WalletConnect getConnector() {
    return _connector;
  }

  // 메타마스크 연결 여부 확인
  static Future<bool> isConnected() async {
    if (!_connector.connected) {
      Logger logger = Logger();
      try {
        _session = await _connector.createSession(
          onDisplayUri: (uri) async {
            _uri = uri;
            bool isLaunched = await launchUrlString(uri,
                mode: LaunchMode.externalApplication);

            // metamask 설치여부에 따른 가이드 제공
            if (!isLaunched) {
              logger.d("[MetamaskUtil] Metamask 설치 필요");
              return;
            }
          },
        );

        // 지갑주소 및 체인아이디 설정
        _senderAddress = _session.accounts.first;
        return true;
      } catch (e) {
        // 연결 거절 상태 처리 예정
        logger.e("[MetamaskUtil] 지갑 연결 거절 및 오류 상태 $e");
        return false;
      }
    }
    return true;
  }

  // 후원 발생 및 후원 메서드
  static void handleGenerateSupport() async {
    final EthereumAddress contractAddr =
        EthereumAddress.fromHex("0x8e1887B19307c2a9e6B0430a77257650dFFa7A02");
    DeployedContract? contract;
    Logger logger = Logger();

    // 파일 읽어오기
    await rootBundle.loadString('assets/contract.json').then((value) => {
          contract = DeployedContract(
              ContractAbi.fromJson(value, "poom"), contractAddr)
        });

    ContractFunction? donate = contract?.function("donate");
    final Web3Client client = Web3Client(apiUrl, Client());

    DateTime dateTime = DateTime.now();
    int millisecondsSinceEpoch = dateTime.millisecondsSinceEpoch;

    // test
    var fundraiserId = 5;
    var memberId = "64584cc982f977110415a93c";
    var donationTime = millisecondsSinceEpoch;

    // await client
    //     .call(
    //       contract: contract!,
    //       function: donate!,
    //       params: [
    //         BigInt.from(fundraiserId),
    //         memberId,
    //         BigInt.from(donationTime),
    //       ],
    //     )
    //     .then((value) => print("success $value"))
    //     .catchError((err) => print("error $err"));
  }

  // json파일 읽는 메서드
  Future<String> readAbi() async {
    return await rootBundle.loadString('contract.json');
  }

  // NFT 발급 메서드
  static void handleIssueNft(
      BuildContext context, Map<String, dynamic> data) async {
    Logger logger = Logger();

    if (await isConnected()) {
      try {
        EthereumWalletConnectProvider provider =
            EthereumWalletConnectProvider(_connector);

        final uri = Uri.parse(_uri);
        if (!await launchUrl(uri)) {
          throw Exception('Could not launch $uri');
        }

        var signature = await provider.personalSign(
            message: "ISSUED_NFT", address: _senderAddress, password: "");

        logger.d("[MetamaskUtil] sign success $signature");

        data.addAll({
          "memberAddress": _senderAddress,
          "memberSignature": signature,
          "signMessage": "ISSUE NFT"
        });

        NftApiService().issueNFt(context, data);
      } catch (e) {
        // 연결 거절 상태 처리 예정
        logger.e("[MetamaskUtil] 지갑 서명 오류 상태 $e");
        return;
      }
    }
  }
}
