import 'package:cached_network_image/cached_network_image.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/screens/my_profile_screen.dart';
import 'package:eeloo/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class SearchedUserCard extends StatelessWidget {
  const SearchedUserCard({required this.userEssentialData, Key? key})
      : super(key: key);
  final Map<String, dynamic> userEssentialData;

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return InkWell(
      child: Container(
        child: Row(
          children: [
            // Profile picture SizedBox
            SizedBox(
              child: ClipRRect(
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  errorWidget:
                      (BuildContext context, String url, dynamic error) =>
                          const Icon(Icons.error),
                  imageUrl: userEssentialData['profile_picture'],
                  placeholder: (BuildContext context, String url) =>
                      const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              height: _marginSize * 4,
              width: _marginSize * 4,
            ),
            // Username Expanded
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Text(
                      userEssentialData['username'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                margin: EdgeInsets.only(left: _marginSize),
              ),
            ),
            SizedBox(
              child: const Icon(Icons.arrow_forward),
              height: _marginSize * 4,
              width: _marginSize * 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(_marginSize),
        margin: EdgeInsets.only(
          left: _marginSize,
          right: _marginSize,
          top: _marginSize,
        ),
      ),
      onTap: () async {
        // Check if user is tapping on its own profile
        if (userEssentialData['uid'] == user['data']['uid']) {
          // User is tapping on its own profile
          // Navigate to MyProfileScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => MyProfileScreen(
                profile: user['data'],
              ),
            ),
          );
        } else {
          // Fetch user's data
          Map userData = await fetchUserData(userEssentialData['uid']);

          // Navigate to ProfileScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ProfileScreen(
                profile: userData,
              ),
            ),
          );
        }
      },
    );
  }
}
