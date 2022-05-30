import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/screens/new_chat_screen.dart';
import 'package:eeloo/widgets/expired_chat_card.dart';
import 'package:eeloo/widgets/searched_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_chats.dart';
import 'package:eeloo/screens/my_profile_screen.dart';
import 'package:eeloo/widgets/user_has_to_reply_card.dart';
import 'package:eeloo/widgets/user_replied_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _searchUser(String searchedUsername) async {
    // Check if searchedUsername is at least 2 characters long
    if (searchedUsername.length < 2) {
      // searchedUsername is less of 2 characters long
      // Don't fetch users
      setState(() {
        _usersList = [];
        _isLoading = false;
      });

      // Shut down function
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    // Set a delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_searchController.text == searchedUsername) {
      // Instanciate reference of Cloud Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Find users with username
      List searchedUsersUids = [];
      List searchedUsersEssentialData = [];

      await firestore.collection('usernames').limit(10).get().then(
        (QuerySnapshot querySnapshot) async {
          for (QueryDocumentSnapshot username in querySnapshot.docs) {
            if (username.id.contains(searchedUsername)) {
              dynamic _user = username.data();
              searchedUsersUids.add(_user['uid']);
            }
          }
        },
      );

      // Check if result isn't empty
      if (searchedUsersUids.isNotEmpty) {
        for (String uid in searchedUsersUids) {
          // Check if user's data is stored locally
          if (users[uid] == null) {
            // User's data isn't stored locally
            // Fetch user's data
            Map eachUserEssentialData = await fetchUserData(uid);

            // Return user's data
            searchedUsersEssentialData.add(eachUserEssentialData);
          } else {
            // User's data is stored locally
            // Return user's data
            searchedUsersEssentialData.add(users[uid]);
          }
        }
      }

      // Return users List and delete loading indicator
      setState(() {
        _usersList = searchedUsersEssentialData;
        _isLoading = false;
      });
    }
  }

  bool _isSearchingUser = false;
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
            actions: [
              // Check if user search is active
              _isSearchingUser
                  // User search is active
                  // Don't show MyProfileScreen's IconButton
                  ? Container()
                  // User search is not active
                  // Show MyProfileScreen's IconButton
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
            // User search's IconButton
            leading: IconButton(
              // Check if user search is active
              icon: _isSearchingUser
                  // User search is active
                  // Show arrow back Icon
                  ? const Icon(Icons.arrow_back)
                  // User search is not active
                  // Show search Icon
                  : const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  // Initialize search TextEditingController
                  _searchController.text = '';
                  // Initialize users List
                  _usersList = [];
                  // Invert _isSearchingUser
                  _isSearchingUser = !_isSearchingUser;
                  // Set _hasToRefresh to false
                  _hasToRefresh = false;
                });
              },
            ),
            // AppBar title
            // Check if user search is active
            title: _isSearchingUser
                // User search is active
                // Search TextField
                ? TextField(
                    autocorrect: false,
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'username',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp("[a-z0-9_]"),
                      ),
                    ],
                    maxLength: 30,
                    maxLines: 1,
                    onChanged: (username) => _searchUser(username),
                    onSubmitted: (username) {
                      // Dismiss keyboard
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    textInputAction: TextInputAction.search,
                  )
                // User search is not active
                // Title Text
                : const Text('eeloo'),
          ),
          body: SafeArea(
            // Check if user search is active
            child: _isSearchingUser
                // Check if Future is loading
                ? _isLoading
                    // Future is loading
                    // Show CircularProgressIndicator
                    ? const Center(child: CircularProgressIndicator())
                    // Future has completed loading
                    // Check if user List is empty
                    : _usersList.isNotEmpty
                        // User List is not empty
                        // User List ListViewBuilder
                        ? ListView.builder(
                            itemCount: _usersList.length,
                            itemBuilder: (BuildContext context, int index) {
                              // Return SearchedUserCard for each user found
                              return SearchedUserCard(
                                userEssentialData: _usersList[index],
                              );
                            },
                          )
                        // Check if username contains at least 2 characters
                        : _searchController.text == '' ||
                                _searchController.text.length < 2
                            // Searched username is less than 2 characters
                            // Show _searchText Text
                            ? Container(
                                child: Text(_searchText),
                                margin: EdgeInsets.only(
                                  left: _marginSize,
                                  right: _marginSize,
                                  top: _marginSize,
                                ),
                                padding: const EdgeInsets.all(10),
                              )
                            // No user was found
                            : Container(
                                child: Text(
                                  '${_searchController.text} non è su eeloo',
                                ),
                                margin: EdgeInsets.only(
                                  left: _marginSize,
                                  right: _marginSize,
                                  top: _marginSize,
                                ),
                                padding: EdgeInsets.all(_marginSize),
                              )
                // User search is not active
                // Fetch user's chats
                : FutureBuilder(
                    future: fetchChats(_hasToRefresh),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // Check if Future has completed
                      if (snapshot.connectionState == ConnectionState.done) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _hasToRefresh = true;
                            });
                          },
                          // Check if snapshot has error
                          child: (snapshot.hasError)
                              // Snapshot has error
                              // Snapshot's error Text
                              ? Text(snapshot.error.toString())
                              // Snapshot has data
                              // Chats ListViewBuilder
                              : ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // Check if chat is active or expired
                                    if (snapshot.data[index]
                                        ['is_chat_expired']) {
                                      // Chat is expired
                                      return ExpiredChatCard(
                                        chatData: snapshot.data[index],
                                      );
                                    } else {
                                      // Chat is active
                                      if (snapshot.data[index]['sender_uid'] ==
                                          user['data']['uid']) {
                                        // User is sender
                                        return UserRepliedCard(
                                          chatData: snapshot.data![index],
                                        );
                                      } else {
                                        // User is recipient
                                        return UserHasToReplyCard(
                                          chatData: snapshot.data![index],
                                        );
                                      }
                                    }
                                  },
                                ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
          ),
          floatingActionButton: _isSearchingUser
              // User search is active
              ? null
              // User search is not active
              : ElevatedButton(
                  child: const Text('inizia una nuova chat'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const NewChatScreen(recipientUsername: ''),
                    ),
                  ),
                ),
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
