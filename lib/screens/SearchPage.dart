import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuchitoapp/models/user.dart';
import 'package:cuchitoapp/registro/login.dart';
import 'package:cuchitoapp/screens/ProfilePage.dart';
import 'package:cuchitoapp/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

import 'GoogleMapScreen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  controlSearching(String str) {
    Future<QuerySnapshot> allUsers = usersReference
        .where("profileName", isGreaterThanOrEqualTo: str)
        .getDocuments();
    setState(() {
      futureSearchResult = allUsers;
    });
  }

  AppBar searchPageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.white),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: 'Busca aqui...',
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 30.0,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: emptyTheTextFormField),
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 200.0,
            ),
            Text(
              "Buscar usuarios aqui",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 65.0),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResult,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        });

        return ListView(children: searchUsersResult);
      },
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResult == null
          ? displayNoSearchResultScreen()
          : displayUsersFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () =>
                  displayUserProfile(context, userProfileId: eachUser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userProfileId: userProfileId,
          ),
        ));
  }
}
