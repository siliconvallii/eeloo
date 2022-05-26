import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/screens/profile_screen.dart';
import 'package:eeloo/services/banner_ad_service.dart';
import 'package:eeloo/widgets/expired_chat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_chats.dart';
import 'package:eeloo/screens/my_profile_screen.dart';
import 'package:eeloo/widgets/start_chat_button.dart';
import 'package:eeloo/widgets/user_has_to_reply_card.dart';
import 'package:eeloo/widgets/user_replied_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;

  bool _isLoading = false;

  bool _hasToRefresh = true;

  final TextEditingController _searchController = TextEditingController();
  final String _searchText =
      'cerca un utente tramite il suo username per vedere il suo profilo';

  List _usersList = [];

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return WillPopScope(
      child: GestureDetector(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              _isSearching
                  ? Container()
                  : IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MyProfileScreen(profile: user['data']),
                          ),
                        );
                      },
                    ),
            ],
            backgroundColor: const Color(0xff2E2E2E),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: _isSearching
                  ? const Icon(Icons.arrow_back)
                  : const Icon(Icons.search),
              onPressed: () => setState(() {
                _searchController.text = '';
                _usersList = [];
                _isSearching = !_isSearching;
                _hasToRefresh = false;
              }),
            ),
            title: _isSearching
                ? TextField(
                    autocorrect: false,
                    controller: _searchController,
                    cursorColor: const Color(0xffBC91F8),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'username...',
                      hintStyle: GoogleFonts.alata(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp("[a-z0-9_]"),
                      ),
                    ],
                    maxLength: 50,
                    maxLines: 1,
                    onChanged: (searchedUsername) async {
                      if (searchedUsername.length > 1) {
                        setState(() {
                          _isLoading = true;
                        });

                        await Future.delayed(const Duration(milliseconds: 500));
                        if (_searchController.text == searchedUsername) {
                          // search users

                          // instatiate reference of Cloud Firestore
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;

                          // find users with username
                          List searchedUsersUids = [];
                          List searchedUsersEssentialData = [];

                          await firestore.collection('usernames').get().then(
                            (QuerySnapshot querySnapshot) async {
                              for (QueryDocumentSnapshot username
                                  in querySnapshot.docs) {
                                if (username.id.contains(searchedUsername)) {
                                  dynamic _user = username.data();
                                  searchedUsersUids.add(_user['uid']);
                                }
                              }
                            },
                          );

                          if (searchedUsersUids.isNotEmpty) {
                            for (var uid in searchedUsersUids) {
                              if (users[uid] == null) {
                                // user isn't stored locally
                                Map eachUserEssentialData =
                                    await fetchUserData(uid);
                                searchedUsersEssentialData
                                    .add(eachUserEssentialData);
                              } else {
                                // user is stored locally
                                searchedUsersEssentialData.add(users[uid]);
                              }
                            }
                          }

                          setState(() {
                            _usersList = searchedUsersEssentialData;
                            _isLoading = false;
                          });
                        }
                      } else {
                        setState(() {
                          _usersList = [];
                          _isLoading = false;
                        });
                      }
                    },
                    onSubmitted: (username) {
                      // dismiss keyboard
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    style: GoogleFonts.alata(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    textInputAction: TextInputAction.search,
                  )
                : Text(
                    'eeloo',
                    style: GoogleFonts.alata(),
                  ),
          ),
          backgroundColor: const Color(0xff121212),
          body: SafeArea(
            child: _isSearching
                ? _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffBC91F8),
                        ),
                      )
                    : _usersList.isNotEmpty
                        ? ListView.builder(
                            itemCount: _usersList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                child: Container(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            errorWidget: (BuildContext context,
                                                    String url,
                                                    dynamic error) =>
                                                const Icon(Icons.error),
                                            imageUrl: _usersList[index]
                                                ['profile_picture'],
                                            placeholder: (BuildContext context,
                                                    String url) =>
                                                const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xffBC91F8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        height: 50,
                                        width: 50,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Text(
                                                _usersList[index]['username'],
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.alata(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ],
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                          ),
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        child: Container(
                                          child:
                                              const Icon(Icons.arrow_forward),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                            color: Color(0xffBC91F8),
                                          ),
                                        ),
                                        height: 50,
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: Color(0xff1E1E1E),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 10,
                                  ),
                                ),
                                onTap: () async {
                                  if (_usersList[index]['uid'] ==
                                      user['data']['uid']) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MyProfileScreen(
                                          profile: user['data'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    Map userData = await fetchUserData(
                                        _usersList[index]['uid']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ProfileScreen(
                                          profile: userData,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                splashColor: Colors.transparent,
                              );
                            },
                          )
                        : _searchController.text == '' ||
                                _searchController.text.length < 2
                            ? Container(
                                child: Text(
                                  _searchText,
                                  style: GoogleFonts.alata(
                                    color: Colors.grey,
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color(0xff1E1E1E),
                                ),
                                margin: EdgeInsets.only(
                                  left: _marginSize,
                                  right: _marginSize,
                                  top: _marginSize,
                                ),
                                padding: const EdgeInsets.all(10),
                              )
                            : Container(
                                child: Text(
                                  '${_searchController.text} non è su eeloo',
                                  style: GoogleFonts.alata(
                                    color: Colors.grey,
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color(0xff1E1E1E),
                                ),
                                margin: EdgeInsets.only(
                                  left: _marginSize,
                                  right: _marginSize,
                                  top: _marginSize,
                                ),
                                padding: const EdgeInsets.all(10),
                              )
                : FutureBuilder(
                    future: fetchChats(_hasToRefresh),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return (snapshot.connectionState ==
                              ConnectionState.waiting)
                          // snapshot is waiting
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xffBC91F8),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  _hasToRefresh = true;
                                });
                              },
                              backgroundColor: const Color(0xff2E2E2E),
                              color: const Color(0xffBC91F8),
                              child: (snapshot.hasError)
                                  // snapshot has error
                                  ? Text(snapshot.error.toString())
                                  // snapshot has data
                                  : ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          bannerAd.load();

                                          return Column(
                                            children: [
                                              Container(
                                                child: AdWidget(
                                                  ad: bannerAd,
                                                ),
                                                height: bannerAd.size.height
                                                    .toDouble(),
                                                margin: EdgeInsets.only(
                                                  top: _marginSize,
                                                ),
                                                width: bannerAd.size.width
                                                    .toDouble(),
                                              ),
                                              DateTime.now()
                                                          .difference(DateTime
                                                              .parse(snapshot
                                                                          .data[
                                                                      index]
                                                                  ['sent_at']))
                                                          .inHours >
                                                      24
                                                  ? ExpiredChatCard(
                                                      chatData:
                                                          snapshot.data[index],
                                                    )
                                                  : snapshot.data[index]
                                                              ['sender_uid'] ==
                                                          user['data']['uid']
                                                      ? UserRepliedCard(
                                                          chatData: snapshot
                                                              .data![index],
                                                        )
                                                      : UserHasToReplyCard(
                                                          chatData: snapshot
                                                              .data![index],
                                                        ),
                                            ],
                                          );
                                        }
                                        if (DateTime.now()
                                                .difference(DateTime.parse(
                                                    snapshot.data[index]
                                                        ['sent_at']))
                                                .inHours >
                                            24) {
                                          // chat is expired
                                          return ExpiredChatCard(
                                            chatData: snapshot.data[index],
                                          );
                                        } else if (snapshot.data[index]
                                                ['sender_uid'] ==
                                            user['data']['uid']) {
                                          // user replied last
                                          return UserRepliedCard(
                                            chatData: snapshot.data![index],
                                          );
                                        } else {
                                          // user has to reply
                                          return UserHasToReplyCard(
                                            chatData: snapshot.data![index],
                                          );
                                        }
                                      },
                                    ),
                            );
                    },
                  ),
          ),
          floatingActionButton: _isSearching ? null : const StartChatButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      ),
      onWillPop: () async => false,
    );
  }
}
