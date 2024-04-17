import 'package:flutter/material.dart';
import 'package:travel_buddy/components/my_button.dart';
import 'package:travel_buddy/components/my_textfield.dart';
import 'package:travel_buddy/components/square_tile.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // how to sign users in
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                const Icon(Icons.airplanemode_active,
                    size: 100, color: Colors.white),
                const SizedBox(height: 50),
                // text instead of welcome back if i wanted to swap out the text
                const Text('Welcome back, you\'ve been missed!',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 25),

                //username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                //forgot password
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                //login button
                MyButton(
                  onTap: signUserIn,
                ),
                const SizedBox(height: 50),

                // or continue with
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 5,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                //good + apple sign in buttons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: 'lib/images/google.png'),
                    SizedBox(width: 10),
                    SquareTile(imagePath: 'lib/images/apple.png'),
                  ],
                ),
                const SizedBox(height: 50),

                //not a memember? register now
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member?',
                        style: TextStyle(color: Colors.black)),
                    SizedBox(width: 5),
                    Text(
                      'Register now',
                      style: TextStyle(
                          color: Color.fromARGB(255, 2, 125, 226),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
