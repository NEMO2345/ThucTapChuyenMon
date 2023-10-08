import 'package:firebase_auth/firebase_auth.dart';
import 'package:rider_app/Models/allUsers.dart';

String mapKey = "AIzaSyC_1sHOAGI52bSK0bMYvSGT6lwE48D41Tg";

User? firebaseUser;
Users? userCurrentInfo;

int driverRequestTimeOut = 20;

String serverToken = "key=AAAAsWnR3fc:APA91bEQ4iHrFGOH5hlJWOtJ-P9F6ACmR8N8UWHxpUUZCLz-SJn1TKHVSkRO3aX0blK_Ik2LknfT5dxp_tmIRU5izDu-MpCglLfUqxiDYw0IlpykGZvA5FfPwrWXxNbBqk3yA4m6WOd9";
//String serverToken = "key=dC0gfTjTS7q8Gjllg7fHoT:APA91bGXg9XEc9FCe8rXula44Lv8rJ1nY_YktBMH1fZh1ZffrPjGvIsid4BsJV5c62IY5eMUAK8CUxC1ZSLtOmGLToPnyOMmWXyy24XiAA91PzW6bP6fzNyiK-ivZ5JNTyqwAboiVfKz";
