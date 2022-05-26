import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/data/data.dart';

class LockedChatScreen extends StatelessWidget {
  final Map chatData;
  final Map recipientData;
  const LockedChatScreen({
    required this.chatData,
    required this.recipientData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'chat',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                chatData['is_recipient_random'] != null &&
                        chatData['is_recipient_random'] == true
                    ? Container(
                        child: Text(
                          'hai inviato questo messaggio a un destinatario '
                          'casuale, che è ${recipientData['username']} :)',
                          style: GoogleFonts.alata(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: Color(0xff1E1E1E),
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                        padding: EdgeInsets.all(
                          _marginSize,
                        ),
                      )
                    : Container(),
                chatData['penultimate'] != null
                    ? Column(
                        children: [
                          Container(
                            child: Text(
                              '${recipientData['username']} ha scritto:',
                              style: GoogleFonts.alata(
                                color: Colors.grey,
                              ),
                            ),
                            margin: EdgeInsets.all(
                              _marginSize,
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        child: SizedBox(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              errorWidget:
                                                  (BuildContext context,
                                                          String url,
                                                          dynamic error) =>
                                                      const Icon(Icons.error),
                                              imageUrl: recipientData[
                                                  'profile_picture'],
                                              placeholder:
                                                  (BuildContext context,
                                                          String url) =>
                                                      const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Color(0xffBC91F8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          height: 40,
                                          width: 40,
                                        ),
                                        margin: EdgeInsets.only(
                                          right: _marginSize,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'da: ',
                                                  style: GoogleFonts.alata(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      recipientData['username'],
                                                  style: GoogleFonts.alata(
                                                    color: Colors.grey,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'a: ',
                                                  style: GoogleFonts.alata(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: user['data']
                                                      ['username'],
                                                  style: GoogleFonts.alata(
                                                    color: Colors.grey,
                                                    fontSize: 17,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.all(
                                    _marginSize,
                                  ),
                                ),
                                SizedBox(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                    imageUrl: chatData['penultimate']['image'],
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xffBC91F8),
                                      ),
                                    ),
                                  ),
                                  width: double.infinity,
                                ),
                                Container(
                                  child: Text(
                                    chatData['penultimate']['text'],
                                    style: GoogleFonts.alata(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  margin: EdgeInsets.all(
                                    _marginSize,
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              color: Color(0xff1E1E1E),
                            ),
                            margin: EdgeInsets.all(_marginSize),
                          ),
                          Container(
                            child: Text(
                              'hai risposto:',
                              style: GoogleFonts.alata(
                                color: Colors.grey,
                              ),
                            ),
                            margin: EdgeInsets.all(
                              _marginSize,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              child: SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                    imageUrl: user['data']['profile_picture'],
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xffBC91F8),
                                      ),
                                    ),
                                  ),
                                ),
                                height: 40,
                                width: 40,
                              ),
                              margin: EdgeInsets.only(
                                right: _marginSize,
                              ),
                            ),
                            Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'da: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text: user['data']['username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'a: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text: recipientData['username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                      ),
                      SizedBox(
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          errorWidget: (BuildContext context, String url,
                                  dynamic error) =>
                              const Icon(Icons.error),
                          imageUrl: chatData['image'],
                          placeholder: (BuildContext context, String url) =>
                              const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffBC91F8),
                            ),
                          ),
                        ),
                        width: double.infinity,
                      ),
                      Container(
                        child: Text(
                          chatData['text'],
                          style: GoogleFonts.alata(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.all(_marginSize),
                ),
                Container(
                  child: Text(
                    'in attesa di risposta...',
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                    ),
                  ),
                  margin: EdgeInsets.all(
                    _marginSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      ),
    );
  }
}
